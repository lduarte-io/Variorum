import Foundation
import GRDB
import Testing
@testable import VariorumCore

// pre-13u Act 10 wave 2c — the P1 statement for the new modes' query
// layer, measured at the Sherlock scale (a ~10k-word note: ~120 blocks of
// ~85 words). The workbench row (renderPost + names + stamps + tags) and
// the TOC row both read one note; the bound here is a SANITY CEILING two
// orders above the measured cost (~2–4 ms cold on the dev machine), so
// the pin can never red under load (the latency-pin lesson) while still
// catching a corpus-shaped regression. The measured numbers are stated in
// the wave record, not asserted.
@Suite("Workbench & TOC P1 sanity (pre-13u Act 10 wave 2c)")
struct WorkbenchP1SanityTests {
    @Test func aTenThousandWordNoteReadsWellUnderTheFeelInstantBar() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the 10k story")
            let sentence = "It was in the spring of the year that the singular "
                + "affair began, and nothing about it promised the turn it took. "
            for i in 0..<120 {
                // ~85 words per block ≈ a Sherlock paragraph.
                let text = "Paragraph \(i). " + String(repeating: sentence, count: 5)
                _ = try ops.newBlock(in: post.id, text: text)
            }
            let clock = ContinuousClock()
            var rows: [Queries.WorkbenchRow] = []
            let workbench = try clock.measure {
                rows = try db.read { try Queries.blockWorkbench($0, post: post.id) }
            }
            var toc: [Queries.TOCRow] = []
            let tocTime = try clock.measure {
                toc = try db.read { try Queries.blockTOC($0, post: post.id) }
            }
            #expect(rows.count == 120)
            #expect(toc.count == 120)
            print("[wave2c P1] blockWorkbench(10k words, 120 blocks): \(workbench)")
            print("[wave2c P1] blockTOC(10k words, 120 blocks): \(tocTime)")
            // The sanity ceiling — two orders above the measured cost.
            #expect(workbench < .seconds(1))
            #expect(tocTime < .seconds(1))
        }
    }
}
