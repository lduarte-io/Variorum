import CryptoKit
import Foundation

// VX-305 U3 — COPIES (design §3.7). One file for the copy acts (a recorded
// refinement of §2's one-file-per-act).
//   - A COPY IS A COPY (rule 17, `notes/CastleRules.md`): opening a copy into
//     this library's own line and landing a pair under its own library
//     identity are gone (VX-378 U1); Look inside and Make this my library are
//     U2's (`LandProgram` below is MakeMine's stub).
//   - SEND LIBRARY writes the pair — a copy (rule 18), with no sharing note.
//   - A PLAINTEXT EXPORT carries its library ID.
//   - THE OFFER deletes another library's copies at her press — this Mac's
//     copies of it only, never another Mac's (rule 19; the last copy's own key
//     file and Apple key — the move's gift — left with VX-378 U1).

/// MAKE THIS MY LIBRARY's stub (rule 17). The landing that kept a pair's own
/// library identity, its held synced landing and Resume Sync are gone (VX-378
/// U1); U2 rebuilds this act as MakeMine — the copy takes the live place as a
/// NEW library (a fresh identity and a fresh key in the posture this device is
/// in now, under its current pair). The stub keeps the act's registry slot;
/// nothing begins it.
struct LandProgram: ActProgram {
    let act = ProtectionAct.land
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { [] }
    func run(_ step: String, _ ctx: ActContext) async throws { throw ExecutorRefusal.nothingToDo }
}

struct SendLibraryProgram: ActProgram {
    let act = ProtectionAct.sendLibrary
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["writePair"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        guard let destination = ctx.parameters.destination, let live = ctx.library.keyFile,
              live.fingerprint == ctx.library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        try ctx.leaves.backups.writeSendPair(with: ctx.library.key, keyFile: live, to: destination)
    }
}

struct PlaintextExportProgram: ActProgram {
    let act = ProtectionAct.plaintextExport
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["export"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        guard let destination = ctx.parameters.destination else { throw ExecutorRefusal.nothingToDo }
        try ctx.leaves.library.exportPlaintext(with: ctx.library.key, to: destination)
    }
}

struct OfferDeleteProgram: ActProgram {
    let act = ProtectionAct.offerDelete
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["deleteCopies"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        if let ids = ctx.parameters.copyIDs, !ids.isEmpty { try ctx.leaves.backups.deleteCopies(ids: ids) }
    }
}

extension ProtectionExecutor {
    /// **Send Library**: the pair, written to the folder she picked — no
    /// sharing note (the other Mac lands it under a key of its own).
    public func sendLibrary(_ library: inout UnlockedLibrary, to destination: String) async throws -> ActOutcome {
        try await perform(SendLibraryProgram(), parameters: ActParameters(destination: destination), secrets: ActSecrets(), library: &library)
    }

    /// **A plaintext export** — re-authenticated: in Castle the passphrase
    /// (never Touch ID alone); in Standard the passphrase if set.
    public func plaintextExport(_ library: inout UnlockedLibrary, typed: TypedSecrets, to destination: String) async throws -> ActOutcome {
        if library.record?.mode == .castle || library.keyFile?.passphrase != nil {
            _ = try verifiedPassphrase(typed.passphrase, against: library.keyFile)
        }
        return try await perform(
            PlaintextExportProgram(), parameters: ActParameters(destination: destination), secrets: ActSecrets(), library: &library)
    }

    /// **The offer's delete** — another library's copies, at her press: this
    /// Mac's copies of it only (never another Mac's, never this library's).
    public func offerDelete(_ library: inout UnlockedLibrary, copies: [CatalogCopy], catalog: Catalog) async throws -> ActOutcome {
        let thisLibrary = library.record?.libraryID
        let mine = library.section.mac8
        let deletable = copies.filter { $0.library != nil && $0.library != thisLibrary && $0.mac.isMac(mine) }
        return try await perform(
            OfferDeleteProgram(), parameters: ActParameters(copyIDs: Set(deletable.map(\.id)).sorted()),
            secrets: ActSecrets(), library: &library)
    }
}
