//
//  BookReadMintSourceTests.swift
//  VariorumTests — the VX-1036 run, batch 2, P7 (ledger row 15, the carried correction of batch 1's P-1036-B1-2):
//  A MINT DOOR PRESSED IN THE BOOK'S READ MODE TURNS THE BOOK TO THE OUTLINE AND LANDS THE NOTE LIVE, the caret in
//  it. Ruled by the architect at batch 1's close against N-1's letter ("every mint door ends with the new note on the
//  page, live") and P-2's fire-and-DO mode choreography; Read itself stays read-only. Batch 1 had built the recorded
//  alternative (a): in Read the note was landed SHOWN, not live — the mint act asked the arrival in whatever mode the
//  book stood in, and Read mounts no editor.
//
//  A SOURCE pin, SELF-CONTAINED (file reads only, no app import — it runs in a minimal SwiftPM package as well as the
//  Mac target; `#filePath`'s symlinks resolved), the batch 1 precedent (`BookMintDoorsLandSourceTests`): the
//  correction is the ORDER inside the one mint act — the turn to the Outline at the PRESS, before the mint's task —
//  which no hosted test reaches without the Read flow's doors on screen. The arrival itself (focus, the landing once
//  the entries hold the note) is batch 1's, pinned by `BookMintLandingTests`; the rule's table is `BookReadMintTests`.
//
//  RED ON OLD: the act never asked the mode (batch 1's tree — `mint(_:door:)` went straight to its placement and task).
//

import Foundation
import Testing

@Suite("VX-1036 P7 — a mint in Read turns to the Outline and lands live (source)")
struct BookReadMintSourceTests {
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    static func codeLines(_ relative: String) throws -> [String] {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init).filter {
            !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//")
        }
    }

    /// The body of the book's one mint act, from its declaration to its task.
    static func mintActHead() throws -> [String] {
        let lines = try codeLines("Variorum/Features/BookView/BookView.swift")
        let start = try #require(lines.firstIndex { $0.contains("private func mint(") }, "the one mint act")
        let task = try #require(lines[start...].firstIndex { $0.contains("Task {") }, "its task")
        return Array(lines[start..<task])
    }

    @Test func theActTurnsReadToTheOutlineAtThePressBeforeItsTask() throws {
        let head = try Self.mintActHead()
        #expect(head.contains { $0.contains("BookReadMint.turnsToOutline(") },
                "the act asks the one rule whether this mode turns to the Outline — at the press, before the task")
        #expect(head.contains { $0.contains("structure.mode = .outline") },
                "…and turns it there (the navigator note door's own road — no carry: the arrival is the landing)")
    }
}
