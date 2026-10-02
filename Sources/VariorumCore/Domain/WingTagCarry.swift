import Foundation

/// **THE BULK WING MOVE'S TAG ARITHMETIC** (13i-d U5b — R-13id-4's sketch +
/// R-13id-6 item 8: "every tag application re-points by path; the source
/// wing's tags, left with no live application after the move, are TOMBSTONED
/// by the act, said in the confirm — the wing ends genuinely empty").
///
/// Pure and path-based, so the confirm (`Queries.wingContentsMovePreview`)
/// and the act (`Operations.moveWingContents`) answer the same question the
/// same way. Every live tag of the SOURCE wing is retired by the act; what
/// the confirm says is what becomes of each one's NAME, in exactly one
/// bucket:
///
/// - **joins** — the destination already has a live tag at that path (a
///   carried application adopts it; R-13ia-1's rider);
/// - **made** — something the move carries wears or names this path (or one
///   beneath it), and the destination lacks it, so the adoption MINTS it
///   there (its missing ancestors with it);
/// - **letting go** — nothing the move carries wears or names it and the
///   destination lacks it: the name does not survive the move (PROVISIONAL
///   P-13id-U5b-6 — the ruling retires every source tag; the confirm NAMES
///   these, because they are the only real loss).
///
/// `minted` is every path the act will mint in the destination — the closure
/// (each carried path and its ancestors) minus what the destination has —
/// which also covers a carried tag of ANOTHER wing (a legacy stray on a
/// moving note), so the act's mint tally equals `minted.count`.
public enum WingTagCarry {
    public struct Plan: Equatable, Sendable {
        public let joins: [String]
        public let made: [String]
        public let lettingGo: [String]
        public let minted: [String]

        public init(joins: [String], made: [String], lettingGo: [String], minted: [String]) {
            self.joins = joins
            self.made = made
            self.lettingGo = lettingGo
            self.minted = minted
        }
    }

    /// Every path with all its ancestors (`a/b/c` → `a`, `a/b`, `a/b/c`).
    public static func closure(_ paths: Set<String>) -> Set<String> {
        var result: Set<String> = []
        for path in paths where !path.isEmpty {
            var prefix = ""
            for segment in path.split(separator: "/") {
                prefix = prefix.isEmpty ? String(segment) : prefix + "/" + segment
                result.insert(prefix)
            }
        }
        return result
    }

    /// The plan. `sourcePaths` = the source wing's live tag paths;
    /// `carriedPaths` = every path the move re-points or adopts (worn by a
    /// moving note or block, worn by any remaining application of a source
    /// tag, or named by a moving reading's rule / outflow / grouping);
    /// `destinationPaths` = the destination's live tag paths before the act.
    /// Each list sorted by path.
    public static func plan(
        sourcePaths: [String], carriedPaths: Set<String>, destinationPaths: Set<String>
    ) -> Plan {
        let carriedClosure = closure(carriedPaths)
        let minted = carriedClosure.subtracting(destinationPaths)
        var joins: [String] = []
        var made: [String] = []
        var lettingGo: [String] = []
        for path in Set(sourcePaths).sorted() {
            if destinationPaths.contains(path) {
                joins.append(path)
            } else if minted.contains(path) {
                made.append(path)
            } else {
                lettingGo.append(path)
            }
        }
        return Plan(joins: joins, made: made, lettingGo: lettingGo, minted: minted.sorted())
    }
}
