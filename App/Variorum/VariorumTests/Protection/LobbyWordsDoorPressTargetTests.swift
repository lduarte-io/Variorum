//
//  LobbyWordsDoorPressTargetTests.swift
//  VariorumTests — VX-510 D-B9 (VX-527, her hand on the Pro's own trackpad: "click on use your twelve words first only
//  works on the little arrow … the words don't open it"): THE LOBBY'S WORDS DOOR IS ONE PRESS TARGET. The mechanism: a
//  macOS `DisclosureGroup`'s label is not a control — only its chevron presses — so a bare `Text` label reads as a door
//  and does nothing (W-13: AXPress opened it at once, three synthetic clicks across the label's own geometry did not).
//  The fix puts the label INSIDE a press target whose action toggles the words road; the phone's arm already does (a
//  whole-label `.plain` Button) and has no bug — its GUARD keeps it so.
//
//  A SOURCE pin, SELF-CONTAINED by design (file reads only, no app import — it runs in a minimal SwiftPM package as well
//  as the Mac target; `#filePath`'s symlinks are resolved). It reads CODE lines (line comments dropped — vx-488 RM3-4: a
//  source pin matches code, never a comment). The pin binds the MECHANISM — the label inside a press target toggling
//  `showsWords` — never the idiom (a Button replacing the DisclosureGroup, or a Button as its label, both pass).
//

import Foundation
import Testing

@Suite("VX-510 D-B9 — the lobby's words door is one press target (source)")
struct LobbyWordsDoorPressTargetTests {
    /// `App/Variorum`, from this file (symlinks resolved — a scratch package links the suite in).
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (line comments dropped).
    static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n", omittingEmptySubsequences: false).filter {
            !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//")
        }.joined(separator: "\n")
    }

    /// The `roads` switch's disclosure arm: from `case .disclosure:` to the words field's own declaration.
    static func disclosureArm(_ code: String) throws -> Substring {
        let roads = try #require(code.range(of: "private var roads: some View {"), "the roads are declared")
        let arm = try #require(code.range(of: "case .disclosure:", range: roads.upperBound..<code.endIndex),
                               "the words road's disclosure arm")
        let end = try #require(code.range(of: "private var wordsField: some View {", range: arm.upperBound..<code.endIndex),
                               "the words field follows the roads")
        return code[arm.lowerBound..<end.lowerBound]
    }

    /// Why `label` does NOT sit inside a press target toggling `showsWords` within `arm` — nil when it does. A press
    /// target here: the nearest `Button {` before the label whose action (up to its `} label: {`) toggles `showsWords`,
    /// with the label inside that label closure (the braces from the closure's opening to the label never close it).
    static func whyNotAPressTarget(label: String, in arm: Substring) -> String? {
        guard let text = arm.range(of: label) else { return "the label \(label) is not in the arm" }
        let before = arm[arm.startIndex..<text.lowerBound]
        guard let button = before.range(of: "Button {", options: .backwards) else {
            return "the label sits in no Button — a bare label (the chevron alone presses)"
        }
        let afterButton = arm[button.upperBound..<text.lowerBound]
        guard let labelClosure = afterButton.range(of: "} label: {") else {
            return "the nearest Button's label closure does not hold the label"
        }
        let action = afterButton[afterButton.startIndex..<labelClosure.lowerBound]
        guard action.contains("showsWords.toggle()") else {
            return "the Button holding the label does not toggle the words road (showsWords)"
        }
        var depth = 1
        for character in afterButton[labelClosure.upperBound...] {
            if character == "{" { depth += 1 }
            if character == "}" { depth -= 1 }
            if depth == 0 { return "the label sits after the Button's label closure closed" }
        }
        return nil
    }

    /// THE FIX (red on the pre-fix tree, where the label is a bare `DisclosureGroup` label): the Mac's disclosure arm
    /// renders `ProtectionWords.wordsDoor` INSIDE a press target that toggles the words road — the whole label presses,
    /// not the chevron alone. The look is kept (the small muted one-line label, the arm's 340 width) and the words field
    /// still unfolds beneath on the same state.
    @Test func theMacsWordsDoorLabelSitsInsideAPressTargetTogglingTheWordsRoad() throws {
        let arm = try Self.disclosureArm(try Self.code("Variorum/StoreLockView.swift"))
        let why = Self.whyNotAPressTarget(label: "Text(ProtectionWords.wordsDoor)", in: arm)
        #expect(why == nil, "the Mac's words door: \(why ?? "")")
        // The look and the unfolding, as today (green on both sides — the red above is the bug's).
        #expect(arm.contains(".font(tokens.small)") && arm.contains(".foregroundStyle(tokens.muted)")
                && arm.contains(".lineLimit(1)"), "the label's look is kept")
        #expect(arm.contains(".frame(maxWidth: 340)"), "the arm's width is kept")
        #expect(arm.contains("wordsField.padding(.top, 6)"), "the words field unfolds beneath as today")
        #expect(arm.contains("$showsWords") || arm.contains("if showsWords"), "the field unfolds on the words road's state")
    }

    /// GUARD (green on both sides): the phone's disclosure arm keeps its whole-label `.plain` Button toggling the words
    /// road — the idiom the Mac's fix follows; the phone has no bug and its code is not this fix's.
    @Test func thePhonesWordsDoorKeepsItsWholeLabelButton() throws {
        let arm = try Self.disclosureArm(try Self.code("VariorumMobile/Features/Protection/MobileRoadFaces.swift"))
        let why = Self.whyNotAPressTarget(label: "Text(tokens.chromeLabel(ProtectionWords.wordsDoor))", in: arm)
        #expect(why == nil, "the phone's words door: \(why ?? "")")
        #expect(arm.contains(".buttonStyle(.plain)"), "the phone's door is a plain Button")
        #expect(arm.contains("if showsWords { wordsField }"), "the phone's field unfolds beneath")
    }
}
