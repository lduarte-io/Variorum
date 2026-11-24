import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VM-71 (the VM-64 run, batch 7) — THE HEADLESS BEFORE/AFTER of a leaving's
// savepoint on a ~100k-word note, on an ENCRYPTED on-disk WAL store.
// MEASUREMENT ONLY — gated off by default, asserts nothing but that it gathered
// its runs:
//
//   VARIORUM_VM71_MEASURE=1 swift test --filter LeavingSavepointMeasurementTests
//
// The note: VARIORUM_VM71_BLOCKS blocks (default 1,370 — the phone fixture's
// "long haul") of ~73 words each, every take savepointed once (a note she has
// left before). Each series n = 5, warm pool, one line per series:
//
//   VM71-CORE|whole-op-one-edit|…   BEFORE: `closeAutoCommit(_:)` after one take
//                                   was edited — the runner's whole turn
//   VM71-CORE|read-one-edit|…       AFTER: `leavingSavepointCandidates`, the read
//                                   (a reader connection — never the runner)
//   VM71-CORE|narrowed-one-edit|…   AFTER: `closeAutoCommit(_:takes:)`, the
//                                   runner's turn for the one take
//   VM71-CORE|whole-op-clean|…      BEFORE: a leaving after only READING the note
//   VM71-CORE|read-clean|…          AFTER: the same leaving — a read, and no
//                                   runner turn at all
//   VM71-CORE|union-turn-one-edit|… the ladder's round 1, finding 1, ARM (b): the
//                                   runner's turn if it re-ran the read inside its
//                                   own transaction and wrote the union (the
//                                   reader's read stays, untimed here)
//   VM71-CORE|read-on-writer-clean|… the read alone inside a write transaction on
//                                   the writer (arm (b)'s new part), nothing owed
//
// A Mac number, headless, Debug — never a phone number; the phone's own
// before/after is `MobileHerPathsPerfTests`' `leaving-*-100k` series.

private let measuring = ProcessInfo.processInfo.environment["VARIORUM_VM71_MEASURE"] == "1"

@Suite("VM-71 — a leaving's savepoint on a 100k-word note (measurement, gated)", .serialized)
struct LeavingSavepointMeasurementTests {
    private static let runs = 5

    private static func line(_ series: String, _ samples: [Double]) -> String {
        let sorted = samples.sorted()
        let mid = sorted.count / 2
        let median = sorted.isEmpty ? 0 : (sorted.count % 2 == 1 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2)
        return "VM71-CORE|\(series)|n=\(samples.count)|median=\(String(format: "%.2f", median))"
            + "|min=\(String(format: "%.2f", sorted.first ?? 0))|max=\(String(format: "%.2f", sorted.last ?? 0))|ms"
    }

    private static func milliseconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) * 1000 + Double(duration.components.attoseconds) / 1e15
    }

    /// ~73 words, deterministic per block.
    private static func prose(_ block: Int) -> String {
        (0..<8).map { sentence in
            "Block \(block) sentence \(sentence) walks on through a long and patient paragraph."
        }.joined(separator: " ")
    }

    @Test(.enabled(if: measuring))
    func aLeavingSavepointOnAHundredThousandWordNote() throws {
        let blocks = Int(ProcessInfo.processInfo.environment["VARIORUM_VM71_BLOCKS"] ?? "") ?? 1_370
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm71-measure-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("store.sqlite")
        let db = try AppDatabase.onDisk(url: url, key: StoreKey.mint())

        try withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 71))
        } operation: {
            let ops = Operations(undoStack: nil)
            let post = try ops.createPost(title: "the long haul", profile: .blog)
            var takes: [String] = []
            for index in 0..<blocks {
                takes.append(try ops.newBlock(
                    in: post.id, text: Self.prose(index), at: .end, registeringUndo: false).variant.id)
            }
            _ = try ops.closeAutoCommit(post.id)  // left before: every take savepointed once
            let words = try db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT v.working_text FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id AND cb.container_id = ?
                    """, arguments: [post.id])
            }.reduce(0) { $0 + $1.split(separator: " ").count }
            print("VM71-CORE|note|\(blocks) blocks, \(words) words, every take savepointed once")

            let clock = ContinuousClock()
            var wholeEdit: [Double] = [], readEdit: [Double] = [], narrowedEdit: [Double] = []
            var wholeClean: [Double] = [], readClean: [Double] = [], unionEdit: [Double] = []
            var writerRead: [Double] = []
            for run in 0...Self.runs {
                // BEFORE, one take edited: the whole op.
                try ops.autosave(takes[run * 7 % blocks], text: "edited \(run) a", charDelta: 10)
                var start = clock.now
                let wrote = try ops.closeAutoCommit(post.id)
                let whole = Self.milliseconds(clock.now - start)
                #expect(wrote.count == 1)

                // AFTER, one take edited: the read, then the narrowed op.
                try ops.autosave(takes[run * 7 % blocks], text: "edited \(run) b", charDelta: 10)
                start = clock.now
                let listed = try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }
                let read = Self.milliseconds(clock.now - start)
                start = clock.now
                let narrowedWrote = try ops.closeAutoCommit(post.id, takes: listed)
                let narrowed = Self.milliseconds(clock.now - start)
                #expect(listed.count == 1 && narrowedWrote.count == 1)

                // A leaving after only reading: BEFORE the whole op, AFTER the read.
                start = clock.now
                #expect(try ops.closeAutoCommit(post.id).isEmpty)
                let clean = Self.milliseconds(clock.now - start)
                start = clock.now
                #expect(try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }.isEmpty)
                let cleanRead = Self.milliseconds(clock.now - start)

                // The ladder's round 1, finding 1, ARM (b) — what it would cost the
                // runner: one take edited, the read on a reader (not timed — arm (b)
                // keeps it), then ONE write transaction that runs the read AGAIN and
                // writes the union of what it lists and what the first read listed,
                // each take re-checked as `closeAutoCommit(_:takes:)` re-checks it.
                try ops.autosave(takes[run * 7 % blocks], text: "edited \(run) c", charDelta: 10)
                let listedAgain = try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }
                start = clock.now
                let unionWrote = try db.write { db -> Int in
                    let inTurn = try Queries.leavingSavepointCandidates(db, containerID: post.id)
                    var wrote = 0
                    for variantID in Set(listedAgain).union(inTurn).sorted() {
                        guard let variant = try Variant.fetchOne(
                            db,
                            sql: """
                                SELECT v.* FROM variant v
                                JOIN container_block cb
                                  ON cb.block_id = v.block_id
                                 AND cb.container_id = ?
                                 AND cb.deleted_at IS NULL
                                WHERE v.id = ? AND v.deleted_at IS NULL AND v.locked = 0
                                """,
                            arguments: [post.id, variantID]),
                              try ops.isDirty(db, variant)
                        else { continue }
                        _ = try ops.insertCommit(db, variant: variant, kind: .auto, message: nil, now: Date())
                        wrote += 1
                    }
                    return wrote
                }
                let union = Self.milliseconds(clock.now - start)
                #expect(listedAgain.count == 1 && unionWrote == 1)
                // …and the read alone on the WRITER, in a write transaction (the
                // part of arm (b)'s turn that is new), nothing owed.
                start = clock.now
                #expect(try db.write { try Queries.leavingSavepointCandidates($0, containerID: post.id) }.isEmpty)
                let readOnWriter = Self.milliseconds(clock.now - start)

                guard run > 0 else { continue }  // the first pass warms the pool
                wholeEdit.append(whole); readEdit.append(read); narrowedEdit.append(narrowed)
                wholeClean.append(clean); readClean.append(cleanRead); unionEdit.append(union)
                writerRead.append(readOnWriter)
            }
            print(Self.line("whole-op-one-edit", wholeEdit))
            print(Self.line("read-one-edit", readEdit))
            print(Self.line("narrowed-one-edit", narrowedEdit))
            print(Self.line("whole-op-clean", wholeClean))
            print(Self.line("read-clean", readClean))
            print(Self.line("union-turn-one-edit", unionEdit))
            print(Self.line("read-on-writer-clean", writerRead))
            #expect(wholeEdit.count == Self.runs && readClean.count == Self.runs && unionEdit.count == Self.runs)
        }
    }
}
