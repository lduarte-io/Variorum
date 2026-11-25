//
//  MobileKeyboardRevealUITests.swift
//  VariorumMobileUITests
//
//  VM-47 (the walk's W-E4; W-A1 redone) — **A MID-NOTE TAP RISES ABOVE THE
//  KEYBOARD.** She taps a line in the lower half of a note; the software
//  keyboard and its bar rise over that line; the note must move so the caret
//  and what she types sit ABOVE the keyboard bar. The walk's W-E4 caught the
//  road broken on the run's first W-A1 fix (`67525b499` — the shell's band
//  clipped sideways only): the text did not move, the caret stayed under the
//  keyboard, and a typed letter landed in the note but nowhere on the visible
//  page. Main's band `.clipped()` at the safe area is what the editor's reveal
//  answers to; the redo restored it. This test holds that road where a real
//  software keyboard exists — the unit-test host raises none reliably.
//
//  RUN IT COLD (from App/Variorum/, under a held stage claim, on a DEDICATED
//  simulator — never the shared suite device; the Debug phone app's dev store):
//    xcodebuild build-for-testing -project Variorum.xcodeproj -scheme TK2SpikeUITests \
//      -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/<yours>
//    xcodebuild test-without-building -project Variorum.xcodeproj -scheme TK2SpikeUITests \
//      -destination 'id=<the dedicated simulator>' -derivedDataPath DerivedData/<yours> \
//      -only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests
//  It needs the SOFTWARE keyboard: it detaches the simulator's hardware
//  keyboard itself at its start (the walk's GraphicsServices road), presses
//  iOS's first-use keyboard card through, passes the lobby's once-shown cards
//  (never capturing the twelve words), and opens the pocket guide through
//  Settings' Debug door ("Open the pocket guide" — it seeds the guide when it
//  is missing, opens it when it is there), so it assumes no seeded library.
//  The lesson it types into is the guide's "swipe & choose"; ONE letter is
//  typed and deleted again, and the lesson's text is checked back as it was.
//
//  WHAT IT ASSERTS, and why it cannot pass when the letter is hidden:
//  · the PREMISE — the tap lands on a line BELOW the keyboard bar's top once
//    the keyboard is up (else it re-taps lower once, then fails as
//    inconclusive); and a software keyboard is up with a real height (else it
//    fails, "no software keyboard" — never a pass);
//  · THE FACT, from the screen's own pixels (XCUITest cannot read a caret
//    rect): three screenshots — S0 once the keyboard has settled, S0b 0.6 s
//    later with nothing typed (the CONTROL), S1 after one letter is typed. Only
//    the band between the editor's top and the keyboard bar's top is read. S1
//    must differ from BOTH S0 and S0b there by at least a glyph — 30 pixels
//    spanning at least 4 pt — which a caret's blink (1.7 pt wide) cannot make,
//    and the control S0→S0b must differ by no more than a caret: a page that
//    changes by itself fails as inconclusive, never passes. The top rows of
//    the band must be the same in S0 and S1: a page that moved between the
//    shots fails as inconclusive too. When the letter and the caret are under
//    the keyboard (the defect), nothing above the bar changes — RED.
//  The three screenshots and a line of frames and difference rows are kept as
//  attachments (and printed, "REVEAL …").
//
//  RE-RUN IT on any change to the shell band's clip or frame
//  (`MobileShellView.body`), the Write screen's layout (`MobileWriteView`), or
//  the editor host's keyboard handling (`MobileEditorTextView`), and with the
//  per-release device checks (TEXTKIT2_NOTES §5). It is not part of the unit
//  targets' whole-run gates.
//
//  VM-260 F-1a-W1 (the walk's s9) — **THE BAR RIDES ABOVE THE LIBRARY
//  SEARCH'S KEYBOARD** (`testTheBarRidesAboveTheLibrarySearchKeyboard`;
//  SurfaceContracts' bar line: "While the capture box or the Library search
//  holds the keyboard the bar rides above it"). The walk caught the bar 52 pt
//  low — on the keys, under the keyboard's candidate strip — on the search's
//  FIRST keyboard after a note's keyboard, whose editor wears its 52-pt bar
//  (an `inputAccessoryView`); the band's SwiftUI keyboard avoidance came out
//  short by exactly that. A real keyboard session before a real keyboard is
//  what the defect needs, so this is a UI test. Its oracle is the screen's own
//  pixels: each of the bar's three doors must draw exactly as it draws at rest
//  (no glass over it), and its frame must end above the keyboard's keys. Leg 1
//  (the search's keyboard with none before it) is the control; leg 2 (right
//  after the note's keyboard, then with the field emptied — the walk's frame)
//  is the finding. Same device, same cold-run commands, the same cleanup
//  discipline: nothing is written (a search typed and cleared, a caret placed).
//

import UIKit
import XCTest

@MainActor
final class MobileKeyboardRevealUITests: XCTestCase {
    private var app: XCUIApplication!

    /// The pocket guide's long lesson the walk's trace used.
    private static let lesson = (query: "swipe", title: "swipe & choose")

    func testAMidNoteTapRisesAboveTheKeyboard() throws {
        continueAfterFailure = false
        Self.setHardwareKeyboard(attached: false)
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20), "the app came up")
        pause(2.0)
        passLobby()
        XCTAssertTrue(button("Bookcase").waitForExistence(timeout: 10), "the shell is up (its bar's Bookcase door)")

        // The lesson: the guide through Settings' Debug door, then the Library's search.
        openThePocketGuide()
        let tv = try openTheLesson()
        let before = tv.frame
        let original = tv.value as? String
        report("the editor before the tap \(before); its text readable: \(original != nil)")

        // The tap, at the editor's centre — a line in the lower half of the note.
        var tapPoint = CGPoint(x: before.midX, y: before.midY)
        tap(at: tapPoint)
        let keyboard = try softwareKeyboardUp()
        var barTop = try keyboardBarTop(keyboard)
        if tapPoint.y <= barTop + 8 {
            // The premise does not hold here: drop the keyboard, tap lower once.
            report("the tap's y \(tapPoint.y) is not below the bar's top \(barTop) — tapping lower")
            dismissKeyboardInNote(tv)
            tapPoint = CGPoint(x: before.midX, y: min(barTop + 40, before.maxY - 20))
            tap(at: tapPoint)
            barTop = try keyboardBarTop(try softwareKeyboardUp())
        }
        guard tapPoint.y > barTop + 8 else {
            XCTFail("""
                INCONCLUSIVE: the tap at y \(tapPoint.y) lands above the keyboard bar's top \(barTop) — the \
                premise (a line the keyboard covers) does not hold on this device
                """)
            return
        }
        pause(1.0)   // the reveal's own motion settles

        let editorAfter = tv.frame
        let regionTop = editorAfter.minY + 1
        let regionBottom = barTop - 1
        guard regionBottom - regionTop > 80 else {
            XCTFail("INCONCLUSIVE: the band above the keyboard bar is \(regionBottom - regionTop) pt — too short to read")
            return
        }
        report("""
            tapped at \(tapPoint); the editor after \(editorAfter); the keyboard \(app.keyboards.firstMatch.frame); \
            the bar's top \(barTop); the band read y \(regionTop)…\(regionBottom)
            """)

        // THE FACT.
        let s0 = XCUIScreen.main.screenshot()
        pause(0.6)
        let s0b = XCUIScreen.main.screenshot()
        let typedByKey = typeOneLetter(into: tv)
        pause(0.6)
        let s1 = XCUIScreen.main.screenshot()
        keep(s0, "S0 keyboard settled")
        keep(s0b, "S0b control, nothing typed")
        keep(s1, "S1 one letter typed")

        let width = app.frame.width
        let a = try XCTUnwrap(ScreenPixels(s0, pointsWide: width), "S0 readable")
        let b = try XCTUnwrap(ScreenPixels(s0b, pointsWide: width), "S0b readable")
        let c = try XCTUnwrap(ScreenPixels(s1, pointsWide: width), "S1 readable")
        let band = regionTop...regionBottom
        let topRows = regionTop...min(regionTop + 60, regionBottom)
        let control = ScreenPixels.difference(a, b, rows: band)
        let moved = ScreenPixels.difference(a, c, rows: topRows)
        let typed = ScreenPixels.difference(a, c, rows: band)
        let typedVsControl = ScreenPixels.difference(b, c, rows: band)
        report("""
            control S0→S0b \(control.describe(a.scale)); top rows S0→S1 \(moved.describe(a.scale)); \
            typed S0→S1 \(typed.describe(a.scale)); typed S0b→S1 \(typedVsControl.describe(a.scale)); \
            the letter typed by \(typedByKey ? "the keyboard's key" : "typeText")
            """)

        // Clean up BEFORE asserting (a failed assertion stops the test).
        let restored = removeTheLetter(from: tv, original: original)
        dismissKeyboardInNote(tv)
        back()

        XCTAssertLessThanOrEqual(control.widthPoints(a.scale), 3, """
            INCONCLUSIVE: above the keyboard bar the page changed by itself between S0 and S0b \
            (\(control.describe(a.scale))) — more than a caret's blink
            """)
        XCTAssertEqual(moved.count, 0, """
            INCONCLUSIVE: the page moved between S0 and S1 (its top rows changed: \(moved.describe(a.scale)))
            """)
        for (name, diff) in [("S0→S1", typed), ("S0b→S1", typedVsControl)] {
            XCTAssertTrue(diff.count >= 30 && diff.widthPoints(a.scale) >= 4, """
                RED — the typed letter is nowhere above the keyboard bar (\(name): \(diff.describe(a.scale))): the \
                caret and the letter sit under the keyboard; the note did not rise when the keyboard did (W-E4)
                """)
        }
        if let restored {
            XCTAssertTrue(restored, "the lesson's text is as it was after the letter was deleted")
        }
    }

    // MARK: - VM-260 F-1a-W1 — the bar rides above the Library search's keyboard

    /// **RED ON OLD (predicted, leg 2): the bar stands 52 pt low — on the keys,
    /// under the candidate strip's glass — on the search's first keyboard after
    /// a note's.** Leg 1 (no keyboard before it) is the control, green on both
    /// trees. See the file header; the record is F-1a-W1 in
    /// `notes/plans/fixes/vm-260-phone-look.md`.
    func testTheBarRidesAboveTheLibrarySearchKeyboard() throws {
        // Every leg reports; the cleanup at the end always runs.
        continueAfterFailure = true
        Self.setHardwareKeyboard(attached: false)
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20), "the app came up")
        pause(2.0)
        passLobby()
        XCTAssertTrue(button("Bookcase").waitForExistence(timeout: 10), "the shell is up (its bar's Bookcase door)")
        openThePocketGuide()

        // AT REST — the Library's root with no keyboard: the bar's own drawing, the reference.
        goTab("Library")
        pause(0.6)
        XCTAssertEqual(app.keyboards.count, 0, "PREMISE: no keyboard is up at rest")
        let rest = try barShot("at rest")

        // LEG 1 — THE CONTROL: the search's keyboard with no keyboard before it (VM-47's c4 shape).
        let field = onscreen(app.textFields, wait: 3)
        XCTAssertTrue(field.waitForExistence(timeout: 4), "the Library's search field")
        field.tap()
        let firstKeyboard = try softwareKeyboardUp()
        pause(1.0)
        judgeTheBar(try barShot("leg 1"), rest: rest, keyboard: firstKeyboard,
                    leg: "LEG 1 (the control: the search's keyboard, none before it)")

        // Into the lesson, and ITS keyboard: the editor's, wearing the 52-pt bar.
        emptyTheSearch(field)
        field.typeText(Self.lesson.query)
        pause(1.4)
        let hit = onscreen(app.buttons.matching(NSPredicate(format: "label BEGINSWITH[c] %@", Self.lesson.title)))
        XCTAssertTrue(tap(hit, "the lesson's search hit"), "the lesson \"\(Self.lesson.title)\" is found")
        pause(1.8)
        let tv = onscreen(app.textViews.matching(NSPredicate(format: "label !=[c] 'Quick note'")), wait: 4)
        XCTAssertTrue(tv.waitForExistence(timeout: 4), "the lesson's editor")
        if app.keyboards.count > 0 {
            // The search's keyboard rode into the note: dropped, so the editor's is a session of its own.
            dismissKeyboardInNote(tv)
        }
        let editor = tv.frame
        tap(at: CGPoint(x: editor.midX, y: editor.midY))
        _ = try softwareKeyboardUp()
        let editorsBar = app.buttons.matching(NSPredicate(format: "identifier == 'kbar.block'")).firstMatch
        XCTAssertTrue(editorsBar.waitForExistence(timeout: 3),
                      "PREMISE: the note's keyboard wears the editor's bar (its inputAccessoryView)")
        report("the note's keyboard \(app.keyboards.firstMatch.frame); the editor's bar cell \(editorsBar.frame)")

        // Back with the keyboard up — the walk's road from s5.
        back()
        pause(1.2)

        // LEG 2 — THE FINDING: the search's keyboard right after the note's.
        if app.keyboards.count == 0 {
            let again = onscreen(app.textFields, wait: 3)
            XCTAssertTrue(again.waitForExistence(timeout: 4), "the Library's search field, back on its root")
            again.tap()
        } else {
            report("at Back the search took the keyboard back on its own (its focus restored)")
        }
        let secondKeyboard = try softwareKeyboardUp()
        pause(1.0)
        judgeTheBar(try barShot("leg 2"), rest: rest, keyboard: secondKeyboard,
                    leg: "LEG 2 (the search's keyboard right after the note's)")

        // And with the field emptied inside that same keyboard — the walk's s9 frame.
        emptyTheSearch(onscreen(app.textFields, wait: 2))
        pause(1.2)
        judgeTheBar(try barShot("leg 2, emptied"), rest: rest, keyboard: app.keyboards.firstMatch,
                    leg: "LEG 2, the field emptied (the walk's s9)")

        // Cleanup: a page change takes the keyboard down (nothing was written).
        goTab("Bookcase")
    }

    /// The bar's three doors' frames and the screen, read together.
    private struct BarShot {
        let name: String
        let doors: [String: CGRect]
        let shot: XCUIScreenshot
    }

    /// The bar's doors are the LOWEST on-screen buttons wearing the three
    /// words (no page draws those words lower than the bar does).
    private func barShot(_ name: String) throws -> BarShot {
        var doors: [String: CGRect] = [:]
        let screen = app.frame
        for word in ["Starred", "Bookcase", "Library"] {
            let query = app.buttons.matching(NSPredicate(format: "label ==[c] %@", word))
            _ = query.firstMatch.waitForExistence(timeout: 2)
            var lowest: CGRect?
            for i in 0..<min(query.count, 12) {
                let frame = query.element(boundBy: i).frame
                guard screen.contains(CGPoint(x: frame.midX, y: frame.midY)) else { continue }
                if let found = lowest, frame.minY <= found.minY { continue }
                lowest = frame
            }
            guard let lowest else {
                throw RevealStop("INCONCLUSIVE: the bar's \(word) door is not on the screen (\(name))")
            }
            doors[word] = lowest
        }
        let shot = XCUIScreen.main.screenshot()
        keep(shot, "BAR \(name)")
        return BarShot(name: name, doors: doors, shot: shot)
    }

    /// THE FACT: each door draws exactly as it does at rest (no glass over it —
    /// the walk's s9 drew the words blurred under the candidate strip), and its
    /// frame ends above the keyboard's keys.
    private func judgeTheBar(_ up: BarShot, rest: BarShot, keyboard: XCUIElement, leg: String) {
        let width = app.frame.width
        guard let a = ScreenPixels(rest.shot, pointsWide: width),
              let b = ScreenPixels(up.shot, pointsWide: width) else {
            XCTFail("INCONCLUSIVE: \(leg) — a screenshot could not be read")
            return
        }
        let keys = keyboard.exists ? keyboard.frame : .null
        var lines = ["\(leg): the keyboard \(keys)"]
        for word in ["Starred", "Bookcase", "Library"] {
            guard let atRest = rest.doors[word], let now = up.doors[word] else { continue }
            let same = ScreenPixels.sameDrawing(a, at: atRest.insetBy(dx: 2, dy: 2), b, at: now.insetBy(dx: 2, dy: 2))
            lines.append("\(word) at rest \(atRest) · now \(now) · ink \(same.ink) px · differing \(same.differing) px")
            XCTAssertGreaterThanOrEqual(same.ink, 40, """
                INCONCLUSIVE: \(leg) — the resting \(word) door draws no word to compare (\(same.ink) px of ink)
                """)
            XCTAssertLessThanOrEqual(same.differing, max(12, same.ink / 10), """
                RED — \(leg): the bar's \(word) door does not draw as it does at rest (\(same.differing) of its \
                \(same.ink) ink pixels differ) — something covers it: the bar is under the keyboard's glass
                """)
            if keyboard.exists {
                XCTAssertLessThanOrEqual(now.maxY, keys.minY + 0.5, """
                    RED — \(leg): the bar's \(word) door ends at y \(now.maxY), on the keyboard's keys (their top \
                    \(keys.minY)) — the bar does not ride above the keyboard
                    """)
            }
        }
        report(lines.joined(separator: "\n"))
    }

    /// The search field emptied by the keyboard's own deletes (an empty field
    /// reads its placeholder back, so a few spare deletes are harmless).
    private func emptyTheSearch(_ field: XCUIElement) {
        guard field.exists, let text = field.value as? String, !text.isEmpty else { return }
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count + 2))
    }

    // MARK: - The road to the lesson

    private func openThePocketGuide() {
        goTab("Bookcase")
        // VM-255 (the VM-260 run): the roots' ⋯ menu became a Settings gear — one
        // press opens Settings, no menu between.
        let settings = onscreen(app.buttons.matching(NSPredicate(format: "label ==[c] %@", "Settings")))
        guard tap(settings, "the Bookcase's Settings gear") else { return }
        pause(1.0)
        if tap(button("Open the pocket guide"), "Settings ▸ Open the pocket guide") {
            pause(4.0)
        }
        if button("Done").exists { tap(button("Done"), "Settings' Done"); pause(0.8) }
        back()
    }

    private func openTheLesson() throws -> XCUIElement {
        goTab("Library")
        let field = onscreen(app.textFields, wait: 3)
        XCTAssertTrue(field.waitForExistence(timeout: 4), "the Library's search field")
        field.tap()
        pause(0.4)
        passKeyboardCard()
        if let text = field.value as? String, !text.isEmpty {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count + 2))
        }
        field.typeText(Self.lesson.query)
        pause(1.4)
        let hit = onscreen(app.buttons.matching(NSPredicate(format: "label BEGINSWITH[c] %@", Self.lesson.title)))
        XCTAssertTrue(tap(hit, "the lesson's search hit"), "the lesson \"\(Self.lesson.title)\" is found")
        pause(1.8)
        let tv = onscreen(app.textViews.matching(NSPredicate(format: "label !=[c] 'Quick note'")), wait: 4)
        XCTAssertTrue(tv.waitForExistence(timeout: 4), "the lesson's editor")
        if app.keyboards.count > 0 {
            // The tap must be the act that raises the keyboard over the line.
            report("a keyboard was still up on arrival — dropped before the tap")
            dismissKeyboardInNote(tv)
        }
        XCTAssertEqual(app.keyboards.count, 0, "no keyboard is up before the tap")
        return tv
    }

    // MARK: - The keyboard

    private func softwareKeyboardUp() throws -> XCUIElement {
        pause(1.4)
        passKeyboardCard()
        let keyboard = app.keyboards.firstMatch
        guard keyboard.waitForExistence(timeout: 4), keyboard.frame.height > 100 else {
            let frame = keyboard.exists ? "\(keyboard.frame)" : "none"
            throw RevealStop("""
                FAIL — no software keyboard rose after the tap (keyboards: \(app.keyboards.count); frame \(frame)) \
                — this test needs the software keyboard
                """)
        }
        return keyboard
    }

    /// The keyboard bar's top: its block cell's top less the cell's own air,
    /// never below the keyboard's own top.
    private func keyboardBarTop(_ keyboard: XCUIElement) throws -> CGFloat {
        let cell = app.buttons.matching(NSPredicate(format: "identifier == 'kbar.block'")).firstMatch
        guard cell.waitForExistence(timeout: 3) else {
            throw RevealStop("INCONCLUSIVE: the keyboard bar's block cell (kbar.block) is not on screen")
        }
        return min(cell.frame.minY - 10, keyboard.frame.minY)
    }

    /// ONE letter, by the keyboard's own key (either case), else typed into
    /// the focused editor. True when the key was used.
    private func typeOneLetter(into tv: XCUIElement) -> Bool {
        let key = app.keyboards.keys.matching(NSPredicate(format: "label ==[c] %@", "x")).firstMatch
        if key.exists, key.isHittable {
            key.tap()
            return true
        }
        tv.typeText("x")
        return false
    }

    /// Deletes the one letter when it is PROVEN to have landed (the text grew
    /// by one), or sends one delete when the text cannot be read (and says so).
    /// Returns whether the text reads as it did (nil: unreadable).
    private func removeTheLetter(from tv: XCUIElement, original: String?) -> Bool? {
        let typed = tv.value as? String
        guard let original, let typed else {
            report("the text cannot be read — ONE delete sent unproven")
            sendOneDelete(tv)
            return nil
        }
        guard typed.count == original.count + 1 else {
            report("the text did not grow by one (\(original.count) → \(typed.count)) — nothing deleted")
            return typed == original
        }
        sendOneDelete(tv)
        pause(0.4)
        let now = tv.value as? String
        report(now == original ? "the lesson reads as it did" : "!!! the lesson does NOT read as it did — look by hand")
        return now == original
    }

    private func sendOneDelete(_ tv: XCUIElement) {
        let key = app.keyboards.keys.matching(
            NSPredicate(format: "label ==[c] 'delete' OR identifier ==[c] 'delete'")).firstMatch
        if key.exists, key.isHittable { key.tap() } else { tv.typeText(XCUIKeyboardKey.delete.rawValue) }
    }

    /// The keyboard down over a note: a drag down from inside the prose (never
    /// Return — Return in a note is structural).
    private func dismissKeyboardInNote(_ tv: XCUIElement) {
        guard app.keyboards.count > 0 else { return }
        passKeyboardCard(wait: 0.3)
        for _ in 0..<2 where app.keyboards.count > 0 {
            tv.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99)))
            pause(0.8)
        }
        if app.keyboards.count > 0 { report("the keyboard stays up after two drags") }
    }

    /// The simulator's HARDWARE keyboard, attached or not (GraphicsServices'
    /// setter, from any process — the walk's road). Detached: a focused text
    /// view raises the software keyboard a phone shows.
    static func setHardwareKeyboard(attached: Bool) {
        typealias Setter = @convention(c) (Bool, Int32) -> Void
        guard let handle = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_NOW),
              let symbol = dlsym(handle, "GSEventSetHardwareKeyboardAttached") else { return }
        unsafeBitCast(symbol, to: Setter.self)(attached, 0)
    }

    /// iOS's own first-use keyboard card ("Speed up your typing by sliding your
    /// finger across the letters…") — pressed through by ITS Continue, only
    /// while its sentence is on screen.
    private func passKeyboardCard(wait: Double = 0.6) {
        let sentence = app.descendants(matching: .any).matching(NSPredicate(
            format: "label CONTAINS[c] 'sliding your finger' OR label CONTAINS[c] 'speed up your typing'")).firstMatch
        guard sentence.waitForExistence(timeout: wait) else { return }
        let word = NSPredicate(format: "label ==[c] 'Continue'")
        let inKeyboard = app.keyboards.buttons.matching(word).firstMatch
        let door = inKeyboard.exists ? inKeyboard : app.buttons.matching(word).firstMatch
        if door.exists, door.isHittable { door.tap(); pause(0.8) }
    }

    // MARK: - The lobby, finders, acts

    /// Before the shell: the first launch's once-shown words card (pressed
    /// through, never captured) and anything an open may owe.
    private func passLobby() {
        let shell = app.buttons.matching(NSPredicate(format: "label ==[c] %@", "Bookcase"))
        let doors = [
            NSPredicate(format: "label CONTAINS[c] %@", "written them down"),
            NSPredicate(format: "label ==[c] %@", "Not now"),
            NSPredicate(format: "label ==[c] %@", "Always ask instead"),
            NSPredicate(format: "label ==[c] %@", "OK"),
        ]
        let deadline = Date().addingTimeInterval(40)
        while Date() < deadline {
            if shell.firstMatch.exists { return }
            for predicate in doors {
                let door = app.buttons.matching(predicate).firstMatch
                if door.exists, door.isHittable { door.tap(); pause(2.0); break }
            }
            pause(0.5)
        }
    }

    /// The first ON-SCREEN, hittable match (the band keeps three roots alive a
    /// screen-width apart).
    private func onscreen(_ query: XCUIElementQuery, wait: Double = 2.5) -> XCUIElement {
        let first = query.firstMatch
        _ = first.waitForExistence(timeout: wait)
        let n = query.count
        if n <= 1 { return first }
        let screen = app.frame
        var fallback: XCUIElement?
        for i in 0..<min(n, 24) {
            let e = query.element(boundBy: i)
            let f = e.frame
            guard screen.contains(CGPoint(x: f.midX, y: min(max(f.midY, screen.minY + 1), screen.maxY - 1))) else { continue }
            if e.isHittable { return e }
            if fallback == nil { fallback = e }
        }
        return fallback ?? first
    }

    private func button(_ label: String) -> XCUIElement {
        onscreen(app.buttons.matching(NSPredicate(format: "label ==[c] %@ OR identifier == %@", label, label)))
    }

    @discardableResult
    private func tap(_ element: XCUIElement, _ what: String, timeout: Double = 4) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { report("MISSING \(what)"); return false }
        var swipes = 0
        while !element.isHittable && swipes < 6 {
            let f = element.frame
            if f.midY > app.frame.maxY * 0.75 { app.swipeUp(velocity: .slow) }
            else if f.midY < app.frame.minY + 120 { app.swipeDown(velocity: .slow) }
            else { break }
            swipes += 1
        }
        if element.isHittable {
            element.tap()
        } else {
            report("NOT-HITTABLE \(what) — its centre tapped")
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        return true
    }

    /// A tap at a point on the screen, in points.
    private func tap(at point: CGPoint) {
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: point.x, dy: point.y))
            .tap()
    }

    private func goTab(_ label: String) { tap(button(label), "the bar's \(label)"); pause(0.9) }

    private func back() {
        let navBack = onscreen(app.navigationBars.buttons, wait: 1.5)
        if navBack.exists, navBack.isHittable { navBack.tap() }
        pause(0.9)
    }

    private func pause(_ seconds: Double) { Thread.sleep(forTimeInterval: seconds) }

    private func report(_ line: String) {
        print("REVEAL \(line)")
        let note = XCTAttachment(string: line)
        note.name = "REVEAL"
        note.lifetime = .keepAlways
        add(note)
    }

    private func keep(_ shot: XCUIScreenshot, _ name: String) {
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

/// A stop with its reason — the test fails with these words (never a skip).
private struct RevealStop: Error, CustomStringConvertible, LocalizedError {
    let description: String
    init(_ description: String) { self.description = description }
    var errorDescription: String? { description }
}

/// A screenshot as sRGB pixels, row 0 at the top. Its scale is measured
/// (pixels ÷ the screen's points), never assumed.
@MainActor
private struct ScreenPixels {
    let width: Int
    let height: Int
    let scale: CGFloat
    let bytes: [UInt8]

    init?(_ shot: XCUIScreenshot, pointsWide: CGFloat) {
        guard let cg = shot.image.cgImage, pointsWide > 0,
              let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let width = cg.width, height = cg.height
        var buffer = [UInt8](repeating: 0, count: width * height * 4)
        let drew = buffer.withUnsafeMutableBytes { raw -> Bool in
            guard let context = CGContext(
                data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: width * 4, space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drew else { return nil }
        self.width = width
        self.height = height
        self.scale = CGFloat(width) / pointsWide
        self.bytes = buffer
    }

    /// Where two screenshots differ (a channel by more than 24 of 255), over
    /// the full width, inside the rows given in points.
    struct Difference {
        var count = 0
        var minX = Int.max, maxX = Int.min, minY = Int.max, maxY = Int.min

        func widthPoints(_ scale: CGFloat) -> CGFloat {
            count == 0 ? 0 : CGFloat(maxX - minX + 1) / scale
        }

        func describe(_ scale: CGFloat) -> String {
            guard count > 0 else { return "no pixel differs" }
            let x0 = CGFloat(minX) / scale, x1 = CGFloat(maxX + 1) / scale
            let y0 = CGFloat(minY) / scale, y1 = CGFloat(maxY + 1) / scale
            return String(format: "%d px differ, x %.1f…%.1f, y %.1f…%.1f (%.1f pt wide)",
                          count, x0, x1, y0, y1, x1 - x0)
        }
    }

    /// One drawing in two places (F-1a-W1): the rect `ra` of `a` against the
    /// same-sized rect `rb` of `b`, pixel for pixel. `ink` counts the pixels
    /// of `a`'s rect that differ from its own top-left pixel (its ground) —
    /// the words and the chip, what there is to compare; `differing` counts the
    /// pixels where the two places differ (a channel by more than 24 of 255).
    /// A rect off either screen reads as nothing comparable (no ink).
    static func sameDrawing(
        _ a: ScreenPixels, at ra: CGRect, _ b: ScreenPixels, at rb: CGRect
    ) -> (ink: Int, differing: Int) {
        let w = Int((min(ra.width, rb.width) * a.scale).rounded(.down))
        let h = Int((min(ra.height, rb.height) * a.scale).rounded(.down))
        let ax = Int((ra.minX * a.scale).rounded()), ay = Int((ra.minY * a.scale).rounded())
        let bx = Int((rb.minX * b.scale).rounded()), by = Int((rb.minY * b.scale).rounded())
        guard w > 0, h > 0, a.scale == b.scale,
              ax >= 0, ay >= 0, ax + w <= a.width, ay + h <= a.height,
              bx >= 0, by >= 0, bx + w <= b.width, by + h <= b.height
        else { return (0, 0) }
        func delta(_ p: [UInt8], _ i: Int, _ q: [UInt8], _ j: Int) -> Int {
            max(abs(Int(p[i]) - Int(q[j])), abs(Int(p[i + 1]) - Int(q[j + 1])),
                abs(Int(p[i + 2]) - Int(q[j + 2])))
        }
        let ground = (ay * a.width + ax) * 4
        var ink = 0, differing = 0
        for y in 0..<h {
            for x in 0..<w {
                let i = ((ay + y) * a.width + ax + x) * 4
                let j = ((by + y) * b.width + bx + x) * 4
                if delta(a.bytes, i, a.bytes, ground) > 24 { ink += 1 }
                if delta(a.bytes, i, b.bytes, j) > 24 { differing += 1 }
            }
        }
        return (ink, differing)
    }

    static func difference(_ a: ScreenPixels, _ b: ScreenPixels, rows: ClosedRange<CGFloat>) -> Difference {
        var found = Difference()
        guard a.width == b.width, a.height == b.height else {
            found.count = Int.max
            return found
        }
        let y0 = max(Int(rows.lowerBound * a.scale), 0)
        let y1 = min(Int(rows.upperBound * a.scale), a.height - 1)
        guard y0 <= y1 else { return found }
        for y in y0...y1 {
            for x in 0..<a.width {
                let i = (y * a.width + x) * 4
                let delta = max(abs(Int(a.bytes[i]) - Int(b.bytes[i])),
                                abs(Int(a.bytes[i + 1]) - Int(b.bytes[i + 1])),
                                abs(Int(a.bytes[i + 2]) - Int(b.bytes[i + 2])))
                guard delta > 24 else { continue }
                found.count += 1
                found.minX = min(found.minX, x); found.maxX = max(found.maxX, x)
                found.minY = min(found.minY, y); found.maxY = max(found.maxY, y)
            }
        }
        return found
    }
}
