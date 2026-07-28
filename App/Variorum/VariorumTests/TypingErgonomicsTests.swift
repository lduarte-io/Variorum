//
//  TypingErgonomicsTests.swift
//  VariorumTests
//
//  13d batch 4 — the typing-ergonomics floor's Mac-side pins: A14 (⌘⇧⏎
//  mints a new block), A16's honesty half (what a post SAYS when it is
//  turned back on under a global one_block), A23 (the paragraph gap) and
//  A24 (spellcheck levels). A15 is traced and pinned separately in
//  `ReturnKeyTraceTests`.
//

import AppKit
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - A14: ⌘⇧⏎ = new block

@MainActor
@Suite("A14 — ⌘⇧⏎ mints a new block (13d batch 4)")
struct NewBlockShortcutTests {
    /// Her row, verbatim: *"⌘⇧Enter = new block"*. The act is 13b 4D's
    /// `insertBlockBelow` (native in Write, Takes and Lenses); this is its
    /// declared key.
    @Test func insertBlockBelowDeclaresCommandShiftReturnAndTheMenuWiresIt() {
        #expect(CapabilityRegistry.capability(.insertBlockBelow).shortcutLabel == "⌘⇧⏎")
        let key = EditorCommands.keyEquivalent(for: .insertBlockBelow)
        #expect(key?.0.character == KeyEquivalent.return.character)
        #expect(key?.1 == EventModifiers([.command, .shift]))
    }

    /// THE COLLISION SWEEP, made permanent rather than performed once.
    /// The brief required a sweep before wiring A14's key; a one-time sweep
    /// protects today and nothing else, so it lives here: no two
    /// capabilities may claim the same chord. ⌘⏎ (Choose Take) and ⌘⇧⏎
    /// (New Block Below) are the two Return chords, and they differ.
    @Test func noTwoCapabilitiesClaimTheSameChord() {
        var claimed: [String: CapabilityID] = [:]
        for id in CapabilityID.allCases {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: id) else { continue }
            let chord = "\(modifiers.rawValue)|\(key.character)"
            #expect(claimed[chord] == nil,
                    "\(id) and \(claimed[chord].map(String.init(describing:)) ?? "-") share a chord")
            claimed[chord] = id
        }
        // Non-vacuity: the sweep really did look at a populated table, and
        // at BOTH Return chords in particular.
        #expect(claimed.count >= 20)
        let chooseTake = EditorCommands.keyEquivalent(for: .chooseTake)
        #expect(chooseTake?.0.character == KeyEquivalent.return.character)
        #expect(chooseTake?.1 == EventModifiers.command)
    }

    /// The retired ⌥⌘N is gone from the copy that NARRATES it, not just
    /// from the wiring (batch 1's judgment call 6: prose that contradicts
    /// the shipped surface is a regression).
    @Test func theRetiredKeyIsGoneFromTheCopyThatNamesTheDoor() {
        for copy in [SegmentationFaceCopy.mintOffNote, SegmentationFaceCopy.help] {
            #expect(copy.contains("⌘⇧⏎"))
            #expect(!copy.contains("⌥⌘N"))
        }
    }
}

// MARK: - A16: the global one_block face's honesty half

@MainActor
@Suite("A16 — the global one_block face (13d batch 4)")
struct GlobalSegmentationFaceTests {
    /// The per-post chip's note describes what the post NOW DOES, not what
    /// was asked for. Only reachable because this batch made the global
    /// settable, which is why this batch owns it.
    @Test func thePerPostNoteTellsTheTruthUnderAGlobalOneBlock() {
        #expect(SegmentationFaceCopy.note(asked: false, effectivelyMints: false)
            == SegmentationFaceCopy.mintOffNote)
        #expect(SegmentationFaceCopy.note(asked: true, effectivelyMints: true)
            == SegmentationFaceCopy.mintOnNote)
        // The case the global face creates: "on" clears the override, and
        // the post still doesn't mint because the GLOBAL says one_block.
        #expect(SegmentationFaceCopy.note(asked: true, effectivelyMints: false)
            == SegmentationFaceCopy.mintOnInheritsOffNote)
        #expect(SegmentationFaceCopy.mintOnInheritsOffNote != SegmentationFaceCopy.mintOnNote)
    }

    /// End to end through the Write bar's own setter: with the global at
    /// `one_block`, turning the post's chip back ON speaks the inherit note
    /// rather than promising blocks it will not mint.
    @Test func theWriteChipSpeaksTheInheritNoteUnderAGlobalOneBlock() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            try await h.session.runner.run { try $0.setDefaultSegmentation(.oneBlock) }
            // First take the post OFF explicitly, so turning it on is a
            // real change rather than a no-op.
            await h.model.setNewlinesMintBlocks(false)
            await h.model.setNewlinesMintBlocks(true)
            #expect(h.model.statusMessage == SegmentationFaceCopy.mintOnInheritsOffNote)

            // …and with the global back at paragraph, the ordinary note.
            try await h.session.runner.run { try $0.setDefaultSegmentation(.paragraph) }
            await h.model.setNewlinesMintBlocks(false)
            await h.model.setNewlinesMintBlocks(true)
            #expect(h.model.statusMessage == SegmentationFaceCopy.mintOnNote)
        }
    }
}

// MARK: - A23: the paragraph gap

@MainActor
@Suite("A23 — the paragraph-gap setting (13d batch 4)", .serialized)
struct ParagraphGapTests {
    /// Runs `body` with the gap setting forced, restoring it after.
    private func withGap<T>(_ gap: ParagraphGap, _ body: () throws -> T) rethrows -> T {
        let saved = UserDefaults.standard.string(forKey: ParagraphGap.settingKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: ParagraphGap.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: ParagraphGap.settingKey)
            }
        }
        UserDefaults.standard.set(gap.rawValue, forKey: ParagraphGap.settingKey)
        return try body()
    }

    @Test func standardIsTheDefaultAndAddsNothing() {
        let saved = UserDefaults.standard.string(forKey: ParagraphGap.settingKey)
        UserDefaults.standard.removeObject(forKey: ParagraphGap.settingKey)
        defer {
            if let saved { UserDefaults.standard.set(saved, forKey: ParagraphGap.settingKey) }
        }
        #expect(ParagraphGap.current == .standard)
        #expect(ParagraphGap.standard.extraSpacing(for: .systemFont(ofSize: 14)) == CGFloat(0))
    }

    /// "A blank line's worth": a whole line of the prose font ON TOP of the
    /// standard gap. Additive by design — an absolute "one line" would do
    /// nothing at all when inline comments already widen the gap past a
    /// line, i.e. a setting that silently does nothing in a shipped state.
    @Test func paragraphTallAddsAWholeLineOfTheProseFont() {
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let line = ParagraphGap.lineHeight(of: font)
        #expect(line > CGFloat(0))
        #expect(ParagraphGap.paragraphTall.extraSpacing(for: font) == line)

        let standard = withGap(.standard) { EditorDocument.baseParagraphStyle.paragraphSpacing }
        let tall = withGap(.paragraphTall) { EditorDocument.baseParagraphStyle.paragraphSpacing }
        #expect(tall > standard)
        #expect(tall - standard
            == ParagraphGap.lineHeight(of: EditorTypography.current.font))
    }

    /// PURE PRESENTATION: the setting must not reach the store. Both the
    /// export projection (which IS `renderedText`) and the store's own rows
    /// are byte-identical either way, and toggling writes nothing at all —
    /// no outbox row, no stamp.
    @Test func theGapChangesNoStoredByteAndNoExportedByte() async throws {
        try await withEditor(seedBlocks: ["alpha one", "beta two"]) { h in
            func snapshot() throws -> (export: String, outbox: Int, updated: [String]) {
                try h.database.read { db in
                    (try Queries.exportPost(db, postID: h.postID),
                     try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1,
                     try String.fetchAll(
                        db, sql: "SELECT updated_at FROM variant ORDER BY id"))
                }
            }
            let before = withGap(.standard) { try? snapshot() }
            let after = withGap(.paragraphTall) { try? snapshot() }
            let a = try #require(before)
            let b = try #require(after)
            #expect(a.export == b.export)
            #expect(a.outbox == b.outbox)
            #expect(a.updated == b.updated)
            // Non-vacuity: the export really carried the prose.
            #expect(a.export.contains("alpha one"))
        }
    }

    /// The chrome value CARRIES the gap — which is what makes a change
    /// re-apply through the app's one "presentation moved" gate instead of
    /// needing a second mechanism (P-3).
    @Test func theChromeGateNoticesAGapChange() {
        let plain = EditorSurfaceChrome(
            voice: .terminal, dark: false, inlineComments: false, paragraphGap: .standard)
        let tall = EditorSurfaceChrome(
            voice: .terminal, dark: false, inlineComments: false, paragraphGap: .paragraphTall)
        #expect(plain != tall)
    }
}

// MARK: - A24: spellcheck levels

/// Counts the spell-check property WRITES a level application makes, so the
/// write-gate can be pinned rather than asserted (the 13c A47c lesson: an
/// unguarded property write on a live TK2 surface is never free).
private final class CountingTextView: NSTextView {
    nonisolated(unsafe) var continuousWrites = 0
    nonisolated(unsafe) var correctionWrites = 0

    override var isContinuousSpellCheckingEnabled: Bool {
        get { super.isContinuousSpellCheckingEnabled }
        set {
            continuousWrites += 1
            super.isContinuousSpellCheckingEnabled = newValue
        }
    }

    override var isAutomaticSpellingCorrectionEnabled: Bool {
        get { super.isAutomaticSpellingCorrectionEnabled }
        set {
            correctionWrites += 1
            super.isAutomaticSpellingCorrectionEnabled = newValue
        }
    }
}

@MainActor
@Suite("A24 — spellcheck levels (13d batch 4)", .serialized)
struct SpellcheckLevelTests {
    private func withLevel<T>(_ level: SpellcheckLevel, _ body: () throws -> T) rethrows -> T {
        let saved = UserDefaults.standard.string(forKey: SpellcheckLevel.settingKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: SpellcheckLevel.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: SpellcheckLevel.settingKey)
            }
        }
        UserDefaults.standard.set(level.rawValue, forKey: SpellcheckLevel.settingKey)
        return try body()
    }

    /// The default is the FULL-DOCUMENT EDITOR's shipped posture — both
    /// flags off, "the author's prose should not be silently rewritten" —
    /// now unified across every TK2 surface.
    ///
    /// Recorded because the pins measured it: a bare NSTextView carries
    /// `isAutomaticSpellingCorrectionEnabled` = TRUE, and take panes never
    /// set it, so before this batch Write and the take boards DISAGREED
    /// about autocorrect. The setting's default closes that divergence
    /// toward Write; "check and correct" is now the deliberate way to ask
    /// for the other behaviour. Flagged for her walk.
    @Test func theDefaultIsTodaysShippedBehaviourOnEverySurface() {
        let saved = UserDefaults.standard.string(forKey: SpellcheckLevel.settingKey)
        UserDefaults.standard.removeObject(forKey: SpellcheckLevel.settingKey)
        defer {
            if let saved { UserDefaults.standard.set(saved, forKey: SpellcheckLevel.settingKey) }
        }
        #expect(SpellcheckLevel.current == .off)
        let (_, editor) = EditorTextView.makeEditor()
        #expect(!editor.isContinuousSpellCheckingEnabled)
        #expect(!editor.isAutomaticSpellingCorrectionEnabled)
        let inline = EditorTextView.makeInlineEditor()
        #expect(!inline.isContinuousSpellCheckingEnabled)
        #expect(!inline.isAutomaticSpellingCorrectionEnabled)
        // Panes joined the setting this batch — before it they set neither
        // flag and inherited NSTextView's defaults.
        let pane = PaneTextView.makeTakeSurface()
        #expect(!pane.isContinuousSpellCheckingEnabled)
        #expect(!pane.isAutomaticSpellingCorrectionEnabled)
        // The measured divergence this closes: untouched, AppKit hands a
        // text view autocorrect ON.
        let bare = NSTextView(frame: NSRect(x: 0, y: 0, width: 100, height: 50))
        #expect(bare.isAutomaticSpellingCorrectionEnabled,
                "AppKit's default — what take panes silently inherited before A24")
    }

    @Test func eachLevelMapsToTheFlagsItNames() {
        let view = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        SpellcheckLevel.checkWhileTyping.apply(to: view)
        #expect(view.isContinuousSpellCheckingEnabled)
        #expect(!view.isAutomaticSpellingCorrectionEnabled)
        SpellcheckLevel.checkAndCorrect.apply(to: view)
        #expect(view.isContinuousSpellCheckingEnabled)
        #expect(view.isAutomaticSpellingCorrectionEnabled)
        SpellcheckLevel.off.apply(to: view)
        #expect(!view.isContinuousSpellCheckingEnabled)
        #expect(!view.isAutomaticSpellingCorrectionEnabled)
    }

    /// The write gate: a same-level application writes NOTHING. Panes call
    /// `apply` on every SwiftUI update, so an ungated version would be a
    /// property write per update on a live TK2 surface.
    @Test func applyingTheSameLevelTwiceWritesNothingTheSecondTime() {
        let view = CountingTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        // Start from a KNOWN state — AppKit hands out autocorrect ON, so
        // "apply the top level to a fresh view" would already have written
        // nothing for that flag and the pin would have proved nothing.
        SpellcheckLevel.off.apply(to: view)
        view.continuousWrites = 0
        view.correctionWrites = 0

        SpellcheckLevel.checkAndCorrect.apply(to: view)
        let afterFirst = (view.continuousWrites, view.correctionWrites)
        #expect(afterFirst.0 == 1, "the level really changed both flags")
        #expect(afterFirst.1 == 1)
        SpellcheckLevel.checkAndCorrect.apply(to: view)
        #expect(view.continuousWrites == afterFirst.0, "a same-level apply writes nothing")
        #expect(view.correctionWrites == afterFirst.1)
    }

    @Test func surfacesBornUnderALevelCarryIt() {
        withLevel(.checkWhileTyping) {
            let (_, editor) = EditorTextView.makeEditor()
            #expect(editor.isContinuousSpellCheckingEnabled)
            #expect(!editor.isAutomaticSpellingCorrectionEnabled)
            let pane = PaneTextView.makeTakeSurface()
            #expect(pane.isContinuousSpellCheckingEnabled)
        }
    }

    /// TEXTKIT2 §3's crash class — and this pin FOUND something rather
    /// than confirming something. `isAutomaticTextCompletionEnabled` is
    /// TRUE by default on every surface in this app, so switching
    /// continuous checking on would have put each of them into the exact
    /// pairing §3 records as crashing NSTextView. `apply` now turns
    /// completion OFF whenever it turns checking ON (and restores AppKit's
    /// default at `.off`, so a round trip is a no-op).
    @Test func theHighestLevelNeverEnablesTheCompletionHalfOfTheCrashPairing() {
        withLevel(.checkAndCorrect) {
            let (_, editor) = EditorTextView.makeEditor()
            #expect(editor.isContinuousSpellCheckingEnabled)
            #expect(!editor.isAutomaticTextCompletionEnabled,
                    "TEXTKIT2 §3: continuous checking + the completion popover is the crash class")
            let inline = EditorTextView.makeInlineEditor()
            #expect(!inline.isAutomaticTextCompletionEnabled)
            let pane = PaneTextView.makeTakeSurface()
            #expect(!pane.isAutomaticTextCompletionEnabled)
        }
        // The round trip: back at `.off`, completion returns to AppKit's
        // default, so the setting never silently strips an affordance from
        // a Mac that tried a level and went back.
        let view = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        let born = view.isAutomaticTextCompletionEnabled
        SpellcheckLevel.checkWhileTyping.apply(to: view)
        #expect(!view.isAutomaticTextCompletionEnabled)
        SpellcheckLevel.off.apply(to: view)
        #expect(view.isAutomaticTextCompletionEnabled == born)
    }

    /// …and a real editing session at the highest level, on a real window,
    /// with the fallback canary armed: typing, selecting, and a structural
    /// gesture all survive it and TK2 never falls back.
    @Test func aRealSessionAtTheHighestLevelIsSurvivable() async throws {
        let saved = UserDefaults.standard.string(forKey: SpellcheckLevel.settingKey)
        UserDefaults.standard.set(
            SpellcheckLevel.checkAndCorrect.rawValue, forKey: SpellcheckLevel.settingKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: SpellcheckLevel.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: SpellcheckLevel.settingKey)
            }
        }
        do {
            try await withEditor(seedBlocks: ["The quik brown fox jumpd over."]) { h in
                SpellcheckLevel.checkAndCorrect.apply(to: h.textView)
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 600, height: 400),
                    styleMask: [.titled, .resizable], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                window.contentView = try #require(h.textView.enclosingScrollView)
                window.orderFrontRegardless()

                h.type(" wih speling erors", at: h.model.index.range(ofEntryAt: 0).upperBound)
                await h.flush()
                h.textView.setSelectedRange(NSRange(location: 0, length: 3))
                h.textView.setSelectedRange(NSRange(location: 0, length: 0))
                #expect(h.model.canaryMessage == nil)
                let stored = try h.storeSlots().first?.text
                #expect(stored?.hasSuffix("erors") == true)
            }
        }
    }
}
