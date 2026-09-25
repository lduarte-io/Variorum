//
//  DebugOracleOwnershipTests.swift
//  VariorumTests
//
//  18k UNIT C4 — **the owner-keyed registration rule, as arithmetic.**
//
//  `DebugOracleTwoWindowTests` holds the rule where it matters — twelve real
//  pairs of windows, each measured red on the pre-fix tree. These pins hold
//  the SHAPE underneath them, the way `ShellDoorOwnershipTests` holds the
//  shell's door (13u4 UNIT S3) and the card half of `StampOracleOwnership
//  Tests` holds the catalog's (UNIT S2): no mount, one turn, every rule
//  stated as a check.
//
//  Two parts:
//    · the container itself (`OwnedRegistrations` / `OwnedSlot` /
//      `DebugOracleLog`) — its rules, one pin each;
//    · every converted oracle driven through its OWN doors by two owners —
//      which is where a field the mounted pins cannot separate (the two
//      windows drew the same rectangle: the catalog's note rows, the
//      Outline's anchor tops, the Index's glyphs…) stands on the structural
//      arm, and where a field forgotten in its oracle's `release(owner:)`
//      would go red.
//
//  RED ON OLD by non-compilation (the `MastheadStampTests` "product row"
//  shape, S2's own for its card pin): none of these doors existed before
//  C4 — the oracles were bare statics.
//

import AppKit
import Foundation
import Testing
@testable import Variorum

#if DEBUG
@MainActor
@Suite("The owner-keyed DEBUG oracle rule, as arithmetic (18k UNIT C4)", .serialized)
struct DebugOracleOwnershipTests {
    private func rect(_ x: CGFloat) -> CGRect { CGRect(x: x, y: 0, width: 10, height: 10) }

    // MARK: - The container

    /// RULE ONE: the most recent registrant answers — and re-publishing
    /// replaces its value IN PLACE, so a body that re-runs never jumps the
    /// queue past a window mounted after it.
    @Test func theNewestRegistrantAnswersAndARepublishKeepsItsPlace() {
        var store = OwnedRegistrations<String, Int>()
        let first = UUID(), second = UUID()
        store.publish(1, for: "k", owner: first)
        store.publish(2, for: "k", owner: second)
        #expect(store["k"] == 2)
        store.publish(11, for: "k", owner: first)
        #expect(store["k"] == 2, "the older owner's re-report does not jump past the newer")
        store.publish(22, for: "k", owner: second)
        #expect(store["k"] == 22, "…and the newer one's replaces its own value")
        #expect(store.current == ["k": 22])
    }

    /// RULE TWO, the whole defect: a teardown takes only its own — from
    /// EITHER side. The newer leaving hands the key back to the older; the
    /// older leaving leaves the newer standing.
    @Test func aTeardownTakesOnlyItsOwnFromEitherSide() {
        var store = OwnedRegistrations<String, Int>()
        let older = UUID(), newer = UUID()
        store.publish(1, for: "k", owner: older)
        store.publish(2, for: "k", owner: newer)
        store.release(owner: newer)
        #expect(store["k"] == 1, "the newer left: the older answers again")

        store.publish(2, for: "k", owner: newer)
        store.release(owner: older)
        #expect(store["k"] == 2, "the older left: the newer still answers")
        store.release(owner: newer)
        #expect(store["k"] == nil, "the last one left: nothing stands")
        #expect(store.current.isEmpty)
    }

    /// A release reaches every key the owner holds — and no key it does not.
    @Test func aReleaseReachesEveryKeyItsOwnerHoldsAndNoOther() {
        var store = OwnedRegistrations<String, Int>()
        let mine = UUID(), theirs = UUID()
        store.publish(1, for: "a", owner: mine)
        store.publish(2, for: "b", owner: mine)
        store.publish(3, for: "b", owner: theirs)
        store.publish(4, for: "c", owner: theirs)
        store.release(owner: mine)
        #expect(store.current == ["b": 3, "c": 4])
    }

    /// Releasing what you never published — or twice — is a no-op: a
    /// teardown must never be order-sensitive.
    @Test func releasingWhatYouDoNotOwnOrTwiceIsANoOp() {
        var store = OwnedRegistrations<String, Int>()
        let mine = UUID()
        store.publish(1, for: "k", owner: mine)
        store.release(owner: UUID())
        #expect(store["k"] == 1, "a stranger's teardown took nothing")
        store.release(owner: mine)
        store.release(owner: mine)
        #expect(store["k"] == nil)
        store.withdraw("k", owner: mine)
        #expect(store.current.isEmpty, "a withdraw of nothing is nothing")
    }

    /// `withdraw` takes ONE key of the owner's — its other keys, and every
    /// other owner's entry on that key, stand.
    @Test func aWithdrawTakesOneKeyOfTheOwnersAndNothingElse() {
        var store = OwnedRegistrations<String, Int>()
        let mine = UUID(), theirs = UUID()
        store.publish(1, for: "a", owner: theirs)
        store.publish(2, for: "a", owner: mine)
        store.publish(3, for: "b", owner: mine)
        store.withdraw("a", owner: mine)
        #expect(store.current == ["a": 1, "b": 3])
        // …and the withdrawn key is no longer the owner's to release.
        store.release(owner: mine)
        #expect(store.current == ["a": 1])
    }

    /// A PIN's doors are unconditional — a pin owns nothing, and "start from
    /// empty" is exactly what it asks for (13u4 S2's `resetStamp` rule).
    @Test func aPinsForgetIsUnconditional() {
        var store = OwnedRegistrations<String, Int>()
        let a = UUID(), b = UUID()
        store.publish(1, for: "k", owner: a)
        store.publish(2, for: "k", owner: b)
        store.publish(3, for: "j", owner: a)
        store.forget("k")
        #expect(store.current == ["j": 3], "one key, every owner")
        store.forgetAll()
        #expect(store.current.isEmpty)
        // A forgotten owner writing again registers afresh, as the newest.
        store.publish(4, for: "k", owner: a)
        store.publish(5, for: "k", owner: b)
        store.release(owner: b)
        #expect(store["k"] == 4)
    }

    /// An owner's OWN value — the read-modify-write door (the Index's content
    /// span folds only its own reports, never another window's).
    @Test func anOwnersOwnValueIsItsOwn() {
        var store = OwnedRegistrations<String, Int>()
        let a = UUID(), b = UUID()
        store.publish(1, for: "k", owner: a)
        store.publish(2, for: "k", owner: b)
        #expect(store.value(for: "k", owner: a) == 1)
        #expect(store.value(for: "k", owner: b) == 2)
        #expect(store.value(for: "k", owner: UUID()) == nil)
    }

    /// A slot whose value is itself optional registers "nothing" as a FACT:
    /// a detail with no panel open answers nil while it stands, and the
    /// other window's panel answers again only once it has gone.
    @Test func aSlotRegistersNothingAsAFact() {
        var slot = OwnedSlot<Int?>()
        let older = UUID(), newer = UUID()
        slot.publish(7, owner: older)
        slot.publish(nil, owner: newer)
        #expect((slot.value ?? nil) == nil, "the newest registrant says nothing is open")
        #expect(slot.value != nil, "…which is a registration, not an empty slot")
        slot.release(owner: newer)
        #expect((slot.value ?? nil) == 7)
        slot.forget()
        #expect(slot.value == nil)
    }

    /// The log bound (the 13u2 UNIT E `TakeCardGeometry` rule, shared):
    /// oldest out, never more than the limit.
    @Test func anAppendOnlyLogIsBoundedOldestOut() {
        var log = Array(0..<(DebugOracleLog.limit + 5))
        DebugOracleLog.bound(&log)
        #expect(log.count == DebugOracleLog.limit)
        #expect(log.first == 5 && log.last == DebugOracleLog.limit + 4)
        var short = [1, 2, 3]
        DebugOracleLog.bound(&short)
        #expect(short == [1, 2, 3])
    }

    // MARK: - Every converted oracle, through its own doors

    /// `BookOutlineGeometry` — including the anchor tops and row heights,
    /// the navigator's ROWS, and the focus door. Two books register; the
    /// newer leaves; every read is the older's; the older leaves; nothing.
    @Test func theOutlinesRegistrationsAnswerForTheBookStillOpen() {
        let book = "book-\(UUID().uuidString)", anchor = "page-\(UUID().uuidString)"
        let chapter = "ch-\(UUID().uuidString)", note = "n-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        var focused: [String] = []
        defer { BookOutlineGeometry.release(owner: older); BookOutlineGeometry.release(owner: newer) }
        for (owner, v) in [(older, CGFloat(1)), (newer, CGFloat(2))] {
            BookOutlineGeometry.recordAnchor(anchor, top: v, height: v * 10, owner: owner)
            BookOutlineGeometry.recordNavigator(book, rect(v), owner: owner)
            BookOutlineGeometry.recordNavigatorRow(chapter, chapter: true, rect(v), owner: owner)
            BookOutlineGeometry.recordNavigatorRow(note, chapter: false, rect(v), owner: owner)
            BookOutlineGeometry.publishFocusDoor(book, owner: owner) { _ in focused.append("\(v)") }
        }
        BookOutlineGeometry.release(owner: newer)
        #expect(BookOutlineGeometry.anchorTops[anchor] == 1)
        #expect(BookOutlineGeometry.rowHeights[anchor] == 10)
        #expect(BookOutlineGeometry.navigatorFrames[book] == rect(1))
        #expect(BookOutlineGeometry.navigatorChapterRows[chapter] == rect(1))
        #expect(BookOutlineGeometry.navigatorNoteRows[note] == rect(1))
        BookOutlineGeometry.focusDoors[book]?(nil)
        #expect(focused == ["1.0"], "the door is the open book's")
        BookOutlineGeometry.release(owner: older)
        #expect(BookOutlineGeometry.anchorTops[anchor] == nil)
        #expect(BookOutlineGeometry.rowHeights[anchor] == nil)
        #expect(BookOutlineGeometry.navigatorFrames[book] == nil)
        #expect(BookOutlineGeometry.navigatorChapterRows[chapter] == nil)
        #expect(BookOutlineGeometry.navigatorNoteRows[note] == nil)
        #expect(BookOutlineGeometry.focusDoors[book] == nil)
    }

    /// `BookIndexGeometry` — including the two trailing glyphs, the wash,
    /// the prose edges, the pane anchors and the content span (whose fold
    /// reads only its OWN row).
    @Test func theIndexsRegistrationsAnswerForTheIndexStillOpen() {
        let book = "book-\(UUID().uuidString)", post = "p-\(UUID().uuidString)"
        let block = "b-\(UUID().uuidString)", anchor = "a-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        defer { BookIndexGeometry.release(owner: older); BookIndexGeometry.release(owner: newer) }
        for (owner, v) in [(older, CGFloat(1)), (newer, CGFloat(2))] {
            BookIndexGeometry.recordChapterCount(rect(v), owner: owner)
            BookIndexGeometry.recordNoteMenu(rect(v), owner: owner)
            BookIndexGeometry.recordColumn(book, rect(v), owner: owner)
            BookIndexGeometry.recordSelectionWash(post, height: v, owner: owner)
            BookIndexGeometry.recordNoteHeight(post, v, owner: owner)
            BookIndexGeometry.recordProseLeading(block, v, owner: owner)
            BookIndexGeometry.recordAnchor(anchor, top: v, owner: owner)
            BookIndexGeometry.recordContentHeight(book, v * 100, owner: owner)
        }
        // The newer window's span folds its OWN second report, never the older's.
        BookIndexGeometry.recordContentHeight(book, 50, owner: newer)
        #expect(BookIndexGeometry.paneContentSpans[book]
                == BookIndexContentSpan(low: 50, high: 200, reports: 2))
        BookIndexGeometry.release(owner: newer)
        #expect(BookIndexGeometry.chapterCountFrame == rect(1))
        #expect(BookIndexGeometry.noteMenuFrame == rect(1))
        #expect(BookIndexGeometry.columnFrames[book] == rect(1))
        #expect(BookIndexGeometry.paneSelectionWashHeights[post] == 1)
        #expect(BookIndexGeometry.paneNoteHeights[post] == 1)
        #expect(BookIndexGeometry.paneProseLeading[block] == 1)
        #expect(BookIndexGeometry.paneAnchorTops[anchor] == 1)
        #expect(BookIndexGeometry.paneContentSpans[book]
                == BookIndexContentSpan(low: 100, high: 100, reports: 1))
        BookIndexGeometry.release(owner: older)
        #expect(BookIndexGeometry.chapterCountFrame == nil && BookIndexGeometry.noteMenuFrame == nil)
        #expect(BookIndexGeometry.columnFrames[book] == nil)
        #expect(BookIndexGeometry.paneSelectionWashHeights[post] == nil)
        #expect(BookIndexGeometry.paneNoteHeights[post] == nil)
        #expect(BookIndexGeometry.paneProseLeading[block] == nil)
        #expect(BookIndexGeometry.paneAnchorTops[anchor] == nil)
        #expect(BookIndexGeometry.paneContentSpans[book] == nil)
    }

    /// `ReadingFlowGeometry`'s row tops.
    @Test func theFlowsRowTopsAnswerForTheFlowStillOpen() {
        let post = "p-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        defer { ReadingFlowGeometry.release(owner: older); ReadingFlowGeometry.release(owner: newer) }
        ReadingFlowGeometry.recordAnchor(post, top: 1, owner: older)
        ReadingFlowGeometry.recordAnchor(post, top: 2, owner: newer)
        ReadingFlowGeometry.release(owner: newer)
        #expect(ReadingFlowGeometry.anchorTops[post] == 1)
        ReadingFlowGeometry.release(owner: older)
        #expect(ReadingFlowGeometry.anchorTops[post] == nil)
    }

    /// `ReadModeOracle` — including `form`, `liveBlockID`, the page face's
    /// rows and each host's own first paint.
    @Test func theReadHostsRegistrationsAnswerForTheHostStillOpen() {
        let post = "p-\(UUID().uuidString)", block = "b-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        defer { ReadModeOracle.release(owner: older); ReadModeOracle.release(owner: newer) }
        ReadModeOracle.report(face: .read, form: .pages, selected: "s1", live: "l1", owner: older)
        ReadModeOracle.recordPageBlock(block, rect(1), owner: older)
        ReadModeOracle.recordEditBlock(block, rect(1), owner: older)
        ReadModeOracle.recordFaceFrame(post, rect(1), owner: older)
        ReadModeOracle.recordIndexColumn(post, rect(1), owner: older)
        let olderPaint = ReadModeOracle.firstEditRowPaintedAt
        #expect(olderPaint != nil)
        ReadModeOracle.report(face: .edit, form: .continuous, selected: "s2", live: nil, owner: newer)
        ReadModeOracle.recordPageBlock(block, rect(2), owner: newer)
        ReadModeOracle.recordEditBlock(block, rect(2), owner: newer)
        ReadModeOracle.recordFaceFrame(post, rect(2), owner: newer)
        ReadModeOracle.recordIndexColumn(post, rect(2), owner: newer)
        ReadModeOracle.recordEditBlock(block, rect(3), owner: older)
        ReadModeOracle.release(owner: newer)
        #expect(ReadModeOracle.face == .read && ReadModeOracle.form == .pages)
        #expect(ReadModeOracle.selectedBlockID == "s1" && ReadModeOracle.liveBlockID == "l1")
        #expect(ReadModeOracle.pageBlockFrames[block] == rect(1))
        #expect(ReadModeOracle.editBlockFrames[block] == rect(3))
        #expect(ReadModeOracle.faceFrames[post] == rect(1))
        #expect(ReadModeOracle.indexColumnFrames[post] == rect(1))
        #expect(ReadModeOracle.firstEditRowPaintedAt == olderPaint,
                "a later row of the same host never moves its first paint")
        ReadModeOracle.release(owner: older)
        #expect(ReadModeOracle.face == nil && ReadModeOracle.selectedBlockID == nil)
        #expect(ReadModeOracle.pageBlockFrames[block] == nil && ReadModeOracle.editBlockFrames[block] == nil)
        #expect(ReadModeOracle.faceFrames[post] == nil && ReadModeOracle.indexColumnFrames[post] == nil)
        #expect(ReadModeOracle.firstEditRowPaintedAt == nil)
    }

    /// `LibraryPanelOracle` — including the message, quick-entry and
    /// book-line frames and the per-row map the mounted pin could not
    /// separate (the two catalogs drew their rows at one width).
    @Test func theCatalogsFramesAnswerForTheCatalogStillOpen() {
        let post = "p-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        defer { LibraryPanelOracle.release(owner: older); LibraryPanelOracle.release(owner: newer) }
        let slots: [LibraryProbeSlot] = [.root, .divider, .panel, .message, .quickEntry, .bookLine, .noteRow(post)]
        for (owner, v) in [(older, CGFloat(1)), (newer, CGFloat(2))] {
            for slot in slots { LibraryPanelOracle.record(slot, rect(v), owner: owner) }
        }
        LibraryPanelOracle.release(owner: newer)
        #expect(LibraryPanelOracle.rootFrame == rect(1) && LibraryPanelOracle.dividerFrame == rect(1))
        #expect(LibraryPanelOracle.panelFrame == rect(1) && LibraryPanelOracle.messageFrame == rect(1))
        #expect(LibraryPanelOracle.quickEntryFrame == rect(1) && LibraryPanelOracle.bookLineFrame == rect(1))
        #expect(LibraryPanelOracle.noteRowFrames[post] == rect(1))
        LibraryPanelOracle.release(owner: older)
        #expect(LibraryPanelOracle.rootFrame == nil && LibraryPanelOracle.noteRowFrames[post] == nil)
    }

    /// `PostDetailOracle`'s four singletons, through their doors.
    @Test func theDetailsSingletonsAnswerForTheDetailStillOpen() {
        let older = UUID(), newer = UUID()
        var opened: [String] = []
        defer { PostDetailOracle.release(owner: older); PostDetailOracle.release(owner: newer) }
        PostDetailOracle.recordInspectorPanel(.versions, owner: older)
        PostDetailOracle.publishTitleDoor(owner: older) { opened.append("older") }
        PostDetailOracle.recordTitleShown("older", owner: older)
        PostDetailOracle.recordSideColumnDivider(rect(1), owner: older)
        PostDetailOracle.recordInspectorPanel(nil, owner: newer)
        PostDetailOracle.publishTitleDoor(owner: newer) { opened.append("newer") }
        PostDetailOracle.recordTitleShown("newer", owner: newer)
        PostDetailOracle.recordSideColumnDivider(nil, owner: newer)
        #expect(PostDetailOracle.inspectorPanel == nil, "the newest detail holds no panel")
        #expect(PostDetailOracle.sideColumnDividerFrame == nil)
        PostDetailOracle.release(owner: newer)
        #expect(PostDetailOracle.inspectorPanel == .versions)
        #expect(PostDetailOracle.titleShown == "older")
        #expect(PostDetailOracle.sideColumnDividerFrame == rect(1))
        PostDetailOracle.beginTitleEditing?()
        #expect(opened == ["older"])
        PostDetailOracle.release(owner: older)
        #expect(PostDetailOracle.inspectorPanel == nil && PostDetailOracle.titleShown == nil)
        #expect(PostDetailOracle.beginTitleEditing == nil && PostDetailOracle.sideColumnDividerFrame == nil)
    }

    /// `ShellGeometry`, `CommitBarGeometry`, `CanvasArrivalOracle`,
    /// `TakesArticleDoorProbe` — the unkeyed frames, through their doors
    /// (including the canvas's landing and content size, which the mounted
    /// pin's two canvases shared).
    @Test func theUnkeyedFramesAnswerForTheViewStillOpen() {
        let older = UUID(), newer = UUID()
        defer {
            for owner in [older, newer] {
                ShellGeometry.release(owner: owner)
                CommitBarGeometry.release(owner: owner)
                CanvasArrivalOracle.release(owner: owner)
                TakesArticleDoorProbe.release(owner: owner)
            }
        }
        let landings: [CanvasArrival.Landing] = [.origin, .centre(CGPoint(x: 5, y: 5))]
        for (index, owner) in [older, newer].enumerated() {
            let v = CGFloat(index + 1)
            ShellGeometry.recordLine(rect(v), owner: owner)
            ShellGeometry.recordGrip(rect(v), owner: owner)
            CommitBarGeometry.recordRow(rect(v), owner: owner)
            CommitBarGeometry.recordWidth(v, owner: owner)
            CanvasArrivalOracle.recordLanding(landings[index], owner: owner)
            CanvasArrivalOracle.recordBoardContentSize(CGSize(width: v, height: v), owner: owner)
            CanvasArrivalOracle.recordViewport(CGSize(width: v, height: v), owner: owner)
            TakesArticleDoorProbe.record(rect(v), owner: owner)
        }
        for owner in [newer] {
            ShellGeometry.release(owner: owner)
            CommitBarGeometry.release(owner: owner)
            CanvasArrivalOracle.release(owner: owner)
            TakesArticleDoorProbe.release(owner: owner)
        }
        #expect(ShellGeometry.dividerLineFrame == rect(1) && ShellGeometry.dividerGripFrame == rect(1))
        #expect(CommitBarGeometry.rowFrame == rect(1) && CommitBarGeometry.barWidth == 1)
        #expect(CanvasArrivalOracle.landing == .origin)
        #expect(CanvasArrivalOracle.boardContentSize == CGSize(width: 1, height: 1))
        #expect(CanvasArrivalOracle.viewport == CGSize(width: 1, height: 1))
        #expect(TakesArticleDoorProbe.frame == rect(1))
    }

    /// `SidebarGeometry`'s rail and box maps — including the box's header,
    /// which the mounted pin's two boxes drew at one place.
    @Test func theRailAndTheBoxAnswerForTheWindowStillOpen() {
        let post = "p-\(UUID().uuidString)", book = "b-\(UUID().uuidString)"
        let older = UUID(), newer = UUID()
        defer { SidebarGeometry.release(owner: older); SidebarGeometry.release(owner: newer) }
        for (owner, v) in [(older, CGFloat(1)), (newer, CGFloat(2))] {
            SidebarGeometry.recordRail(post, v, owner: owner)
            SidebarGeometry.recordBoxFrame(book, rect(v), owner: owner)
            SidebarGeometry.recordBoxHeader(book, rect(v), owner: owner)
            SidebarGeometry.recordWhereLine("line \(v)", for: book, owner: owner)
        }
        SidebarGeometry.release(owner: newer)
        #expect(SidebarGeometry.railGroupHeights[post] == 1)
        #expect(SidebarGeometry.noteBoxFrames[book] == rect(1))
        #expect(SidebarGeometry.noteBoxHeaderFrames[book] == rect(1))
        #expect(SidebarGeometry.noteBoxWhereLines[book] == "line 1.0")
        SidebarGeometry.release(owner: older)
        #expect(SidebarGeometry.railGroupHeights[post] == nil && SidebarGeometry.noteBoxFrames[book] == nil)
        #expect(SidebarGeometry.noteBoxHeaderFrames[book] == nil && SidebarGeometry.noteBoxWhereLines[book] == nil)
    }

    /// `SeamGeometry` — and its pin door, `forget(key)`, still unconditional.
    @Test func aSeamAnswersForTheWindowStillOpenAndItsPinDoorStillForgets() {
        let key = SeamGeometry.key("family", subject: UUID().uuidString)
        let older = UUID(), newer = UUID()
        defer { SeamGeometry.release(owner: older); SeamGeometry.release(owner: newer) }
        for (owner, v) in [(older, CGFloat(1)), (newer, CGFloat(2))] {
            SeamGeometry.recordLine(key, rect(v), owner: owner)
            SeamGeometry.recordGrip(key, rect(v), owner: owner)
        }
        SeamGeometry.release(owner: newer)
        #expect(SeamGeometry.lineFrames[key] == rect(1) && SeamGeometry.gripFrames[key] == rect(1))
        SeamGeometry.forget(key)
        #expect(SeamGeometry.lineFrames[key] == nil && SeamGeometry.gripFrames[key] == nil)
    }
}
#endif
