import CryptoKit
import Foundation

// VX-378 U4 resumption — RULE 21's KEY-FILE OFFER (her ruling at the U4 stop,
// 2026-10-17): "The one case that needs a hand — the key file beside the
// library does not open it — is an OFFER, naming where the working key file
// was found … the app asks for a secret once, opens the candidate key files in
// the places it writes them (this Mac's keychain copy; each backup's key file
// in the folders of rule 19), tries each key against the library, and offers
// the one that works — "The key file beside your library doesn't open it. This
// Mac's keychain holds a copy that does. Use it?" / "…The backup from August 3
// holds a key file that does. Use it?"; none → rule 27's refusal naming the
// places it looked. Nothing guessed; nothing written before her yes."
//   - THE SEARCH reads only. With the library open (the lobby reached its key by
//     some road), each candidate yields the keys it can — the key in hand when
//     the candidate names it, the secret she typed, the candidate's own quiet
//     road (a custody item for its key, its Apple wrap readable here) — and
//     each is TRIED against the library file. The first that opens it is
//     offered, its source named. The key file beside counts as the library's
//     own only when its CURRENT key opens it: a file that reaches the library
//     only through its history leaves the pair split, and the offer of the
//     library's own file stands (PROVISIONAL P-VX378-U4-6) — with none found,
//     that split pair is said, never refused (the library opened); with
//     nothing reaching it at all, rule 27.
//   - ACCEPTING is one act on a plan (rule 20): the offered file written beside
//     the library, then what this Mac remembers (its sealed copy follows).

/// Where a key file that opens the library was found (rule 1's homes).
public enum KeyFileSource: Equatable, Sendable {
    /// This Mac's keychain copy — the sealed copy in what this Mac remembers.
    case thisMacsKeychain
    /// A backup's key file (rule 19's folders) — `date`: the backup's day.
    case backup(keyFileID: String, date: Date?)
}

/// RULE 21's offer: a key file that opens the library, and where it was found.
/// Nothing is written until she accepts (`useOfferedKeyFile`).
public struct KeyFileOffer: Equatable, Sendable {
    /// Her strings, verbatim (the U4 stop sitting, 2026-10-17).
    public static let besideDoesNotOpenIt = "The key file beside your library doesn't open it."
    public static let keychainHoldsOne = "This Mac's keychain holds a copy that does. Use it?"
    public static let backupHoldsOne = "The backup from <date> holds a key file that does. Use it?"

    public let source: KeyFileSource
    public let keyFile: KeyFile

    /// The offer's words — her sentences, `<date>` where the backup's day goes.
    public var words: String {
        switch source {
        case .thisMacsKeychain: return "\(Self.besideDoesNotOpenIt) \(Self.keychainHoldsOne)"
        case .backup: return "\(Self.besideDoesNotOpenIt) \(Self.backupHoldsOne)"
        }
    }

    /// The words with the backup's day written in (the face picks its form).
    public func sentence(date format: (Date) -> String) -> String {
        guard case .backup(_, let date?) = source else { return words }
        return words.replacingOccurrences(of: "<date>", with: format(date))
    }
}

/// What the search found.
public enum KeyFileSearch: Equatable, Sendable {
    /// The key file beside the library is its own — nothing to offer.
    case besideOpensIt
    /// One of the places the app keeps key files holds the library's own.
    case offer(KeyFileOffer)
    /// No copy of the library's own key file anywhere — and the key file beside
    /// it reaches it only through its history (the pair split from outside):
    /// said, never refused; the acts that need the library's own key file
    /// refuse at their door (PROVISIONAL P-VX378-U4-6).
    case besideOpensItOnlyThroughItsHistory
    /// RULE 27: no key file anywhere opens it — the places looked, named.
    case noKeyFileAnywhere(NoKeyFileAnywhere)
}

struct UseKeyFileProgram: ActProgram {
    let act = ProtectionAct.useKeyFile
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["keyFile", "memory"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "keyFile": try ctx.writeOfferedKeyFile()
        case "memory": try ctx.executor.writeMemory(&ctx.library)
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The offered key file beside the library — only the library's own (its
    /// current key the one the library opened under); idempotent.
    func writeOfferedKeyFile() throws {
        if let live = library.keyFile, live.fingerprint == library.fingerprint { return }
        guard let offered = parameters.offeredKeyFile, offered.fingerprint == library.fingerprint,
              offered.libraryID == library.record?.libraryID else { return }
        try executor.writeLiveKeyFile(offered, &library)
        log("the offered key file written beside the library (\(Self.fp8(offered.fingerprint)))")
    }
}

extension ProtectionExecutor {
    /// **The search** (rule 21's offer — reads only). `typed`: the secret she
    /// typed at the open (or nothing). Candidates in order: this Mac's keychain
    /// copy, then every catalogued key file outside the live place, newest
    /// first.
    public func searchKeyFiles(_ library: UnlockedLibrary, catalog: Catalog, typed: TypedSecrets = .none) throws -> KeyFileSearch {
        let current = library.fingerprint
        let live = library.keyFile
        if let live, live.fingerprint == current { return .besideOpensIt }
        var candidates: [(KeyFileSource, KeyFile)] = []
        let remembered = (try? leaves.memory.readMemory(libraryID: library.record?.libraryID ?? libraryID))
            .flatMap { $0 }.flatMap { try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: $0.payload) }
        if let mirror = library.memory?.keyFileMirror ?? remembered?.keyFileMirror { candidates.append((.thisMacsKeychain, mirror)) }
        let others = catalog.keyFiles.filter { $0.role != .live }
            .sorted { ($0.frozenAt ?? .distantPast, $0.id) > ($1.frozenAt ?? .distantPast, $1.id) }
        for file in others {
            if let document = file.document { candidates.append((.backup(keyFileID: file.id, date: file.frozenAt), document)) }
        }
        var secrets: [ProtectionSecret] = []
        if let passphrase = typed.passphrase { secrets.append(.passphrase(passphrase)) }
        if let words = typed.words { secrets.append(.words(words)) }
        let items = try leaves.custody.custodyItems()
        for (source, file) in candidates {
            var keys: [StoreKey] = []
            if file.fingerprint == current { keys.append(library.key) }
            for secret in secrets { if let key = try? file.open(secret, floor: configuration.floor) { keys.append(key) } }
            if items.contains(CustodyItemFact(fingerprint: file.fingerprint, itemClass: .silent)),
               let key = try leaves.custody.readCustody(fingerprint: file.fingerprint, itemClass: .silent) {
                keys.append(key)
            }
            if let wrap = file.apple, let apple = try leaves.apple.readAppleKey(id: wrap.keyID),
               let key = try? file.open(apple: apple) {
                keys.append(key)
            }
            // Each key tried against the library file (a read): the file is the
            // library's own when its current key opens it.
            for key in keys where Self.fp(key) == file.fingerprint {
                if try leaves.library.libraryOpens(with: key) {
                    return .offer(KeyFileOffer(source: source, keyFile: file))
                }
            }
        }
        if let live, live.heldFingerprints.contains(current) { return .besideOpensItOnlyThroughItsHistory }
        return .noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: library.record?.account != nil))
    }

    /// **The offer, accepted** — one act on a plan (rule 20): the offered key
    /// file written beside the library, then what this Mac remembers.
    public func useOfferedKeyFile(_ library: inout UnlockedLibrary, _ offer: KeyFileOffer) async throws -> ActOutcome {
        guard offer.keyFile.fingerprint == library.fingerprint, offer.keyFile.libraryID == library.record?.libraryID else {
            throw ExecutorRefusal.keyDoesNotOpenLibrary
        }
        var parameters = ActParameters()
        parameters.offeredKeyFile = offer.keyFile
        return try await perform(UseKeyFileProgram(), parameters: parameters, secrets: ActSecrets(), library: &library)
    }
}
