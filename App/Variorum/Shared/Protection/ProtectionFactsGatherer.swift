//
//  ProtectionFactsGatherer.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — WHAT `assess` READS, GATHERED FROM THE LEAVES (`notes/plans/vx-306-castle-open-road.md`
//  §2 U1a; `Assess/Facts.swift` is the contract; the scenario world's `SWorld.facts(_:)` is the shape this
//  mirrors — `Tests/VariorumCoreTests/Protection/Scenario/World.swift`). Before unlock nothing here decides
//  anything: `unlocked` is nil and the facts are roads and hints.
//
//    - `custodyOpensLibrary` — each SILENT item's key tried against the slot (a read, no press). An item
//      the leaf could not READ, or whose key could not be tried, has its fingerprint INCLUDED:
//      could-not-read is never verified-fails (the VX-378 ladder's round-2 NIT — a transient keychain error
//      must never surface rule 27's refusal while a working quiet road exists). An item gone since the
//      listing, or whose key verifiably opens nothing, is left out.
//      VX-329 U4: over a store from before this design (rule 26's fact, from the catalogue's names alone) no item is
//      read and no key is tried against the store — `custodyOpensLibrary` is nil (not read).
//    - A Touch ID item is counted by the listing (attributes only) and NEVER pressed here.
//    - `rememberedKeyFileCopies` — the key-file copies the memory items carry, read from their payloads
//      WITHOUT verifying (a key file holds no secret); a payload that cannot be read makes the whole fact
//      nil (not read — every remembered library then counts as one that might hold a copy).
//    - THE LISTINGS RULE 27 STANDS ON ARE NEVER GUESSED: if the custody items or the memory items cannot be
//      listed, gathering THROWS (`GatherError`) rather than reporting "none" — an empty listing would read
//      as "no road at all" (P-VX306-U1a-3). The sync-keys and Apple listings fall back to empty (neither
//      feeds rule 27; an unread Apple road only means the lobby asks for a secret).
//    - `vault` is nil this phase (P-VX306-K3); `session` and the last Touch ID press are the caller's.
//

import Foundation
import VariorumCore

nonisolated struct ProtectionFactsGatherer {
    enum GatherError: Error, Equatable {
        case custodyUnlistable(String)
        case memoryUnlistable(String)
    }

    let scope: String
    let places: ProtectionPlaces
    let leaves: ExecutorLeaves
    let lister: CatalogLister

    func facts(
        session: SessionFact, unlocked: UnlockedLibrary? = nil, touchIDPress: TouchIDPress? = nil
    ) throws -> ProtectionFacts {
        let catalog = lister.catalog()
        let storeFile = Self.storeFileFact(at: places.slot)
        let custody: [CustodyItemFact]
        do {
            custody = try leaves.custody.custodyItems()
        } catch {
            throw GatherError.custodyUnlistable(String(describing: error))
        }
        // VX-329 U4 — RULE 26: over a store from before this design (the catalogue's names alone say so —
        // `AssessRules.preDesignStore`), no silent item is read and no key is tried against the store: the verdict
        // precedes every road, so the probe has nothing to decide (`custodyOpensLibrary` nil — not read).
        let preDesign = AssessRules.preDesignStore(storeFile: storeFile, catalog: catalog)
        var opens: Set<String> = []
        for item in custody where item.itemClass == .silent && !preDesign {
            do {
                guard let key = try leaves.custody.readCustody(fingerprint: item.fingerprint, itemClass: .silent) else {
                    continue  // gone since the listing
                }
                // A key that could not be tried counts as one that might open it.
                if (try? leaves.library.libraryOpens(with: key)) != false { opens.insert(item.fingerprint) }
            } catch {
                opens.insert(item.fingerprint)  // could not read ≠ opens nothing
            }
        }
        let remembered: Set<String>
        do {
            remembered = try leaves.memory.rememberedLibraryIDs()
        } catch {
            throw GatherError.memoryUnlistable(String(describing: error))
        }
        var copies: Set<String>? = []
        for libraryID in remembered.sorted() {
            do {
                guard let sealed = try leaves.memory.readMemory(libraryID: libraryID) else { continue }
                // As the item states it — unverified (a key file holds no secret).
                if let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload),
                   let mirror = memory.keyFileMirror {
                    copies?.insert(mirror.fingerprint)
                }
            } catch {
                copies = nil
                break
            }
        }
        var unlockedFacts: UnlockedFacts?
        if let unlocked, let record = unlocked.record {
            unlockedFacts = UnlockedFacts(
                record: record, thisMac: unlocked.section, memory: unlocked.memory,
                currentFingerprint: unlocked.fingerprint, liveKeyFileID: catalog.liveKeyFile?.id,
                notice: unlocked.notice)
        }
        return ProtectionFacts(
            scope: scope, storeFile: storeFile,
            containerMarker: FileManager.default.fileExists(atPath: places.livedHereMarker.path),
            unlocked: unlockedFacts, slotFingerprintHint: catalog.liveKeyFile?.fingerprint,
            rememberedLibraryIDs: remembered, rememberedKeyFileCopies: copies, custody: custody,
            custodyOpensLibrary: preDesign ? nil : opens,
            syncKeys: (try? leaves.syncKeys.syncKeyItems()) ?? [],
            appleKeys: AppleKeyFacts(readable: (try? leaves.apple.readableAppleKeyIDs()) ?? []),
            biometry: leaves.biometry.biometry(), touchIDPress: touchIDPress, session: session,
            vault: nil, catalog: catalog, now: leaves.clock.now())
    }

    /// What sits at the slot, as `assess` reads it (`StoreFilePresence` — the file's header shape, never its content).
    static func storeFileFact(at slot: URL) -> StoreFileFact {
        switch StoreFilePresence.classify(at: slot) {
        case .absent: return .absent
        case .plaintext: return .plaintext
        case .encryptedOrUnknown: return .present
        }
    }
}
