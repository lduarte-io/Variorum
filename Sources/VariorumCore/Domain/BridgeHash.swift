import CryptoKit
import Foundation

/// SHA-256 hex of a text's UTF-8 bytes — the sample library's MANIFEST HASH
/// RECIPE. `SampleLibrarySeeder` classifies a seeded copy PRISTINE by
/// comparing `BridgeHash.body(Queries.renderedText(…))` against the bundled
/// manifest's per-title hashes (pre-13u Act 3), and the pristine-copy dedupe
/// (`Sync/SampleLibraryDedupe`, SyncSpec §7) takes this function by
/// reference through `SampleLibraryDedupeFacts`. The BUNDLED manifest was
/// computed with it, so the recipe must never change — a drift would mark
/// every shipped copy EDITED (both-survive, the safe direction) and never
/// pristine again. Pinned to independently computed vectors in
/// `SampleLibraryDedupeRepairTests`.
///
/// The NAME is history: this was the retired Fragments bridge's body hash
/// (Phase 9b's change detection; the bridge was archived 2026-09-04 at tag
/// `archive/fragments-bridge-2026-09-04` — `notes/archive/fragments-bridge.md`)
/// and moved here verbatim when the module left, because the manifest already
/// rode it. Kept as-is so the `Sync/` reference and the shipped tests stay
/// byte-unchanged; a rename is a later touch under the `Sync/` rider.
public enum BridgeHash {
    public static func body(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
