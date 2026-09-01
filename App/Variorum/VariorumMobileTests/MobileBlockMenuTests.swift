//
//  MobileBlockMenuTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 4, batch 1 — the ⋯ block menu's brains: the one-builder
//  vocabulary (two doors, zero drift), the callout transform through the
//  standing op, Name, Delete Block, the comments controller's CRUD +
//  never-skimpy deleted section, and the block decor's overlays (real
//  laid-out geometry — the S2 chrome suite's pattern).
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

@MainActor
private func seedTwoBlockPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, blockB: String, b1: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "menu", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block here.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "Second block here.", at: .end)
        return (post.id, a.block.id, a.variant.id, b.block.id, b.variant.id)
    }
}

@MainActor
private func storedPresentation(_ db: AppDatabase, blockID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT presentation FROM block WHERE id = ?", arguments: [blockID])
    }
}

@MainActor
private func storedName(_ db: AppDatabase, blockID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT name FROM block WHERE id = ?", arguments: [blockID])
    }
}

@MainActor
private func liveCommentTexts(_ db: AppDatabase, blockID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT text FROM block_comment
                WHERE block_id = ? AND deleted_at IS NULL
                ORDER BY created_at, id
                """,
            arguments: [blockID])
    }
}

@MainActor
private func makeDecorSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    return (model, surface)
}

// MARK: - The menu vocabulary

@MainActor
@Suite("Mobile block menu — the one builder (S4 batch 1)")
struct MobileBlockMenuTests {
    @Test func theTwoDoorsShareOneVocabulary() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Rendered titles are VOICE-CASED since parity A3 (P26/P43's
            // ruled flip — the world runs terminal, so lowercase); the
            // constants stay the canonical vocabulary. This pin's old
            // uncased comparison is the SANCTIONED flip.
            let cased = { MobileEditorStyle.chromeCase($0) }

            // The bar's ⋯ renders the WHOLE row set.
            let barElements = model.blockMenu.menuElements(blockID: seed.blockA)
            let barTitles = barElements.map(\.title)
            #expect(barTitles == MobileBlockMenuController.rowTitles.map(cased))
            #expect(barTitles.first == "comments…", "terminal chrome lowercases")

            // **SANCTIONED FLIP (batch 9):** the two doors now render the
            // IDENTICAL list. The `includeTakes:` split existed only to keep
            // `Takes…` out of the edit menu's Block submenu, which carries
            // its own flat one — and her letter retired the row, so the
            // split had nothing left to suppress. One builder, one list,
            // no arm.
            //
            // **Read through the SEAM, not the builder twice** (batch 9's
            // fix wave, cold-review NIT 1): with the arm gone, calling
            // `menuElements` a second time and comparing to the same
            // oracle pinned nothing the line above had not. The claim
            // that WAS unpinned is the one `MobileEditMenuSeam` makes —
            // that the edit menu's Block submenu is this same list — so
            // this half now composes the real edit menu and reads that
            // submenu's children.
            //
            // **Red on old (behavioural revert):** drop a row on the way
            // through the seam (`.dropLast()` on `menuElements`'s result
            // in `MobileEditMenuSeam`) and this reds while the bar's own
            // assertion above stays green.
            let composed = MobileEditMenu.menu(
                model: model, range: NSRange(location: 1, length: 0), suggested: [])
            let blockSubmenu = try #require(
                composed.children.first { $0.title == cased("Block") } as? UIMenu)
            #expect(blockSubmenu.children.map(\.title)
                == MobileBlockMenuController.rowTitles.map(cased))

            // The callout submenu's words are the Mac CalloutMenu's rows,
            // mirrored (toggle · five colors · emoji · remove).
            let callout = try #require(
                barElements.first {
                    $0.title == cased(MobileBlockMenuController.calloutTitle)
                } as? UIMenu)
            #expect(callout.children.map(\.title)
                == MobileBlockMenuController.calloutRowTitles.map(cased))
            #expect(MobileBlockMenuController.calloutRowTitles
                == ["Toggle Callout", "Blue", "Green", "Sand", "Violet", "Rose",
                    "Emoji…", "Remove Callout"])

            // **PR19 (batch 7) — THE DRIFT PIN IS EXTENDED, NEVER
            // WEAKENED.** The row WORDS above are untouched: no row was
            // added, an image was hung on the FIVE that existed (the
            // palette is blue · green · sand · violet · rose — the literal
            // list two assertions above says so, and the fix wave corrected
            // the "four" this comment used to claim; cold review NIT 1).
            // What is new is
            // the composition claim — the COLOUR rows wear a swatch and the
            // non-colour rows do not, which is the Mac `CalloutMenu.Row`'s
            // own `swatch` nil-ness rule (nil on toggle, emoji and Remove:
            // Remove takes a frame AWAY rather than choosing one).
            //
            // **Red on old (behavioural revert):** drop `image:` from the
            // colour rows' `UIAction` in `calloutSubmenu` and the first
            // half reds; hang one on Remove and the second half does.
            let colourWords = Set(MobileCallout.names.map { cased($0.capitalized) })
            for row in callout.children.compactMap({ $0 as? UIAction }) {
                if colourWords.contains(row.title) {
                    #expect(row.image != nil,
                            "a colour row wears its colour (PR19)")
                } else {
                    #expect(row.image == nil,
                            "\(row.title) names no colour, so it wears no swatch")
                }
            }
            // And the swatch is a PREVIEW of the one palette, never a second
            // source of truth: it is built from `MobileCallout.color(_:)`,
            // and it must NOT be a template image — UIKit would recolour a
            // template to the menu's tint, which is the one thing a colour
            // chip must not be (the Mac's `isTemplate = false`, exactly).
            let swatch = MobileCallout.swatchImage(for: "sand")
            #expect(swatch.renderingMode == .alwaysOriginal)
            #expect(swatch.size == CGSize(width: MobileCallout.swatchSize,
                                          height: MobileCallout.swatchSize))

            // Delete is the destructive row (the card-⋯ grammar).
            let delete = try #require(
                barElements.first {
                    $0.title == cased(MobileBlockMenuController.deleteTitle)
                } as? UIAction)
            #expect(delete.attributes.contains(.destructive))

            // The STUDY register keeps normal case (discrimination — the
            // register follows the voice, never a hardcoded lowering).
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let studyTitles = model.blockMenu.menuElements(blockID: seed.blockA).map(\.title)
            #expect(studyTitles == MobileBlockMenuController.rowTitles)
        }
    }

    /// P26/P43's sweep, the rest of the register (parity A3): the edit
    /// menu's Takes… + Block submenu titles, the bar's tail refusal row,
    /// and the A1 seal-door strings (PA1-1 resolved — the recorded
    /// system-register wording joins the ONE voice register) all case
    /// with the voice.
    @Test func theEditMenuAndSealDoorsSpeakTheOneRegister() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // The edit menu's own items (suggested actions excluded here)
            // render cased in terminal…
            let composed = MobileEditMenu.menu(
                model: model, range: NSRange(location: 1, length: 0), suggested: [])
            #expect(composed.children.map(\.title) == ["takes…", "block"])
            // …and uncased in study (the register follows the voice).
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let studyComposed = MobileEditMenu.menu(
                model: model, range: NSRange(location: 1, length: 0), suggested: [])
            #expect(studyComposed.children.map(\.title) == ["Takes…", "Block"])

            // The bar's open-tail refusal row is menu-grammared chrome.
            #expect(MobileEditorStyle.chromeCase(
                "Tap into a block first — block acts live on blocks.")
                == "Tap into a block first — block acts live on blocks.",
                "study keeps the sentence as written")

            // The seal door's strings render through the same rule on the
            // SwiftUI side (`tokens.chromeLabel`).
            #expect(VoiceTokens.terminalLight.chromeLabel(MobileWriteScreen.sealedStateLine)
                    == "this note is locked — reading only.")
            #expect(VoiceTokens.terminalLight.chromeLabel(MobileWriteScreen.unlockDoorTitle)
                    == "unlock note")
            #expect(VoiceTokens.studyLight.chromeLabel(MobileWriteScreen.unlockDoorTitle)
                    == "Unlock Note")
            #expect(MobileWriteScreen.lockDoorTitle == "Lock Note")
        }
    }

    // MARK: Callout (M12 — the mirrored transform through the op)

    @Test func calloutEditsWriteTheStoredFrameThroughTheOp() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Toggle ON: the default blue frame.
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .toggle)
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"blue","kind":"callout"}"#)
            // The projection follows (the decor's bookkeeping).
            #expect(model.presentations[seed.blockA]?.color == "blue")

            // A color keeps the emoji; an emoji keeps the color — the
            // read-modify-write runs INSIDE the op's transaction.
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .emoji("🕯"))
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"blue","emoji":"🕯","kind":"callout"}"#)
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .color("sand"))
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"sand","emoji":"🕯","kind":"callout"}"#)

            // An EMPTY emoji is a real answer — "no glyph" (the Mac
            // prompt's semantics).
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .emoji(""))
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"sand","kind":"callout"}"#)

            // Remove: a plain block again (NULL, never "{}").
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .color(nil))
            #expect(try await storedPresentation(db, blockID: seed.blockA) == nil)
            #expect(model.presentations[seed.blockA] == nil)
            // The neighbor never moved.
            #expect(try await storedPresentation(db, blockID: seed.blockB) == nil)
        }
    }

    // MARK: - PR19's emoji road (batch 7)

    /// **The RULE, pinned against fakes.** `UITextInputMode` has no public
    /// initializer, so the selection rule is lifted out of
    /// `MobileEmojiTextField.textInputMode` into a pure function — which is
    /// exactly where a typo would silently disable the whole feature (the
    /// override would just keep returning `super`, i.e. the ordinary
    /// keyboard, and nothing would look broken).
    ///
    /// **Red on old (behavioural revert):** change `emojiLanguage` to
    /// anything else, or `first { … == }` to `first { … != }`, and both
    /// halves red.
    @Test func theEmojiKeyboardRuleFindsTheEmojiModeAndFallsBackWhenThereIsNone() {
        struct Mode { let language: String? }
        let withEmoji = [Mode(language: "en-US"), Mode(language: "emoji"),
                         Mode(language: "fr-FR")]
        #expect(MobileEmojiKeyboard.emojiMode(
            in: withEmoji, primaryLanguage: \.language)?.language == "emoji")

        // THE FALLBACK ARM, which is the one that ships to a user who
        // removed the emoji keyboard: nil, so the field returns
        // `super.textInputMode` — the ordinary keyboard, i.e. exactly the
        // prompt that shipped before this batch. Structural, not promised.
        let withoutEmoji = [Mode(language: "en-US"), Mode(language: nil)]
        #expect(MobileEmojiKeyboard.emojiMode(
            in: withoutEmoji, primaryLanguage: \.language) == nil)
        #expect(MobileEmojiKeyboard.emojiMode(
            in: [Mode](), primaryLanguage: \.language) == nil)
    }

    /// **THE EMOJI SHEET STAYS USABLE AT ACCESSIBILITY TEXT SIZES** (the
    /// batch-7 fix wave, cold review MINOR 4).
    ///
    /// As shipped, the sheet fixed itself at one hard 220 pt detent over a
    /// stack pinned leading/trailing/top ONLY — no bottom constraint, no
    /// scroll. `.headline` and `.footnote` both scale and the message wraps
    /// to more lines, so at accessibility sizes the Cancel/Set row was
    /// pushed past the sheet's bottom with nothing to scroll it back: the
    /// only road out was swipe-to-dismiss, which is a CANCEL, so the emoji
    /// could never be SET at large text sizes. MobileSoul §5.6 names
    /// Dynamic Type as a phone-native expectation.
    ///
    /// The content now scrolls (and the detent clamps, with `.medium()`
    /// beside it so the sheet may grow). Driven at an accessibility size in
    /// a real window: the stack outgrows the detent, and `Set` is still
    /// reachable — inside the scroll's content, with somewhere to scroll to.
    ///
    /// **Red on old (behavioural revert):** pin the stack straight to
    /// `view` again (drop the scroll wrapper) and the `#require` for the
    /// scroll reds, with the reachability assertions behind it.
    @Test func theEmojiSheetsButtonsStayReachableAtAccessibilityTextSizes() async throws {
        let controller = MobileEmojiPromptController(
            title: "Callout Emoji",
            message: "One character. Leave it empty to remove the emoji.",
            completion: { _ in })
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 220))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }

        // The largest system text size, applied the way iOS applies it.
        controller.traitOverrides.preferredContentSizeCategory =
            .accessibilityExtraExtraExtraLarge
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()

        func descendant(_ root: UIView, _ id: String) -> UIView? {
            for child in root.subviews {
                if child.accessibilityIdentifier == id { return child }
                if let found = descendant(child, id) { return found }
            }
            return nil
        }
        let scroll = try #require(
            descendant(controller.view, "callout.emoji.scroll") as? UIScrollView)
        let set = try #require(descendant(controller.view, "callout.emoji.set"))

        // The content genuinely outgrows the sheet at this size — which is
        // exactly what used to push the buttons off it.
        #expect(scroll.contentSize.height > scroll.bounds.height,
                "content \(scroll.contentSize.height) vs frame \(scroll.bounds.height)")
        // …and `Set` is inside that content, so scrolling reaches it.
        #expect(set.isDescendant(of: scroll))
        let inContent = set.convert(set.bounds, to: scroll)
        #expect(inContent.maxY <= scroll.contentSize.height + 1)
        #expect(scroll.contentSize.height - scroll.bounds.height > 0,
                "there is somewhere to scroll to")
    }

    /// **The SEAM's fallback, and the Mac's semantics travelling with the
    /// new chrome.** `promptForEmoji` is a separate seam so the emoji
    /// keyboard can ride a field we own — and it falls back to
    /// `promptForText` when nothing installed one, which is what keeps every
    /// harness that injects only the old seam driving this door.
    ///
    /// **Red on old (behavioural revert):** delete the `promptForText`
    /// fallback arm in `promptEmoji` and the first half reds (the glyph
    /// never lands); make `land` treat `""` as a cancel and the third does.
    @Test func theEmojiRowFallsBackToTheTextPromptAndKeepsTheMacsSemantics() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .toggle)

            // ONLY the old seam is installed — no `promptForEmoji`.
            var asked: [String] = []
            var answer: String?
            model.blockMenu.promptForText = { title, message, _, completion in
                asked.append(title)
                #expect(message == MobileBlockMenuController.emojiPromptMessage)
                completion(answer)
            }
            model.blockMenu.promptForEmoji = nil

            answer = "🕯"
            model.blockMenu.promptEmoji(blockID: seed.blockA)
            try await Task.sleep(nanoseconds: 40_000_000)
            #expect(asked == [MobileBlockMenuController.emojiPromptTitle])
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"blue","emoji":"🕯","kind":"callout"}"#)

            // EMPTY is a REAL answer — "no glyph" (the Mac
            // `CalloutMenu.promptEmoji` rule, travelling with the chrome).
            answer = ""
            model.blockMenu.promptEmoji(blockID: seed.blockA)
            try await Task.sleep(nanoseconds: 40_000_000)
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"blue","kind":"callout"}"#)

            // CANCEL does nothing at all.
            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .emoji("🌙"))
            answer = nil
            model.blockMenu.promptEmoji(blockID: seed.blockA)
            try await Task.sleep(nanoseconds: 40_000_000)
            #expect(try await storedPresentation(db, blockID: seed.blockA)
                == #"{"color":"blue","emoji":"🌙","kind":"callout"}"#)
        }
    }

    /// The new seam WINS when it is installed — otherwise the emoji keyboard
    /// would never be reached in production, where both seams exist.
    ///
    /// **Red on old (behavioural revert):** reorder `promptEmoji` so the
    /// `promptForText` arm is tried first and this reds.
    @Test func theEmojiSeamIsPreferredOverTheTextPromptWhenBothExist() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            var textAsked = 0
            var emojiAsked = 0
            model.blockMenu.promptForText = { _, _, _, completion in
                textAsked += 1
                completion(nil)
            }
            model.blockMenu.promptForEmoji = { _, _, completion in
                emojiAsked += 1
                completion(nil)
            }
            model.blockMenu.promptEmoji(blockID: seed.blockA)
            #expect(emojiAsked == 1)
            #expect(textAsked == 0)
        }
    }

    @Test func calloutAndNameRefuseUnderASealedNote() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }

            await model.blockMenu.applyCallout(blockID: seed.blockA, edit: .toggle)
            #expect(model.statusMessage
                == "This note is locked — unlock it to change the callout.")
            #expect(try await storedPresentation(db, blockID: seed.blockA) == nil)

            await model.blockMenu.rename(blockID: seed.blockA, name: "handle")
            #expect(model.statusMessage
                == "This note is locked — unlock it to name the block.")
            #expect(try await storedName(db, blockID: seed.blockA) == nil)
        }
    }

    // MARK: Name (the block's handle)

    @Test func nameBlockSetsAndClearsThroughTheOp() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await model.blockMenu.rename(blockID: seed.blockA, name: "the thesis")
            #expect(try await storedName(db, blockID: seed.blockA) == "the thesis")
            #expect(model.statusMessage == nil)

            // Whitespace clears (the op's own trim-to-nil rule).
            await model.blockMenu.rename(blockID: seed.blockA, name: "  ")
            #expect(try await storedName(db, blockID: seed.blockA) == nil)
        }
    }

    // MARK: Delete block (flush-first; the tray's recovery door rides
    // PL-3/13j — the copy no longer redirects, parity C2)

    // MARK: - The menu's own safety (batch 4.5b)

    /// **A DESTRUCTIVE DOOR MUST NOT PROCEED BECAUSE ITS CONFIRM IS
    /// MISSING** (§44's NIT 7). The shipped `confirmDelete` fell straight
    /// through to the act when its seam was nil — a delete that happens
    /// *because* nothing was there to ask, which is exactly backwards and the
    /// one shape M-E cannot tolerate (R13's carve-out covers the in-editor ⌫
    /// keystroke, never this menu row).
    ///
    /// Driven through the REAL Delete row's own handler — `menuElements` is
    /// what both of this menu's doors render, and a `UIAction`'s installed
    /// handler is the exact closure UIKit runs on a tap.
    ///
    /// **Red on old:** with the fall-through restored, the block is
    /// tombstoned by this pin with no confirm anywhere in sight.
    @Test func theDeleteRowRefusesWhenItHasNoConfirmToAskWith() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockMenu.confirmDestructive = nil

            let elements = model.blockMenu.menuElements(blockID: seed.blockA)
            #expect(MenuActionHandler.activate(
                MobileEditorStyle.chromeCase(MobileBlockMenuController.deleteTitle),
                in: elements),
                    "the Delete row's real handler must be drivable")
            for _ in 0..<20 {
                try? await Task.sleep(for: .milliseconds(10))
                await Task.yield()
            }

            #expect(try await storedBlockTexts(db, postID: seed.postID).count == 2,
                    "nothing was deleted without a confirm")
            #expect(model.statusMessage == MobileBlockMenuController.deleteNeedsItsConfirm)
        }
    }

    /// **ONE ACT AT A TIME** (§53 finding 3): every row here is a bare
    /// `Task { await … }` off a `UIAction`, and a rapid double-tap ran two
    /// concurrently. For `applyCallout` — a read-modify-write — that is a
    /// LOST UPDATE: both read the pre-state, and the second silently discards
    /// the first, so a toggle un-toggles and a colour does not stick.
    ///
    /// Its two siblings (`MobileStructuralController.structuralInFlight`,
    /// `MobileUndoDoor.inFlight`) already latch; this is the same idiom, and
    /// it lands before **batch 7 adds more rows to this same menu**.
    ///
    /// **Red on old:** without the latch the second call runs, reports
    /// nothing, and its write lands over the first's.
    @Test func aSecondBlockMenuActInsideTheFirstIsRefusedNotRun() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            async let first: Void = model.blockMenu.applyCallout(
                blockID: seed.blockA, edit: .toggle)
            async let second: Void = model.blockMenu.applyCallout(
                blockID: seed.blockA, edit: .color("rose"))
            _ = await (first, second)

            // **The oracle is the STORE, not the message.** A landed act
            // clears the status (`report(nil)`), so whichever finishes last
            // decides what is on screen — asserting the sentence would pin
            // the race rather than the fix. What the latch changes is what
            // REACHES the row: the second act must not have written.
            let presentation = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT presentation FROM block WHERE id = ?",
                    arguments: [seed.blockA])
            }
            #expect(presentation?.contains("rose") != true,
                    "the second press never wrote — pre-fix it lands over the first")
            #expect(model.blockMenu.actInFlight == false, "the latch always releases")
        }
    }

    @Test func deleteBlockTombstonesAndSpeaksTheTrayNote() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Unflushed typing lands FIRST (flush-first: the tray's copy
            // of the block holds every typed byte).
            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed.")
            await model.blockMenu.delete(blockID: seed.blockA)

            // **13j batch 2 — a SECOND sanctioned pin flip on this door.**
            // Parity C2 kept the "deleted-blocks tray" sentence here after
            // dissolving its "on the Mac" redirect, reasoning that the tray
            // was a FACT even without a phone face. J8's copy doctrine — and
            // her own morning report on the Mac's identical promise — says a
            // promise a user cannot act on is not a fact she can use. This
            // phone has no tray face and no undo door, so both strings now
            // say only what is true HERE.
            //
            // **ROUND 2 BATCH 4: the confirm's second half CHANGED, and the
            // pin changed WITH the fact it pins.** M20 built the structural
            // undo door, so "There's no undo here" became false — the same
            // J8 failure this pin was written to prevent, arriving from the
            // other direction.
            //
            // **ROUND 2 BATCH 6b: THE THIRD SANCTIONED FLIP, and the last of
            // this pin's "not yet" clauses.** Both strings carried an
            // explicit note that they promised no tray *because the phone had
            // none*; §69.3's tray landed at this batch, so both name it — the
            // DURABLE road before the session's undo, because a destructive
            // confirm owes her the durable one first. The phrase is COMPOSED
            // from the door's own two words (`MobileNoteTrayModel
            // .putBackRoadPhrase` over the chip and the segment), so a
            // re-word cannot leave either sentence pointing at a door that no
            // longer exists — which is what this assertion now holds.
            #expect(model.statusMessage == MobileStructuralController.blockDeletedStatus)
            #expect(MobileStructuralController.blockDeletedStatus
                == "Block deleted — \(MobileNoteTrayModel.putBackRoadPhrase).")
            #expect(MobileBlockMenuController.deleteConfirmDetail.hasPrefix(
                "The block leaves this note, with its takes."))
            #expect(MobileBlockMenuController.deleteConfirmDetail
                .contains("Undo is on the receipt afterwards, and in the note's ⋯."))
            for line in [MobileStructuralController.blockDeletedStatus,
                         MobileBlockMenuController.deleteConfirmDetail] {
                // The no-redirect principle (MobileSoul §4) — unchanged.
                #expect(!line.contains("Mac"))
                // The road each names is a road THIS PHONE HAS: the tray's
                // Leaving segment, reached from the blocks chip's sheet.
                #expect(line.contains(MobileNoteTrayModel.roadPhrase(to: .leaving)),
                        "line was \(line)")
                // …and never the MAC's name for it, which names a Mac door.
                #expect(!line.lowercased().contains("this note's tray"))
            }
            let deletedAt = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT deleted_at FROM block WHERE id = ?",
                    arguments: [seed.blockA])
            }
            #expect(deletedAt != nil)
            // The flushed bytes rode into the tray.
            #expect(try await storedText(db, variantID: seed.a1)
                == "First block here. Typed.")
            // The surface healed: one block left.
            #expect(model.index.entries.map(\.blockID) == [seed.blockB])

            // Under a seal the door refuses through the op, store safe.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.blockMenu.delete(blockID: seed.blockB)
            #expect(model.statusMessage
                == "This note is locked — unlock it to delete the block.")
            #expect(model.index.entries.map(\.blockID) == [seed.blockB])
        }
    }

    /// **PR6 — ARCHIVE BLOCK, THROUGH THE REAL ROW'S OWN HANDLER** (round 2,
    /// batch 6b). 13j's round-7 ruling built `archiveBlock`/`unarchiveBlock`
    /// and the Mac wore both doors from that phase; a grep of
    /// `VariorumMobile/` for either op returned ZERO hits, so the phone had
    /// the whole capability with no way in and (until this batch's tray) no
    /// way back.
    ///
    /// The block leaves the SURFACE, its stamp lands, its takes are all still
    /// there (archive destroys nothing), and the receipt names where it went
    /// AND the promise that distinguishes it from the row beneath it: **no
    /// clock**.
    ///
    /// **Red on old (behavioural revert):** delete the `archiveTitle` element
    /// from `menuElements` and `MenuActionHandler.activate` returns false —
    /// the row is not there to drive. Revert the act instead
    /// (`archiveBlock` → a no-op) and the stamp assertion reds.
    @Test func theArchiveRowSetsTheBlockAsideWithNoClock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Unflushed typing lands FIRST — the structural contract's
            // flush, so the archived copy holds every typed byte.
            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed.")

            let elements = model.blockMenu.menuElements(blockID: seed.blockA)
            #expect(MenuActionHandler.activate(
                MobileEditorStyle.chromeCase(MobileBlockMenuController.archiveTitle),
                in: elements),
                    "the Archive row's real handler must be drivable")
            for _ in 0..<40 {
                try? await Task.sleep(for: .milliseconds(10))
                await Task.yield()
            }

            let stamps = try await db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT archived_at, deleted_at FROM block WHERE id = ?",
                    arguments: [seed.blockA])
            }
            #expect(stamps?["archived_at"] as String? != nil, "the archive stamp landed")
            #expect(stamps?["deleted_at"] as String? == nil,
                    "archive is not deletion — no tombstone, no clock")
            #expect(model.index.entries.map(\.blockID) == [seed.blockB],
                    "the block left the surface")
            #expect(try await storedText(db, variantID: seed.a1)
                == "First block here. Typed.",
                    "flush-first — the archived copy holds the typed bytes")

            // The receipt says the promise and names the road back.
            #expect(model.statusMessage == MobileStructuralController.blockArchivedStatus)
            #expect(MobileStructuralController.blockArchivedStatus
                .contains(RecoveryCopy.archivedForever))
            #expect(MobileStructuralController.blockArchivedStatus
                .contains(MobileNoteTrayModel.roadPhrase(to: .archived)))
            #expect(!MobileStructuralController.blockArchivedStatus.contains("Mac"))

            // It is NOT the destructive row — nothing is destroyed here.
            let archive = try #require(
                elements.first {
                    $0.title == MobileEditorStyle.chromeCase(
                        MobileBlockMenuController.archiveTitle)
                } as? UIAction)
            #expect(!archive.attributes.contains(.destructive))
        }
    }

    /// The archive door refuses through the OPERATION under a seal, in phone
    /// words, with nothing archived (P-2, fire-and-DO: no pre-check, the
    /// ops layer's own answer).
    @Test func archiveRefusesUnderTheSealInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }

            await model.structural.archiveBlock(blockID: seed.blockA)
            #expect(model.statusMessage
                == "This note is locked — unlock it to archive the block.")
            let stamp = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT archived_at FROM block WHERE id = ?",
                    arguments: [seed.blockA])
            }
            #expect(stamp == nil, "nothing was archived")
        }
    }

    /// S4 ladder MAJOR 1's red-on-old pin: the Delete Block door carries
    /// the structural-act contract's SECOND half — the post-flush dirty
    /// re-check. A refused flush keeps its text pending (`isDirty` stays
    /// true; the coordinator's pinned posture), and `deleteBlock`'s
    /// `.none` door does NOT refuse a locked take — so the pre-fix door
    /// tombstoned the block here, stranding the typed bytes outside both
    /// the surface and the tray's copy (the text-loss class).
    @Test func deleteRefusesWhenTheFlushItselfRefuses() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Type into A's take, then lock that take REMOTELY (through
            // ops directly — the lock lands while the typing sits
            // unflushed; the headless world runs no live observation, so
            // the surface deliberately does not know).
            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed.")
            #expect(model.autosave.isDirty)
            try await session.runner.run { [a1 = seed.a1] ops in
                try ops.lockVariant(a1)
            }

            await model.blockMenu.delete(blockID: seed.blockA)

            // The flush refused (`lockedVariant`), so the DELETE refuses —
            // the contract's copy, the block live, the bytes still pending.
            #expect(model.statusMessage
                == "Unsaved changes couldn't be written — resolve that first, then retry.")
            let deletedAt = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT deleted_at FROM block WHERE id = ?",
                    arguments: [seed.blockA])
            }
            #expect(deletedAt == nil)
            #expect(model.autosave.isDirty)
            // The stored take never gained the unflushed bytes (the store
            // still disagrees with the surface — exactly why acting was
            // forbidden).
            #expect(try await storedText(db, variantID: seed.a1) == "First block here.")
        }
    }
}

// MARK: - Comments (M12)

@MainActor
@Suite("Mobile comments — CRUD + the never-skimpy deleted section (S4 batch 1)")
struct MobileCommentsTests {
    @Test func commentCRUDAndTheDeletedSectionThroughTheOps() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.openComments(blockID: seed.blockA)
            #expect(model.comments.isOpen)
            await model.comments.refresh()
            #expect(model.comments.comments.isEmpty)

            // ADD — stored verbatim; the slot's count follows (the ●n
            // marker's brain).
            await model.comments.add("First thought.")
            await model.comments.add("Second thought.")
            #expect(try await liveCommentTexts(db, blockID: seed.blockA)
                == ["First thought.", "Second thought."])
            #expect(model.comments.comments.map(\.text)
                == ["First thought.", "Second thought."])
            #expect(model.slot(for: seed.blockA)?.commentCount == 2)

            // EDIT through the draft door.
            let first = try #require(model.comments.comments.first)
            model.comments.beginEditing(first.id)
            await model.comments.submitDraft("First thought, sharpened.")
            #expect(try await liveCommentTexts(db, blockID: seed.blockA)
                == ["First thought, sharpened.", "Second thought."])
            #expect(model.comments.editingID == nil)

            // DELETE tombstones; the deleted list shows it (never
            // skimpy); RESTORE revives it.
            await model.comments.delete(first.id)
            #expect(model.comments.comments.map(\.text) == ["Second thought."])
            #expect(model.comments.deleted.map(\.text) == ["First thought, sharpened."])
            #expect(model.slot(for: seed.blockA)?.commentCount == 1)
            await model.comments.restore(first.id)
            #expect(model.comments.comments.map(\.text)
                == ["First thought, sharpened.", "Second thought."])
            #expect(model.comments.deleted.isEmpty)
            #expect(model.slot(for: seed.blockA)?.commentCount == 2)
        }
    }

    @Test func commentRefusalsSpeakTheOpsOwnWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.openComments(blockID: seed.blockA)

            // Whitespace-only refuses (the op's own guard, the Mac
            // panel's words).
            await model.comments.add("   ")
            #expect(model.statusMessage == "A comment needs some text.")
            #expect(try await liveCommentTexts(db, blockID: seed.blockA).isEmpty)

            // The seal refuses writes; reading stays free.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.comments.add("Under seal.")
            #expect(model.statusMessage
                == "This note is locked — unlock it to change comments.")
            #expect(try await liveCommentTexts(db, blockID: seed.blockA).isEmpty)
        }
    }

    @Test func theSheetClosesWhenItsBlockLeavesTheSurface() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.openComments(blockID: seed.blockA)
            #expect(model.comments.isOpen)
            try await session.runner.run { [blockID = seed.blockA] ops in
                try ops.deleteBlock(blockID)
            }
            await model.refreshTakesFromStore()
            #expect(!model.comments.isOpen)
        }
    }
}

// MARK: - The block decor (real laid-out geometry)

@MainActor
@Suite("Mobile block decor — callout frames + comment markers (S4 batch 1)")
struct MobileBlockDecorTests {
    @Test func aFramedBlockWearsOneWashAndAPlainBlockNothing() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            try await session.runner.run { [blockID = seed.blockA] ops in
                try ops.setBlockPresentation(
                    blockID, BlockPresentation(color: "sand", emoji: nil))
            }
            let (model, surface) = await makeDecorSurface(session, postID: seed.postID)
            let decor = try #require(surface.textView.blockDecor)

            let wash = try #require(decor.frameView(for: seed.blockA))
            #expect(wash.superview === surface.textView)
            // ONE frame around the block's whole region, BEHIND the text
            // canvas (the overlay law — subview index 0's family).
            #expect(surface.textView.subviews.firstIndex(of: wash)
                .map { $0 <= 1 } == true)
            #expect(wash.frame.width > 0 && wash.frame.height > 0)
            // A plain block carries nothing.
            #expect(decor.frameView(for: seed.blockB) == nil)
            #expect(decor.emojiLabel(for: seed.blockA) == nil)
            _ = model
        }
    }

    @Test func theEmojiReservesALeadingGapAndRendersTheGlyph() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            try await session.runner.run { [blockID = seed.blockA] ops in
                try ops.setBlockPresentation(
                    blockID, BlockPresentation(color: "blue", emoji: "🕯"))
            }
            let (_, surface) = await makeDecorSurface(session, postID: seed.postID)
            let decor = try #require(surface.textView.blockDecor)

            let label = try #require(decor.emojiLabel(for: seed.blockA))
            #expect(label.text == "🕯")
            // The reserved leading gap (LK10's mirror corner; B3's
            // mechanism): a firstLineHeadIndent on the block's first
            // paragraph — exactly first-line-only, covering the glyph —
            // and the container carries NO exclusion paths (FB2-1).
            let style = surface.textView.textStorage.attribute(
                .paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
            let gap = style?.firstLineHeadIndent ?? 0
            #expect(gap >= label.bounds.width, "the gap must cover the glyph (gap \(gap))")
            #expect(gap <= label.bounds.width + 10)
            #expect(surface.textView.textContainer.exclusionPaths.isEmpty)
        }
    }

    @Test func aCommentedBlockWearsItsCountAndTheTapOpensTheSheet() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            try await session.runner.run { [blockID = seed.blockA] ops in
                _ = try ops.addBlockComment(to: blockID, text: "One.")
                _ = try ops.addBlockComment(to: blockID, text: "Two.")
            }
            let (model, surface) = await makeDecorSurface(session, postID: seed.postID)
            let decor = try #require(surface.textView.blockDecor)

            let mark = try #require(decor.commentMark(for: seed.blockA) as? UIButton)
            #expect(mark.title(for: .normal) == "●2")
            // The uncommented neighbor carries nothing.
            #expect(decor.commentMark(for: seed.blockB) == nil)

            // The tap is a door (the badge grammar): the comments sheet
            // opens on the block.
            mark.sendActions(for: .touchUpInside)
            #expect(model.comments.isOpen)
            #expect(model.comments.openBlockID == seed.blockA)
            #expect(surface.textView.commentsSheetView?.isHidden == false)
        }
    }
}
