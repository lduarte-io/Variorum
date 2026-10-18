import Foundation

// VX-378 U4 resumption — RULE 21, THE NOTICE (her ruling at the U4 stop,
// 2026-10-17, superseding U2's detect-and-refuse: "we also do not need to
// protect them from hand copying an old library over - they have to just
// remember that at that point"; "I think we can have a popup that it's probably
// an issue without banning it from working"). When the library in the live
// place is not the one this Mac last opened, the app OPENS it, says so ONCE —
// her two strings, verbatim — and then remembers this one (the memory follows
// the file: one write, no repair); posture is the ordinary follow. One pure
// function, read by the executor's unlock (which reports it and writes
// nothing) and carried into `assess` (which reports it as a fault until the
// memory has followed, and closes no door).
//   - It keys on a DISAGREEMENT, never on absence: no memory item at all is
//     rule 8's keychain reset (or a new Mac), and the open says nothing (the
//     orchestrator's adjudication 5 after U1).
//   - A DIFFERENT LIBRARY: the memory items name other library IDs and none
//     names this one.
//   - AN OLDER COPY: this Mac remembers this library under another key than the
//     library file's — a replayed old file, a backup pair copied in by hand —
//     unless this Mac's own act in flight explains it (the act moves between
//     exactly those two keys), or the library has MOVED ON past what this Mac
//     remembers (its own key file's history carries the remembered key — a
//     memory item from an earlier moment): PROVISIONAL P-VX378-U4-5, no notice,
//     the memory follows.
//   - The KEY FILE beside the library is not this check's: a key file that
//     doesn't open the library is the key-file OFFER's (`KeyFileOffer`).
// What this Mac remembers is read as the item names it (its payload) — the
// notice changes nothing but the memory write that follows, so an item whose
// seal the keys in reach can't verify (one sealed under a newer key) still
// says what it remembers.

/// What an open says when the library in the live place is not the one this
/// Mac last opened (rule 21) — said once, never refused, never repaired.
public struct LibraryNotice: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        /// An older copy of the library this Mac remembers — `date`: the date
        /// its record carries (the day its key began; the face may read the
        /// file's own date — PROVISIONAL P-VX378-U4-5).
        case olderCopy(date: Date)
        /// Another library than the one this Mac last had open.
        case differentLibrary
    }

    /// Her strings, verbatim (the U4 stop sitting, 2026-10-17).
    public static let olderCopyWords = "This is an older copy of your library, from <date>"
    public static let differentLibraryWords = "This is a different library than the one this Mac last had open"

    public var kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    /// The sentence's template — her words, `<date>` where the date goes.
    public var words: String {
        switch kind {
        case .olderCopy: return Self.olderCopyWords
        case .differentLibrary: return Self.differentLibraryWords
        }
    }

    /// The sentence with the date written in (the face picks the date's form).
    public func sentence(date format: (Date) -> String) -> String {
        guard case .olderCopy(let date) = kind else { return words }
        return words.replacingOccurrences(of: "<date>", with: format(date))
    }

    /// **The check.** `rememberedFingerprint`: the key this Mac's memory item
    /// for the library in the live place names (nil — no item, or one naming
    /// another library — is no notice of an older copy); `rememberedLibraryIDs`:
    /// every library this scope's memory items name; `liveKeyFile`: the key
    /// file beside the library; `actInFlight`: this Mac's own act, which may
    /// explain two keys; `recordDate`: the library's record date.
    public static func check(
        libraryID: String, libraryFingerprint: String, recordDate: Date, rememberedFingerprint: String?,
        rememberedLibraryIDs: Set<String>, liveKeyFile: KeyFile?, actInFlight: ActInFlight?
    ) -> LibraryNotice? {
        guard let remembered = rememberedFingerprint else {
            let others = rememberedLibraryIDs.subtracting([libraryID])
            if !others.isEmpty, !rememberedLibraryIDs.contains(libraryID) { return LibraryNotice(kind: .differentLibrary) }
            return nil
        }
        if libraryFingerprint == remembered { return nil }
        let actKeys = Set([actInFlight?.fromFingerprint, actInFlight?.toFingerprint].compactMap { $0 })
        if actKeys.contains(libraryFingerprint), actKeys.contains(remembered) { return nil }
        // The library moved on past what this Mac remembers (PROVISIONAL
        // P-VX378-U4-5): its own key file carries the remembered key.
        if let live = liveKeyFile, live.fingerprint == libraryFingerprint,
           live.history.contains(where: { $0.fingerprint == remembered }) {
            return nil
        }
        return LibraryNotice(kind: .olderCopy(date: recordDate))
    }

    /// The key a memory item names, read as the item states it (unverified —
    /// see the header): nil when it names another library or doesn't decode.
    public static func rememberedFingerprint(_ sealed: Sealed<DeviceMemory>?, libraryID: String) -> String? {
        guard let sealed, let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload),
              memory.libraryID == libraryID else { return nil }
        return memory.currentFingerprint
    }
}
