//
//  BarCountsFaceTests.swift
//  VariorumTests
//
//  **13u4 UNIT S2 — her item 1's second half**, verbatim: *"it would be
//  nice if the word counter thing at the bottom could condense as well - I
//  like that it offers to set a word count target, so I want to keep that
//  functionality, but maybe a little icon meant to represent count or
//  something could be an optional condensed view. Or show only note, only
//  block, or only icon. I don't necessarily want an appearance setting - I
//  want these to be changed by clicking on them."*
//
//  Three claims, and every one of them is a rule rather than a rendering,
//  which is why these pins need no window:
//
//    1. the CYCLE is her four in her order, and a click is what moves it;
//    2. the WORDS of each face are the bar's own, unchanged — this unit
//       condenses the counter, it does not re-word it;
//    3. **the word-target door is offered in EVERY face** (her keep), and
//       the four faces are listed beside it so the cycle is legible.
//
//  The counter's USE evidence is the walk (the unit record's table): a
//  click through all four faces on both bars, in both voices and both
//  appearances, with the target door opened from the icon face.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The bar's word counter condenses (13u4 UNIT S2 — her item 1)")
struct BarCountsFaceTests {

    private var write: WordCounts {
        WordCounts(
            unit: "12w block", selected: "3w selected", note: "1,240w in note",
            unitNoun: "block")
    }

    private var board: WordCounts {
        WordCounts(unit: "12w take", selected: nil, note: "1,240w note", unitNoun: "take")
    }

    /// **HER CYCLE, in her order** — and round again, so a fifth click is
    /// back where a first one started.
    @Test func theCycleIsHerFourInHerOrder() {
        #expect(CountsFace.full.next == .note)
        #expect(CountsFace.note.next == .block)
        #expect(CountsFace.block.next == .icon)
        #expect(CountsFace.icon.next == .full)
        #expect(CountsFace.allCases == [.full, .note, .block, .icon])

        var face = CountsFace.full
        for _ in 0..<4 { face = face.next }
        #expect(face == .full, "four clicks return to the counts she started with")
    }

    /// **EACH FACE SAYS THE BAR'S OWN WORDS** — byte-identical to what the
    /// two bars have always said, *"in note"* / *"note"* and *"block"* /
    /// *"take"* included. The icon face says nothing in words, which is
    /// what makes it an icon.
    @Test func eachFaceSaysExactlyTheBarsOwnWords() {
        #expect(CountsFace.full.label(write) == "12w block · 3w selected · 1,240w in note")
        #expect(CountsFace.note.label(write) == "1,240w in note")
        #expect(CountsFace.block.label(write) == "12w block")
        #expect(CountsFace.icon.label(write) == nil)

        #expect(CountsFace.full.label(board) == "12w take · 1,240w note")
        #expect(CountsFace.note.label(board) == "1,240w note")
        #expect(CountsFace.block.label(board) == "12w take",
                "the boards' unit is a TAKE — the bar's own word, not this unit's")
        #expect(CountsFace.icon.label(board) == nil)
    }

    /// **A face whose parts are absent falls through rather than vanishing**
    /// — the counter is also the target door, and a door that disappears
    /// because the caret is nowhere is a door she cannot find.
    @Test func aFaceWithNothingToSayFallsThroughToOneThatHasSomething() {
        let noCaret = WordCounts(unit: nil, selected: nil, note: "1,240w in note")
        #expect(CountsFace.block.drawable(for: noCaret) == .note,
                "only-this-block, with the caret nowhere, shows the note instead")
        #expect(CountsFace.full.drawable(for: noCaret) == .full)

        let nothing = WordCounts()
        #expect(!nothing.hasAnything)
        for face in CountsFace.allCases {
            #expect(face.drawable(for: nothing) == .icon,
                    "\(face): with nothing to say, the door is the icon")
        }

        let onlyBlock = WordCounts(unit: "12w block", selected: nil, note: nil)
        #expect(CountsFace.note.drawable(for: onlyBlock) == .block)
        #expect(CountsFace.icon.drawable(for: write) == .icon, "the icon is never talked out of")
    }

    /// **A NARROW BAR MAY SHORTEN A FULL FACE, NEVER LENGTHEN A CONDENSED
    /// ONE.** C-6's verdict (the block and selected counts are noise where
    /// the width is short) shipped as a second view that hard-coded the
    /// note's total; it is now one rule, and her own choice outranks it in
    /// the direction that matters.
    @Test func aNarrowBarCondensesAFullFaceAndLeavesHerOwnChoiceAlone() {
        #expect(CountsFace.full.narrowed == .note)
        #expect(CountsFace.note.narrowed == .note)
        #expect(CountsFace.block.narrowed == .block,
                "she asked for the block; a narrow bar does not overrule her with the note")
        #expect(CountsFace.icon.narrowed == .icon)
    }

    /// **THE TARGET DOOR IS OFFERED IN EVERY FACE — her keep**, including
    /// the icon, which is the face that would otherwise have quietly lost
    /// it: *"I like that it offers to set a word count target, so I want to
    /// keep that functionality."*
    @Test func theWordTargetDoorIsOfferedInEveryFaceIncludingTheIcon() {
        for face in CountsFace.allCases {
            let none = CountsMenu.rows(face: face, target: nil, unitNoun: "block")
            #expect(none.first?.act == .target, "\(face): the target row leads the menu")
            #expect(none.first?.title == WordTargetFaceCopy.setTargetItem)
            #expect(!none.contains { $0.act == .clearTarget },
                    "\(face): nothing to clear when there is no target")

            let set = CountsMenu.rows(face: face, target: 5_000, unitNoun: "block")
            #expect(set.first?.title == WordTargetFaceCopy.changeTargetItem,
                    "\(face): with a target set the row says CHANGE")
            #expect(set.contains { $0.act == .clearTarget }, "\(face): …and one clears it")
        }
    }

    /// **The four faces are listed beside the target door, with a ✓ on the
    /// one she is in** — the cycle made legible, which is the one thing a
    /// bare click cannot do.
    @Test func theMenuListsHerFourFacesAndTicksTheOneSheIsIn() {
        for face in CountsFace.allCases {
            let rows = CountsMenu.rows(face: face, target: nil, unitNoun: "take")
            let faces = rows.compactMap { row -> CountsFace? in
                if case .face(let option) = row.act { return option }
                return nil
            }
            #expect(faces == CountsFace.allCases, "\(face): every face is offered, in her order")
            let checked = rows.filter(\.checked)
            #expect(checked.count == 1, "\(face): exactly one ✓")
            #expect(checked.first?.act == .face(face), "\(face): …on the face she is in")
            #expect(rows.contains { $0.title == "Only this take" },
                    "the unit's noun is the BAR's — a take on the boards, a block in Write")
        }
        #expect(CountsMenu.rows(face: .full, target: nil, unitNoun: "block")
            .contains { $0.title == "Only this block" })
    }

    /// The memory's posture, the same one every local key in this app
    /// takes: the default is the shipped face, and a stored stranger reads
    /// as the default rather than as a crash or a blank bar.
    @Test func theRememberedFaceDefaultsToTheShippedOneAndSurvivesNonsense() throws {
        let suiteName = "13u4-s2-countsface-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(CountsFace.remembered(defaults) == .full)
        defaults.set("icon", forKey: CountsFace.key)
        #expect(CountsFace.remembered(defaults) == .icon)
        defaults.set("sideways", forKey: CountsFace.key)
        #expect(CountsFace.remembered(defaults) == .full)
        #expect(CountsFace.key != StampFace.key, "the two cycles remember separately")
    }

    /// **The hover carries the WHOLE fact in every face** — which is what
    /// makes a collapse a collapse rather than a loss — and it names both
    /// gestures, because her click took the one the target setter had.
    @Test func theHoverKeepsTheWholeFactAndNamesBothGestures() {
        let whole = "12w block · 3w selected · 1,240w in note · 26% of 5,000w target"
        let help = WordTargetFaceCopy.help(whole: whole)
        #expect(help.hasPrefix(whole), "the counts she is not looking at are in the sentence")
        #expect(help.contains("click condenses"))
        #expect(help.contains("right-click sets a word target"))
        #expect(help.contains("never a wall"), "the ratified semantics survive the re-wording")
        #expect(WordTargetFaceCopy.help(whole: nil).hasPrefix("Word counts"),
                "…and it still reads as a sentence before the counts land")
    }
}
