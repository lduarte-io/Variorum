//
//  WingsModel+Mac.swift
//  Variorum (MAC ONLY) — Core/Views
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — THE MAC'S HALF OF THE
//  WINGS' BRAIN, split out of `WingsModel.swift` when the brain moved to
//  shared code (`Shared/WingsModel.swift`). Three seams, each a Mac-only fact
//  the shared brain must not name, each the Mac's own code moved byte for
//  byte:
//
//  · the Mac's REFUSAL WORDS — `init(session:)` hands the shared brain the
//    Mac's `OpsRefusalCopy.message(for:)` (its own arms, then the shared table
//    on the Mac's roads — `Registry/OpsRefusalCopy.swift`), so every Mac
//    construction site and pin reads, and speaks, exactly as before;
//  · the MCP door's REACH on the switcher's rows (`watchSharing` — the hold is
//    `MCPRowReach`, the Mac's, and the MCP door is the Mac's); it lands through
//    the brain's `adoptReach`;
//  · the ⌘DIGIT CHORD's answer (`answer(_:)` — `WingNumberKeys` is AppKit's).
//
//  And every word the Mac's wing FACES say (`WingCopy` — menu verbs, the ⌘L
//  notes, the switcher's prompt, foot and header, the delete confirm, the
//  move confirm's title and message, the lineage line). The words the brain
//  itself SPEAKS — its receipts and refusals — are declared with it, in
//  `Shared/WingsModel.swift`.
//

import Foundation
import VariorumCore

extension WingsModel {
    /// The Mac's wings brain: the shared brain speaking the Mac's refusal
    /// words. Every Mac construction site (the main window, a note window,
    /// the quick-note pad) and every Mac pin reads this initializer.
    convenience init(session: AppSession) {
        self.init(session: session, refusalWords: { OpsRefusalCopy.message(for: $0) })
    }

    /// VX-268 — hold every wing's reach (the main window's task, beside
    /// `track` — the window that renders the switcher).
    func watchSharing() async {
        await MCPRowReach.hold(session, { try Queries.mcpWingReaches($0) }) { [weak self] value in
            self?.adoptReach(value)
        }
    }

    /// **VX-824 — the ⌘digit chord's answer** (`WingNumberKeys`' decision): a
    /// wing goes the deliberate road, said ("Now in …" — a chord is blind
    /// until it is said, the cycle's reason); a number no wing answers speaks
    /// its refusal (P-828-1 (i)); a key the chord does not own passes on.
    /// Returns whether the key was the chord's (the monitor consumes it then).
    @discardableResult
    func answer(_ decision: WingNumberKeys.Decision) -> Bool {
        switch decision {
        case .passOn:
            return false
        case .goTo(let id):
            goTo(id, saying: true)
            return true
        case .refuse(let note):
            session.status.refuse(note)
            return true
        }
    }
}

/// Every Mac word the wing doors say (13s-revoicable — PROVISIONAL
/// P-13id-U5-11). The platform-neutral sentences are `WingWords`; the
/// sentences the shared brain speaks are declared with it (VM-63).
nonisolated extension WingCopy {
    static let newWingVerb = "New Wing\u{2026}"
    static let renameWingVerb = "Rename Wing\u{2026}"
    static let deleteWingVerb = "Delete Wing\u{2026}"
    static let moveToWingVerb = "Move to Wing"
    static let copyToWingVerb = "Copy to Wing"
    /// **VX-632 — the View menu's two chord items** (A-648-7: the ellipsis on
    /// the MENU face only — the ticket's spelling and the macOS convention for
    /// an item that opens a selector; every other face wears the bare verb,
    /// RB-15's copy pass may still adjust). Derived from the verb, so the two
    /// can never drift apart.
    static func menuTitle(_ verb: String) -> String { verb + "\u{2026}" }
    // 13n-c U4 (round 5 — the switcher joins the Library masthead; ⌘L, VX-157):
    // the note says where wings live now, both mastheads and the chord.
    static let unavailableNote = "Wings live at the top of the Bookcase and the Library \u{2014} "
        + "\u{201C}Bookcase \u{00B7} \(WingWords.home) \u{25BE}\u{201D} \u{2014} and \u{2318}L switches between them."

    // MARK: - 13n-c U4 — ⌘L and the cycling masthead (VX-157; round 5)

    /// ⌘L's menu verb (the View menu; the registry's `.switchWing`).
    static let switchWingVerb = "Switch Wing\u{2026}"
    /// 13n-c Stage B R1 B6 — why ⌘L is grey with ONE wing, and where another
    /// comes from (PROVISIONAL P-13nc-SB-2).
    /// Her sitting (2026-10-11, second round — P-13nc-SB-2 RULED with a
    /// reword): grey-with-a-note stands, but "masthead" was too opaque — the
    /// note says where New Wing… lives in plain words (PROVISIONAL for her
    /// copy pass).
    static let switchWingUnavailable = "There is only one wing so far \u{2014} \(newWingVerb) under the "
        + "wing name at the top of the Bookcase makes another, and then \u{2318}L switches between them."
    /// **VX-824 — a ⌘digit no wing answers** (P-828-1 (i), the words as drafted
    /// at the fork — PROVISIONAL, hers to tune): with one wing, ⌘L's ruled
    /// note's shape naming the next chord; with several, the span that works.
    static func noWingAtNumber(_ number: Int, wingCount: Int) -> String {
        guard wingCount > 1 else {
            return "There is only one wing so far \u{2014} \(newWingVerb) under the wing name at the top "
                + "of the Bookcase makes another, and then \u{2318}2 goes to it."
        }
        return "There's no wing \(number) \u{2014} \u{2318}1\u{2013}\u{2318}\(wingCount) go to your "
            + "\(wingCount) wings, Home first."
    }
    /// THE SWITCHER's one quiet line (round 5, her ruling: the wing-isolation
    /// UI makes clear Snippets is the one room shared across wings).
    static let snippetsShared = "Snippets is the one room every wing shares."
    /// ⌘L's field (mockup §6: type a few letters).
    static let switcherPrompt = "Switch to a wing"
    /// ⌘L's foot (mockup §6's, with her held-⌘ cycling said).
    static func switcherFoot(current: String) -> String {
        "\(current) is the current wing \u{00B7} \u{23CE} switches \u{00B7} hold \u{2318} and tap L to "
            + "step \u{00B7} esc closes"
    }
    static let noWingMatches = "No wing has that name."
    /// The masthead word's hover where it CYCLES (two or more wings).
    static func cycleHelp(next: String) -> String {
        "Next wing: \u{201C}\(next)\u{201D} \u{2014} or \u{2318}L to choose one"
    }
    /// The ▾ beside the cycling word: the list and the wing acts.
    static let menuDoorHelp = "Every wing \u{2014} switch to one, or make, rename, move or delete a wing"
    /// The wing whose row the switcher marks.
    static let currentMark = "current"
    static let noteUnavailableNote = "Moving or copying a note to another wing acts on a "
        + "note \u{2014} right-click its row in the Library or the Pool, or open it and use "
        + "its note \u{25BE} menu."

    /// The switcher list's header (13i-d U6 (b)).
    static let switcherHeader = "Wings \u{2014} each a separate library"
    static let newWingTitle = "New Wing"
    static let renameWingTitle = "Rename Wing"

    static func deleteTitle(_ name: String) -> String { "Delete the wing \u{201C}\(name)\u{201D}?" }
    static let deleteMessage = "It's empty. Its shelves go with it; nothing else is touched."

    static func moveTitle(_ title: String, to wing: String) -> String {
        "Move \u{201C}\(title)\u{201D} to \u{201C}\(wing)\u{201D}?"
    }
    static func moveMessage(leaves books: [String]) -> String {
        let names = books.map { "\u{201C}\($0)\u{201D}" }
        let list = names.count <= 1 ? (names.first ?? "")
            : names.dropLast().joined(separator: ", ") + " and " + names.last!
        return "It leaves \(list) \u{2014} a wing is a separate library, and a book only "
            + "holds notes of its own wing. Its tags come with it."
    }

    /// The lineage line (#166(e) — minimal naming, nothing deeper).
    static func versionElsewhere(_ wing: String) -> String {
        "a version of this note lives in another library \u{2014} the wing \u{201C}\(wing)\u{201D}"
    }
    static func goTo(_ wing: String) -> String { "go to \(wing) \u{203A}" }
}
