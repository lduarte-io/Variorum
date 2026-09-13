//
//  ConfirmationsSettingTests.swift
//  VariorumTests
//
//  **18i — THE CONFIRMATIONS SETTING** (her ruling R-Q5, the 2026-09-12
//  use-report round; her words: *"there's these little text confirmation
//  popups that are always appearing… i either need them off, more subtle in
//  the bottom bar in more muted text, or a setting if i can turn it on or
//  off"*, and on the default: *"Quiet should be the default, but toast
//  should still be an option"*).
//
//  `StatusCenterTests` pins the SEAM — which slot each kind lands in under
//  each setting. THIS suite pins the classification BY BEHAVIOUR, through
//  two real doors driven the way she drives them: the seam backspace that
//  joins two blocks (her image 6) and the newlines chip (her image 7). It is
//  the brief's "pin by BEHAVIOUR on two representative doors" — a grep over
//  the source would prove a spelling, not a behaviour.
//
//  RED ON OLD (by behavioural revert of the two SITES — `showReceipt` back
//  to `showStatus`, which is exactly what they said before 18i): the receipt
//  lands as a TOAST under `.quiet`. The numbers are in the batch record.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The confirmations setting — the doors (18i, R-Q5)", .serialized)
struct ConfirmationsSettingTests {
    private static let joinReceipt = "Blocks joined — \u{2325}\u{2318}Z undoes it."

    private func hosted(_ h: EditorHarness) throws -> (window: NSWindow, teardown: () -> Void) {
        let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
        hosted.window.makeFirstResponder(h.textView)
        return hosted
    }

    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    /// A real Delete key through `keyDown` — the road a seam backspace
    /// takes (`ReturnKeyTraceTests`' own helper, same reasoning: the
    /// question is what the KEY does).
    private func deleteKey(_ h: EditorHarness, _ window: NSWindow) {
        let event = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0,
            windowNumber: window.windowNumber, context: nil,
            characters: "\u{7F}", charactersIgnoringModifiers: "\u{7F}",
            isARepeat: false, keyCode: 51)!
        h.textView.keyDown(with: event)
    }

    /// Backspace at the seam between two texted blocks: they join, and the
    /// receipt says so. Shared by the three setting arms below so the
    /// GESTURE is written once and only the setting differs.
    private func joinAtTheSeam(_ h: EditorHarness) async throws {
        let window = try hosted(h)
        defer { window.teardown() }
        caret(h, entry: 1, offset: 0)
        deleteKey(h, window.window)
        await h.flush()
        for _ in 0..<400 where h.model.statusMessage == nil {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    // MARK: - Her image 6: the seam backspace's join

    /// **HER DEFAULT.** The join lands, and its confirmation is a muted line
    /// in the bottom bar — no toast over the prose.
    @Test func theSeamJoinSpeaksQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .quiet
            try await joinAtTheSeam(h)

            #expect(try h.storeSlots().count == 1, "the blocks really joined")
            #expect(h.session.status.current == nil, "NO TOAST — this is the whole row")
            #expect(h.session.status.quietLine?.text == Self.joinReceipt,
                    "…the bar's quiet line carries her words, unchanged")
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.model.statusMessage == Self.joinReceipt,
                    "the model's tested property is untouched by the routing")
        }
    }

    /// **TOAST STAYS AN OPTION** (her words). The same gesture, the old face.
    @Test func theSameJoinToastsWhenSheAsksForToasts() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .toast
            try await joinAtTheSeam(h)

            #expect(h.session.status.current?.text == Self.joinReceipt)
            #expect(h.session.status.quietLine == nil)
        }
    }

    /// **OFF MEANS OFF** — and the receipt still REACHED the centre, so the
    /// door is speaking and the setting is swallowing (not a door gone
    /// silent by accident).
    @Test func theSameJoinSaysNothingWhenConfirmationsAreOff() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .off
            try await joinAtTheSeam(h)

            #expect(try h.storeSlots().count == 1, "the act still lands")
            #expect(h.session.status.current == nil && h.session.status.quietLine == nil)
            #expect(h.session.status.lastDroppedReceipt == Self.joinReceipt)
        }
    }

    // MARK: - Her image 7: the newlines chip

    /// The chip's sentence is a RECEIPT of a toggle that landed — quiet by
    /// default, with the words untouched.
    @Test func theNewlinesChipSpeaksQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["alpha."]) { h in
            h.session.status.receiptStyle = .quiet
            await h.model.setNewlinesMintBlocks(false)

            #expect(h.session.status.current == nil, "no toast")
            #expect(h.session.status.quietLine?.text == SegmentationFaceCopy.mintOffNote,
                    "the chip's own sentence, byte-unchanged")
            #expect(h.session.status.quietLine?.kind == .receipt)
        }
    }

    // MARK: - What the setting must NEVER reach

    /// **A REFUSAL IS NOT A CONFIRMATION.** With receipts OFF — the most
    /// aggressive setting she can choose — a door that could not act still
    /// delivers the operations layer's real refusal, as a toast (P-2,
    /// fire-and-DO). This is the guard that makes the setting safe to
    /// default to something other than `toast`.
    @Test func aRefusalStillToastsWithConfirmationsOff() async throws {
        try await withEditor(seedBlocks: []) { h in
            h.session.status.receiptStyle = .off
            await h.model.commitCaret()  // no caret block: the real refusal

            #expect(h.session.status.current?.text == "Place the caret in a block to commit.")
            #expect(h.session.status.current?.kind == .refusal)
            #expect(h.session.status.quietLine == nil)
            #expect(h.session.status.lastDroppedReceipt == nil, "nothing was dropped")
        }
    }

    // MARK: - A door that did nothing says so (the ladder's BLOCKER, J29)

    /// The standing async-poll rule (never a sync RunLoop pump from an async
    /// context). `NoteDeletion.fire` is a detached `Task`, so its outcome
    /// arrives a turn or more later.
    private func settleStatus(_ predicate: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if predicate() { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// **A DELETE THAT DELETED NOTHING STILL SPEAKS** (the 18i ladder round
    /// 1's BLOCKER — J29). `NoteDeletion.run` has FOUR outcomes and three of
    /// them report that nothing happened: the empty gesture, the scraps kind
    /// fence, and this one — the race where every named note was already
    /// tombstoned (a double-press, a second window, a stale list, a pull that
    /// landed the tombstones). The copy's own doc says it in words:
    /// *"Nothing happened, so this is a refusal's voice, not a receipt's."*
    ///
    /// They were all handed to `receipt(…)`, so her setting could hide them —
    /// and the four doors that fire this act (the Library, the Pool, Archived
    /// and both `note ▾` menus) mount NO bottom bar, so under her own default
    /// "quiet" was already silence, and `off` dropped them outright.
    ///
    /// **Red on old:** `current == nil`, with the words sitting in
    /// `lastDroppedReceipt`.
    @Test func aDeleteThatDeletedNothingStillSpeaks() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            h.session.status.receiptStyle = .off
            let dead = try h.session.operations.createPost(title: "gone already").id
            try h.session.operations.deleteContainer(dead)

            NoteDeletion.fire(session: h.session, postIDs: [dead])
            await settleStatus {
                h.session.status.current != nil || h.session.status.lastDroppedReceipt != nil
            }

            #expect(h.session.status.current?.text == RecoveryCopy.notesAlreadyGone(1))
            #expect(h.session.status.current?.kind == .refusal)
            #expect(h.session.status.lastDroppedReceipt == nil,
                    "nothing was dropped — this was never a receipt")
        }
    }

    /// The Act-7 kind fence is the BELT behind `CommitBar`'s braces, and a
    /// belt that speaks only where a bar happens to be mounted is not one.
    /// Under HER DEFAULT the scraps refusal must still be a toast.
    @Test func theScrapsFenceStillSpeaksUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            h.session.status.receiptStyle = .quiet
            let pool = try h.session.operations.createPool(title: "scraps").id

            NoteDeletion.fire(session: h.session, postIDs: [pool])
            await settleStatus {
                h.session.status.current != nil || h.session.status.quietLine != nil
            }

            #expect(h.session.status.current?.text == RecoveryCopy.notADeletableNote)
            #expect(h.session.status.current?.kind == .refusal)
            #expect(h.session.status.quietLine == nil,
                    "a refusal never rides the quiet slot, under any setting")
        }
    }

    /// **AN IMPORT THAT IMPORTED NOTHING SAYS SO** (the same BLOCKER's second
    /// member — J29). An EMPTY `.md` is read fine and then refused by the
    /// operation (`emptyImport`), so it is collected as a SKIP: `imported`
    /// is 0, `lastError` is explicitly nil, and the report names only skips.
    /// That reports a no-op, and it fires from the Library, which mounts no
    /// bottom bar — so under her default it was said to nobody.
    ///
    /// **Red on old** (behavioural revert — the predicate is new API, so the
    /// honest red is the predicate forced to `false`, the pre-J29 behaviour
    /// where every import report was a receipt).
    @Test func anImportThatImportedNothingIsARefusal() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            let dir = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("variorum-18i-import-\(UUID().uuidString)")
            try FileManager.default.createDirectory(
                at: dir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: dir) }
            let empty = dir.appendingPathComponent("empty.md")
            try Data().write(to: empty)

            let importer = ImportModel(session: h.session)
            await importer.importFiles([empty], into: .library)

            #expect(importer.lastError == nil,
                    "the gesture did not FAIL — it landed nothing, which is a different thing")
            #expect(importer.lastReport?.contains("Skipped") == true,
                    "the report names only skips: \(importer.lastReport ?? "nil")")
            #expect(importer.lastReportIsRefusal,
                    "nothing arrived, so nothing landed — it is a refusal's voice")

            // …and one that DID import is a receipt, so the predicate is not
            // simply always true.
            let real = dir.appendingPathComponent("real.md")
            try "A paragraph.".write(to: real, atomically: true, encoding: .utf8)
            await importer.importFiles([real], into: .library)
            #expect(importer.lastReportIsRefusal == false)
            #expect(importer.lastReport?.contains("Imported 1 note") == true)
        }
    }

    /// **AN EXPORT THAT WROTE NO FILE SAYS SO** (J37 — the import predicate's
    /// twin). A store with nothing to export still said *"Exported 0 files."*
    /// as a confirmation. Same rule, same shape, one line apart.
    @Test func anExportThatWroteNothingIsARefusal() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            try h.session.operations.deleteContainer(h.postID)  // nothing left to export
            let dir = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("variorum-18i-export-\(UUID().uuidString)")
            try FileManager.default.createDirectory(
                at: dir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: dir) }

            let exporter = ExportModel(session: h.session)
            await exporter.writeBulkExport(to: dir)

            #expect(exporter.lastError == nil)
            #expect(exporter.lastReport == "Exported 0 files.")
            #expect(exporter.lastReportIsRefusal, "no file was written — nothing landed")
        }
    }

    // MARK: - Found ON THE WALK, round 2 (the J38 class, other direction)

    /// **⌘⇧S's RECEIPT IS A RECEIPT** — found on the round-2 walk, which
    /// captured it toasting over the book's Outline while her setting said
    /// quiet. `EditorViewModel.saveNoteVersion`'s SUCCESS arm spoke through
    /// `showStatus` — the always-shown refusal door — so the one door whose
    /// twin two files over (`TakesViewModel:1775`) is a `.receipt` behaved
    /// differently on Write and the book's inline editor than on the boards,
    /// and kept toasting under the default she chose to stop the toasting.
    ///
    /// Same class as the round-2 BLOCKER, opposite direction: there a refusal
    /// wore a receipt's clothes and could be hidden; here a receipt wears a
    /// refusal's and cannot be quieted. The error arm stays `showStatus`.
    ///
    /// **Red on old:** the sentence in `current`, `quietLine == nil`.
    @Test func savingAVersionSpeaksQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["A note worth keeping."]) { h in
            h.session.status.receiptStyle = .quiet

            await h.model.saveNoteVersion()

            #expect(h.session.status.current == nil, "no toast — this is the row")
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.session.status.quietLine?.text.hasPrefix("Saved a version") == true,
                    "the words are untouched: \(h.session.status.quietLine?.text ?? "nil")")
        }
    }

    // MARK: - Write's own acts obey her setting too (the round-3 BLOCKER, J43)

    /// **SEALING A NOTE IS AN ACT THAT LANDED** (the 18i ladder round 3's
    /// BLOCKER — J43). Eight Write doors reported acts through `showStatus`,
    /// which is `setStatusMessage(_, kind: .refusal)` — the ALWAYS-SHOWN
    /// door — so sealing, archiving a take, saving a lens, a pool drop, a new
    /// take, a word target and an entry date all kept throwing the card she
    /// asked to stop seeing, and kept throwing it under `off`, where the
    /// Settings pane prints "Nothing: they stay unsaid."
    ///
    /// Three arms: her default, a second door, and `off` — where the receipt
    /// must REACH the centre and be dropped, not vanish before it.
    ///
    /// **Red on old:** the sentence in `current` with `kind: .refusal`,
    /// `quietLine == nil`.
    @Test func writesOwnActsSpeakQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            h.session.status.receiptStyle = .quiet

            h.model.toggleSeal()
            await settleStatus {
                h.session.status.quietLine != nil || h.session.status.current != nil
            }

            #expect(h.session.status.current == nil, "no toast — this is the row")
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.session.status.quietLine?.text
                    == "Sealed — the note is read-only until unsealed.",
                    "her words, unchanged: \(h.session.status.quietLine?.text ?? "nil")")
        }
    }

    /// The second door, so the pin is a CLASS pin and not one site's.
    @Test func archivingATakeFromWriteSpeaksQuietlyToo() async throws {
        try await withEditor(seedBlocks: ["Alpha.", "Beta."]) { h in
            // A block keeps at least one take (I10), so the door only ACTS on
            // a fanned block — branch one, then archive it.
            let slot = try #require(try h.storeSlots().first)
            let second = try h.session.operations.branchVariant(
                slot.blockID, from: try #require(slot.variantID))
            try h.session.operations.chooseVariant(slot.blockID, variantID: second.id)
            try h.reload()
            h.session.status.receiptStyle = .quiet
            caret(h, entry: 0, offset: 1)

            h.model.archiveCaretTake()
            await settleStatus {
                h.session.status.quietLine != nil || h.session.status.current != nil
            }

            #expect(h.session.status.current == nil)
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.session.status.quietLine?.text.hasPrefix("Take archived") == true,
                    "\(h.session.status.quietLine?.text ?? "nil")")
        }
    }

    /// **AND `off` MEANS OFF ON WRITE'S DOORS TOO** — the receipt reaches the
    /// centre and is dropped there, which is what makes the pane's sentence
    /// true; a refusal from the same surface still toasts beside it.
    @Test func writesOwnActsSayNothingWhenConfirmationsAreOff() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            h.session.status.receiptStyle = .off

            h.model.toggleSeal()
            await settleStatus { h.session.status.lastDroppedReceipt != nil }

            #expect(h.session.status.current == nil && h.session.status.quietLine == nil)
            #expect(h.session.status.lastDroppedReceipt
                    == "Sealed — the note is read-only until unsealed.",
                    "it REACHED the centre and was dropped — not a door gone accidentally silent")
        }
    }

    // MARK: - The one predicate that keeps a no-op split a refusal (J32)

    /// **"MAKE EVERY NEWLINE A BLOCK" ON A NOTE THAT ALREADY IS** (the ladder
    /// round 1, MINOR-2 — J32). `SplitAtNewlinesCopy.acted` is the ONE guard
    /// that keeps a split which split nothing a REFUSAL, and it shipped with
    /// four consumers and zero pins: the three shipped pins on this copy
    /// assert `model.statusMessage`, which is written on BOTH roads, so a
    /// reverted `acted` left every one of them green. That missing axis is
    /// exactly how the round's BLOCKER got through a green suite.
    ///
    /// The BLOCK door is the reachable no-op road (the note door refuses
    /// before its flight); under `.off` her press must still answer.
    ///
    /// **Red on old** (behavioural revert — `acted` forced to `true`, the
    /// reading where a no-op split is a confirmation).
    @Test func aSplitThatSplitNothingStillSpeaks() async throws {
        try await withEditor(seedBlocks: ["One.", "Two."]) { h in
            h.session.status.receiptStyle = .off
            caret(h, entry: 0, offset: 1)

            await h.model.splitCaretBlockAtNewlines()

            #expect(h.session.status.current?.text == SplitAtNewlinesCopy.blockAlreadyWhole)
            #expect(h.session.status.current?.kind == .refusal,
                    "nothing happened — P-2 says she sees it whatever the setting")
            #expect(h.session.status.lastDroppedReceipt == nil, "nothing was dropped")
            let slots = try h.storeSlots()
            #expect(slots.count == 2, "and nothing was written")
        }
    }

    /// The other side of the same predicate: a split that DID split is a
    /// receipt, so it lands in the bar's quiet line under her default.
    @Test func aSplitThatSplitLandsQuietly() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo."]) { h in
            h.session.status.receiptStyle = .quiet

            await h.model.splitEveryNewlineIntoBlocks()

            let slots = try h.storeSlots()
            #expect(slots.count == 2, "it really split")
            #expect(h.session.status.current == nil, "no toast under her default")
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.session.status.quietLine?.text.contains("2 blocks from 1 block") == true,
                    "the split's own arithmetic, in the muted line: \(h.session.status.quietLine?.text ?? "nil")")
        }
    }

    // MARK: - The quiet slot itself (a mounted geometry oracle)

    /// **THE SLOT TAKES NO ROOM WHEN THERE IS NOTHING TO SAY** — and the
    /// words when there is. That is the layout claim the bars depend on: a
    /// receipt must not widen the bar or push a count, and six seconds later
    /// the room must go back. Only a mount can answer it, so this is a real
    /// `NSHostingView` measured three times: idle, speaking, idle again.
    ///
    /// What it deliberately does NOT claim: that the view is permanently
    /// mounted (an inserted-and-removed slot would measure the same). That
    /// is an implementation choice, stated in `QuietReceiptLine`'s own doc
    /// with its reason; the LOOK and the PLACE in each of the three bars are
    /// walked, not pinned — the rig cannot mount a whole bar (KnownIssues).
    ///
    /// **The HEIGHT is pinned too** (the 18i ladder round 1, MINOR-1 — J31):
    /// the shipped oracle asserted width three times and height never, so the
    /// vertical composition's reservation was unpinned in BOTH directions —
    /// nothing caught that the note-box footer permanently carries a blank
    /// row, and nothing would have caught someone collapsing it. Both are
    /// asserted now, because "nothing moves for it" is the claim every bar
    /// depends on and it is a claim about height, not only width.
    @Test func theQuietSlotIsWeightlessUntilItSpeaks() async throws {
        let center = StatusCenter()
        center.receiptStyle = .quiet
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let host = NSHostingView(
            rootView: QuietReceiptLine(status: center, tokens: tokens))
        host.frame = NSRect(x: 0, y: 0, width: 420, height: 24)
        let window = NSWindow(
            contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        defer { window.orderOut(nil); window.close() }

        // The VERTICAL composition — the book's sidebar note-box footer, in
        // its real ~200 pt column.
        //
        // **WIDTH-CONSTRAINED, and that is the whole point** (the 18i ladder
        // round 2's MAJOR — J39): `NSHostingView.fittingSize` is the
        // UNCONSTRAINED ideal size and the host's frame does not constrain
        // it, so the round-1 version of this oracle measured the receipt at
        // 204 pt of width in a 200 pt column and reported a stable 14 pt
        // height for every string at every `lines` value — a pin that could
        // not fail on the axis it named. The `.frame(width:)` on the ROOT is
        // what makes the measurement the one the box actually performs.
        let boxHost = NSHostingView(
            rootView: QuietReceiptLine(status: center, tokens: tokens)
                .frame(width: 200))
        boxHost.frame = NSRect(x: 0, y: 0, width: 200, height: 40)
        let boxWindow = NSWindow(
            contentRect: boxHost.frame, styleMask: [.titled], backing: .buffered, defer: false)
        boxWindow.isReleasedWhenClosed = false
        boxWindow.contentView = boxHost
        defer { boxWindow.orderOut(nil); boxWindow.close() }

        /// The standing async-poll rule (never a sync RunLoop pump from an
        /// async context — Swift 6 makes that unavailable, and it is the
        /// repo's rule anyway).
        func settleLayout(until predicate: () -> Bool) async {
            for _ in 0..<60 {
                host.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                boxHost.layoutSubtreeIfNeeded()
                boxWindow.layoutIfNeeded()
                boxWindow.displayIfNeeded()
                if predicate() { return }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
        }

        await settleLayout { host.fittingSize.width == 0 }
        #expect(host.fittingSize.width == 0,
                "idle: the slot is mounted and takes NO width — nothing reflows")
        let idleHeight = host.fittingSize.height
        let idleBoxHeight = boxHost.fittingSize.height
        #expect(idleBoxHeight > 0,
                "…but ONE LINE'S HEIGHT, reserved deliberately so the counts and the `?` door never move when a receipt lands (J31)")

        center.receipt("Blocks joined — \u{2325}\u{2318}Z undoes it.")
        await settleLayout { host.fittingSize.width > 0 }
        #expect(host.fittingSize.width > 0, "speaking: the words are there")
        #expect(host.fittingSize.height == idleHeight,
                "the flat bar's row NEVER changes height for it")
        #expect(boxHost.fittingSize.height == idleBoxHeight,
                "…and the box's column holds exactly the room it already had — at ITS width, where this sentence measures 204 pt and would otherwise wrap")

        center.clear()
        await settleLayout { host.fittingSize.width == 0 }
        #expect(host.fittingSize.width == 0, "and the room goes back")
        #expect(boxHost.fittingSize.height == idleBoxHeight,
                "the reservation is stable across the whole cycle")
    }

    /// **A REFUSAL NEVER REACHES THE QUIET SLOT** — even under `.quiet`, so
    /// the bar can never hold a refusal she would only see by looking down.
    @Test func theQuietSlotNeverHoldsARefusal() async throws {
        let center = StatusCenter()
        center.receiptStyle = .quiet
        center.speak("Click into a block first.")
        #expect(center.quietLine == nil)
        #expect(center.current?.text == "Click into a block first.")
    }

    /// **A DIRECTION RIDES THE REFUSAL CLASS** (the brief's letter: the undo
    /// hint is a direction, not a receipt). ⌘Z with nothing on the text
    /// stack and something on the structural one points at the other chord —
    /// and she must see it whatever her confirmations setting says.
    @Test func theUndoHintIsADirectionAndAlwaysShows() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .off
            // A structural act, so the structural stack has an entry and
            // the text stack does not (the rewrite clears it by design).
            try await joinAtTheSeam(h)
            h.session.status.clear()

            h.model.speakUndoHint(.undo)
            let spoken = try #require(h.session.status.current?.text)
            #expect(spoken.contains("\u{2325}\u{2318}Z"), "it names the chord that CAN: \(spoken)")
            #expect(h.session.status.current?.kind == .refusal,
                    "a direction is not a confirmation — it always shows")
        }
    }
}
