//
//  CommitRestingPreviewTests.swift
//  VariorumTests
//
//  VX-674 (the VX-677 run, batch 4) — her ruling on P-440-9's flagged gap
//  (QUESTIONS #249, 2026-10-28): an UNNAMED commit's resting row in Block
//  History showed only its time — none of her words until she opened it.
//  Ruled: the resting row carries a few words of the commit's text as a
//  MUTED preview after the stamp; a NAMED commit keeps its name alone; the
//  quiet ◦ automatic mark is unchanged.
//
//  Red on `rev674` (the behavioural revert: `CommitRowFace.restingWords`
//  answers nil — the pre-ruling anatomy, no words at rest):
//  `anUnnamedCommitRestsOnItsFirstWords` and
//  `theRestingRowDrawsTheWordsMutedAfterTheStampAndOnlyWhenUnnamed`. The other
//  three are GUARDS, green on both trees by construction — the named row's
//  anatomy (unchanged by the ruling), the preview's bound (a new function),
//  and the one-line height.
//
//  VX-692 (F-B3-1): no closure-bearing expression sits inside `#expect` or
//  `#require` here — every value is bound to a local first.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-674 — an unnamed commit rests on its first words")
struct CommitRestingPreviewTests {
    // MARK: - Fixtures

    private static let now = Date(timeIntervalSince1970: 1_791_331_200)

    private static func commit(
        _ text: String, kind: CommitKind = .manual, message: String? = nil
    ) -> CommitPoint {
        CommitPoint(
            id: UUID().uuidString, variantId: "v1", text: text, kind: kind,
            message: message, createdAt: now.addingTimeInterval(-3_600))
    }

    private static func row(_ commit: CommitPoint, tokens: VoiceTokens) -> CommitRowView {
        CommitRowView(
            commit: commit, tokens: tokens, predatesSplit: false, now: Self.now,
            renameOpensField: true, renameAsk: .constant(nil),
            onName: {}, onRename: { _ in }, onRestore: {},
            expanded: false, onToggle: {}, onReadInFull: {})
    }

    /// Every value of type `T` reachable in `subject`'s stored structure, not
    /// descending into `VoiceTokens` (`CommitsPageLedgerTests`' walk).
    private static func values<T>(_ type: T.Type, in subject: Any, depth: Int = 0) -> [T] {
        guard depth < 80 else { return [] }
        if subject is VoiceTokens { return [] }
        var found: [T] = []
        if let hit = subject as? T { found.append(hit) }
        for child in Mirror(reflecting: subject).children {
            found += values(type, in: child.value, depth: depth + 1)
        }
        return found
    }

    /// A value's identity as SwiftUI reflects it (`Font`/`Color` compare
    /// their provider boxes, so two built apart are never `==`).
    private static func signature(_ value: Any) -> String {
        var out = ""
        dump(value, to: &out)
        return out
    }

    private static func dumped(_ view: some View) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 120)
        return out
    }

    // MARK: - The words (RED on rev674)

    /// **An unnamed commit's resting words are the moment's first line** —
    /// a deliberate one and a quiet one alike (the ◦ sits beside them; the
    /// ruling leaves it as it was), and a name that normalises away is no
    /// name (the store's own rule, `SavepointName.normalized`).
    @Test func anUnnamedCommitRestsOnItsFirstWords() {
        let deliberate = CommitRowFace.restingWords(
            Self.commit("The kettle again. I keep meaning to write before the day starts."))
        #expect(deliberate == "The kettle again. I keep meaning to write before the day starts.")

        let quiet = CommitRowFace.restingWords(Self.commit("Quiet words, saved on their own.", kind: .auto))
        #expect(quiet == "Quiet words, saved on their own.")
        let quietGlyph = CommitRowFace.kindGlyph(Self.commit("x", kind: .auto))
        #expect(quietGlyph == CommitRowFace.quietGlyph, "the ◦ is unchanged")

        let blankName = CommitRowFace.restingWords(Self.commit("Words under a blank name.", message: "   "))
        #expect(blankName == "Words under a blank name.", "a blank name is no name")
    }

    /// **The resting row DRAWS them** — after the stamp, in the voice's muted
    /// ink, one line (the second paragraph never reaches it) — and a NAMED
    /// row draws its name and none of the moment's words. Every voice.
    @Test func theRestingRowDrawsTheWordsMutedAfterTheStampAndOnlyWhenUnnamed() {
        let text = "A sentence that rests on the line.\nA second paragraph the line never shows."
        for tokens in [VoiceTokens.studyLight, .terminalLight, .studyDark, .terminalDark] {
            let unnamed = Self.row(Self.commit(text), tokens: tokens)
            let unnamedText = Self.dumped(unnamed.body)
            #expect(unnamedText.contains("A sentence that rests on the line."),
                    "\(tokens.voice): the unnamed row's first words are on its resting line")
            #expect(!unnamedText.contains("A second paragraph"),
                    "\(tokens.voice): the first line only")
            let unnamedInks = Self.values(Color.self, in: unnamed.body).map(Self.signature)
            let muted = Self.signature(tokens.muted)
            #expect(unnamedInks.contains(muted), "\(tokens.voice): drawn in the voice's muted ink")

            let named = Self.row(Self.commit(text, message: "before the rewrite"), tokens: tokens)
            let namedText = Self.dumped(named.body)
            #expect(namedText.contains("before the rewrite"), "\(tokens.voice): the name leads")
            #expect(!namedText.contains("A sentence that rests"),
                    "\(tokens.voice): a named commit keeps its name alone")
            let namedInks = Self.values(Color.self, in: named.body).map(Self.signature)
            #expect(!namedInks.contains(muted), "\(tokens.voice): no muted preview beside a name")
        }
    }

    // MARK: - Guards (green on both trees)

    /// A named commit's resting words are nil — its name alone (the ruled
    /// anatomy for a named row, unchanged).
    @Test func aNamedCommitKeepsItsNameAlone() {
        let named = CommitRowFace.restingWords(Self.commit("Words she named.", message: "first draft"))
        #expect(named == nil)
        let quietNamed = CommitRowFace.restingWords(
            Self.commit("Quiet, then named.", kind: .auto, message: "kept"))
        #expect(quietNamed == nil, "a renamed quiet commit keeps its name alone too")
    }

    /// **The preview's bound** — leading blank lines dropped, the first line
    /// only (any newline, CRLF included), trailing spaces trimmed, capped at
    /// `restingCap` CHARACTERS so a cut can never split a grapheme, and no
    /// ellipsis of the face's own (VX-144's "…had.…" lesson). An empty
    /// moment says so in the open row's own words (PROVISIONAL P-674-1).
    @Test func thePreviewIsTheFirstLineBoundedAndNeverCutsAGrapheme() {
        let leading = CommitRowFace.restingPreview("\n  \n\tFirst line leads.\nSecond stays in the open row.")
        #expect(leading == "First line leads.")
        let crlf = CommitRowFace.restingPreview("A Windows line.\r\nThe next.")
        #expect(crlf == "A Windows line.")
        let trailing = CommitRowFace.restingPreview("Ends with spaces.   \nNext.")
        #expect(trailing == "Ends with spaces.")

        let long = String(repeating: "word ", count: 200)
        let cut = CommitRowFace.restingPreview(long)
        #expect(cut.count <= CommitRowFace.restingCap, "bounded: \(cut.count)")
        #expect(long.hasPrefix(cut))
        #expect(!cut.hasSuffix("\u{2026}"), "no ellipsis of the face's own")

        // One grapheme of seven scalars, then a decomposed é (two scalars):
        // 240 characters, so the cap falls inside the run.
        let family = "\u{1F469}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}"
        let clusters = String(repeating: family + "e\u{301}", count: 120)
        let safe = CommitRowFace.restingPreview(clusters)
        #expect(safe.count == CommitRowFace.restingCap)
        #expect(clusters.hasPrefix(safe), "a whole-grapheme prefix (String.hasPrefix compares Characters)")
        let lastScalars = safe.last.map { $0.unicodeScalars.count }
        #expect(lastScalars == 2, "the cut ends on a whole é, never on its bare e")

        let empty = CommitRowFace.restingPreview(" \n\t ")
        #expect(empty == BlockPastCopy.emptyTake)
        let nothing = CommitRowFace.restingPreview("")
        #expect(nothing == BlockPastCopy.emptyTake)
    }

    /// The resting row stays ONE line with a long first line in it — the
    /// layout truncates (the 34-pt bound `CommitsPageLedgerTests` holds for
    /// the ordinary row, both voices, at the column's default width).
    @Test func aLongFirstLineStillRestsOnOneLine() {
        let long = String(repeating: "a long first line of her own words ", count: 8)
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            let host = NSHostingController(rootView: Self.row(Self.commit(long), tokens: tokens))
            let height = host.sizeThatFits(in: NSSize(width: 396, height: 10_000)).height
            print("[VX-674] \(tokens.voice) resting row with a long first line: \(height) pt")
            #expect(height <= 34, "\(tokens.voice): one line — \(height)")
        }
    }
}
