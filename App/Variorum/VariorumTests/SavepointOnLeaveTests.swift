//
//  SavepointOnLeaveTests.swift
//  VariorumTests
//
//  Phase 13j, J11 — **the app half of her savepoint-cadence ruling.**
//
//  The RULES are core's and are pinned there (`SavepointCadenceTests`: the
//  dedupe, the three modes' occasion matrix, the sealed/vanished no-ops, the
//  24 h → 2 h backstop). What these pins own is the MAPPING — where
//  "close/leave" actually hooks — and they are written to be red on dead
//  wiring, which is this phase's own lesson: ladder A's BLOCKER shipped a
//  region that could never render, green through five pins that all drove a
//  test seam. So nothing here calls a seam:
//
//  · the workspace's departure signal is driven by the real navigation door
//    (`select`), not by poking the closure;
//  · the wired end-to-end pin runs `SavepointOnLeave.wire` — the exact call
//    `RootView.wireWorkspace` makes — against a real store and polls for the
//    commit ROW;
//  · the quit pin runs `quitFinalize.finalizeAll()`, the exact call the app
//    delegate makes on ⌘Q.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withLeaveWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A post with one block and a keystroke PENDING in the shared coordinator's
/// debounce — the state a leaving gesture actually arrives in (she stops
/// typing and navigates away).
@MainActor
private func dirtyNote(
    _ session: AppSession, text: String = "Alpha beta.", typed: String = "Alpha beta. NEW"
) throws -> (postID: String, variantID: String) {
    let post = try session.operations.createPost(title: "note")
    let block = try session.operations.newBlock(in: post.id, text: text)
    session.autosave(forPost: post.id).record(
        variantID: block.variant.id, text: typed, charDelta: 4)
    return (post.id, block.variant.id)
}

@MainActor
private func savepointTexts(_ db: AppDatabase, variantID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT text FROM commit_point WHERE variant_id = ?
                 ORDER BY created_at, id
                """,
            arguments: [variantID])
    }
}

/// Poll for an expected savepoint count — the spawned-Task roads
/// (`SavepointOnLeave.leaving`) detach from the caller deliberately.
@MainActor
private func awaitSavepoints(
    _ db: AppDatabase, variantID: String, count: Int
) async throws -> [String] {
    for _ in 0..<200 {
        let texts = try await savepointTexts(db, variantID: variantID)
        if texts.count >= count { return texts }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
    return try await savepointTexts(db, variantID: variantID)
}

@Suite("13j J11 — leaving a note leaves a savepoint", .serialized)
@MainActor
struct SavepointOnLeaveTests {

    // MARK: - The one entry

    /// **FLUSH-FIRST IS THE CLAIM.** `closeAutoCommit` reads `working_text`
    /// ROWS, and a leaving gesture arrives inside the autosave debounce by
    /// construction — so a savepoint taken without the flush would preserve
    /// the text as of half a second before she stopped typing. (The copy
    /// doors' 13e E10 class, arriving at the cadence.)
    @Test func leavingFlushesThenSavepointsWhatSheJustTyped() async throws {
        try await withLeaveWorld { session, db in
            let note = try dirtyNote(session)
            let stored = try await db.read { db in
                try Queries.renderPost(db, containerID: note.postID).first?.text
            }
            #expect(stored == "Alpha beta.", "the premise: the store has not seen the edit yet")

            await session.savepointOnLeaving(note.postID)

            #expect(try await savepointTexts(db, variantID: note.variantID)
                    == ["Alpha beta. NEW"])
        }
    }

    /// The dedupe at the door: leaving twice with nothing typed between
    /// writes one row, not two (core's `isDirty` guard, reached through the
    /// app's entry).
    @Test func leavingTwiceWithNothingTypedWritesOneSavepoint() async throws {
        try await withLeaveWorld { session, db in
            let note = try dirtyNote(session)
            await session.savepointOnLeaving(note.postID)
            await session.savepointOnLeaving(note.postID)
            #expect(try await savepointTexts(db, variantID: note.variantID).count == 1)
        }
    }

    /// The entry never throws at a surface that is going away — the sealed
    /// and vanished cases reach it as ordinary calls, not as refusals to
    /// present.
    @Test func leavingASealedOrDeletedNoteIsSilent() async throws {
        try await withLeaveWorld { session, db in
            let note = try dirtyNote(session)
            await session.savepointOnLeaving(note.postID)          // the one savepoint
            try session.operations.lockPost(note.postID)
            await session.savepointOnLeaving(note.postID)
            try session.operations.deleteContainer(note.postID)
            await session.savepointOnLeaving(note.postID)
            #expect(try await savepointTexts(db, variantID: note.variantID).count == 1)
        }
    }

    /// The app path does not bypass the cadence gate (core pins the matrix;
    /// this pins that the door reads it).
    @Test func theOnlyWhenICommitModeLeavesNothingBehind() async throws {
        try await withLeaveWorld { session, db in
            try session.operations.setSavepointCadence(.onlyOnCommit)
            let note = try dirtyNote(session)
            await session.savepointOnLeaving(note.postID)
            #expect(try await savepointTexts(db, variantID: note.variantID).isEmpty)
            // …and the flush still ran: leaving must never lose text, whatever
            // the cadence says about savepoints.
            let stored = try await db.read { db in
                try Queries.renderPost(db, containerID: note.postID).first?.text
            }
            #expect(stored == "Alpha beta. NEW")
        }
    }

    // MARK: - The mapping: what counts as leaving

    @Test func navigatingAPaneAwayReportsExactlyThatNote() async throws {
        let workspace = WorkspaceModel()
        var left: [[String]] = []
        workspace.onNotesLeft = { left.append($0) }

        workspace.select(.post("a"))
        #expect(left.isEmpty, "arriving is not leaving")
        workspace.select(.post("b"))
        #expect(left == [["a"]])
        workspace.select(.shelf)
        #expect(left == [["a"], ["b"]], "leaving for a non-note destination counts")
        workspace.select(.pool("scraps"))
        workspace.select(.library)
        #expect(left == [["a"], ["b"], ["scraps"]],
                "a scraps container leaves like a note — its buffers are buffers")
    }

    /// Moving focus between two panes is NOT a leaving: both notes are still
    /// on screen. The signal compares SETS for exactly this case.
    @Test func focusMovingBetweenPanesLeavesNothing() async throws {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        workspace.openBeside(.post("b"))
        var left: [[String]] = []
        workspace.onNotesLeft = { left.append($0) }

        workspace.focus(workspace.panes[0])
        workspace.focus(workspace.panes[1])
        #expect(left.isEmpty)
        #expect(Set(workspace.shownNoteIDs) == ["a", "b"])

        // …but folding the split away IS one.
        workspace.focus(workspace.panes[1])
        #expect(workspace.closeSplit())
        #expect(left == [["b"]])
    }

    /// Closing an Open-strip row is deliberately NOT a leaving — its own
    /// contract is that it "closes a ROW and nothing else", and the pane goes
    /// on showing the note.
    @Test func closingAnOpenStripRowIsNotALeaving() async throws {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        var left: [[String]] = []
        workspace.onNotesLeft = { left.append($0) }
        workspace.closeNote("a")
        #expect(left.isEmpty)
        #expect(workspace.shownNoteIDs == ["a"])
    }

    /// **THE WIRED ROAD, END TO END, WITH NO SEAM** — `SavepointOnLeave.wire`
    /// is the exact call `RootView.wireWorkspace` makes, and the assertion is
    /// on the commit ROW, so wiring that could never fire is red here.
    @Test func aWiredWorkspaceSavepointsTheNoteSheNavigatedAwayFrom() async throws {
        try await withLeaveWorld { session, db in
            let note = try dirtyNote(session, text: "Kept.", typed: "Kept, and typed.")
            let workspace = WorkspaceModel()
            SavepointOnLeave.wire(workspace: workspace, session: session)

            workspace.select(.post(note.postID))
            workspace.select(.shelf)

            #expect(try await awaitSavepoints(db, variantID: note.variantID, count: 1)
                    == ["Kept, and typed."])
        }
    }

    /// A window's teardown, same road — the call both `RootView` and
    /// `NoteWindowView` make from `onDisappear`.
    @Test func aClosingWindowSavepointsEverythingItsPanesWereShowing() async throws {
        try await withLeaveWorld { session, db in
            let first = try dirtyNote(session, text: "One.", typed: "One, typed.")
            let second = try dirtyNote(session, text: "Two.", typed: "Two, typed.")
            let workspace = WorkspaceModel()
            workspace.select(.post(first.postID))
            workspace.openBeside(.post(second.postID))
            #expect(workspace.shownNoteIDs.count == 2, "the premise: a split window")

            SavepointOnLeave.windowClosing(workspace: workspace, session: session)

            #expect(try await awaitSavepoints(db, variantID: first.variantID, count: 1)
                    == ["One, typed."])
            #expect(try await awaitSavepoints(db, variantID: second.variantID, count: 1)
                    == ["Two, typed."])
        }
    }

    /// **⌘Q**, through the exact registry the app delegate awaits. The
    /// registration rides `AppSession.autosave(forPost:)`, so every post any
    /// surface has opened this session is covered by construction.
    @Test func theQuitDoorSavepointsEveryOpenNote() async throws {
        try await withLeaveWorld { session, db in
            let note = try dirtyNote(session, text: "Quit.", typed: "Quit, typed.")
            await session.quitFinalize.finalizeAll()
            #expect(try await savepointTexts(db, variantID: note.variantID)
                    == ["Quit, typed."])
        }
    }
}

// MARK: - The faces' collapse

@Suite("13j J11 — the quiet-run collapse, as the faces render it")
@MainActor
struct SavepointHistoryFaceTests {
    private func run(_ ids: [String]) -> SavepointRuns.Row<String> {
        .quietRun(id: ids[0], items: ids)
    }

    @Test func aCollapsedRunDrawsItsLineAndNoneOfItsSavepoints() {
        let rendered = SavepointHistoryFace.rendered(run(["1", "2", "3"]), expanded: [])
        #expect(rendered.runCount == 3)
        #expect(rendered.expanded == false)
        #expect(rendered.items.isEmpty, "collapsing IS drawing none of them")
    }

    @Test func anExpandedRunDrawsTheLineAndAllOfThem() {
        let row = run(["1", "2", "3"])
        let rendered = SavepointHistoryFace.rendered(row, expanded: [row.id])
        #expect(rendered.runCount == 3)
        #expect(rendered.expanded)
        #expect(rendered.items == ["1", "2", "3"])
    }

    @Test func aDeliberateSavepointDrawsItselfAndNoLine() {
        let rendered = SavepointHistoryFace.rendered(
            .single("m", id: "m"), expanded: ["m"])
        #expect(rendered.runCount == nil, "a lone savepoint never wears a run line")
        #expect(rendered.items == ["m"])
    }

    @Test func theToggleOpensAndClosesOneRunAtATime() {
        var open = SavepointHistoryFace.toggling("run:1", in: [])
        #expect(open == ["run:1"])
        open = SavepointHistoryFace.toggling("run:9", in: open)
        #expect(open == ["run:1", "run:9"])
        open = SavepointHistoryFace.toggling("run:1", in: open)
        #expect(open == ["run:9"])
    }

    /// The words on the collapsed line, and the promise its help makes.
    @Test func theLineNamesWhatItStandsForAndTheHelpDoesNotOverclaim() {
        // 13s-b U4 (R-13s-31): the word on the line is COMMIT.
        #expect(SavepointRuns.runLabel(count: 4) == "4 quiet commits")
        #expect(SavepointRuns.showVerb == "show" && SavepointRuns.hideVerb == "hide")
        #expect(SavepointRuns.runHelp.contains("never folded in"))
    }

    /// The cadence setting's help must NAME the insurance occasions — a
    /// setting reading as "nothing else writes savepoints" while three other
    /// occasions still do is the J8 copy-truth defect (this phase's own bar).
    @Test func theCadenceSettingsHelpNamesTheInsuranceOccasions() {
        let note = SavepointCadenceCopy.insuranceNote
        #expect(note.contains("complete"), "sealing a note")
        #expect(note.contains("locking a take"))
        #expect(note.contains("structural"))
        #expect(!note.contains("Fragments"),
                "the bridge's landing occasion left with the bridge (2026-09-04) — the help must not name it")
        #expect(SavepointCadenceCopy.label(.onlyOnCommit).contains("\u{2318}S"))
        // Every mode is worded — a picker row with no words is a silent door.
        for cadence in SavepointCadence.allCases {
            #expect(!SavepointCadenceCopy.label(cadence).isEmpty)
        }
    }
}

// MARK: - The visual loop

/// THE ONE new piece of chrome this batch adds that CAN be rendered
/// offscreen. Batch 2's measured limit still holds — SwiftUI `List` is
/// NSTableView-backed and `ImageRenderer` draws its unsupported-view
/// placeholder — so the two history LISTS remain hand-check items, named as
/// such in the batch record rather than faked here. `QuietRunRow` is a plain
/// HStack of text and a link button, so it renders at full fidelity, and it
/// is exactly the chrome that needs looking at: it appears INSIDE an existing
/// list where "quiet" is the whole design requirement.
///
/// LIGHT only (13g batch 2's recorded finding: this project's offscreen dark
/// renders resolve the wrong appearance).
@MainActor
@Suite("The quiet-run line's capture (13j J11 — the visual loop)")
struct QuietRunRowCaptureTests {
    private static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-13j-batch5-screens")

    @Test func captureTheCollapsedAndExpandedRunLine() throws {
        try FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)
        for (voiceName, tokens) in [
            ("terminal", VoiceTokens.terminalLight), ("study", VoiceTokens.studyLight),
        ] {
            for (name, count, expanded) in [
                ("1-collapsed-three", 3, false),
                ("2-expanded-three", 3, true),
                ("3-collapsed-many", 17, false),
            ] {
                let view = VStack(alignment: .leading, spacing: 6) {
                    QuietRunRow(
                        count: count, expanded: expanded, tokens: tokens, onToggle: {})
                    // One deliberate savepoint beneath it, so the capture
                    // shows the contrast the design is about: a ⌘S row is
                    // never folded away.
                    HStack(spacing: 8) {
                        Text("Aug 18, 2026 at 9:30:04 AM").font(.caption)
                        Text("manual").font(.caption2)
                        Spacer()
                        Text("The paragraph as she left it.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Button("Restore") {}.controlSize(.small)
                    }
                }
                try writeImage(
                    view
                        .frame(width: 560, alignment: .leading)
                        .padding(8)
                        .background(tokens.room),
                    to: "\(voiceName)-\(name).png")
            }
        }
        print("13j batch 5 captures: \(Self.outputDirectory.path)")
    }

    private func writeImage(_ view: some View, to name: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:])
        else {
            Issue.record("the renderer produced no image for \(name)")
            return
        }
        try png.write(to: Self.outputDirectory.appendingPathComponent(name))
    }
}
