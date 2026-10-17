import Foundation

// VX-378 U2 — RULE 21, DETECT AND REFUSE (`notes/CastleRules.md`: "This Mac
// remembers four things about its library — its ID, its current key, its device
// ID and the sealed copy of its key file … If the file in the live place is not
// the one this Mac remembers, the app refuses to open, says what it found, and
// offers the two doors of rule 17. It never repairs by guessing, and it never
// decides for you."). One pure function, read by the executor's unlock (which
// refuses before it writes anything) and by `assess` (which reports it and
// opens no door, owes no repair and no act).
//   - It keys on a DISAGREEMENT, never on absence: no memory item at all is
//     rule 8's keychain reset (or a new Mac), and the open goes on (the
//     orchestrator's adjudication 5 after U1).
//   - The live place holds another library while this Mac remembers one: the
//     memory items name other library IDs and none names this one.
//   - The library file, or the key file beside it, is another key's than the
//     one this Mac remembers — a replayed or swapped-in file, a backup pair
//     copied in by hand — unless this Mac's own act in flight explains it (the
//     act moves between exactly those two keys).

/// The two doors rule 21 offers (rule 17's).
public enum CopyDoor: String, Hashable, Sendable, CaseIterable {
    case lookInside
    case makeThisMyLibrary
}

/// What an open found that this Mac doesn't remember — said, never repaired.
public struct LibraryDisagreement: Hashable, Sendable {
    public enum Finding: Hashable, Sendable {
        /// The live place holds library `found`; this Mac remembers `remembered`.
        case anotherLibrary(found: String, remembered: [String])
        /// The library file is under key `found`; this Mac remembers `remembered`.
        case libraryFileUnderAnotherKey(found: String, remembered: String)
        /// The key file in the live place is key `found`'s; this Mac remembers `remembered`.
        case keyFileOfAnotherKey(found: String, remembered: String)
    }

    public var findings: [Finding]
    /// Rule 17's two doors, offered — never chosen for her.
    public var offers: [CopyDoor] { CopyDoor.allCases }

    public init(findings: [Finding]) {
        self.findings = findings
    }

    /// **The check.** `memory`: what this Mac remembers for the library in the
    /// live place, verified (nil — absent, or failing its seal — is no
    /// disagreement); `rememberedLibraryIDs`: every library this scope's memory
    /// items name; `actInFlight`: this Mac's own act, which may explain two keys.
    public static func check(
        libraryID: String, libraryFingerprint: String, memory: DeviceMemory?, rememberedLibraryIDs: Set<String>,
        liveKeyFileFingerprint: String?, actInFlight: ActInFlight?
    ) -> LibraryDisagreement? {
        var findings: [Finding] = []
        guard let memory else {
            let others = rememberedLibraryIDs.subtracting([libraryID])
            if !others.isEmpty, !rememberedLibraryIDs.contains(libraryID) {
                findings.append(.anotherLibrary(found: libraryID, remembered: others.sorted()))
            }
            return findings.isEmpty ? nil : LibraryDisagreement(findings: findings)
        }
        let actKeys = Set([actInFlight?.fromFingerprint, actInFlight?.toFingerprint].compactMap { $0 })
        func explained(_ a: String, _ b: String) -> Bool { actKeys.contains(a) && actKeys.contains(b) }
        let remembered = memory.currentFingerprint
        if libraryFingerprint != remembered, !explained(libraryFingerprint, remembered) {
            findings.append(.libraryFileUnderAnotherKey(found: libraryFingerprint, remembered: remembered))
        }
        if let file = liveKeyFileFingerprint, file != remembered, !explained(file, remembered) {
            findings.append(.keyFileOfAnotherKey(found: file, remembered: remembered))
        }
        return findings.isEmpty ? nil : LibraryDisagreement(findings: findings)
    }
}
