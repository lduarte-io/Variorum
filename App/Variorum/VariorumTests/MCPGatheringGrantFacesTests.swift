//
//  MCPGatheringGrantFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-549 (VX-548 batch 3) — A GATHERING AS A GRANT PLACE, its faces. Her
//  sitting (2026-10-27, RATIFIED): "Gathering joins the grant scopes … Starring
//  is not on the wire … so write_new on a rule tagging can't satisfy (star
//  terms) refuses honestly and the grant sheet presents such a grant as
//  read/suggest-shaped."
//
//  The pure decisions the sheet, the road and the ask queue read: a gathering
//  picked is a gathering grant; a star-rule gathering offers every rung with a
//  heads-up at write new or edit (VX-596 — her ruling 2026-10-27, "let's add the
//  star over the wire", superseding VX-549's read/suggest shaping — the flips
//  below cite it); Change… on a gathering grant replaces only on its own
//  place (VX-516's rule, one more place kind); the gathering picker's rows; an
//  ask on a gathering keys as its reading (MB-10's question — PROVISIONAL
//  MB-17); the words. Red on the old tree by construction (no gathering place,
//  prefill or scope kind existed).
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
@Suite("VX-549 — a gathering as a grant place: the sheet, the road, the ask's key, the words")
struct MCPGatheringGrantFacesTests {
    private let stamp = "2026-07-01T00:00:00.000Z"

    private func gathering(
        _ id: String, _ name: String, starred: Bool = false, archived: Bool = false, needsStar: Bool = false,
        wing: String = ""
    ) -> Queries.MCPGrantableGathering {
        .init(id: id, name: name, wingID: wing, starred: starred, archived: archived, needsStar: needsStar,
              createdAt: stamp)
    }

    @Test func aGatheringPickedIsAGatheringGrantOnItsOwnPlace() {
        let spec = MCPGrantSheet.spec(
            place: .gathering, noteID: nil, bookID: "a-book", wingID: "", rung: .suggest, duration: .always,
            offered: [.once, .always], gatheringID: "g")
        #expect(spec == .init(rung: .suggest, scopeKind: .gathering, scopeID: "g", duration: .always))
        #expect(MCPGrantSheet.spec(
            place: .gathering, noteID: nil, bookID: nil, wingID: "", rung: .read, duration: .always,
            offered: [.always], gatheringID: nil) == nil, "nothing picked yet")
        #expect(MCPGrantSheet.confirmedPlaces(
            place: .gathering, noteID: nil, noteIDs: [], bookID: "a-book", wingID: "", gatheringID: "g")
                == [MCPGrantChange.Place(.gathering, "g")])
        // The prefill names the same place; a gathering grant's own place is one.
        #expect(MCPGrantPrefill.gathering("g").places == [MCPGrantChange.Place(.gathering, "g")])
        let row = MCPGrantRow(
            id: "grant", clientID: "c", rung: .read, scopeKind: .gathering, scopeID: "g", duration: .always,
            createdAt: stamp, consumedAt: nil, revokedAt: nil)
        #expect(MCPGrantPrefill.place(of: row) == .gathering("g"))
    }

    /// VX-516's rule holds for the new place kind: Change… on a gathering grant
    /// replaces only while the gathering confirmed IS the one it was opened on.
    @Test func changeOnAGatheringGrantReplacesOnlyOnItsOwnPlace() {
        let client = MCPClient(
            id: "c", name: "claude-code", version: "1", state: .approved, firstSeenAt: stamp, lastSeenAt: stamp,
            decidedAt: stamp)
        let row = MCPGrantRow(
            id: "grant", clientID: "c", rung: .suggest, scopeKind: .gathering, scopeID: "g", duration: .always,
            createdAt: stamp, consumedAt: nil, revokedAt: nil)
        let opening = MCPReachPopover.changeOpening(client, row)
        #expect(opening.place == .gathering("g") && opening.replacing == ["grant"])
        let same = Operations.MCPGrantSpec(rung: .read, scopeKind: .gathering, scopeID: "g", duration: .always)
        #expect(MCPGrantSheet.act(opening: opening, place: .gathering, spec: same, noteIDs: [], rung: .read,
                                  duration: .always) == .grant(same, replacing: ["grant"]))
        let other = Operations.MCPGrantSpec(rung: .read, scopeKind: .gathering, scopeID: "g2", duration: .always)
        #expect(MCPGrantSheet.act(opening: opening, place: .gathering, spec: other, noteIDs: [], rung: .read,
                                  duration: .always) == .grant(other, replacing: []), "another gathering: a new grant")
        let book = Operations.MCPGrantSpec(rung: .read, scopeKind: .book, scopeID: "g", duration: .always)
        #expect(MCPGrantSheet.act(opening: opening, place: .book, spec: book, noteIDs: [], rung: .read,
                                  duration: .always) == .grant(book, replacing: []), "a kind is part of the place")
    }

    /// **A DELIBERATE FLIP (VX-596 — her ruling 2026-10-27, "let's add the star
    /// over the wire, it might as well be included"; the ticket's wording points
    /// 1 and 2).** Was `aStarRuleGatheringOffersReadAndSuggestOnlyWithTheWhy`:
    /// VX-549 offered a star-rule gathering read and suggest only
    /// (`offeredRungs(needsStar: true) == [.read, .suggest]`) with the why "Its
    /// rule needs a starred note, and only you can star one — so a client can
    /// read and suggest here, but not write new or edit." The wire stars such a
    /// note now, so every rung is offered and the why is reworded into the one
    /// heads-up at the rungs that write a new note.
    @Test func aStarRuleGatheringOffersEveryRungWithAHeadsUpWhereANoteIsWritten() {
        #expect(MCPPaneCopy.offeredRungs == [.read, .suggest, .writeNew, .edit], "the sheet's one rung list")
        for rung in [MCPGrantRule.Rung.read, .suggest] {
            #expect(MCPGrantPicker.starHeadsUp(needsStar: true, rung: rung) == nil, "\(rung) writes no note")
        }
        for rung in [MCPGrantRule.Rung.writeNew, .edit] {
            #expect(MCPGrantPicker.starHeadsUp(needsStar: true, rung: rung) == MCPPaneCopy.starHeadsUp, "\(rung)")
            #expect(MCPGrantPicker.starHeadsUp(needsStar: false, rung: rung) == nil, "a tag rule stars nothing")
        }
        #expect(MCPPaneCopy.starHeadsUp == "Its rule needs a star, so a new note a client writes here is starred.")
        #expect(!MCPPaneCopy.starHeadsUp.contains("only you"), "the premise set_starred made false is gone")
        #expect(!MCPPaneCopy.starHeadsUp.contains("AI"), "settings-class words (VX-272)")
    }

    /// The gathering picker: Starred (quick, before typing) then every
    /// gathering a–z; each row's footing says its shelf and its archived state.
    /// A DELIBERATE FLIP (VX-596 — her ruling 2026-10-27; the ticket's wording
    /// point 2): the star-rule row's "read and suggest only" footing retired
    /// with the shaping it named.
    @Test func theGatheringPickerIsStarredThenAToZWithEachRowsFooting() {
        let places = MCPGrantPlaces(gatherings: [
            gathering("g2", "zeta ideas", starred: true),
            gathering("g1", "alpha ideas", needsStar: true),
            gathering("g3", "mid ideas", archived: true),
        ])
        let layouts = MCPGrantPicker.gatheringArrangements(places, now: Date(timeIntervalSince1970: 1_782_864_000))
        #expect(layouts.count == 1)
        let sections = layouts[0].sections
        #expect(sections.map(\.id) == ["starred", "all"])
        #expect(sections[0].isQuick && sections[0].options.map(\.id) == ["g2"])
        #expect(sections[1].options.map(\.id) == ["g1", "g3", "g2"], "a–z, digit-aware")
        let alpha = try? #require(sections[1].options.first { $0.id == "g1" })
        #expect(alpha?.detail?.contains("read and suggest") == false, "the star-rule row: no rung footing")
        #expect(alpha?.detail == PlaceLabels.unshelved, "its shelf, as every row")
        #expect(sections[1].options.first { $0.id == "g3" }?.detail?.contains("archived") == true)
    }

    /// MB-10's question, answered (PROVISIONAL MB-17): an ask on a gathering
    /// keys as its READING — the key every reading row's glyph already asks
    /// with — so the Bookcase's, the Library's and the Book Panel's gathering
    /// rows mark it with no face change.
    @Test func anAskOnAGatheringKeysAsItsReading() {
        let ask = MCPAsk(
            clientName: "claude-code", scopeKind: .gathering, scopeID: "g", title: "parser things",
            rung: .writeNew, fence: nil)
        #expect(MCPAskQueue.target(ask) == .book("g"))
        #expect(MCPAskCopy.title(ask) == "claude-code asks to write new in \u{201C}parser things\u{201D}")
        #expect(MCPAskCopy.reachLine(ask)
                == "Allowing grants it in \u{201C}parser things\u{201D}, including notes its rule gathers later.")
        #expect(MCPAskCopy.lead(ask)
                == "If you allow it, " + MCPPaneCopy.rungDetail(.writeNew, scope: .gathering) + ".")
        var fenced = ask
        fenced = MCPAsk(clientName: ask.clientName, scopeKind: .gathering, scopeID: "g", title: ask.title,
                        rung: .writeNew, fence: .privateMark)
        #expect(MCPAskCopy.reachLine(fenced) == nil, "a gathering fenced since takes no grant")
        #expect(MCPAskCopy.granted(ask, duration: .always)
                == "Allowed claude-code: write new in \u{201C}parser things\u{201D} always.")
    }

    /// The ladder's round 1, finding 4: a gathering ask that meets a fence
    /// before she opens it — `MCPDoor.askStanding` re-reads it through
    /// `mcpGatheringFacts`, where a stale 'daily' marker on the row is
    /// `.journal` — names WHICH fence, as the book's ask does and as the pane's
    /// inert row already does (`inertDetail`), never "marked Private" for the
    /// Journal. Red on the old tree: its one gathering arm said "marked
    /// Private" for any fence.
    @Test func aFencedGatheringsAskNamesItsFenceAsTheBooksDoes() {
        func ask(_ kind: MCPGrantRule.ScopeKind, _ fence: MCPGrantRule.Fence) -> MCPAsk {
            MCPAsk(clientName: "claude-code", scopeKind: kind, scopeID: "g", title: "parser things",
                   rung: .writeNew, fence: fence)
        }
        let journal = MCPAskCopy.lead(ask(.gathering, .journal))
        #expect(journal
                == "This gathering is your daily Journal now, which no grant reaches. Don't allow lets this ask go.")
        #expect(!journal.contains("Private"), "the Journal's fence is never called the Private mark")
        #expect(MCPAskCopy.lead(ask(.gathering, .privateMark))
                == "This gathering is marked Private now, which no grant reaches. Don't allow lets this ask go.",
                "the Private arm is unchanged")
        // The words are the book arm's where the kinds align, and the pane's
        // inert row says the same of the same gathering.
        #expect(MCPAskCopy.lead(ask(.book, .journal))
                    .hasPrefix("This book is your daily Journal now, which no grant reaches"))
        #expect(MCPPaneCopy.inertDetail(.journal, kind: .gathering).contains("your daily Journal now"))
        // Either fence still grants nothing from the ask.
        #expect(MCPAskCopy.reachLine(ask(.gathering, .journal)) == nil)
        #expect(MCPAskCopy.reachLine(ask(.gathering, .privateMark)) == nil)
    }

    /// **VX-609 — the write-new ask on a star-rule gathering promises what its
    /// grant now does.** The VX-548 final walk: the ask offered Once / Until it
    /// disconnects / Always to "write new", promising "it can also make new notes
    /// in it, wearing the tags its rule needs", and the answered grant could only
    /// refuse — a dead door (P-2). The act is fixed on the wire (the answered
    /// Once now lands the note starred — `MCPGatheringGrantServerTests
    /// .anAnsweredAskOnAStarRuleGatheringLandsTheNoteNeverADeadDoor`, red on the
    /// pre-fix tree); here the ask's face follows the new reach instead of
    /// being removed: its durations stand (every one honest now) and its lead
    /// says the star. Red on old: the lead never said "starred".
    @Test func theWriteNewAskOnAGatheringOffersItsDurationsAndSaysTheStar() {
        let ask = MCPAsk(
            clientName: "claude-code", scopeKind: .gathering, scopeID: "g", title: "starred ideas",
            rung: .writeNew, fence: nil)
        let door = MCPDoor(serverAllowed: false)
        #expect(door.durations(for: ask) == [.once, .always], "every honest duration — while connected needs a connection")
        #expect(MCPAskCopy.lead(ask)
                == "If you allow it, it can also make new notes in it, wearing the tags its rule needs (starred, "
                + "if it needs a star), and apply tags.")
        #expect(MCPAskCopy.reachLine(ask)
                == "Allowing grants it in \u{201C}starred ideas\u{201D}, including notes its rule gathers later.")
    }

    /// The words a gathering grant wears in the pane, the confirm and the
    /// popover's why (PROVISIONAL, her copy pass).
    @Test func theWordsAGatheringGrantWears() {
        #expect(MCPPaneCopy.kindChip(.gathering) == "gathering")
        #expect(MCPPaneCopy.confirm(verb: "Grant", rung: .read, scope: .gathering, place: "parser things",
                                    duration: .always)
                == "Grant read in \u{201C}parser things\u{201D} always, including notes its rule gathers later")
        // A DELIBERATE FLIP (VX-596 — her ruling 2026-10-27; the ticket's wording
        // point 4, VX-609): "…wearing the tags its rule needs, and apply tags"
        // now says the star a rule may need — the sheet's line and the ask's lead.
        #expect(MCPPaneCopy.rungDetail(.writeNew, scope: .gathering)
                == "it can also make new notes in it, wearing the tags its rule needs (starred, if it needs a "
                + "star), and apply tags")
        #expect(MCPPaneCopy.inertDetail(.privateMark, kind: .gathering)
                == "inert \u{2014} the gathering is marked Private, which always asks")
        let client = MCPClient(
            id: "c", name: "claude-code", version: "1", state: .approved, firstSeenAt: stamp, lastSeenAt: stamp,
            decidedAt: stamp)
        let grant = MCPGrantRow(
            id: "grant", clientID: "c", rung: .read, scopeKind: .gathering, scopeID: "g", duration: .always,
            createdAt: stamp, consumedAt: nil, revokedAt: nil)
        let through = MCPPlaceReach(client: client, rung: .read, grant: grant, throughTitle: "parser things")
        #expect(MCPShareCopy.why(through) == "through \u{201C}parser things\u{201D}")
        #expect(MCPShareCopy.revokeLabel(through) == "Revoke the grant on \u{201C}parser things\u{201D}")
    }
}
