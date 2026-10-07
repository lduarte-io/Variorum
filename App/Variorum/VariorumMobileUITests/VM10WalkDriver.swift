//
//  VM10WalkDriver.swift — THROWAWAY (deleted after the VM-10 walk; the
//  parity round's FIX-1 precedent: a driver that only navigates and holds
//  each surface on the REAL app, real touches through the real gesture
//  system). Captures land in the gitignored notes/plans/vm-10-screens/.
//

import XCTest

final class VM10WalkDriver: XCTestCase {
    private let dir = "<home>/dev/variorum-vm-10/notes/plans/vm-10-screens"
    private var app: XCUIApplication!

    private func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        try? png.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func element(_ query: XCUIElementQuery, containing text: String) -> XCUIElement {
        query.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).firstMatch
    }

    /// The first HITTABLE match — every page of the band wears its own tab
    /// bar, so the first label match can be an off-screen copy.
    private func tapVisible(_ query: XCUIElementQuery, containing text: String, timeout: TimeInterval = 10) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            let matches = query.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).allElementsBoundByIndex
            if let hit = matches.first(where: { $0.exists && $0.isHittable }) {
                hit.tap()
                return true
            }
            usleep(300_000)
        } while Date() < deadline
        return false
    }

    private func softwareKeyboard() {
        guard let h = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_NOW),
              let sym = dlsym(h, "GSEventSetHardwareKeyboardAttached") else { return }
        typealias F = @convention(c) (Bool, UInt8) -> Void
        unsafeBitCast(sym, to: F.self)(false, 0)
    }

    private func goBack() {
        let back = app.buttons["Back"].firstMatch
        if back.waitForExistence(timeout: 2) {
            back.tap()
        } else {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
        }
        sleep(1)
    }

    /// The END-of-note road, walked as she journals: the Today entry, the
    /// caret at the end, paragraph after paragraph typed with ⏎ until the
    /// text outgrows the keyboard-up page; then her scroll back up; then a
    /// re-entry through the Today door (the session memory + focus).
    @MainActor
    func testWalkEnd() throws {
        continueAfterFailure = true
        softwareKeyboard()
        app = XCUIApplication()
        app.launch()
        sleep(3)
        _ = tapVisible(app.buttons, containing: "later", timeout: 3)
        sleep(1)
        XCTAssertTrue(tapVisible(app.buttons, containing: "Today's Entry"))
        sleep(3)
        let tv = app.textViews.firstMatch
        XCTAssertTrue(tv.waitForExistence(timeout: 5))
        // Her finger in the room below the text: the caret goes to the end.
        tv.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45)).tap()
        sleep(1)
        shot("07a-today-entry-caret-at-end")
        tv.typeText("\n")
        for n in 1...9 {
            tv.typeText("Journal paragraph \(n), a few more words so it fills a line or two of the page.")
            tv.typeText("\n")
            usleep(400_000)
            if n == 5 || n == 7 { sleep(1); shot("07b-after-return-\(n)") }
        }
        sleep(2)
        shot("07c-return-at-the-end-of-a-growing-entry")
        // Her scroll back up — and she waits.
        tv.swipeDown(velocity: .slow)
        sleep(1)
        shot("08a-scrolled-back-up-after-return")
        sleep(3)
        shot("08b-scrolled-back-up-3s-later")
        // She carries on typing: the caret's line is revealed minimally.
        tv.typeText("and on")
        sleep(2)
        shot("08c-typing-again-after-scrolling-up")
        // Re-entry through the Today door: her place and her caret.
        goBack()
        sleep(1)
        XCTAssertTrue(tapVisible(app.buttons, containing: "Today's Entry"))
        sleep(3)
        shot("09a-today-door-re-entry-remembers")
        tv.typeText(" again")
        sleep(2)
        shot("09b-today-door-re-entry-typing")
    }

    @MainActor
    func testWalk() throws {
        continueAfterFailure = true
        softwareKeyboard()
        app = XCUIApplication()
        app.launch()
        sleep(3)
        shot("00-launch")
        // The encryption nudge sits over the shelf's path line: "later".
        _ = tapVisible(app.buttons, containing: "later", timeout: 3)
        sleep(1)

        // Seed the long note (the DEBUG fixture door; find-or-seed).
        if !tapVisible(app.buttons, containing: "Settings") {
            print("VM10WALK tree: \(app.debugDescription)")
            XCTFail("no Settings door")
        }
        sleep(1)
        let seed = element(app.buttons, containing: "100k fixture")
        if seed.waitForExistence(timeout: 5) {
            for _ in 0..<4 where !seed.isHittable { app.swipeUp() }
            seed.tap()
            let done = app.staticTexts.matching(NSPredicate(
                format: "label CONTAINS[c] 'seeded'")).firstMatch
            _ = done.waitForExistence(timeout: 180)
        }
        shot("00b-seeded")
        _ = tapVisible(app.buttons, containing: "done", timeout: 3)
        sleep(1)

        // 1 · A long note opened cold shows its first lines.
        XCTAssertTrue(tapVisible(app.buttons, containing: "Library"))
        sleep(1)
        XCTAssertTrue(tapVisible(app.buttons, containing: "the short walk"), "the short walk row")
        sleep(3)
        shot("01-long-note-opened-cold")

        // 2 · A note left mid-way re-opens there.
        let tv = app.textViews.firstMatch
        XCTAssertTrue(tv.waitForExistence(timeout: 5))
        tv.swipeUp(velocity: .slow)
        tv.swipeUp(velocity: .slow)
        sleep(2)
        shot("02a-left-mid-way")
        goBack()
        shot("02b-back-in-library")
        XCTAssertTrue(tapVisible(app.buttons, containing: "the short walk"))
        sleep(3)
        shot("02c-reopened-where-left")

        // 3 · ⏎ mid-note does not jump to empty page.
        tv.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.40)).tap()
        sleep(2)
        shot("03a-caret-mid-note")
        tv.typeText("\n")
        sleep(2)
        shot("03b-return-mid-note")

        // 4 · ⏎ at the END (the bug's home) shows text, not empty page.
        for _ in 0..<12 { tv.swipeUp(velocity: .fast) }
        sleep(3)
        shot("04a-scrolled-into-the-room-by-her-own-swipes")
        tv.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6)).tap()
        sleep(2)
        shot("04b-tapped-the-room-caret-at-end")
        tv.typeText("A last line typed on the walk.")
        sleep(1)
        tv.typeText("\n")
        sleep(2)
        shot("04c-return-at-the-end")
        tv.typeText("\n")
        sleep(2)
        shot("04d-second-return-at-the-end")

        // 5 · Scroll-up after ⏎ sticks (her drag down, then she waits).
        tv.swipeDown(velocity: .slow)
        sleep(1)
        shot("05a-scrolled-up-after-return")
        sleep(3)
        shot("05b-scrolled-up-3s-later-still-there")
        // …and the next keystroke reveals the caret minimally.
        tv.typeText("x")
        sleep(2)
        shot("05c-typing-again-reveals-the-caret-line")

        // 6 · The Today door's straight-into-typing arrival.
        goBack()
        _ = tapVisible(app.buttons, containing: "Shelf")
        sleep(1)
        if tapVisible(app.buttons, containing: "Today's Entry") {
            sleep(3)
            shot("06a-today-door-arrival")
            app.typeText("Typed straight in from the Today door.")
            sleep(2)
            shot("06b-today-door-typing")
        } else {
            shot("06-today-door-missing")
        }
    }
}
