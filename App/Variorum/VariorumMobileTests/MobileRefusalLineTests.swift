//
//  MobileRefusalLineTests.swift
//  VariorumMobileTests
//
//  VM-277 (the VM-260 run, batch 1b; her ruling in the ticket; the proposal
//  ruled as A-260-4) — **A REFUSAL ON THE PHONE IS ONE SHORT LINE, DISMISSABLE,
//  ITS FULL REASON ON DEMAND; THE LINE FLOATS AS A CARD.** Her words
//  (2026-11-24): "refusals should be dismissable and they should be much
//  shorter. maybe you even have to click on it for the reason (or it's clear
//  that you could swipe upwards for the reason on it)".
//
//  As ruled: (a) a refusal's line is its headline — answered beside its
//  sentence from the one composer's arm — or, unauthored, the sentence clipped
//  to one line with "…"; (b) a 44 × 44 ✕ plus a flick down dismiss it (P-55-3's
//  refusal arm superseded); (c) a tap anywhere on the line opens the reason,
//  signposted by "›" after the headline; (d) the opened reason is the card
//  grown upward, its clock held while she reads, closing on the ✕, a flick
//  down, leaving the note, or a newer message; (e) the line is a card clear of
//  the bar and the screen's sides (VM-275 half 2's cure; PROVISIONAL).
//
//  THESE PINS run on the pre-VM-277 tree (the face's frame seam `lineFrame`
//  committed with them, no behaviour) — RED ON OLD where named: the old line
//  drew a refusal's whole sentence over up to four lines in a full-width band
//  flush on the bar, with no door of its own and no way to it but its clock.
//  The headline's own pins (the composers' pairs, the seam's headline and hold
//  doors) need the fix's vocabulary and live with the fix.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-277 — a refusal is one short line, dismissable, its reason on demand; the line is a card", .serialized)
struct MobileRefusalLineTests {
    static let inset: CGFloat = 34
    static let bar: CGFloat = 56

    /// The line in a real KEY window of the test host's scene (activation needs
    /// one), fed the home indicator's inset and the bar's height.
    private func standing(
        _ model: MobileMessageLineModel, _ body: (UIWindow) async throws -> Void
    ) async throws {
        _ = AccessibilityServer.armOnce()
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
            "the test host has a window scene")
        let window = UIWindow(windowScene: scene)
        model.safeBottom = Self.inset
        model.chromeInset = Self.bar
        window.rootViewController = UIHostingController(rootView: MobileMessageLineView(model: model))
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        try await body(window)
    }

    private func settle(_ window: UIWindow, _ turns: Int = 30) async {
        for _ in 0..<turns {
            try? await Task.sleep(for: .milliseconds(10))
            window.rootViewController?.view.setNeedsLayout()
            window.layoutIfNeeded()
        }
    }

    private func elements(_ window: UIWindow) -> [NSObject] {
        guard let view = window.rootViewController?.view else { return [] }
        return HostedSurface<EmptyView>.elements(of: view)
    }

    private func element(
        _ window: UIWindow, label: String, button: Bool? = nil
    ) -> NSObject? {
        elements(window).first { candidate in
            guard candidate.accessibilityLabel == label else { return false }
            guard let button else { return true }
            return candidate.accessibilityTraits.contains(.button) == button
        }
    }

    /// The line's frame once drawn.
    private func lineFrame(_ window: UIWindow, _ model: MobileMessageLineModel) async -> CGRect? {
        for _ in 0..<200 {
            window.layoutIfNeeded()
            if let frame = model.lineFrame, frame.height > 0 { return frame }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return model.lineFrame
    }

    private var long: String { MobileRefusalLeavesItsNoteTests.longRefusal }

    // MARK: (a) — one line

    /// **RED ON OLD — "much shorter".** Her recording's refusal (three to four
    /// lines on the old line) takes ONE 44 pt line, in both voices.
    @Test func aLongRefusalTakesOneLine() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withEditorWorld { session, _ in
                let model = MobileMessageLineModel(status: session.status, voice: { voice })
                try await standing(model) { window in
                    session.status.refuse(long)
                    await settle(window)
                    let frame = try #require(await lineFrame(window, model), "the line drew")
                    #expect(frame.height <= PhoneMetrics.touchMinimum + 0.5,
                            "one 44 pt line in \(voice), not \(frame.height)")
                    session.status.clear()
                }
            }
        }
    }

    // MARK: (b) — dismissable

    /// **RED ON OLD — "dismissable".** The refusal's line carries its own ✕,
    /// answering across 44 × 44; pressing it takes the line away at once.
    @Test func aRefusalCarriesItsDismissDoorAcrossFortyFour() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let model = MobileMessageLineModel(status: session.status, voice: { .study })
            try await standing(model) { window in
                session.status.refuse(long)
                await settle(window)
                let dismiss = try #require(element(window, label: "Dismiss", button: true),
                                           "the line's ✕: \(elements(window).compactMap(\.accessibilityLabel))")
                let frame = dismiss.accessibilityFrame
                #expect(frame.width >= 43.5 && frame.height >= 43.5, "a 44 × 44 target: \(frame)")
                #expect(dismiss.accessibilityActivate())
                await settle(window, 10)
                #expect(session.status.current == nil, "dismissed — not left to its clock")
            }
        }
    }

    // MARK: (c) + (d) — the reason on demand, held while she reads

    /// **RED ON OLD — "click on it for the reason".** The line is a door; its
    /// press opens the whole sentence above it, and the seam's clock HOLDS while
    /// the reason is open (a short clock here, long past by the check); the ✕
    /// then closes it.
    @Test func aTapOpensTheReasonAndItStaysWhileSheReads() async throws {
        try await withEditorWorld { session, _ in
            // (Tip: 500 ms, read at 1.2 s — margin under load; the red-on-old
            // tree ran 250/600 and fails at the missing door before any timing.)
            session.status.dismissAfter = .milliseconds(500)
            let model = MobileMessageLineModel(status: session.status, voice: { .terminal })
            try await standing(model) { window in
                session.status.refuse(long)
                let said = try #require(session.status.current)
                await settle(window, 5)
                let labels = elements(window).compactMap(\.accessibilityLabel)
                let line = try #require(element(window, label: long, button: true),
                                        "the line is a door to its reason: \(labels)")
                #expect(line.accessibilityActivate())
                try? await Task.sleep(for: .milliseconds(1200))
                await settle(window, 10)
                #expect(session.status.current?.id == said.id,
                        "the reason stays while she reads — the clock held")
                let reason = try #require(element(window, label: long, button: false),
                                          "the whole sentence shows")
                #expect(reason.accessibilityFrame.height > 30,
                        "the reason reads whole, over its lines: \(reason.accessibilityFrame)")
                let dismiss = try #require(element(window, label: "Dismiss", button: true))
                #expect(dismiss.accessibilityActivate())
                await settle(window, 10)
                #expect(session.status.current == nil, "the ✕ closes it")
            }
        }
    }

    // MARK: (e) — the card

    /// **RED ON OLD — the line floats as a card** clear of the screen's sides
    /// and of the bar beneath it (the old band ran edge to edge, flush on the
    /// bar — VM-275 half 2's look). Every class wears the card.
    @Test func theLineIsACardClearOfTheBarAndTheSides() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withEditorWorld { session, _ in
                session.status.dismissAfter = .seconds(60)
                let model = MobileMessageLineModel(status: session.status, voice: { voice })
                try await standing(model) { window in
                    let foot = window.bounds.maxY - Self.inset - Self.bar
                    let margin = PhoneMetrics.Space.s8 - 0.5
                    for say in [
                        { session.status.refuse("That couldn't be done.") },
                        { session.status.removal(
                            "Block deleted.", undo: .init(label: MobileLine.undoLabel, perform: {})) },
                    ] {
                        session.status.clear()
                        model.lineFrame = nil
                        say()
                        await settle(window)
                        let frame = try #require(await lineFrame(window, model))
                        #expect(frame.minX >= margin, "clear of the left edge in \(voice): \(frame)")
                        #expect(frame.maxX <= window.bounds.maxX - margin,
                                "clear of the right edge in \(voice): \(frame)")
                        #expect(frame.maxY <= foot - margin,
                                "clear of the bar in \(voice): \(frame), bar's top \(foot)")
                        #expect(frame.maxY >= foot - 30, "and close above it, not floated away: \(frame)")
                    }
                    session.status.clear()
                }
            }
        }
    }

    // MARK: The other classes keep their anatomy

    /// **A direction is dismissable and keeps its whole sentence** (it is
    /// information, not a complaint — the proposal's scope call): its ✕ — RED
    /// ON OLD — and no reason door, its words reading whole.
    @Test func aDirectionIsDismissableAndReadsWhole() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let model = MobileMessageLineModel(status: session.status, voice: { .study })
            try await standing(model) { window in
                let words = "Entry saved. Your daily journal book is finished, so it wasn't added "
                    + "— reopen it from its book details."
                session.status.direct(words)
                await settle(window)
                #expect(element(window, label: "Dismiss", button: true) != nil, "a direction's ✕")
                #expect(element(window, label: words, button: true) == nil, "no reason door — it reads whole")
                let shown = try #require(element(window, label: words, button: false))
                #expect(shown.accessibilityFrame.height > 30, "the whole sentence, over its lines")
            }
        }
    }

    /// **A GUARD (green on both trees) — a removal keeps its anatomy**: its
    /// words and its Undo, no ✕ beside it, its fade the way it goes; an offer
    /// likewise keeps its door alone.
    @Test func aRemovalAndAnOfferKeepTheirDoorsAndNoDismiss() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let model = MobileMessageLineModel(status: session.status, voice: { .study })
            try await standing(model) { window in
                session.status.removal(
                    "Block deleted.", undo: .init(label: MobileLine.undoLabel, perform: {}))
                await settle(window)
                #expect(element(window, label: MobileLine.undoLabel, button: true) != nil)
                #expect(element(window, label: "Dismiss", button: true) == nil, "a removal has no ✕")

                session.status.offer("Diverge?", action: .init(label: "Diverge", perform: {}))
                await settle(window)
                #expect(element(window, label: "Diverge", button: true) != nil)
                #expect(element(window, label: "Dismiss", button: true) == nil, "an offer has no ✕")
            }
        }
    }

    // MARK: The fix's own pins (added with the fix — not part of the red-on-old run)

    /// **(a) — the headline is the line; the sentence is the reason.** A row the
    /// table authored speaks its headline on the line (the door's spoken name)
    /// and its whole sentence in the opened card.
    @Test func aHeadlineIsTheLineAndItsSentenceTheReason() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let model = MobileMessageLineModel(status: session.status, voice: { .study })
            let words = try #require(OpsRefusalCopy.refusal(
                for: OperationError.lastActiveVariant(id: "x"), roads: .phone))
            let headline = try #require(words.headline)
            try await standing(model) { window in
                MobileLine.refuse(words, session: session)
                await settle(window)
                let line = try #require(element(window, label: headline, button: true),
                                        "the headline is the line's door")
                #expect(element(window, label: words.sentence, button: nil) == nil,
                        "the sentence waits behind the tap")
                #expect(line.accessibilityActivate())
                await settle(window, 10)
                #expect(element(window, label: headline, button: false) != nil, "the card keeps its headline")
                #expect(element(window, label: words.sentence, button: false) != nil, "and shows the reason whole")
            }
        }
    }

    /// The table answers both halves from one arm: an authored row's headline
    /// is shorter than its sentence, and its sentence is exactly what the
    /// table has always said (`words(for:)`, the Mac's and the wire's read);
    /// an unauthored row answers no headline; an unworded error answers the one
    /// plain fallback with none.
    @Test func theTableAnswersBothHalvesFromOneArm() throws {
        let authored: [OperationError] = [
            .purgeTargetNotDeleted(table: "variant", id: "x"), .lastActiveVariant(id: "x"),
            .blocksNotAdjacent(first: "a", second: "b"), .invalidCut(variantID: "v", cut: 3),
            .gatheringRequiresRule(id: "g"),
        ]
        for error in authored {
            let pair = try #require(OpsRefusalCopy.refusal(for: error, roads: .phone))
            #expect(pair.sentence == OpsRefusalCopy.words(for: error, roads: .phone))
            let headline = try #require(pair.headline, "\(error) has its headline")
            #expect(headline.count < pair.sentence.count, "shorter than its sentence: \(headline)")
        }
        for error in [OperationError.blockNotDeleted(id: "x"), .invalidCommentText] {
            let pair = try #require(OpsRefusalCopy.refusal(for: error, roads: .phone))
            #expect(pair.headline == nil, "unauthored — the face clips its sentence")
            #expect(pair.sentence == OpsRefusalCopy.words(for: error, roads: .phone))
        }
        struct Unworded: Error {}
        let fallback = OpsRefusalCopy.refusalWords(for: Unworded(), roads: .phone)
        #expect(fallback == RefusalWords(OpsRefusalCopy.unexpectedFailure))
    }

    /// Every authored headline is one short clause that fits the card's one
    /// line at the default size (a conservative character budget), ends as a
    /// sentence, and carries no em-dash road (the road is the reason's).
    @Test func everyAuthoredHeadlineIsOneShortClause() throws {
        let file = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Shared/OpsRefusalTable.swift")
        let source = try String(contentsOf: file, encoding: .utf8)
        let pattern = try NSRegularExpression(pattern: #"headline: "((?:[^"\\]|\\.)*)"\)"#)
        let found = pattern.matches(in: source, range: NSRange(source.startIndex..., in: source)).map {
            String(source[Range($0.range(at: 1), in: source)!])
        }
        #expect(found.count >= 20, "the authored set is read: \(found.count)")
        for headline in found {
            let visible = headline
                .replacingOccurrences(of: #"\\u\{[0-9A-Fa-f]+\}"#, with: "x", options: .regularExpression)
                .replacingOccurrences(of: #"\\\([^)]*\)"#, with: "", options: .regularExpression)
            #expect(visible.count <= 36, "one line on the card: \(headline)")
            #expect(visible.hasSuffix("."), "a sentence: \(headline)")
            #expect(!visible.contains("\u{2014}") && !visible.contains("—"), "one clause, no road: \(headline)")
        }
    }

    /// The anatomy is the item's facts: a refusal carries its headline, a
    /// direction is its own, a removal and an offer are plain; only the first
    /// two take a dismissal.
    @Test func theAnatomyIsTheItemsFacts() {
        let refusal = StatusCenter.Item(
            id: UUID(), text: "Long.", kind: .refusal, refusalHeadline: "Short.")
        let direction = StatusCenter.Item(id: UUID(), text: "There.", kind: .refusal, isDirection: true)
        let removal = StatusCenter.Item(
            id: UUID(), text: "Gone.", action: .init(label: "Undo", perform: {}), kind: .receipt,
            leavesPage: true)
        let offer = StatusCenter.Item(
            id: UUID(), text: "Diverge?", action: .init(label: "Diverge", perform: {}), kind: .offer)
        #expect(MobileMessageLineModel.anatomy(for: refusal) == .refusal(headline: "Short."))
        #expect(MobileMessageLineModel.anatomy(for: direction) == .direction)
        #expect(MobileMessageLineModel.anatomy(for: removal) == .plain)
        #expect(MobileMessageLineModel.anatomy(for: offer) == .plain)
        #expect(MobileMessageLineModel.anatomy(for: refusal).isDismissable)
        #expect(MobileMessageLineModel.anatomy(for: direction).isDismissable)
        #expect(!MobileMessageLineModel.anatomy(for: removal).isDismissable)
        #expect(!MobileMessageLineModel.anatomy(for: offer).isDismissable)
    }

    /// The flick: far enough down, or thrown down — never up, never a nudge.
    @Test func theFlickDownDismissesAndANudgeDoesNot() {
        let distance = MobileMessageLineModel.flickDistance
        let toss = MobileMessageLineModel.flickThrow
        #expect(MobileMessageLineModel.dismisses(translation: distance, predicted: distance))
        #expect(MobileMessageLineModel.dismisses(translation: 4, predicted: toss), "thrown down")
        #expect(!MobileMessageLineModel.dismisses(translation: 6, predicted: 12), "a nudge settles back")
        #expect(!MobileMessageLineModel.dismisses(translation: -80, predicted: -200), "up never dismisses")
    }

    /// The whole card takes a touch for a line she can dismiss (the tap, the
    /// ✕ and the flick live there); any other line only on its door.
    @Test func theWholeCardTakesATouchOnlyForALineSheCanDismiss() {
        let card = CGRect(x: 8, y: 700, width: 377, height: 44)
        let door = CGRect(x: 300, y: 700, width: 60, height: 44)
        let inside = CGPoint(x: 40, y: 720)
        let refusal = StatusCenter.Item(id: UUID(), text: "Refused.", kind: .refusal)
        let direction = StatusCenter.Item(id: UUID(), text: "There.", kind: .refusal, isDirection: true)
        let removal = StatusCenter.Item(
            id: UUID(), text: "Gone.", action: .init(label: "Undo", perform: {}), kind: .receipt,
            leavesPage: true)
        #expect(MobileMessageLineModel.takesTouch(at: inside, doorFrame: nil, lineFrame: card, showing: refusal))
        #expect(MobileMessageLineModel.takesTouch(at: inside, doorFrame: nil, lineFrame: card, showing: direction))
        #expect(!MobileMessageLineModel.takesTouch(at: CGPoint(x: 40, y: 600), doorFrame: nil,
                                                   lineFrame: card, showing: refusal), "above it is the app's")
        #expect(!MobileMessageLineModel.takesTouch(at: inside, doorFrame: door, lineFrame: card, showing: removal),
                "a removal's ground passes the touch through")
        #expect(MobileMessageLineModel.takesTouch(
            at: CGPoint(x: door.midX, y: door.midY), doorFrame: door, lineFrame: card, showing: removal))
    }
}
