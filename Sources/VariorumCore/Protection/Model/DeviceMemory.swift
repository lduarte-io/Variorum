import Foundation

// VX-305 U1 — WHAT THIS MAC REMEMBERS (design §3.2, §3.6): one non-secret
// Keychain item per library ID (device-only; service `io.lduarte.Variorum.
// memory`, account `<scope>-<libraryID>`), SEALED WHOLE (purpose `memory`)
// under the library key, so an edit is caught and a replayed item loses to a
// newer record. Before unlock it is a display hint only and decides nothing
// (§3.10).
//
// RULE 21 (`notes/CastleRules.md`, as ruled at the U4 stop, 2026-10-17): "This
// Mac remembers four things about its library — its ID, its device ID, a
// fingerprint of its current key, and a copy of its key file: the key itself,
// still wrapped under your locks — and only the app's own doors change them."
// EXACTLY those four (VX-378 U2, adjudication 7): the biometry state hash left —
// §3.10's which-line hint is the face's to read from `LAEnvironment` — and the
// vault facts left with the vault's rotation (the record names the sync key the
// library follows). The memory is used for two things: rule 1's redundancy (the
// wrapped copy comes back when the live key file is absent) and NOTICING — a
// memory naming another library, or another key, than the one in the live
// place is rule 21's disagreement, and the open GOES ON, says so once
// (`LibraryNotice`: "This is an older copy of your library, from <date>" /
// "This is a different library than the one this Mac last had open"), then
// remembers this library at the open's repairs. Nothing refuses and nothing
// repairs by guessing (the refusal design left at the U4 resumption's piece 3).
// Two another-key cases say NOTHING, by design (`LibraryNotice.check`): this
// Mac's own act in flight explains the two keys, and the library moved on past
// the memory — its live key file's history carries the remembered key
// (P-VX378-U4-5). An ABSENT memory is no disagreement (rule 8's keychain reset).
// (The mode and account last confirmed, the key epoch, the nudge dismissals,
// the family tree's mirror and the device section's second home left with
// VX-378 U1 — rules 21, 23.)

public struct DeviceMemory: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    public var libraryID: String
    public var currentFingerprint: String
    /// This Mac's plain random device ID for the library (rule 23) — it names
    /// this Mac's section of the record.
    public var deviceID: String
    /// The key file's mirror — its wraps and history (§3.2): THE on-device
    /// copy, written back only into an empty live place (rule 1).
    public var keyFileMirror: KeyFile?

    public init(
        format: Int = DeviceMemory.currentFormat, libraryID: String, currentFingerprint: String, deviceID: String,
        keyFileMirror: KeyFile? = nil
    ) {
        self.format = format
        self.libraryID = libraryID
        self.currentFingerprint = currentFingerprint
        self.deviceID = deviceID
        self.keyFileMirror = keyFileMirror
    }

    /// Sealed whole under the library key in hand.
    public func sealed(under key: StoreKey) throws -> Sealed<DeviceMemory> {
        try Sealed.sealing(self, purpose: .memory, libraryID: libraryID, key: key)
    }

    /// Open a memory item for `libraryID`: verified, else nil (a memory item
    /// that fails its seal remembers nothing). A memory item for another
    /// library is not this one's.
    public static func opening(
        _ sealed: Sealed<DeviceMemory>, libraryID: String, reach: (String) -> StoreKey?
    ) -> DeviceMemory? {
        guard let memory = try? sealed.open(purpose: .memory, libraryID: libraryID, reach: reach),
              memory.libraryID == libraryID
        else { return nil }
        return memory
    }
}
