//
//  TK2SpikeUITests.swift
//  VariorumMobileUITests — Stage 0 TK2-on-iOS spike (THROWAWAY; deleted at
//  stage close, with the Spike/ folder and the TK2SpikeUITests scheme).
//
//  The real-touch half of the spike inventory: synthesized touches through
//  the actual iOS gesture/input system — the part no in-process scenario
//  can honestly measure. Runs ONLY via the throwaway TK2SpikeUITests
//  scheme (-only-testing:VariorumMobileUITests/TK2SpikeUITests); the
//  VariorumMobile scheme's test action is untouched.
//
//  Evidence channel: assertions here + the app's own
//  Documents/tk2spike-results.log (pulled after the run).
//

import XCTest

final class TK2SpikeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchBench() -> (XCUIApplication, XCUIElement, XCUIElement) {
        let app = XCUIApplication()
        app.launchEnvironment["TK2SPIKE_UI"] = "1"
        app.launch()
        let textView = app.textViews["spike.textView"]
        XCTAssertTrue(textView.waitForExistence(timeout: 15), "spike bench text view must appear")
        let status = app.staticTexts["spike.status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5), "spike status label must exist")
        return (app, textView, status)
    }

    private func statusValue(_ status: XCUIElement, _ key: String) -> String? {
        let text = status.label
        guard let range = text.range(of: "\(key)=") else { return nil }
        return String(text[range.upperBound...].prefix(while: { $0 != " " }))
    }

    /// Item 4 — horizontal swipe over the fanned block flips the peek;
    /// a second swipe flips again; storage stays untouched (app-side log).
    @MainActor
    func testHorizontalSwipeOnFannedBlockPeeks() throws {
        let (_, textView, status) = launchBench()
        sleep(1)
        guard let fracString = statusValue(status, "fanFrac"), let frac = Double(fracString),
            frac > 0, frac < 1
        else {
            XCTFail("fanFrac not published: \(status.label)")
            return
        }
        XCTAssertEqual(statusValue(status, "peek"), "0")

        // Fast horizontal drag across the fanned block.
        let start = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: frac))
        let end = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: frac))
        start.press(forDuration: 0.02, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0.05)
        sleep(1)
        XCTAssertEqual(statusValue(status, "peek"), "1", "swipe left should peek take 1: \(status.label)")

        // And back the other way.
        let start2 = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: frac))
        let end2 = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: frac))
        start2.press(forDuration: 0.02, thenDragTo: end2, withVelocity: .fast, thenHoldForDuration: 0.05)
        sleep(1)
        XCTAssertEqual(statusValue(status, "peek"), "0", "swipe right should peek back: \(status.label)")
    }

    /// Item 4 — a horizontal swipe on a NON-fanned block does nothing
    /// (the recognizer is scoped to the fanned block's fragment rects).
    @MainActor
    func testHorizontalSwipeOutsideFannedBlockDoesNotPeek() throws {
        let (_, textView, status) = launchBench()
        sleep(1)
        // The top of the view is block 0 (not fanned).
        let start = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.05))
        let end = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.05))
        start.press(forDuration: 0.02, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0.05)
        sleep(1)
        XCTAssertEqual(statusValue(status, "peek"), "0", "swipe outside the fanned block must not peek: \(status.label)")
    }

    /// Item 4 — vertical scroll coexists: a vertical swipe scrolls and does
    /// NOT flip the peek.
    @MainActor
    func testVerticalSwipeScrollsWithoutPeeking() throws {
        let (_, textView, status) = launchBench()
        sleep(1)
        let offsetBefore = statusValue(status, "offset")
        textView.swipeUp()
        sleep(1)
        // Force a status refresh via a tap (offset is stamped on refresh).
        textView.tap()
        sleep(1)
        let offsetAfter = statusValue(status, "offset")
        XCTAssertEqual(statusValue(status, "peek"), "0", "vertical swipe must not peek: \(status.label)")
        XCTAssertNotEqual(offsetBefore, offsetAfter, "vertical swipe should scroll: \(status.label)")
    }

    /// Item 5 — the extended edit menu carries the custom block items and
    /// tapping one fires its action (the M2 door, real presentation).
    @MainActor
    func testEditMenuCarriesCustomBlockItems() throws {
        let (app, textView, status) = launchBench()
        sleep(1)
        // Select a word: double-tap presents the edit menu on selection.
        textView.doubleTap()
        sleep(2)
        // The custom item may surface as a button or a menu item, possibly
        // behind the overflow chevron. Look, page once if needed, tap.
        var takes = app.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@", "Block Takes")
        ).firstMatch
        if !takes.waitForExistence(timeout: 3) {
            // Page the menu forward if an overflow arrow exists.
            let forward = app.buttons["Forward"].firstMatch
            if forward.exists { forward.tap(); sleep(1) }
            takes = app.descendants(matching: .any).matching(
                NSPredicate(format: "label == %@", "Block Takes")
            ).firstMatch
        }
        XCTAssertTrue(
            takes.waitForExistence(timeout: 3),
            "custom Block Takes item should be on the edit menu (menuCalls=\(statusValue(status, "menuCalls") ?? "?"))"
        )
        takes.tap()
        sleep(1)
        XCTAssertTrue(
            (statusValue(status, "menu") ?? "").hasPrefix("takes"),
            "tapping the item should fire its action: \(status.label)")
    }

    /// Items 3+6 — REAL keyboard typing (the genuine input pipeline):
    /// type a classic autocorrect bait; the app-side storage-edit log
    /// records whether autocorrect fired and what attributes the mutation
    /// carried. Also surfaces whether the software keyboard appeared.
    @MainActor
    func testRealTypingPipelineAndKeyboard() throws {
        let (app, textView, status) = launchBench()
        sleep(1)
        textView.tap()
        sleep(1)
        let keyboardUp = app.keyboards.count > 0
        // Type the bait regardless — with a hardware-keyboard sim the events
        // still run the input pipeline; autocorrect needs the software side.
        textView.typeText("I like teh ")
        sleep(2)
        let edits = Int(statusValue(status, "edits") ?? "0") ?? 0
        XCTAssertGreaterThan(edits, 0, "typing must land storage edits: \(status.label)")
        // Record the keyboard fact loudly in the test log for the memo.
        print("TK2SPIKE-UITEST|softwareKeyboardVisible=\(keyboardUp)|edits=\(edits)|status=\(status.label)")
    }
}
