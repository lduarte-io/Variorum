//
//  TutorialProtectionRecoveryTests.swift
//  VariorumTests
//
//  VX-916 (the VX-915 run, batch 4) — THE PROTECTION CHAPTER'S TWO NEW PIECES (`TutorialProtectionPassages.swift`):
//  R-529-6's guide line (the "your account's passphrase hasn't been typed on this Mac yet" state — why, why it isn't a
//  state to stay in, the road) and THE COMPROMISE-RECOVERY RECIPE (her VX-379 words as the content direction). The words
//  are byte-pinned here (the guide suites' pattern — a wording pass is one visible change), the doors read from their
//  own constants, the card's words QUOTED so the guide and VX-538's card can never disagree, the register held (no
//  key-family internal, nothing shouted, nothing retired), every rule clause the sentences lean on read from
//  `notes/CastleRules.md` itself (a rule change turns this red), and the SEED: lesson 2 ("Standard and Castle") mints
//  its own six paragraphs, then the line, then the recipe, on both store variants (PROVISIONAL P-915-B4-1).
//
//  RED ON OLD by construction — an Improvement's new contract (the old chapter carried neither piece; VX-529's
//  closeout verified them absent). Mac-only (the seeder is the Mac's): run on the stage — PENDING(gate).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

/// A store with the field guide seeded through the restore road (the protection chapter suite's world).
@MainActor
private func withGuide<T>(
    variant: AppDatabase.StoreVariant,
    _ body: @MainActor (AppDatabase, _ guideID: String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 916))
    } operation: { @MainActor in
        let session = AppSession(database: db, storeVariant: variant)
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        let guideID = try await TutorialSeeder.restore(session: session)
        return try await body(db, guideID)
    }
}

@MainActor
@Suite("VX-916 — the guide's protection chapter: R-529-6's line and the compromise-recovery recipe")
struct TutorialProtectionRecoveryTests {
    /// `notes/CastleRules.md`, its whitespace runs collapsed (the rules wrap mid-sentence — `RoadCrossingWordsTests`).
    static func rules() throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // the repo
            .appendingPathComponent("notes/CastleRules.md")
        let text = try String(contentsOf: url, encoding: .utf8)
        return text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
    }

    /// The two-register rule (`CopyRegisterPinTests.forbidden`'s pattern, the guide walk's `forbiddenRegisterWords`).
    static var forbidden: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }

    /// Her draft's key-family internals that stay out of the guide's register (the file header's departure (b)), and
    /// the words no rule as built says any more (`U2WordsTests.retired`).
    static let internals = ["master", "proof", "escrow", "recovery key", "recovery phrase", "anchor", "savepoint"]

    static func shouts(_ line: String) -> [Substring] {
        line.split(whereSeparator: { !$0.isLetter }).filter { word in
            word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
        }
    }

    /// The door's words as a sentence names it (no trailing ellipsis).
    static func named(_ door: String) -> String {
        door.hasSuffix("\u{2026}") ? String(door.dropLast()) : door
    }

    // MARK: - Piece 1 — R-529-6's line

    /// **The why and the road, in the card's own words.** Byte-pinned (the Mac's device word); the card's line and its
    /// forgot-road QUOTED from `ProtectionWords` (VX-538's band card renders exactly these constants —
    /// `WordsBandCard.swift`'s `AccountPassphraseRow`), the window sentence R-529-5's ratified one, the cadence rule 3's.
    @Test func theE6LineSaysTheWhyAndTheRoadInTheCardsOwnWords() {
        let line = TutorialSeeder.accountPassphraseNotTypedHerePassage
        #expect(line == "If this library joined your account with your twelve words, or caught up with them, and your account's passphrase hasn't been typed on this Mac since, the card above the quick entry says so: \u{201C}Your account's passphrase hasn't been typed on this Mac yet \u{2014} type it once and it opens this library here too.\u{201D} It isn't a state to stay in. Until you type your account's passphrase on this Mac, copies made here open with your twelve words. So the card comes back from the third launch, and a week after each time you put it away, until a passphrase is typed here. If you don't know it, set one you do with Reset forgotten passphrase.")
        // The guide and the card agree BY CONSTRUCTION: the card's two sentences, verbatim, inside the line.
        #expect(line.contains("\u{201C}\(ProtectionWords.accountPassphraseCardLine)\u{201D}"), "the card's line, quoted")
        #expect(line.hasSuffix(ProtectionWords.accountPassphraseCardForgot), "the card's forgot-road closes it")
        #expect(line.contains(ProtectionWords.pairWordsWindow), "R-529-5's ratified window sentence — why it isn't ideal")
        #expect(line.contains(Self.named(ProtectionWords.resetPassphraseDoor)), "the forgot door by its own name")
    }

    // MARK: - Piece 2 — the recipe

    /// **The three moves, in order; the already-in-Castle road; the honest limit; why no new account.** Each passage
    /// byte-pinned; the doors read from their own constants below.
    @Test func theRecipeSaysTheThreeMovesInOrder() {
        let recipe = TutorialSeeder.compromiseRecoveryPassages
        #expect(recipe == [
            "If you think someone has your passphrase, your twelve words or your library's key, three moves keep what you write from then on out of reach of what they took. Make them in this order. First, your account: Sign Out Everywhere (Account\u{2026}, at the bottom of the sidebar), then change your account password at stargazing.tech \u{2014} changing it happens on the website, not in the app. Every device is signed out and the old password signs no one back in; sign in again here with the new one.",
            "Second, your passphrase and your twelve words: Change passphrase\u{2026} and Record your twelve words\u{2026} in Settings \u{25B8} Protection give you new ones. With sync on, they replace your account's too, on every device, and each of your other devices, once it signs in again, catches up with Follow your account\u{2026} there by typing the new passphrase or the new words once. This comes before the third move, so the new keys it makes are locked under secrets they don't have.",
            "Third, Use Castle\u{2026} in Settings \u{25B8} Protection. Entering asks for your passphrase and your twelve words, gives your library a new key and your account a new sync key, and seals what you write from then on under keys none of their copies hold; each of your other devices follows by typing one of the two once. Rather stay in Standard? Use Standard\u{2026} afterward: leaving keeps your account's new sync key, which changes only when an account enters Castle, and gives your library another new key on the way out.",
            "Already in Castle? Then the third move is Use Standard\u{2026}, then Use Castle\u{2026} again, since entering is what makes the new keys. Between the two crossings your library and every backup open through your Apple account and this Mac again, until entering deletes those roads once more, so make both in one sitting, one right after the other.",
            "What no move can do: anything they already copied \u{2014} an old backup, your library as it stood, what the server held until now \u{2014} stays readable to them with the keys they took. New keys protect what you write from now on, never what's already taken. And you don't need a new account: after the three moves your old password signs no one in, your old passphrase and words open nothing you write from then on, and the new keys are locked under secrets they don't have. A fresh account would only clear the old sealed writing off the server, and whatever of it they copied, they already have.",
        ])
        let all = recipe.joined(separator: "\n")
        // Her order (account → the pair → Castle), said in order.
        let first = all.range(of: "First, your account")
        let second = all.range(of: "Second, your passphrase and your twelve words")
        let third = all.range(of: "Third, \(ProtectionWords.useCastleDoor)")
        #expect(first != nil && second != nil && third != nil, "each move is said")
        if let first, let second, let third {
            #expect(first.lowerBound < second.lowerBound && second.lowerBound < third.lowerBound, "the three moves in order")
        }
        // Every door by its own constant (a rename turns the guide red, never wrong).
        for door in [ProtectionCopy.signOutEverywhereDoor, ProtectionWords.changePassphraseDoor,
                     ProtectionWords.wordsSectionDoor, ProtectionWords.followDoor,
                     ProtectionWords.useCastleDoor, ProtectionWords.useStandardDoor] {
            #expect(all.contains(door), "\(door) by its own name")
        }
        // Her #90 (7) ruling: the account password changes on the website, and the guide names that road.
        #expect(all.contains("change your account password at stargazing.tech"))
        // The honest limit and the already-in-Castle road are each said.
        #expect(all.contains("never what's already taken"))
        #expect(all.contains("Already in Castle? Then the third move is \(ProtectionWords.useStandardDoor), then "
                             + "\(ProtectionWords.useCastleDoor) again"))
        #expect(all.contains("make both in one sitting"))
        #expect(all.contains("you don't need a new account"))
    }

    /// The Account sheet's Sign Out Everywhere is reached from the sync row's "Account…" door (the row's inline label —
    /// a source scan, the H pattern's surface arm), and the sync row lives at the sidebar's foot (`RootView.statusRows`).
    @Test func theAccountDoorTheRecipeNamesIsTheSyncRowsOwn() throws {
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent()  // App/Variorum
        let row = try String(contentsOf: app.appendingPathComponent("Shared/SyncStatusViews.swift"), encoding: .utf8)
        #expect(row.contains("Door(label: \"Account\u{2026}\", act: .openAccount(.account))"))
        let sheet = try String(contentsOf: app.appendingPathComponent("Shared/AuthViews.swift"), encoding: .utf8)
        #expect(sheet.contains("ProtectionCopy.signOutEverywhereDoor"), "the sheet draws the door the recipe names")
        let root = try String(contentsOf: app.appendingPathComponent("Variorum/RootView.swift"), encoding: .utf8)
        #expect(root.contains("SyncStatusRow(services: services)"), "the row sits in the sidebar's bottom region")
    }

    // MARK: - The register and the rules

    /// Every new sentence keeps the guide's register: no key-family internal (the two-register rule — her draft's
    /// "session" is said through Sign Out Everywhere), no internal of her draft (master, proof), nothing retired, nothing
    /// shouted, the device by `ProtectionCopy`'s word.
    @Test func everyNewSentenceKeepsTheGuidesRegister() {
        for paragraph in [TutorialSeeder.accountPassphraseNotTypedHerePassage] + TutorialSeeder.compromiseRecoveryPassages {
            #expect(!paragraph.contains(Self.forbidden), "the two-register rule: \(paragraph.prefix(60))…")
            for word in Self.internals {
                #expect(!paragraph.lowercased().contains(word), "\(word) in \(paragraph.prefix(60))…")
            }
            #expect(Self.shouts(paragraph).isEmpty, "nothing shouted: \(paragraph.prefix(60))…")
            #expect(paragraph.firstMatch(of: /\bMac\b/) == nil || ProtectionCopy.deviceName == "Mac",
                    "the device through ProtectionCopy")
        }
    }

    /// **Every rule clause the sentences lean on, read from `notes/CastleRules.md`** (the self-check table in the vx-915
    /// record names each claim's rule): if a rule changes, the guide's sentence is re-read, never silently stale.
    @Test func theRuleClausesTheSentencesLeanOnAreTheRules() throws {
        let rules = try Self.rules()
        // Rule 3 — the told state, its cadence and its forgot-road (the E6 line).
        #expect(rules.contains("it joined by the twelve words, or caught up with them"))
        #expect(rules.contains("It comes back from the third launch, and a week after each time it is put away, until a "
                               + "passphrase is typed here"))
        #expect(rules.contains("Reset forgotten passphrase sets one you do"))
        // Rules 6 and 7 — the key doors re-lock and change the account's lock with the library's (move 2).
        #expect(rules.contains("The key doors change the library's and the account's locks together."))
        // Rule 14 — the account's keys are wrapped by the pair only (why move 2 comes first).
        #expect(rules.contains("The account's shared keys are wrapped by the passphrase and the twelve words only"))
        // Rule 11 — entering types both and makes a new library key and a new sync key (move 3).
        #expect(rules.contains("Entering Castle types your passphrase and your twelve words."))
        #expect(rules.contains("On the account: a new sync key, in one write"))
        // Rule 10 — the other devices follow, each typing a secret once.
        #expect(rules.contains("every device of the account follows, each typing a secret once"))
        // Rule 15 — the sync key changes only at an entry (staying in Standard keeps the rotation).
        #expect(rules.contains("The sync key changes only when the account enters Castle"))
        // Rule 12 — leaving gives the library a new key, and what the window re-opens (the already-in-Castle road).
        #expect(rules.contains("On this device: a new Standard key carrying every earlier key"))
        #expect(rules.contains("*\(ProtectionWords.leaveSentence.prefix(1).lowercased() + ProtectionWords.leaveSentence.dropFirst())*"))
        // Rules 4 and 5 — the honest limit: what was made with the old secrets still opens with them.
        #expect(rules.contains("A backup always opens with the passphrase and words you had when you made it."))
    }

    // MARK: - The seed

    /// **Lesson 2 mints its six paragraphs byte-unchanged, then the line, then the recipe** — on both store variants;
    /// the chapter keeps its three lessons and lesson 2 its title (PROVISIONAL P-915-B4-1).
    @Test(arguments: [AppDatabase.StoreVariant.dev, .real])
    func lessonTwoSeedsItsParagraphsThenTheLineThenTheRecipe(_ variant: AppDatabase.StoreVariant) async throws {
        #expect(TutorialSeeder.posturesLessonParagraphs
                == ProtectionWords.guidePosturesLesson + [TutorialSeeder.accountPassphraseNotTypedHerePassage]
                + TutorialSeeder.compromiseRecoveryPassages)
        #expect(TutorialSeeder.plan.first { $0.chapter == "keeping it private" }?.lessons == [
            ProtectionWords.guideKeyLessonTitle, ProtectionWords.guidePosturesLessonTitle,
            ProtectionWords.guideCopiesLessonTitle,
        ], "still three lessons")
        try await withGuide(variant: variant) { db, guideID in
            let (text, blocks) = try await db.read { db -> (String, [String?]) in
                let id = try #require(try String.fetchOne(
                    db,
                    sql: """
                        SELECT c.id FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                        """,
                    arguments: [guideID, ProtectionWords.guidePosturesLessonTitle]))
                return (try Queries.renderedText(db, containerID: id),
                        try Queries.renderPost(db, containerID: id).map(\.text))
            }
            // A JUSTIFIED EDIT, STRENGTHENED (the VX-915 gate36 disposition — a RIG red,
            // both variants): this line joined the expected paragraphs with "\n", but
            // `renderedText` joins blocks through `Queries.joinRenderedTexts`
            // (`blockJoinSeparator`, "\n\n"). The expectation is now THE app's join, BY
            // NAME, so the two can never drift…
            #expect(text == Queries.joinRenderedTexts(TutorialSeeder.posturesLessonParagraphs),
                    "the lesson renders the paragraphs through the app's own join, in order")
            // …and, row by row, what a joined string alone cannot prove: the lesson's live
            // blocks in position order are EXACTLY the paragraphs — one block per
            // paragraph, none merged, none extra, none empty.
            #expect(blocks == TutorialSeeder.posturesLessonParagraphs.map { Optional($0) },
                    "one live block per paragraph, in position order: the lesson's six, the line, the recipe")
        }
    }
}
