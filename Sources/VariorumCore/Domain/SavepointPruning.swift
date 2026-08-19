import Foundation

/// **Quiet-savepoint pruning** (Phase 13j batch 6b — her round-9 ruling,
/// verbatim: *"I think 90 days, N=10 is fine for a default, but I think
/// users should be able to choose to never prune. it might be important
/// for some users."*).
///
/// Pure and clock-injected, like `TrashWindow`: the janitor asks this
/// brain which of ONE take's quiet savepoints are prunable, and mints a
/// purge intent per answer — so the rule has exactly one home and a test
/// can stand on either side of the 90-day line without a store.
///
/// **Deliberate ⌘S commits are NEVER prunable, in either mode** — enforced
/// twice: this brain only ever considers `kind == 'auto'` rows, and
/// `Operations.requestPurge` refuses a manual savepoint outright (the
/// belt behind the brain).
public enum SavepointPruning {
    /// A quiet savepoint younger than this never prunes (her ruling).
    public static let ageDays = 90
    /// The newest N quiet savepoints per take survive any age (her ruling).
    public static let keepNewestQuiet = 10

    /// One savepoint as the brain sees it. `kind` is the stored enum text
    /// ('manual' | 'auto'); anything not exactly 'auto' is untouchable.
    public struct Savepoint: Equatable, Sendable {
        public let id: String
        public let kind: String
        public let createdAt: Date

        public init(id: String, kind: String, createdAt: Date) {
            self.id = id
            self.kind = kind
            self.createdAt = createdAt
        }
    }

    /// The prunable ids among ONE take's savepoints under the Standard
    /// mode: quiet (`kind == 'auto'`) rows older than `ageDays`, excluding
    /// the newest `keepNewestQuiet` quiet rows (newest by `createdAt`,
    /// tie-broken by id descending — the store's own display order).
    /// The Never mode never calls this — the janitor consults the setting
    /// before minting anything (memo §4d).
    public static func prunable(among savepoints: [Savepoint], now: Date) -> [String] {
        let cutoff = now.addingTimeInterval(-Double(ageDays) * 86_400)
        let quiet = savepoints
            .filter { $0.kind == "auto" }
            .sorted {
                $0.createdAt == $1.createdAt
                    ? $0.id > $1.id
                    : $0.createdAt > $1.createdAt
            }
        guard quiet.count > keepNewestQuiet else { return [] }
        return quiet.dropFirst(keepNewestQuiet)
            .filter { $0.createdAt < cutoff }
            .map(\.id)
    }
}
