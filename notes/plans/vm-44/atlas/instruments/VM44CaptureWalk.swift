//
//  VM44CaptureWalk.swift — THROWAWAY (VM-44 capture atlas). NEVER COMMITTED.
//
//  Lives in notes/plans/vm-44/atlas/instruments/; copied into the throwaway
//  worktree ~/dev/variorum-vm44-capture/App/Variorum/VariorumMobileUITests/ only so it
//  compiles into the UI test bundle. Run through the TK2SpikeUITests scheme (the shared
//  scheme whose test action is VariorumMobileUITests — no scheme edits), under a held
//  stage claim, on the dedicated "MobileCatchup Capture" simulator, by UDID:
//
//    TEST_RUNNER_ATLAS_DIR=<dir> TEST_RUNNER_ATLAS_PREFIX=<prefix> xcodebuild test-without-building \
//      -project Variorum.xcodeproj -scheme TK2SpikeUITests -destination "id=<UDID>" \
//      -derivedDataPath "$HOME/Library/Developer/Xcode/DerivedData/mobilecatchup-capture" \
//      -only-testing:VariorumMobileUITests/VM44CaptureWalk
//
//  It only NAVIGATES and HOLDS each surface; every capture is XCUIScreen's framebuffer PNG
//  written straight to the atlas folder (plus a keepAlways attachment in the xcresult). A
//  missing element is LOGGED to <dir>/walk-log.txt and the walk moves on (soft by design —
//  one moved button must not cost the rest of the atlas). It never signs in, never presses
//  Resume or Sync, never types a secret.
//

import XCTest

// MARK: - Shared machinery

class VM44CaptureBase: XCTestCase {
    var app: XCUIApplication!

    var outDir: String {
        ProcessInfo.processInfo.environment["ATLAS_DIR"]
            ?? "notes/plans/vm-44/atlas/screens"
    }
    var prefix: String { ProcessInfo.processInfo.environment["ATLAS_PREFIX"] ?? "" }

    override func setUpWithError() throws {
        continueAfterFailure = true
        try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
        Self.forceSoftwareKeyboard()
        app = XCUIApplication()
    }

    /// Headless simulators sit in hardware-keyboard mode; this flips the device to the software
    /// keyboard system-wide (the VM-10 record's road: GraphicsServices' setter, from any process).
    static func forceSoftwareKeyboard() {
        typealias Setter = @convention(c) (Bool, Int32) -> Void
        guard let handle = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_NOW),
              let symbol = dlsym(handle, "GSEventSetHardwareKeyboardAttached") else { return }
        unsafeBitCast(symbol, to: Setter.self)(false, 0)
    }

    func log(_ line: String) {
        let path = outDir + "/walk-log.txt"
        let stamped = "\(ISO8601DateFormatter().string(from: Date()))  \(name)  \(line)\n"
        if let handle = FileHandle(forWritingAtPath: path) {
            handle.seekToEndOfFile()
            handle.write(stamped.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? stamped.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }

    /// The capture: settle, then the framebuffer PNG to disk + a kept attachment.
    func shot(_ name: String, settle: Double = 0.8) {
        Thread.sleep(forTimeInterval: settle)
        let screenshot = XCUIScreen.main.screenshot()
        let file = "\(outDir)/\(prefix)\(name).png"
        do { try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: file)) } catch {
            log("WRITE-FAILED \(file): \(error)")
        }
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = prefix + name
        attachment.lifetime = .keepAlways
        add(attachment)
        log("SHOT \(prefix)\(name)")
    }

    /// The phone's voice is a device-local UserDefaults preference (`MobileVoicePreference.key`); the
    /// launch argument puts it in the argument domain for this launch only — nothing persisted.
    /// ATLAS_VOICE = study | terminal (unset = whatever the device holds; the app's default is terminal).
    /// NOTE: the phone has NO palette road (every token site calls the palette-less two-parameter
    /// resolver), so no launch setting can put it in the sea-glass — the captures show Classic colours.
    func launch() {
        if let voice = ProcessInfo.processInfo.environment["ATLAS_VOICE"], !voice.isEmpty {
            app.launchArguments = ["-io.lduarte.variorum.mobile.themeVoice", voice]
        }
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 15)
        Thread.sleep(forTimeInterval: 1.5)
    }

    // Element finders — labels are matched case-insensitively (the Terminal voice lowercases chrome).
    //
    // PHASE B FIX: the shell's BAND keeps all three pages (Starred · Shelf · Library) alive side by
    // side, each with its OWN tab bar, path line and doors, offset a screen-width apart and clipped.
    // `firstMatch` therefore routinely resolved to an OFF-SCREEN copy (the Starred page's "Library"
    // door), the old scroll loop swiped eight times and then tapped off-screen. Every finder now
    // resolves to the first match whose centre is ON the screen (hittable preferred).
    func onscreen(_ q: XCUIElementQuery, wait: Double = 2.5) -> XCUIElement {
        let first = q.firstMatch
        _ = first.waitForExistence(timeout: wait)
        let n = q.count
        if n <= 1 { return first }
        let screen = app.frame
        var fallback: XCUIElement? = nil
        for i in 0..<min(n, 16) {
            let e = q.element(boundBy: i)
            let f = e.frame
            guard screen.contains(CGPoint(x: f.midX, y: min(max(f.midY, screen.minY + 1), screen.maxY - 1))) else { continue }
            if e.isHittable { return e }
            if fallback == nil { fallback = e }
        }
        return fallback ?? first
    }
    func any(_ label: String) -> XCUIElement {
        onscreen(app.descendants(matching: .any)
            .matching(NSPredicate(format: "label ==[c] %@ OR identifier == %@", label, label)))
    }
    func button(_ label: String) -> XCUIElement {
        onscreen(app.buttons.matching(NSPredicate(format: "label ==[c] %@ OR identifier == %@", label, label)))
    }
    func buttonBeginning(_ prefix: String) -> XCUIElement {
        onscreen(app.buttons.matching(NSPredicate(format: "label BEGINSWITH[c] %@", prefix)))
    }
    func idBeginning(_ prefix: String) -> XCUIElement {
        onscreen(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix)))
    }
    var editor: XCUIElement { onscreen(app.textViews, wait: 3) }
    var searchField: XCUIElement { onscreen(app.textFields, wait: 3) }

    func isOnOtherPage(_ element: XCUIElement) -> Bool {
        let f = element.frame, s = app.frame
        return f.midX < s.minX || f.midX > s.maxX
    }

    @discardableResult
    func tap(_ element: XCUIElement, _ what: String, timeout: Double = 4) -> Bool {
        guard element.waitForExistence(timeout: timeout) else {
            log("MISSING \(what)")
            return false
        }
        if !element.isHittable { scrollUntilHittable(element) }
        if element.isHittable {
            element.tap()
        } else if isOnOtherPage(element) {
            log("OFFSCREEN \(what) (only an off-screen band page holds it)")
            return false
        } else {
            log("NOT-HITTABLE \(what) — tapped its centre anyway")
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        return true
    }
    @discardableResult
    func tap(_ label: String, timeout: Double = 4) -> Bool { tap(button(label), label, timeout: timeout) }

    func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 5) {
        var n = 0
        let s = app.frame
        while !element.isHittable && n < maxSwipes {
            if isOnOtherPage(element) { return }      // another band page: scrolling cannot help
            let f = element.frame
            if f.midY > s.maxY * 0.75 { app.swipeUp(velocity: .slow) }
            else if f.midY < s.minY + 120 { app.swipeDown(velocity: .slow) }
            else { return }                            // on screen but covered (a keyboard, a sheet)
            n += 1
        }
    }

    func longPress(_ element: XCUIElement, _ what: String) -> Bool {
        guard element.waitForExistence(timeout: 4) else { log("MISSING \(what)"); return false }
        if !element.isHittable { scrollUntilHittable(element) }
        element.press(forDuration: 1.2)
        return true
    }

    /// PHASE B FIX: a tap on the status bar (dy 0.06) does not close a context menu. Prefer the
    /// system's own dismiss region, else tap the dimmed backdrop low on the screen (menus open
    /// near the pressed row, and the walk's rows sit in the upper half).
    func dismissMenu(at point: CGVector = CGVector(dx: 0.5, dy: 0.95)) {
        let region = app.descendants(matching: .any).matching(NSPredicate(
            format: "identifier ==[c] 'PopoverDismissRegion' OR label ==[c] 'dismiss popup' OR label ==[c] 'dismiss context menu'")).firstMatch
        if region.exists, region.isHittable { region.tap() }
        else { app.coordinate(withNormalizedOffset: point).tap() }
        Thread.sleep(forTimeInterval: 0.7)
    }
    /// In the editor the keyboard owns the bottom of the screen; close a bar menu by tapping the
    /// masthead's empty band (left of the title, above the prose) instead.
    func dismissEditorMenu() { dismissMenu(at: CGVector(dx: 0.5, dy: 0.10)) }

    /// The shelf's books region is a BOUNDED list under the quick-entry box; `+ New Book` is its
    /// last row. Swipe the region (never the page) until the element is hittable.
    func revealInBooksRegion(_ element: XCUIElement, max: Int = 8) {
        let region = idBeginning("shelf.booksRegion")
        var n = 0
        while element.exists && !element.isHittable && n < max {
            if region.exists { region.swipeUp(velocity: .slow) } else { app.swipeUp(velocity: .slow) }
            n += 1
        }
    }

    func back() {
        let navBack = onscreen(app.navigationBars.buttons, wait: 1.5)
        if navBack.waitForExistence(timeout: 1.5), navBack.isHittable {
            navBack.tap()
        } else {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)))
        }
        Thread.sleep(forTimeInterval: 0.8)
    }

    func done() {
        if !tap(button("Done"), "Done", timeout: 2) {
            app.swipeDown(velocity: .fast)
        }
        Thread.sleep(forTimeInterval: 0.6)
    }

    func cancelAlert() {
        let cancel = app.alerts.buttons.matching(NSPredicate(format: "label ==[c] 'Cancel'")).firstMatch
        if cancel.waitForExistence(timeout: 2) { cancel.tap() } else { log("MISSING alert Cancel") }
        Thread.sleep(forTimeInterval: 0.5)
    }

    func goTab(_ label: String) { tap(label) ; Thread.sleep(forTimeInterval: 0.6) }

    /// PHASE B FIX: a tap at the top of the screen dismisses nothing on this app. The editor's text
    /// view is `.interactive` (drag down into the keyboard); a single-line field ends editing on
    /// Return. NEVER call this with the quick-note box focused (Return there is a newline) — leave
    /// the shelf by a tab instead (leaving files the box).
    func dismissKeyboard() {
        guard app.keyboards.count > 0 else { return }
        let text = app.textViews.matching(NSPredicate(format: "label !=[c] 'Quick note'"))
        let tv = onscreen(text, wait: 0.5)
        let editorOnScreen = tv.exists && !isOnOtherPage(tv)
        if editorOnScreen {
            for _ in 0..<2 where app.keyboards.count > 0 {
                tv.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                    .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99)))
                Thread.sleep(forTimeInterval: 0.8)
            }
            // NEVER press Return with an editor on screen — Return in a note is a structural act
            // (the first pass split a paragraph of the seeded commonplace note this way).
            if app.keyboards.count > 0 { log("KEYBOARD-STAYS (editor) after drag attempts") }
            return
        }
        if app.keyboards.count > 0 {
            let ret = app.keyboards.buttons.matching(NSPredicate(
                format: "label IN[c] {'return', 'search', 'done', 'go', 'next'}")).firstMatch
            if ret.exists { ret.tap(); Thread.sleep(forTimeInterval: 0.6) }
        }
        if app.keyboards.count > 0 { log("KEYBOARD-STAYS after dismiss attempts") }
    }

    /// Library ▸ search ▸ the first hit whose label begins with `title`.
    @discardableResult
    func openNote(search query: String, title: String) -> Bool {
        goTab("Library")
        let field = searchField
        guard field.waitForExistence(timeout: 4) else { log("MISSING library search field"); return false }
        field.tap()
        field.typeText(query)
        Thread.sleep(forTimeInterval: 1.2)
        let hit = buttonBeginning(title)
        let ok = tap(hit, "search hit \(title)")
        Thread.sleep(forTimeInterval: 1.5)
        return ok
    }

    func clearLibrarySearch() {
        let field = searchField
        guard field.exists else { return }
        field.tap()
        if let text = field.value as? String, !text.isEmpty {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count + 2))
        }
        dismissKeyboard()
    }

    func openBookOnShelf(_ name: String) -> Bool {
        goTab("Shelf")
        let row = buttonBeginning(name)
        guard row.waitForExistence(timeout: 4) else { log("MISSING shelf row \(name)"); return false }
        var n = 0
        let region = idBeginning("shelf.booksRegion")
        while !row.isHittable && n < 10 {
            if region.exists { region.swipeUp(velocity: .slow) } else { app.swipeUp(velocity: .slow) }
            n += 1
        }
        tap(row, "shelf row \(name)")
        Thread.sleep(forTimeInterval: 1.2)
        return true
    }
}

// MARK: - First run (a FRESH install, before the seed)

final class VM44CaptureFirstRun: VM44CaptureBase {
    func test01_firstLaunchAndFirstWrite() {
        launch()
        shot("00-first-launch")
        if any("I've written them down").waitForExistence(timeout: 6) {
            shot("00-words-card-REDACT-ME")
            tap("I've written them down")
            Thread.sleep(forTimeInterval: 2)
        } else {
            log("NOTE no words card at first launch (state shot taken)")
        }
        shot("01-empty-shelf")
        goTab("Library"); shot("01-empty-library")
        goTab("Starred"); shot("01-empty-starred")
        goTab("Shelf")
        let box = any("Quick note")
        if tap(box, "quick note box") {
            Thread.sleep(forTimeInterval: 1)
            shot("01-empty-quick-entry-focused")
            box.typeText("First note, typed on the phone")
            shot("01-first-write-typed")
            // (no dismissKeyboard here: Return in the box is a newline; leaving the shelf files the box)
            goTab("Library")
            Thread.sleep(forTimeInterval: 4)   // the first-write furniture lands (Journal + the Prince)
            shot("01-library-after-first-write")
            goTab("Starred"); shot("01-starred-after-first-write")
            goTab("Shelf"); shot("01-shelf-after-first-write")
        }
    }
}

// MARK: - The main walk (the SEEDED store)

final class VM44CaptureWalk: VM44CaptureBase {

    func test01_shelf() {
        launch()
        goTab("Shelf")
        shot("10-shelf-rest")
        let region = idBeginning("shelf.booksRegion")
        if region.exists { region.swipeUp(velocity: .slow); shot("10-shelf-books-scrolled") ; region.swipeDown(velocity: .fast) }
        if longPress(buttonBeginning("Essays"), "Essays row") { shot("11-shelf-book-longpress-menu"); dismissMenu() }
        if longPress(buttonBeginning("Journal"), "Journal row") { shot("11-shelf-journal-longpress-menu"); dismissMenu() }
        let newBook = button("New Book")
        revealInBooksRegion(newBook)
        if tap(newBook, "+ New Book") { Thread.sleep(forTimeInterval: 0.8); shot("12-create-book-sheet"); tap("Cancel") }
        if region.exists { region.swipeDown(velocity: .fast); region.swipeDown(velocity: .fast) }
        if tap(button("Trash"), "Trash door (shelf)") { shot("13-trash-from-shelf"); back() }
        goTab("Starred"); shot("14-starred-page")
        // the band swipe between pages (start of a drag, held)
        goTab("Shelf")
        let a = app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.45))
        a.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.45)))
        shot("14-after-band-swipe-left")
    }

    func test02_quickEntry() {
        launch()
        goTab("Shelf")
        let box = any("Quick note")
        shot("20-quick-entry-at-rest")
        guard tap(box, "quick note box") else { return }
        Thread.sleep(forTimeInterval: 1.2)
        shot("21-quick-entry-focused-keyboard")
        box.typeText("Walk note: the ferry timetable changes in December")
        shot("22-quick-entry-typed")
        // PHASE B: Return in the box OPENS the note (⏎ opens it) — a wrapped second line is typed instead.
        box.typeText(", and the morning boat now leaves at seven forty")
        shot("22-quick-entry-typed-two-lines")
        if tap(button("Open this note in the editor"), "open ↵ door") {
            Thread.sleep(forTimeInterval: 1.5)
            shot("23-quick-entry-opened-note")
            back()
        }
        shot("24-shelf-after-quick-note-filed")
    }

    func test03_library() {
        launch()
        goTab("Library")
        shot("30-library-rest-all")
        app.swipeUp(velocity: .slow); shot("30-library-scrolled-1")
        app.swipeUp(velocity: .slow); app.swipeUp(velocity: .slow); shot("30-library-scrolled-2")
        app.swipeDown(velocity: .fast); app.swipeDown(velocity: .fast); app.swipeDown(velocity: .fast)
        for filter in ["Books", "Notes", "Bookless", "Scraps"] {
            if tap(button(filter), "filter \(filter)") { shot("31-library-filter-\(filter.lowercased())") }
        }
        tap(button("All"), "filter All")
        if tap(buttonBeginning("Sort"), "sort menu") { shot("32-library-sort-menu"); dismissMenu() }
        let field = searchField
        if tap(field, "search field") {
            shot("33-library-search-focused")
            field.typeText("lighthouse")
            Thread.sleep(forTimeInterval: 1.2)
            shot("33-library-search-lighthouse")
            clearLibrarySearch()
        }
        if longPress(buttonBeginning("Grocery list"), "note row Grocery list") { shot("34-library-note-longpress-menu"); dismissMenu() }
        // PHASE B: the Archived door is the LAST row of the list — under All it sits ~150 rows down
        // (lazy, absent from the tree); the short Bookless list shows it on the first screen.
        tap(button("Bookless"), "filter Bookless")
        if tap(button("Archived"), "Archived row") { Thread.sleep(forTimeInterval: 0.8); shot("35-archive-room"); back() }
        tap(button("All"), "filter All")
        if tap(button("Trash"), "Trash door (library)") {
            shot("36-trash-room")
            app.swipeUp(velocity: .slow); shot("36-trash-room-scrolled")
            back()
        }
    }

    func test04_books() {
        launch()
        if openBookOnShelf("Essays") {
            shot("40-book-essays-contents")
            if tap(button("Details"), "Details") { shot("41-book-details-sheet"); done() }
            if tap(button("Read"), "Read door") {
                shot("42-book-read-view")
                app.swipeUp(velocity: .slow); shot("42-book-read-view-scrolled")
                back()
            }
            back()
        }
        if openBookOnShelf("Blog drafts") {
            shot("43-book-chapters")
            if tap(buttonBeginning("+ New Chapter"), "+ New Chapter") { shot("43-new-chapter-alert"); cancelAlert() }
            back()
        }
        if openBookOnShelf("Journal") { shot("44-book-daily-journal"); back() }
        if openBookOnShelf("Quotes") { shot("45-gathering-quotes"); back() }
        if openBookOnShelf("Ideas inbox") { shot("46-book-ideas-inbox-arrivals"); back() }
        if openBookOnShelf("Letters") { shot("47-book-finished-letters"); back() }
        if openBookOnShelf("The Lighthouse Keeper") {
            shot("48-book-lighthouse-chapters-pinned")
            if tap(button("Details"), "Details") { shot("48-book-details-lighthouse"); done() }
            back()
        }
        if openBookOnShelf("the prince") { shot("49-book-the-prince"); back() }
        if openBookOnShelf("Receipts") { shot("49-book-empty-receipts"); back() }
    }

    func test05_noteMasthead() {
        launch()
        guard openNote(search: "commonplace", title: "On keeping a commonplace book") else { return }
        shot("50-note-write-rest")
        let chips: [(String, String)] = [
            ("Books holding this note", "51-note-membership-sheet"),
            ("Tags", "52-note-tags-sheet"),
            ("More Info", "53-note-more-info-sheet"),
            ("Blocks", "54-note-blocks-sheet"),
            ("Lenses", "55-note-lenses-sheet"),
            ("Note Actions", "56-note-actions-sheet"),
        ]
        for (label, name) in chips {
            if tap(button(label), label) {
                shot(name)
                if label == "Blocks", tap(button("Select blocks"), "Select blocks") { shot("54-note-blocks-picking") ; tap(button("Done picking"), "Done picking") }
                done()
            }
        }
        if tap(button("Entry Date"), "Entry Date") { shot("57-note-entry-date-alert"); cancelAlert() }
        if tap(button("Rename Note"), "Rename Note") { shot("58-note-rename-alert"); cancelAlert() }
        if tap(button("Find in Note"), "Find in Note") { shot("59-note-find-navigator"); dismissKeyboard() }
        if tap(button("Copy Note"), "Copy Note") { shot("59-note-copied-receipt") }
    }

    func test06_editor() {
        launch()
        guard openNote(search: "commonplace", title: "On keeping a commonplace book") else { return }
        let text = editor
        guard tap(text, "editor text view") else { return }
        Thread.sleep(forTimeInterval: 1.2)
        shot("60-editor-keyboard-bar-rest")
        if tap(button("Formatting"), "Aa") {
            shot("61-editor-formatting-strip")
            if longPress(button("Heading"), "Heading") { shot("61-editor-heading-menu"); dismissEditorMenu() }
            tap(button("Hide Formatting"), "× hide formatting")
        }
        if tap(button("Block"), "kbar ⋯ block menu") {
            shot("62-editor-block-menu")
            if tap(button("Callout"), "Callout submenu") { shot("62-editor-callout-submenu") }
            dismissEditorMenu()
        }
        if tap(button("Block"), "kbar ⋯ (comments)") {
            if tap(button("Comments…"), "Comments…") {
                shot("63-comments-sheet")
                tap(any("comments.done"), "comments Done")
            } else { dismissEditorMenu() }
        }
        // the selection edit menu (Takes… · Extract · Make Block)
        text.doubleTap()
        Thread.sleep(forTimeInterval: 1.0)
        shot("64-editor-selection-edit-menu")
        dismissEditorMenu()
        if tap(button("Block"), "kbar ⋯ (new block below)") {
            if tap(button("New Block Below"), "New Block Below") {
                shot("65-editor-structural-receipt-undo")
                tap(button("Undo"), "receipt Undo")
                shot("65-editor-after-undo")
            } else { dismissEditorMenu() }
        }
        dismissKeyboard()
        shot("66-editor-keyboard-down")
    }

    func test07_takes() {
        launch()
        guard openNote(search: "commonplace", title: "On keeping a commonplace book") else { return }
        let badge = idBeginning("takes.badge.")
        if badge.waitForExistence(timeout: 4) {
            shot("70-takes-badge-on-fanned-block")
            // swipe-peek across the fanned block's line
            let text = editor
            let y = (badge.frame.midY - text.frame.minY) / max(1, text.frame.height)
            let start = text.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: y))
            start.press(forDuration: 0.02, thenDragTo: text.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: y)),
                        withVelocity: .fast, thenHoldForDuration: 0.05)
            Thread.sleep(forTimeInterval: 0.8)
            shot("71-takes-peek-pill")
            tap(any("takes.pill.previous"), "pill previous")
        } else { log("MISSING takes badge") }
        let text = editor
        tap(text, "editor (for ⑂)")
        Thread.sleep(forTimeInterval: 1)
        // put the caret in the first block, then ⑂
        text.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.02)).tap()
        if tap(button("Takes"), "kbar ⑂") {
            Thread.sleep(forTimeInterval: 1)
            shot("72-takes-browser")
            if tap(idBeginning("takes.card.menu"), "take card ⋯") {
                shot("73-take-card-menu")
                if tap(buttonBeginning("Block History"), "Block History…") {
                    shot("74-block-history-sheet")
                    tap(button("Done"), "history Done")
                } else { dismissEditorMenu() }
            }
            tap(any("takes.browser.done"), "browser Done")
        }
        dismissKeyboard()
    }

    func test08_specialNotes() {
        launch()
        if openNote(search: "export subset", title: "Spec — export subset") { shot("80-note-sealed"); back() }
        clearLibrarySearch()
        if openNote(search: "Full draft", title: "Full draft") {
            shot("81-long-note-top")
            for _ in 0..<6 { app.swipeUp(velocity: .fast) }
            shot("81-long-note-scrolled")
            back()
        }
        clearLibrarySearch()
        if openNote(search: "night of the storm", title: "The night of the storm") {
            shot("82-note-heavy-fan-callout-comments")
            app.swipeUp(velocity: .slow); shot("82-note-heavy-fan-scrolled")
            if tap(button("Note Actions"), "Note Actions") {
                if tap(buttonBeginning("Versions"), "Versions…") { shot("83-versions-screen"); back() } else { done() }
            }
            if tap(button("Blocks"), "Blocks") { app.swipeUp(velocity: .slow); shot("84-note-tray-in-blocks-sheet"); done() }
            back()
        }
        clearLibrarySearch()
        if openNote(search: "pencil", title: "Why I write in pencil first") {
            if tap(button("Note Actions"), "Note Actions") {
                if tap(buttonBeginning("Versions"), "Versions…") { shot("85-versions-with-saved-version"); back() } else { done() }
            }
            back()
        }
        // Today's entry (journal) — opens for writing, keyboard up.
        goTab("Shelf")
        if tap(button("Today's Entry"), "today badge") {
            Thread.sleep(forTimeInterval: 1.5)
            shot("86-today-entry-keyboard")
            dismissKeyboard()
            back()
        }
    }

    func test09_settings() {
        launch()
        goTab("Shelf")
        guard tap(button("Settings"), "Settings") else { return }
        shot("90-settings-sheet")
        app.swipeUp(velocity: .slow); shot("90-settings-sheet-swiped")
        if tap(button("Manage Tags"), "Manage Tags") {
            shot("91-tag-manager")
            if longPress(any("#life"), "tag row life") { shot("91-tag-manager-row-menu"); dismissMenu() }
            done()
        }
        if tap(button("Acknowledgments"), "Acknowledgments") { shot("92-acknowledgments"); done() }
        if tap(button("Open the edit trace"), "Edit trace…") { shot("93-edit-trace"); done() }
        // PHASE B: the dev store's Sync row reads "Sync off (dev store)" — no sign-in door there;
        // the Protection screen carries "Sign in…" (opened, captured, cancelled — NEVER typed into).
        if tap(button("Protection…"), "Protection…") {
            shot("95-protection-screen")
            app.swipeUp(velocity: .slow); shot("95-protection-screen-scrolled")
            if tap(buttonBeginning("Sign in"), "Protection ▸ Sign in…") {
                Thread.sleep(forTimeInterval: 1)
                shot("94-account-sheet-signed-out")
                if !tap(button("Cancel"), "account Cancel", timeout: 2) { done() }
            }
            back()
        }
    }
}

// MARK: - Extras (PHASE B: the confirm-then-Cancel rows and prompts the inventory left to hand).
// Every destructive door here opens its CONFIRM and is cancelled — nothing is deleted.

final class VM44CaptureExtras: VM44CaptureBase {
    func cancelAny() {
        let alertCancel = app.alerts.buttons.matching(NSPredicate(format: "label ==[c] 'Cancel'")).firstMatch
        if alertCancel.waitForExistence(timeout: 2) { alertCancel.tap() }
        else if !tap(button("Cancel"), "Cancel", timeout: 1.5) { log("NOTE no Cancel found — dismissing"); dismissMenu() }
        Thread.sleep(forTimeInterval: 0.6)
    }

    func test01_shelfAndLibraryConfirms() {
        launch()
        goTab("Shelf")
        if longPress(buttonBeginning("Essays"), "Essays row") {
            if tap(buttonBeginning("Delete Book"), "Delete Book…") {
                Thread.sleep(forTimeInterval: 0.8); shot("15-delete-book-confirm"); cancelAny()
            } else { dismissMenu() }
        }
        goTab("Library")
        if longPress(buttonBeginning("Grocery list"), "Grocery list row") {
            if tap(buttonBeginning("Delete Note"), "Delete Note… (row)") {
                Thread.sleep(forTimeInterval: 0.8); shot("34-library-delete-note-confirm"); cancelAny()
            } else { dismissMenu() }
        }
        let field = searchField
        if tap(field, "search field") {
            field.typeText("zzqxv")
            Thread.sleep(forTimeInterval: 1.2)
            shot("33-library-search-nothing-found")
            clearLibrarySearch()
        }
        // full-body search check: a word that lives only in note BODIES of the seed
        if tap(searchField, "search field (body word)") {
            searchField.typeText("ferry")
            Thread.sleep(forTimeInterval: 1.2)
            shot("33-library-search-body-word-ferry")
            clearLibrarySearch()
        }
        if tap(button("Scraps"), "filter Scraps") {
            if tap(buttonBeginning("+ new scrap"), "+ new scrap") {
                Thread.sleep(forTimeInterval: 0.8); shot("31-library-new-scrap-alert"); cancelAny()
            }
            tap(button("All"), "filter All")
        }
        if tap(button("Trash"), "Trash door (library)") {
            Thread.sleep(forTimeInterval: 0.8)
            if tap(button("Delete Now"), "Delete Now") {
                Thread.sleep(forTimeInterval: 0.8); shot("36-trash-delete-now-confirm"); cancelAny()
            }
            if tap(buttonBeginning("Empty Trash"), "Empty Trash…") {
                Thread.sleep(forTimeInterval: 0.8); shot("36-trash-empty-confirm"); cancelAny()
            }
            back()
        }
    }

    func test02_noteConfirmsAndPrompts() {
        launch()
        guard openNote(search: "commonplace", title: "On keeping a commonplace book") else { return }
        if tap(button("More Info"), "More Info") {
            if tap(buttonBeginning("+ add a link"), "+ add a link") {
                Thread.sleep(forTimeInterval: 0.8); shot("53-note-add-link-alert"); cancelAny()
            }
            done()
        }
        if tap(button("Note Actions"), "Note Actions") {
            if tap(buttonBeginning("Delete Note"), "Delete Note… (actions)") {
                Thread.sleep(forTimeInterval: 0.8); shot("56-note-delete-confirm"); cancelAny()
            }
            if button("Done").exists { done() }
        }
        let text = editor
        if tap(text, "editor") {
            Thread.sleep(forTimeInterval: 1.2)
            if tap(button("Block"), "kbar ⋯") {
                if tap(buttonBeginning("Name Block"), "Name Block…") {
                    Thread.sleep(forTimeInterval: 0.8); shot("62-editor-name-block-prompt"); cancelAny()
                } else { dismissEditorMenu() }
            }
            text.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.02)).tap()
            if tap(button("Takes"), "kbar ⑂") {
                Thread.sleep(forTimeInterval: 1)
                if tap(idBeginning("takes.card.menu"), "take card ⋯") {
                    if tap(buttonBeginning("Label Take"), "Label Take…") {
                        Thread.sleep(forTimeInterval: 0.8); shot("73-take-label-prompt"); cancelAny()
                    } else { dismissEditorMenu() }
                }
                tap(any("takes.browser.done"), "browser Done")
            }
            dismissKeyboard()
        }
    }

    func test03_bookRename() {
        launch()
        if openBookOnShelf("Essays") {
            if tap(button("Details"), "Details") {
                if tap(button("Rename Book"), "Rename Book") {
                    Thread.sleep(forTimeInterval: 0.8); shot("41-book-rename-alert"); cancelAny()
                }
                done()
            }
            back()
        }
    }
}


extension VM44CaptureExtras {
    func test04_settingsBits() {
        launch()
        goTab("Shelf")
        guard tap(button("Settings"), "Settings") else { return }
        if tap(button("Manage Tags"), "Manage Tags") {
            if longPress(any("#life"), "tag row life") {
                shot("91-tag-manager-row-menu")
                if tap(buttonBeginning("Rename"), "Rename…") {
                    Thread.sleep(forTimeInterval: 0.8); shot("91-tag-rename-alert"); cancelAny()
                } else { dismissMenu() }
            }
            done()
        }
        if tap(button("Protection…"), "Protection…") {
            if tap(buttonBeginning("Sign in"), "Protection ▸ Sign in…") {
                Thread.sleep(forTimeInterval: 1)
                shot("94-account-sheet-signed-out")
                // NEVER typed into — straight back out
                if !tap(button("Cancel"), "account Cancel", timeout: 2) { done() }
            }
            back()
        }
    }

    func test05_todayEntry() {
        launch()
        goTab("Shelf")
        if tap(button("Today's Entry"), "today badge") {
            Thread.sleep(forTimeInterval: 1.5)
            shot("86-today-entry-keyboard")
            dismissKeyboard()
            back()
        }
    }

    func test06_noteTray() {
        launch()
        guard openNote(search: "night of the storm", title: "The night of the storm") else { return }
        if tap(button("Blocks"), "Blocks") {
            if tap(button("leaving"), "tray leaving") { Thread.sleep(forTimeInterval: 0.6); shot("84-note-tray-leaving") }
            if tap(button("archived"), "tray archived") { Thread.sleep(forTimeInterval: 0.6); shot("84-note-tray-archived") }
            done()
        }
    }

    /// Run with `simctl ui <udid> content_size extra-extra-extra-large` set by the host, then reset.
    func test07_settingsLargeText() {
        launch()
        goTab("Shelf")
        shot("96-shelf-xxxl-text")
        guard tap(button("Settings"), "Settings") else { return }
        Thread.sleep(forTimeInterval: 0.8)
        shot("96-settings-xxxl-text")
        app.swipeUp(velocity: .slow)
        shot("96-settings-xxxl-text-swiped")
        let trace = button("Open the edit trace")
        log("XXXL: edit-trace door exists=\(trace.exists) hittable=\(trace.isHittable) frame=\(trace.frame)")
        let spike = buttonBeginning("TK2")
        log("XXXL: TK2 Spike door exists=\(spike.exists) hittable=\(spike.isHittable) frame=\(spike.frame)")
        done()
    }
}

// MARK: - Variants (re-run under another appearance / voice / text size; prefix names the variant)

final class VM44CaptureVariants: VM44CaptureBase {
    func test01_coreSet() {
        launch()
        goTab("Shelf"); shot("V1-shelf")
        let box = any("Quick note")
        if tap(box, "quick note") { Thread.sleep(forTimeInterval: 1); shot("V2-quick-entry-focused") }
        goTab("Library"); shot("V3-library")
        if openNote(search: "commonplace", title: "On keeping a commonplace book") {
            shot("V4-note-write")
            if tap(editor, "editor") {
                Thread.sleep(forTimeInterval: 1); shot("V5-editor-keyboard-bar")
                if tap(button("Formatting"), "Aa") { shot("V6-formatting-strip"); tap(button("Hide Formatting"), "×") }
                dismissKeyboard()
            }
            back()
        }
        goTab("Shelf")
        if tap(button("Settings"), "Settings") { shot("V7-settings"); done() }
    }

    /// PHASE B part 2: Settings alone (test01's V7 can miss when the pop from the note lands late).
    func test02_settings() {
        launch()
        goTab("Shelf")
        if tap(button("Settings"), "Settings") { Thread.sleep(forTimeInterval: 0.8); shot("V7-settings"); done() }
    }

    /// Voice switch through the app's own Settings door (phone-local preference).
    func test90_setVoiceStudy() { setVoice("Study") }
    func test91_setVoiceTerminal() { setVoice("Terminal") }
    private func setVoice(_ voice: String) {
        launch()
        goTab("Shelf")
        guard tap(button("Settings"), "Settings") else { return }
        tap(buttonBeginning(voice), "voice \(voice)")
        done()
    }
}

// MARK: - Recordings (one method per clip; the host runs `simctl io recordVideo` around each)

final class VM44CaptureRecordings: VM44CaptureBase {
    private func mark(_ what: String) { log("MARK \(what) at \(Date().timeIntervalSince1970)") }

    func test01_tapIntoQuickEntry() {
        launch(); goTab("Shelf"); Thread.sleep(forTimeInterval: 2)
        mark("tap quick entry")
        tap(any("Quick note"), "quick note")
        Thread.sleep(forTimeInterval: 3)
        any("Quick note").typeText("timing the quick entry")
        Thread.sleep(forTimeInterval: 2)
    }

    func test02_quickEntryToNote() {
        launch(); goTab("Shelf")
        let box = any("Quick note")
        tap(box, "quick note"); Thread.sleep(forTimeInterval: 1)
        box.typeText("from quick entry into the note")
        Thread.sleep(forTimeInterval: 1.5)
        mark("tap open")
        tap(button("Open this note in the editor"), "open ↵")
        Thread.sleep(forTimeInterval: 4)
    }

    func test03_openLongNote() {
        launch(); goTab("Library")
        let field = searchField
        if tap(field, "search") { field.typeText("Full draft"); Thread.sleep(forTimeInterval: 1.5); dismissKeyboard() }
        mark("tap long note")
        tap(buttonBeginning("Full draft"), "long note hit")
        Thread.sleep(forTimeInterval: 5)
        for _ in 0..<4 { app.swipeUp(velocity: .fast) }
        Thread.sleep(forTimeInterval: 2)
    }

    func test04_scrollLibrary() {
        launch(); goTab("Library"); Thread.sleep(forTimeInterval: 2)
        mark("scroll")
        for _ in 0..<6 { app.swipeUp(velocity: .default) }
        for _ in 0..<6 { app.swipeDown(velocity: .fast) }
        Thread.sleep(forTimeInterval: 1.5)
    }
}
