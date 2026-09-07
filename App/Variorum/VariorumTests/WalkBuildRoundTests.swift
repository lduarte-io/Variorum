//
//  WalkBuildRoundTests.swift
//  VariorumTests
//
//  Phase 13k, batch 1 — the Mac-side pins for the fully-ruled set:
//  **K3** (tag chips show the LEAF), **K5** (⏎ continues a list) and
//  **K6** (the right-click callout door). K1/K2 are Domain + read-side and
//  are pinned in core (`DisplayTitleTests`); their app-side wiring rides
//  `NodSetTests`' chrome pin.
//

import AppKit
import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The house store harness (each suite file keeps its own — the
/// `NodSetTests` / `MorningListTests` pattern).
@MainActor
private func withStore<T>(
    _ body: @MainActor (AppDatabase, AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(db, AppSession(database: db))
    }
}

// MARK: - K3: a chip says the LEAF, and keeps the path's colour

/// Her ruling, 2026-08-02: *"chips should show leaf only"* — the alternative
/// QUESTIONS #52(e) recorded, now taken. The colour is deliberately NOT
/// narrowed with the label.
@MainActor
@Suite("K3 — tag chips show the leaf (13k)")
struct TagChipLeafTests {
    @Test func aChipsLabelIsTheLastSegmentOfItsPath() {
        #expect(TagChipLabel.leaf(of: "life/goals/2024") == "2024")
        #expect(TagChipLabel.leaf(of: "life") == "life")
        #expect(TagChipLabel.leaf(of: "a/b") == "b")
    }

    /// A chip must never be blank: a degenerate path reads as itself.
    @Test func aDegeneratePathReadsAsItselfRatherThanAsNothing() {
        #expect(TagChipLabel.leaf(of: "") == "")
        #expect(TagChipLabel.leaf(of: "life/") == "life")
        #expect(TagChipLabel.leaf(of: "/") == "/")
    }

    /// **The half that must NOT change with it.** Two tags whose leaves are
    /// identical still wear different colours, because the colour is keyed
    /// on the whole path — which is exactly why leaf-only labels are safe.
    ///
    /// DISCRIMINATING REVERT (verified): key `TagChipColor.hue` on
    /// `TagChipLabel.leaf(of: path)` instead of the path and the first
    /// expectation fails — `life/goals` and `work/goals` become one colour.
    @Test func theCOLOURStaysKeyedOnTheWHOLEPath() {
        #expect(TagChipColor.hue(forPath: "life/goals")
                != TagChipColor.hue(forPath: "work/goals"))
        // …and is stable, which is what "same tag, same colour, forever"
        // means (the 9d never-re-ripple family).
        #expect(TagChipColor.hue(forPath: "life/goals")
                == TagChipColor.hue(forPath: "life/goals"))
    }
}

// MARK: - K4: a note card names its smart books too

/// Her ruling, 2026-08-02, reversing the shipped curated-only card
/// (QUESTIONS #51(c)). The bounded read and its P1 plan pin live in core
/// (`SmartBookMembershipTests`); this is the CARD — that the two halves reach
/// the row, in the ruled order, with the curated half byte-unchanged.
@MainActor
@Suite("K4 — note cards name smart books (13k)")
struct NoteCardSmartBooksTests {
    /// `nonisolated` because it runs inside the ops runner's own closure.
    /// `Tag` is also a Swift Testing type — qualify it, as the house does.
    private nonisolated static func seedTag(
        _ ops: Operations, path: String
    ) throws -> VariorumCore.Tag {
        var parent: VariorumCore.Tag?
        for segment in path.split(separator: "/") {
            parent = try ops.createTag(parent: parent?.id, name: String(segment))
        }
        return parent!
    }

    /// **RED on the pre-K4 code**, where `NoteCards.load` read `reading_post`
    /// and nothing else.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `smartBookMembership` merge
    /// from `NoteCards.load` and this test fails on its second and third
    /// expectations — the smart-only note names no book at all.
    @Test func aCardNamesCuratedBooksFirstThenTheSmartOnesThatCollectIt() async throws {
        try await withStore { db, session in
            let (curatedOnly, smartOnly, both) = try await session.runner.run {
                ops -> (String, String, String) in
                let stars = try Self.seedTag(ops, path: "stars")
                let hand = try ops.createReading(name: "hand-made", kind: .curated)
                let smart = try ops.createReading(name: "starred", kind: .smart)
                try ops.setReadingQuerySpec(
                    smart.id,
                    querySpec: Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())

                let curatedOnly = try ops.createPost(title: "Curated")
                try ops.addPostToReading(curatedOnly.id, to: hand.id)
                let smartOnly = try ops.createPost(title: "Smart")
                _ = try ops.applyTag(stars.id, toPost: smartOnly.id)
                let both = try ops.createPost(title: "Both")
                try ops.addPostToReading(both.id, to: hand.id)
                _ = try ops.applyTag(stars.id, toPost: both.id)
                return (curatedOnly.id, smartOnly.id, both.id)
            }

            let cards = try await db.read { database in
                try NoteCards.load(
                    database, postIDs: [curatedOnly, smartOnly, both])
            }
            // The curated half is byte-unchanged…
            #expect(cards[curatedOnly]?.books == ["hand-made"])
            // …the smart half now reaches the row…
            #expect(cards[smartOnly]?.books == ["starred"])
            // …and a note in both names the CURATED one first (a membership
            // row is a decision she made; a smart match is the filter's).
            #expect(cards[both]?.books == ["hand-made", "starred"])
        }
    }

    /// A name appearing in BOTH halves shows once — a card row reading
    /// "Ideas, Ideas" is worse than the rare ambiguity of two same-named
    /// books (#53(l)). Names have no uniqueness (AppSpec §7), so this corner
    /// is reachable.
    @Test func aNameInBothHalvesShowsOnce() async throws {
        try await withStore { db, session in
            let postID = try await session.runner.run { ops -> String in
                let stars = try Self.seedTag(ops, path: "stars")
                let curated = try ops.createReading(name: "Ideas", kind: .curated)
                let smart = try ops.createReading(name: "Ideas", kind: .smart)
                try ops.setReadingQuerySpec(
                    smart.id,
                    querySpec: Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
                let post = try ops.createPost(title: "In both")
                try ops.addPostToReading(post.id, to: curated.id)
                _ = try ops.applyTag(stars.id, toPost: post.id)
                return post.id
            }
            let cards = try await db.read { try NoteCards.load($0, postIDs: [postID]) }
            #expect(cards[postID]?.books == ["Ideas"])
        }
    }

    /// The snippet half is untouched by K4 — the card's other extra still
    /// costs its bounded window and nothing more.
    @Test func theSnippetHalfIsUnchanged() async throws {
        try await withStore { db, session in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Snippet")
                _ = try ops.newBlock(in: post.id, text: "")
                _ = try ops.newBlock(in: post.id, text: "The second block has words.")
                return post.id
            }
            let cards = try await db.read { try NoteCards.load($0, postIDs: [postID]) }
            #expect(cards[postID]?.snippet == "The second block has words.")
            #expect(cards[postID]?.books.isEmpty == true)
        }
    }
}

// MARK: - K6: the right-click callout door

/// Her report, 2026-08-01: she went looking for callouts in the RIGHT-CLICK
/// and they were not there. The act is unchanged (13c R2-2's routed
/// transform); what this adds is a door and a declaration.
@MainActor
@Suite("K6 — the right-click callout door (13k)", .serialized)
struct CalloutContextMenuTests {
    /// P-1: the door is DECLARED, so the registry walk covers it — and the
    /// menu-bar door it joins is untouched.
    @Test func theCalloutCapabilityDeclaresTheContextMenuDoor() {
        let capability = CapabilityRegistry.capability(.callout)
        #expect(capability.doors.contains(.contextMenu))
        #expect(capability.doors.contains(.menuBar))
        #expect(capability.shortcutLabel == "⌥⌘C")
    }

    /// ONE vocabulary, three renderers — the `MarkdownActs.rows` pattern.
    /// The rows carry the toggle, the five palette colours, the emoji prompt
    /// and the remove row, in that order.
    @Test func theRowsAreOneVocabularyTheThreeDoorsShare() {
        let titles = CalloutMenu.rowTitles
        #expect(titles.first == "Toggle Callout")
        #expect(titles.last == "Remove Callout")
        #expect(titles.contains("Emoji…"))
        for name in CalloutPalette.names {
            #expect(titles.contains(name.capitalized))
        }
        #expect(titles.count == CalloutPalette.names.count + 3)
        // Exactly one row prompts, and it carries no edit of its own.
        let prompting = CalloutMenu.rows.filter(\.promptsForEmoji)
        #expect(prompting.count == 1)
        #expect(prompting[0].edit == nil)
    }

    /// **The pin that is RED on the pre-13k code:** Write's own context menu
    /// carries a "Callout" submenu, whose rows are the shared vocabulary.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `calloutMenuItem` wiring
    /// from `EditorViewModel.attach` and this test fails at its `#require` —
    /// the right-click has a Format submenu and no Callout one, which is
    /// exactly the state she reported.
    @Test func theEditorsRightClickCarriesTheCalloutSubmenu() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let event = NSEvent.mouseEvent(
                with: .rightMouseDown, location: NSPoint(x: 20, y: 20),
                modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
                eventNumber: 0, clickCount: 1, pressure: 1)!
            let menu = try #require(h.textView.menu(for: event))
            let callout = try #require(
                menu.items.first { $0.title == CalloutMenu.title },
                "the right-click must offer the Callout submenu (K6)")
            let submenu = try #require(callout.submenu)
            let rendered = submenu.items.filter { !$0.isSeparatorItem }.map(\.title)
            #expect(rendered == CalloutMenu.rowTitles)
            // It sits BESIDE Format, which stays exactly as it was.
            #expect(menu.items.contains { $0.title == MarkdownActs.menuTitle })
        }
    }

    /// The submenu ACTS — one click dispatches the row's edit through the
    /// caller's own route (P-2: a rendered door performs the act). Driven
    /// through the real `NSMenuItem` target, which is where the trampoline
    /// pattern's retention could silently fail.
    @Test func clickingARowDispatchesThatRowsEdit() throws {
        var seen: [CalloutEdit] = []
        let item = CalloutMenu.menuItem { seen.append($0) }
        let submenu = try #require(item.submenu)
        let rows = submenu.items.filter { !$0.isSeparatorItem }

        let toggle = try #require(rows.first { $0.title == "Toggle Callout" })
        _ = toggle.target?.perform(toggle.action, with: toggle)
        let green = try #require(rows.first { $0.title == "Green" })
        _ = green.target?.perform(green.action, with: green)
        let remove = try #require(rows.first { $0.title == "Remove Callout" })
        _ = remove.target?.perform(remove.action, with: remove)

        #expect(seen == [.toggle, .color("green"), .color(nil)])
    }

    /// The registry walk's own union already covers the new door; this names
    /// the two renderers explicitly so a future edit that drops one from a
    /// surface fails with its name rather than by set arithmetic.
    @Test func bothTextSurfacesDeclareTheDoorTheyRender() {
        #expect(EditorViewModel.contextMenuCapabilities.contains(.callout))
        #expect(TakesCellView.contextMenuCapabilities.contains(.callout))
    }
}

// MARK: - K5: ⏎ continues a list

/// Her ruling: *⏎ at the end of a texted list line mints the next lead; ⏎ on
/// an EMPTY list item removes the lead and exits the list.*
///
/// Every pin here drives a REAL Return key event through the real AppKit
/// interpretation path (the `ReturnKeyTraceTests` discipline — the whole
/// question is what the KEY does), because the continuation's safety claim
/// is precisely that `super.insertNewline` runs unchanged underneath it.
@MainActor
@Suite("K5 — ⏎ continues a list (13k)", .serialized)
struct ListContinuationTests {
    private static func returnEvent(shift: Bool, windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero,
            modifierFlags: shift ? .shift : [], timestamp: 0,
            windowNumber: windowNumber, context: nil,
            characters: "\r", charactersIgnoringModifiers: "\r",
            isARepeat: false, keyCode: 36)!
    }

    private static func host(_ view: NSView) -> (window: NSWindow, teardown: () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        return (window, {
            window.orderOut(nil)
            window.close()
        })
    }

    /// A texted bullet mints the next bullet, and the caret lands after it.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `.continueList` arm's lead
    /// insertion from `MarkdownActs.insertNewlineContinuingLists` and this
    /// test fails with `"- milk\n"` — the newline lands, the lead does not.
    @Test func aTextedBulletMintsTheNextLead() async throws {
        // MID-BLOCK deliberately (the document end is its own pin below —
        // since the 18c ladder's R1-1 it too stays in the block): one block
        // whose text already carries a second line, caret at the end of the
        // first.
        try await withEditor(seedBlocks: ["- milk\nsecond"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- milk\n- \nsecond")
            #expect(h.textView.selectedRange().location == 9)
            // I4: the newline and the lead are the block's CONTENT — the
            // structure is untouched, and one block is still one block.
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- \nsecond"])
        }
    }

    /// A checklist item continues UNCHECKED (QUESTIONS #49(h)'s rule:
    /// checking is the click).
    @Test func aTextedChecklistItemMintsAnUncheckedBox() async throws {
        try await withEditor(seedBlocks: ["- [x] milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 10, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- [x] milk\n- [ ] ")
        }
    }

    /// The exit half — the ONE place the keystroke is consumed: the lead
    /// goes and NO newline is inserted.
    ///
    /// DISCRIMINATING REVERT (verified): make the `.exitList` arm fall
    /// through to `ordinary()` and this test fails with `"- milk\n- \n"` —
    /// the empty item survives and the list never ends.
    ///
    /// **RE-POINTED (18c batch 2, her U-1): the exit now composes with the
    /// key's own act** — the lead goes, no newline is typed, and THEN the
    /// Return makes the block it makes anywhere else (the caret sits at the
    /// block's end once the lead is gone). The pin was
    /// `anEmptyListItemExitsTheListWithoutMakingALine`; the "line" it
    /// defends — no newline inside the block — is untouched, and the block
    /// below is the new half. §5.1: *"a second ⏎ on the empty item ends the
    /// list AND makes the block (the two intercepts compose in that
    /// order)."*
    @Test func anEmptyListItemExitsTheListAndThenTheKeyMakesTheBlock() async throws {
        try await withEditor(seedBlocks: ["- milk\n- "]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 9, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["- milk\n", ""],
                    "the lead went, no newline was typed, and the block below is U-1's")
            #expect(h.model.caretBlockID == h.model.index.entries[1].blockID)
            #expect(!h.model.hasOpenTail)
        }
    }

    /// **RETIRED BY NAME (18c ladder round 1, R1-1 — under her U-1):** this
    /// was `theDocumentEndTailGestureStillFiresAndTheLeadLandsInTheTail`,
    /// K5's pin that ⏎ at the exact document end "still opens the tail
    /// (Phase 7's ruling)" with the lead landing in the tail. U-1 retired
    /// that gesture from the key, and this door was the one road that still
    /// reached it — a list typed at a note's end went into the tail and
    /// crystallized ONE BLOCK PER ITEM, while the same list mid-note stayed
    /// one block. The continuation's newline now takes the soft road there:
    /// it lands as the last block's CONTENT, the lead follows it inside the
    /// block, and the list stays whole at the end exactly as it does in the
    /// middle (K5's own "in the same block").
    ///
    /// RED-ON-OLD (behavioural revert, recorded in the ladder record): drop
    /// the `.continueList` soft-road branch from `EditorTextView.insertNewline`
    /// and the first half fails with `hasOpenTail == true`.
    @Test func aListContinuationAtTheDocumentEndStaysInTheBlock() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail, "U-1: no key opens the tail — the list door included")
            #expect(h.model.index.entries.count == 1)
            #expect(h.documentText == "- milk\n- ")
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- "],
                    "the newline and the lead are the block's content (I4), stored")

            // …and the list keeps growing in that one block: the next item's
            // ⏎ is an ordinary mid-block continuation, no tail, no mint.
            h.textView.insertText("eggs", replacementRange: h.textView.selectedRange())
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()
            #expect(!h.model.hasOpenTail)
            #expect(h.model.index.entries.count == 1, "one block per LIST, never per item")
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- eggs\n- "])
        }
    }

    /// `one_block`'s newlines-don't-mint is untouched: the newline AND the
    /// lead are content of the one block.
    @Test func oneBlockKeepsBothTheNewlineAndTheLeadAsContent() async throws {
        try await withEditor(profile: .journal, seedBlocks: ["- milk"]) { h in
            #expect(h.model.header?.effectiveSegmentation == .oneBlock)
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail)
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- "])
        }
    }

    /// **⇧⏎ is a different gesture and stays byte-identical** (A15): its
    /// newline lands inside the block and NO lead follows it.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `isSoftNewline` guard from
    /// `EditorTextView.insertNewline` and this test fails with
    /// `"- milk\n- "` — ⇧⏎ starts sprouting bullets.
    @Test func shiftReturnNeverContinuesTheList() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail)  // A15/B1, unchanged
            #expect(h.documentText == "- milk\n")
            #expect(try h.storeSlots().map(\.text) == ["- milk\n"])
        }
    }

    /// A SEALED note refuses the whole keystroke in its own words, with no
    /// new refusal code — the lead rides the same `shouldChangeText` verdict
    /// the newline does, so a refused newline can never be led.
    @Test func aSealedNoteRefusesTheContinuationWithoutTouchingAByte() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            _ = try h.session.operations.lockPost(h.postID)
            try h.reload()
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- milk")
            #expect(try h.storeSlots().map(\.text) == ["- milk"])
        }
    }

    /// **⌘Z takes back the keystroke she pressed, not half of it** — the
    /// brief's own edge, pinned as BEHAVIOUR.
    ///
    /// **REVERT MEASURED, AND IT DOES NOT DISCRIMINATE — recorded rather
    /// than claimed (13k batch 1, revert G).** Dropping the explicit
    /// `beginUndoGrouping`/`endUndoGrouping` pair around the newline and the
    /// lead leaves this test GREEN, because `NSUndoManager.groupsByEvent` is
    /// on by default: both edits happen inside ONE key event, so AppKit's
    /// own per-event group already contains them. The explicit group is
    /// therefore redundant TODAY and is kept deliberately — it states the
    /// intent at the one place that owns it and does not depend on an AppKit
    /// default staying true — but this pin proves the BEHAVIOUR, not that
    /// mechanism, and the hallucination guard says say so.
    @Test func oneUndoTakesBackBothTheNewlineAndTheLead() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "- milk\n- ")

            let undoManager = try #require(h.textView.undoManager)
            undoManager.undo()
            #expect(h.documentText == "- milk")
        }
    }

    /// Ordinary prose sees NO LIST DOOR — that is what this pin defends, and
    /// it is untouched. **RE-POINTED (18c batch 2, her U-1):** what the key
    /// then does on plain prose is no longer a content newline but the
    /// ruling's own act — a divide at the caret, through the one snapping
    /// rule. No lead is inserted anywhere, which is the list door's whole
    /// claim here.
    @Test func plainProseSeesNoListLeadAndTakesTheKeysOwnRoad() async throws {
        try await withEditor(seedBlocks: ["alpha beta"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 5, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha", "beta"], "U-1's divide, and no bullet in sight")
            #expect(!h.documentText.contains("- "))
        }
    }

    /// A take pane gets the same rule (R118 — Write is never privileged over
    /// Takes), and its ⇧⏎ is excluded the same way.
    @Test func aTakePaneContinuesListsToo() throws {
        let view = PaneTextView.makeTakeSurface()
        view.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
        view.isEditable = true
        let hosted = Self.host(view)
        defer { hosted.teardown() }
        hosted.window.makeFirstResponder(view)

        view.string = "- milk"
        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(
            with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n- ")

        // The empty item exits.
        view.keyDown(
            with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n")

        // ⇧⏎ stays a plain newline.
        view.string = "- milk"
        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(
            with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n")
    }
}

// MARK: - K8: Tab indents a list line

/// **13k K8 — indented (nested) lists.** Her ruling: *"we should allow
/// indented lists and it should happen when you click tab"*; sitting Q3 gave
/// ⇧Tab and the two Format rows the way back.
///
/// The arithmetic is pinned in the core suite (`MarkdownNestedListTests`).
/// What is pinned HERE is everything that only exists in the app: the two
/// keys through real key events on both surface kinds, the promise that Tab
/// OUTSIDE a list line is byte-for-byte the key it always was, the ordinary
/// pipeline carrying the edit into the store, and the registry declarations
/// (keyless, and NOT on the toolbar).
@MainActor
@Suite("K8 — Tab indents a list (13k)", .serialized)
struct NestedListDoorTests {

    private static func returnEvent(windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero,
            modifierFlags: [], timestamp: 0,
            windowNumber: windowNumber, context: nil,
            characters: "\r", charactersIgnoringModifiers: "\r",
            isARepeat: false, keyCode: 36)!
    }

    private static func tabEvent(shift: Bool, windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero,
            modifierFlags: shift ? .shift : [], timestamp: 0,
            windowNumber: windowNumber, context: nil,
            characters: shift ? "\u{19}" : "\t",
            charactersIgnoringModifiers: shift ? "\u{19}" : "\t",
            isARepeat: false, keyCode: 48)!
    }

    private static func host(_ view: NSView) -> (window: NSWindow, teardown: () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        return (window, {
            window.orderOut(nil)
            window.close()
        })
    }

    /// DISCRIMINATING REVERT: make `MarkdownActs.indentLists` always call
    /// `ordinary()` and this fails — Tab types a tab character into the list
    /// line instead of indenting it.
    @Test func tabIndentsAndShiftTabOutdentsThroughTheRealKeystroke() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "  - milk")
            h.textView.keyDown(
                with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "    - milk", "one unit per press")

            h.textView.keyDown(
                with: Self.tabEvent(shift: true, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "  - milk")
            await h.flush()
            // The ordinary pipeline all the way into the store — no operation,
            // no schema: the spaces are ordinary content she typed.
            #expect(try h.storeSlots().map(\.text) == ["  - milk"])
        }
    }

    /// **The byte-unchanged promise, as a pin.** Outside a list line the key
    /// is AppKit's own — here, the tab character it has always typed.
    ///
    /// DISCRIMINATING REVERT: drop `indentLists`' empty-plan fallthrough (act
    /// unconditionally) and this fails — Tab would silently do nothing in
    /// prose, which is a dead key in the one place the key already had a
    /// meaning.
    @Test func tabOutsideAListLineIsTheKeyItAlwaysWas() async throws {
        try await withEditor(seedBlocks: ["ordinary prose"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 8, length: 0))
            h.textView.keyDown(
                with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "ordinary\t prose",
                    "AppKit's own insertTab — a literal tab, exactly as before")
        }
    }

    /// A SEALED note refuses it in its own words, with no new refusal code —
    /// the indent rides the same `shouldChangeText` verdict every other
    /// formatting act does.
    @Test func aSealedNoteRefusesTheIndentWithoutTouchingAByte() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            _ = try h.session.operations.lockPost(h.postID)
            try h.reload()
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()
            #expect(h.documentText == "- milk")
            #expect(try h.storeSlots().map(\.text) == ["- milk"])
        }
    }

    /// **⏎ at depth, through the real keystroke:** a nested item continues at
    /// its own level, and an EMPTY nested item OUTDENTS before it exits (the
    /// architect's ruling on this batch's proposal — at level 0 K5's ruling is
    /// byte-identical, which the K5 suite above still pins).
    @Test func returnAtDepthContinuesThenOutdentsThenExits() async throws {
        try await withEditor(seedBlocks: ["- milk\n  - almond"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            let press = { h.textView.keyDown(
                with: Self.returnEvent(windowNumber: hosted.window.windowNumber)) }

            press()
            #expect(h.documentText == "- milk\n  - almond\n  - ", "same level")
            press()
            #expect(h.documentText == "- milk\n  - almond\n- ", "outdent first")
            press()
            #expect(h.documentText == "- milk\n  - almond\n", "then exit")
        }
    }

    /// R118 parity: a take pane does all of it too — a list behaves the same
    /// wherever she is typing.
    @Test func aTakePaneIndentsAndOutdentsTheSameWay() throws {
        let view = PaneTextView.makeTakeSurface()
        view.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
        view.isEditable = true
        let hosted = Self.host(view)
        defer { hosted.teardown() }
        hosted.window.makeFirstResponder(view)

        view.string = "- milk"
        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "  - milk")
        view.keyDown(with: Self.tabEvent(shift: true, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk")

        // …and outside a list it is AppKit's key here too.
        view.string = "prose"
        view.setSelectedRange(NSRange(location: 5, length: 0))
        view.keyDown(with: Self.tabEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "prose\t")
    }

    /// The declarations (P-1): keyless BY DESIGN, on the two menus, and
    /// deliberately NOT on the bottom bar's toolbar.
    @Test func theNestingActsAreDeclaredKeylessAndOffTheToolbar() {
        for id in [CapabilityID.formatIndent, .formatOutdent] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.menuBar, .contextMenu])
            #expect(!capability.doors.contains(.bottomBar),
                    "\(id): Tab is the primary door; the bar is already eight wide")
            #expect(capability.shortcutLabel == nil,
                    "declaring ⇥ would force a menu key equivalent and steal Tab app-wide")
            #expect(EditorCommands.keyEquivalent(for: id) == nil)
            #expect(capability.takesAccess == .native)
            #expect(!FormatBar.renderedCapabilities.contains(id))
        }
        #expect(MarkdownActs.indentRows.map(\.id) == [.formatIndent, .formatOutdent])
        #expect(MarkdownActs.contextMenuCapabilities.contains(.formatIndent))
        #expect(MarkdownActs.contextMenuCapabilities.contains(.formatOutdent))
    }

    /// The helper carries BOTH doors in prose — the registry's drift guard
    /// cannot see a keyless act, so the written line is the only guard there
    /// is (WT-1's lesson).
    @Test func theHelperNamesTabAndTheMenuRows() {
        let prose = HelperView.groups
            .flatMap { $0.items }
            .map { "\($0.0) \($0.1)" }
            .joined(separator: "\n")
            .lowercased()
        #expect(prose.contains("indent"))
        #expect(prose.contains("outdent"))
        #expect(prose.contains("tab"))
    }
}
