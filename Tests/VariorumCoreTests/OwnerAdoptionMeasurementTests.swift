import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VM-67 (the VM-64 run, batch 4) — THE HEADLESS BEFORE/AFTER of owner adoption
// with nothing to adopt, on an ENCRYPTED on-disk WAL store at about her scale
// (her phone's sync row read "108,000" rows in all; the owner-carrying tables
// here hold ~62k). MEASUREMENT ONLY — gated off by default, asserts nothing but
// that it gathered its runs. Run it on the fix and on the pre-fix tree (the
// record's §5 batch 4 names the revert) and compare:
//
//   VARIORUM_VM67_MEASURE=1 swift test --filter OwnerAdoptionMeasurementTests
//
// Two series, n = 5 each, one line per series:
//   VM67-CORE|owner-adoption-warm|…  the same pool, five passes in a row
//   VM67-CORE|owner-adoption-cold|…  the store CLOSED and reopened before each
//                                    pass — SQLCipher's page cache empty, as
//                                    after every Castle unlock on her phone
// Knobs: VARIORUM_VM67_POSTS (default 5,000) · VARIORUM_VM67_BLOCKS (50,000).
// A Mac number, headless, Debug — never a phone number; the phone's own
// before/after is `MobileHerPathsPerfTests`' `owner-adoption-nothing-to-adopt`.

private let measuring = ProcessInfo.processInfo.environment["VARIORUM_VM67_MEASURE"] == "1"

private func knob(_ name: String, _ fallback: Int) -> Int {
    Int(ProcessInfo.processInfo.environment[name] ?? "") ?? fallback
}

@Suite("VM-67 — owner adoption's cost with nothing to adopt (measurement, gated)", .serialized)
struct OwnerAdoptionMeasurementTests {
    private static let owner = "vm67-0000-4000-8000-0000000000ff"
    private static let runs = 5

    private static func line(_ series: String, _ samples: [Double]) -> String {
        let sorted = samples.sorted()
        let mid = sorted.count / 2
        let median = sorted.isEmpty ? 0 : (sorted.count % 2 == 1 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2)
        return "VM67-CORE|\(series)|n=\(samples.count)|median=\(String(format: "%.2f", median))"
            + "|min=\(String(format: "%.2f", sorted.first ?? 0))|max=\(String(format: "%.2f", sorted.last ?? 0))|ms"
    }

    @Test(.enabled(if: measuring))
    func ownerAdoptionWithNothingToAdoptOnAnEncryptedStoreAtHerScale() throws {
        let posts = knob("VARIORUM_VM67_POSTS", 5_000)
        let blocks = knob("VARIORUM_VM67_BLOCKS", 50_000)
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm67-measure-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("store.sqlite")
        let key = StoreKey.mint()
        let stamp = "2026-11-19T00:00:00.000Z"

        // Every row OWNED (her phone's steady state): bulk rows through the
        // ordinary triggers, in one transaction.
        do {
            let db = try AppDatabase.onDisk(url: url, key: key)
            try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let arguments: StatementArguments = ["owner": Self.owner, "stamp": stamp, "posts": posts, "blocks": blocks]
                try db.execute(sql: """
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < :posts)
                    INSERT INTO container (id, owner_id, kind, title, created_at, updated_at, last_touched_at)
                      SELECT 'c' || i, :owner, 'post', 'note ' || i, :stamp, :stamp, :stamp FROM n;
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < :blocks)
                    INSERT INTO block (id, owner_id, last_container_id, created_at, updated_at)
                      SELECT 'b' || i, :owner, 'c' || (1 + i % :posts), :stamp, :stamp FROM n;
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 1000)
                    INSERT INTO tag (id, owner_id, name, path, created_at, updated_at)
                      SELECT 't' || i, :owner, 'tag' || i, 'tag' || i, :stamp, :stamp FROM n;
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 200)
                    INSERT INTO reading (id, owner_id, name, kind, created_at, updated_at)
                      SELECT 'r' || i, :owner, 'book ' || i, 'book', :stamp, :stamp FROM n;
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
                    INSERT INTO block_comment (id, owner_id, block_id, text, created_at, updated_at)
                      SELECT 'k' || i, :owner, 'b' || i, 'a working note ' || i, :stamp, :stamp FROM n;
                    WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 500)
                    INSERT INTO reference (id, owner_id, container_id, kind, url, position, created_at, updated_at)
                      SELECT 'f' || i, :owner, 'c' || i, 'url', 'https://example.com/' || i, 'a0', :stamp, :stamp FROM n;
                    DELETE FROM sync_outbox;
                    """, arguments: arguments)
            }
        }
        let owned = try AppDatabase.onDisk(url: url, key: key).read { db in
            try Int.fetchOne(db, sql: """
                SELECT (SELECT COUNT(*) FROM container) + (SELECT COUNT(*) FROM block) + (SELECT COUNT(*) FROM tag)
                     + (SELECT COUNT(*) FROM reading) + (SELECT COUNT(*) FROM block_comment) + (SELECT COUNT(*) FROM reference)
                """) ?? 0
        }

        func timedPass(_ db: AppDatabase) throws -> Double {
            let ops = withDependencies {
                $0.database = db
                $0.ownerIdentity = OwnerIdentity { Self.owner }
            } operation: { Operations() }
            let clock = ContinuousClock()
            let start = clock.now
            let report = try ops.adoptOwnerID()
            let elapsed = clock.now - start
            #expect(report.total == 0, "every row is owned")
            return Double(elapsed.components.seconds) * 1000 + Double(elapsed.components.attoseconds) / 1e15
        }

        // Warm: one pool, a pass to warm it, then five measured.
        let warmDB = try AppDatabase.onDisk(url: url, key: key)
        _ = try timedPass(warmDB)
        var warm: [Double] = []
        for _ in 0..<Self.runs { warm.append(try timedPass(warmDB)) }

        // Cold: the store reopened before each pass (a fresh pool, an empty
        // page cache — the unlock's shape).
        var cold: [Double] = []
        for _ in 0..<Self.runs {
            let reopened = try AppDatabase.onDisk(url: url, key: key)
            cold.append(try timedPass(reopened))
        }

        print("VM67-CORE|owner-rows|\(owned) owned rows in the owner-carrying tables")
        print(Self.line("owner-adoption-warm", warm))
        print(Self.line("owner-adoption-cold", cold))
        #expect(warm.count == Self.runs && cold.count == Self.runs)

        // The options' query plans (the record's §7 batch 4 table), through
        // THIS build's SQLite on this seeded store. `NOT INDEXED` shows what a
        // statement costs without the v1_38 index (option (b) alone; the
        // pre-fix update). The last two are the store's other `owner_id`
        // reads — the partial index must not move their plans.
        try warmDB.writeWithoutTransaction { db in
            print("VM67-PLAN|sqlite_version|" + (try String.fetchOne(db, sql: "SELECT sqlite_version()") ?? "?"))
            for (label, sql) in [
                ("probe (a)+(b)", "SELECT EXISTS (SELECT 1 FROM block WHERE owner_id IS NULL)"),
                ("update (a)", "UPDATE block SET owner_id = 'x' WHERE owner_id IS NULL"),
                ("probe without the index — (b) alone", "SELECT EXISTS (SELECT 1 FROM block NOT INDEXED WHERE owner_id IS NULL)"),
                ("update without the index — before", "UPDATE block NOT INDEXED SET owner_id = 'x' WHERE owner_id IS NULL"),
                ("owner_id = ? (unchanged)", "SELECT 1 FROM block WHERE owner_id = 'x' LIMIT 1"),
                ("foreign-owner read (unchanged)", "SELECT 1 FROM block WHERE owner_id IS NOT NULL AND owner_id != 'x' LIMIT 1"),
            ] {
                let details = try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + sql).map { $0["detail"] as String }
                print("VM67-PLAN|\(label)|\(details.joined(separator: " ; "))")
            }
        }
    }
}
