//
//  HelperCurrencyTests.swift
//  VariorumTests
//
//  librarywalkpolish's FINAL round, findings 1–3 + NIT-4: the ⌘/ helper had
//  NO currency pin — the same premise VR-122 proved on the field guide (the
//  claim-classes without a pin are exactly the ones that drift; the helper's
//  own header calls the list hand-maintained, and `HelperCoverageTests`
//  guards only that every registry shortcut APPEARS, never that the prose
//  says true things). Each arm binds the helper's words to the app's own
//  constants. RED ON OLD (the pre-fix tree, three ways): the masthead
//  tag-cards row taught a ＋ the cluster does not render
//  (`MastheadTagCluster.chipsShowAddDoor == false` — the ＃ is the one
//  door), two sites taught "right-click ▸ Toggle Star" while every
//  right-click row reads `StarCopy.starRow` ("Star"), and the "tag"
//  dictionary entry kept the cards on the context bar they left at Act 10.
//

import Foundation
import Testing

@testable import Variorum

@MainActor
@Suite("The ⌘/ helper says what the app does (the final-round currency pins)")
struct HelperCurrencyTests {

    private var everyText: [String] {
        HelperView.groups.flatMap { $0.items.map { "\($0.keys) — \($0.does)" } }
            + HelperView.entries.map { "\($0.term) — \($0.definition)" }
    }

    @Test func theMastheadTagCardsRowOffersNoRetiredPlusDoor() {
        let row = HelperView.groups.flatMap(\.items).first {
            $0.keys.hasPrefix("tag cards")
        }
        guard let row else {
            Issue.record("the helper lost its tag-cards row entirely")
            return
        }
        if !MastheadTagCluster.chipsShowAddDoor {
            #expect(
                !row.does.contains("\u{FF0B}"),
                "the masthead cards render no ＋ (the ＃ is the one door) — the helper must not teach one"
            )
        }
        #expect(!row.does.contains("fold"), "the tag-card fold is retired (Act 10)")
        #expect(row.does.contains("masthead"), "the cards' home is the masthead, not a bar")
    }

    @Test func noSiteTeachesARightClickVerbTheRowsDoNotWear() {
        // The right-click rows wear StarCopy.starRow/unstarRow; the ⌘K act
        // alone wears StarCopy.verb. A helper site joining "right-click ▸"
        // to the ⌘K verb teaches a row that exists nowhere.
        for text in everyText {
            #expect(
                !text.contains("right-click ▸ \(StarCopy.verb)")
                    && !text.contains("Right-click anything ▸ \(StarCopy.verb)"),
                "a helper site joins right-click to the ⌘K verb: \(text.prefix(80))"
            )
        }
        // The positive arm: the helper still names BOTH constants somewhere —
        // the row's own word on a right-click site, and the ⌘K act's verb
        // (the registry-coverage guard needs the latter; a rename tracks).
        #expect(everyText.contains { $0.contains("right-click ▸ \(StarCopy.starRow)") })
        #expect(everyText.contains { $0.contains(StarCopy.verb) })
    }

    @Test func theTagEntryHomesTheCardsInTheMasthead() {
        let entry = HelperView.entries.first { $0.term == "tag" }
        guard let entry else {
            Issue.record("the helper lost its tag dictionary entry")
            return
        }
        #expect(
            !entry.definition.contains("context bar"),
            "a note's tag cards left the context bar at Act 10 (ContextBar.surfaceCapabilities excludes .tagNote)"
        )
        #expect(entry.definition.contains("masthead"))
        if !MastheadTagCluster.chipsShowAddDoor {
            #expect(!entry.definition.contains("\u{FF0B} adds"))
        }
    }

    /// 13s-b U4 round 1, MINOR-2: the `note ▾` row taught a HISTORY door the
    /// note menu has not carried since the post-13l polish round (06263d16 —
    /// Block History moved to the bar beside commit; her F2 report: *"it's
    /// unclear that history is under Note, that makes it seem like the
    /// Note's history"*), and U4's word swap carried it forward as "history
    /// (commits)" — pairing commits with the NOTE menu, the per-take vs
    /// whole-note confusion her R-VX83-10 reason names. The row now lists the
    /// menu's own doors, composed from their constants so it cannot drift.
    @Test func theNoteMenuRowTeachesNoHistoryDoorAndNamesVersions() throws {
        let row = try #require(HelperView.groups.flatMap(\.items).first {
            $0.keys.hasPrefix("note \u{25BE}")
        })
        #expect(!row.does.localizedCaseInsensitiveContains("history"),
                "the note menu carries no history door — Block History sits beside commit: \(row.does)")
        #expect(row.does.localizedCaseInsensitiveContains(VersionsPath.menuLabel),
                "the note menu's Versions… door, by its own constant")
        #expect(row.does.localizedCaseInsensitiveContains(VersionsPath.saveVerb))
    }

    /// 13s-b U4 round 2 (the NIT adopted in-ladder): F1 removed the only
    /// line that pointed at Block History's home, and the group's own rule is
    /// that a door which moves without a line here is a door she cannot find.
    /// So the shortcuts tab teaches the real road — the bars' `history` door,
    /// beside commit — naming the face by its ONE constant.
    @Test func theHelperTeachesBlockHistorysRealRoad() throws {
        let rows = HelperView.groups.flatMap(\.items)
        #expect(rows.contains {
            $0.keys.localizedCaseInsensitiveContains(BlockHistoryPath.name)
                || $0.does.localizedCaseInsensitiveContains(BlockHistoryPath.name)
        }, "a shortcuts-tab row names \(BlockHistoryPath.name)")
        let door = try #require(rows.first {
            $0.does.localizedCaseInsensitiveContains(BlockHistoryPath.name)
        })
        #expect(door.keys.hasPrefix(BlockHistoryPath.doorLabel),
                "the row is keyed by the bars' own door word: \(door.keys)")
        #expect(door.does.localizedCaseInsensitiveContains("beside commit"),
                "…and says where the door sits")
    }
}
