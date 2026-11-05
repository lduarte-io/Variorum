//
//  SpellingDoorTests.swift
//  VariorumTests (Mac)
//
//  VX-798 (the VX-828 run, batch E) — Edit ▸ Spelling and Grammar: ⌘: Show
//  Spelling and Grammar and ⌘; Check Document Now, the macOS-standard pair a
//  SwiftUI-lifecycle menu bar never carried. The run record:
//  `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch E".
//
//  An Improvement, not a bug: the old tree has NO door, so every pin here is
//  red on old by construction (the acts did not exist). The behavioural
//  revert that proves the flags pin is load-bearing is the record's R-E1: the
//  check act's selector swapped for `toggleContinuousSpellChecking(_:)` — the
//  one-shot becoming the toggle her ask said it must not be — turns
//  `aCheckStepsToTheNextMisspellingAndTurnsNothingOn` red on every surface.
//
//  The surfaces sit in an OFFSCREEN window (`checkSpelling(_:)` does nothing
//  in a view no window holds — probed on 27.0.1), and the walk starts at a
//  known first responder (`SpellingDoor.perform(_:from:)` — `tryToPerform`,
//  the same chain the menu's nil-target action walks), so no pin needs a key
//  window. ⌘:'s panel is never SHOWN here: ordering the system panel front
//  would take key status from the test host mid-suite; its act is pinned by
//  selector (and its refusal arm, which shows nothing), and the walk shows the
//  panel.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("VX-798 — Edit ▸ Spelling and Grammar, the one-shot pair", .serialized)
struct SpellingDoorTests {
    // MARK: - The declarations (P-1)

    @Test func thePairIsDeclaredWithAppKitsTitlesAndKeys() throws {
        let panel = CapabilityRegistry.capability(.showSpellingPanel)
        let check = CapabilityRegistry.capability(.checkSpelling)
        #expect(panel.verb == "Show Spelling and Grammar")
        #expect(check.verb == "Check Document Now")
        #expect(panel.shortcutLabel == "\u{2318}:")
        #expect(check.shortcutLabel == "\u{2318};")
        #expect(panel.doors == [.menuBar] && check.doors == [.menuBar], "menu doors only")
        #expect(panel.scope == .app && check.scope == .app)

        let panelKey = try #require(EditorCommands.keyEquivalent(for: .showSpellingPanel))
        #expect(panelKey.0 == KeyEquivalent(":") && panelKey.1 == .command)
        let checkKey = try #require(EditorCommands.keyEquivalent(for: .checkSpelling))
        #expect(checkKey.0 == KeyEquivalent(";") && checkKey.1 == .command)

        #expect(EditorCommands.menuRendered.contains(.showSpellingPanel))
        #expect(EditorCommands.menuRendered.contains(.checkSpelling))
        // No other act wears either chord (the collision sweep, as data).
        let wearers = CapabilityRegistry.all.filter {
            $0.shortcutLabel == "\u{2318}:" || $0.shortcutLabel == "\u{2318};"
        }.map(\.id)
        #expect(Set(wearers) == [.showSpellingPanel, .checkSpelling])
        // Findable where she looks for keys (13g L1's guard, for these two).
        #expect(HelperView.shortcutKeysShown.isSuperset(of: ["\u{2318}:", "\u{2318};"]))
    }

    /// The chain decides, never the context: the declarations act everywhere
    /// the registry looks, and the door speaks where the chain finds no taker.
    @Test func theRegistryNeverGreysThePair() {
        for context in [CapabilityContext(), CapabilityContext(mode: .write),
                        CapabilityContext(mode: .takes), CapabilityContext(mode: .read)] {
            #expect(CapabilityRegistry.availability(.checkSpelling, in: context) == .act)
            #expect(CapabilityRegistry.availability(.showSpellingPanel, in: context) == .act)
        }
    }

    /// Each act is AppKit's own, and every writing surface the app builds
    /// answers both with no override of ours.
    @Test func everyWritingSurfaceAnswersBothActs() {
        #expect(SpellingDoor.Act.checkDocument.selector == #selector(NSText.checkSpelling(_:)))
        #expect(SpellingDoor.Act.showPanel.selector == #selector(NSText.showGuessPanel(_:)))
        let kinds: [NSTextView.Type] = [
            EditorTextView.self, PaneTextView.self, CaptureNSTextView.self, CommentNSTextView.self,
        ]
        for kind in kinds {
            for act in SpellingDoor.Act.allCases {
                #expect(kind.instancesRespond(to: act.selector), "\(kind) answers \(act)")
            }
        }
    }

    // MARK: - The act (one-shot: the A24 flags never move)

    /// A surface of each live kind, as the app builds it.
    enum Surface: String, CaseIterable, CustomTestStringConvertible {
        case write, livePane, readPane, captureBox, comment
        var testDescription: String { rawValue }

        /// The text view and the view a window holds (Write's editor rides
        /// its scroll view, as in the app).
        @MainActor func make() -> (text: NSTextView, root: NSView) {
            switch self {
            case .write:
                let made = EditorTextView.makeEditor()
                return (made.textView, made.scrollView)
            case .livePane:
                let pane = PaneTextView.makeTakeSurface()
                pane.isEditable = true  // a take pane gone live
                return (pane, pane)
            case .readPane:
                let pane = PaneTextView.makeReadSurface()
                return (pane, pane)
            case .captureBox:
                let box = CaptureNSTextView(usingTextLayoutManager: true)
                return (box, box)
            case .comment:
                let field = CommentNSTextView(usingTextLayoutManager: true)
                return (field, field)
            }
        }
    }

    private struct Flags: Equatable {
        let continuous, grammar, correction, completion: Bool
        @MainActor init(_ view: NSTextView) {
            continuous = view.isContinuousSpellCheckingEnabled
            grammar = view.isGrammarCheckingEnabled
            correction = view.isAutomaticSpellingCorrectionEnabled
            completion = view.isAutomaticTextCompletionEnabled
        }
    }

    private static let sentence = "The quick brwn fox jumpd over the lazy dog."

    /// An offscreen window holding `root`, the text view its first responder.
    private func host(_ made: (text: NSTextView, root: NSView)) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: -4000, y: -4000, width: 480, height: 240),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        made.root.frame = NSRect(x: 0, y: 0, width: 480, height: 240)
        window.contentView = made.root
        window.makeFirstResponder(made.text)
        return window
    }

    private func word(in view: NSTextView) -> String {
        (view.string as NSString).substring(with: view.selectedRange())
    }

    /// ⌘; — the next misspelled word after the selection is selected, and
    /// again for the one after; checking as you type stays exactly where the
    /// A24 level put it, at the shipped default AND at a checking level (the
    /// §3 pairing — completion off while checking is on — untouched).
    @Test(arguments: Surface.allCases)
    func aCheckStepsToTheNextMisspellingAndTurnsNothingOn(surface: Surface) {
        for level in [SpellcheckLevel.off, .checkWhileTyping] {
            let made = surface.make()
            let window = host(made)
            defer { window.close() }
            let view = made.text
            view.string = Self.sentence
            level.apply(to: view)
            view.setSelectedRange(NSRange(location: 0, length: 0))
            let before = Flags(view)

            #expect(SpellingDoor.perform(.checkDocument, from: view), "\(surface) took the act")
            #expect(word(in: view) == "brwn", "\(surface) @ \(level): the first misspelling is selected")
            #expect(SpellingDoor.perform(.checkDocument, from: view))
            #expect(word(in: view) == "jumpd", "\(surface) @ \(level): again — the one after")

            #expect(Flags(view) == before, "\(surface) @ \(level): one-shot — no checking flag moved")
            #expect(view.isContinuousSpellCheckingEnabled == level.continuousChecking,
                    "\(surface) @ \(level): checking as you type is the setting's, still")
            #expect(view.string == Self.sentence, "\(surface): a check selects, it never edits")
        }
    }

    // MARK: - P-2: a door that did nothing speaks

    /// Nothing in the chain can check spelling (the keyboard on a plain view —
    /// a list, a button): the door speaks its declared note, once, for either
    /// act; with a text view holding the keys it says nothing.
    @Test func withNoTextInTheChainTheDoorSpeaksItsNote() {
        let window = NSWindow(
            contentRect: NSRect(x: -4000, y: -4000, width: 200, height: 100),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.close() }
        let plain = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        window.contentView = plain
        // Both acts: with no taker in the chain nothing is shown, so ⌘:'s arm
        // runs safely here too (only a TAKER would order the panel front).
        for act in SpellingDoor.Act.allCases {
            var spoken: [String] = []
            SpellingDoor.door(act, from: plain) { spoken.append($0) }
            #expect(spoken == [SpellingDoorCopy.nothingToCheck], "\(act) speaks its refusal")
            #expect(CapabilityRegistry.capability(act.capability).unavailableNote
                    == SpellingDoorCopy.nothingToCheck)
        }

        let made = Surface.write.make()
        let textWindow = host(made)
        defer { textWindow.close() }
        made.text.string = Self.sentence
        var spoken: [String] = []
        SpellingDoor.door(.checkDocument, from: made.text) { spoken.append($0) }
        #expect(spoken.isEmpty, "a text view took it — nothing to say")
    }
}
