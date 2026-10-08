import Foundation

// Phase 13x, U2 row 9 — THE iCLOUD-DRIVE LIVE-LIBRARY GUARD's two pure
// rules (pre-13x ledger 4, deferred-and-owned here; copy §6's why-not
// sentence is the words both faces render). The guard's faces:
//
// · the BACKUP-DESTINATION picker refuses the live library's own folder
//   (copy §8's recorded note: "the picker's refusal of the live library's
//   own folder is 13x's") — a second folder that IS the first is no second
//   location, and pointing a cloud-synced picker at the live store is the
//   exact corruption road the sentence teaches against;
// · the ADOPTION door's confirm renders the sentence as an informational
//   line when the picked SOURCE sits inside iCloud Drive — the door adopts
//   BY COPY into the app's own place, so the guard there teaches rather
//   than refuses ("your working library stays on this Mac").

public enum LibraryPlacementGuard {
    /// Whether `url` sits inside iCloud Drive (any container: the user's
    /// `com~apple~CloudDocs` Documents home or an app's own iCloud
    /// container) — the `Mobile Documents` home under `~/Library` is the
    /// one stable marker of both. A path-shape rule, no file I/O.
    public static func isInsideICloudDrive(_ url: URL) -> Bool {
        url.standardizedFileURL.pathComponents.contains("Mobile Documents")
    }

    /// Whether a picked folder is the live library's own (the store's
    /// folder itself, or an ancestor that contains it — picking
    /// `Application Support` wholesale points the picker at the library
    /// just as surely). The store file itself counts too.
    public static func isLiveLibraryFolder(_ picked: URL, storeURL: URL) -> Bool {
        let store = storeURL.standardizedFileURL.pathComponents
        let storeFolder = Array(store.dropLast())
        let candidate = picked.standardizedFileURL.pathComponents
        if candidate == store { return true }
        guard candidate.count <= storeFolder.count else { return false }
        return Array(storeFolder.prefix(candidate.count)) == candidate
    }
}
