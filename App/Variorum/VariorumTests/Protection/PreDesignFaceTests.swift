//
//  PreDesignFaceTests.swift
//  VariorumTests — VX-329 U4 piece 2: HER PRE-DESIGN FACE (the plan's §6d — her ruling and her approved words at the
//  2026-10-22 morning sitting, after the §8 rehearsal's byte-copy finding). Three pins:
//    · THE WORDS ARE HERS, BYTE-EQUAL: every string the face says is read out of the plan file's §6d itself (its prose
//      wraps lines, so whitespace runs collapse to one space; each string is looked up between its own quotes or bold
//      markers there). An edit to her words in the plan turns this red until `ProtectionWords.swift` follows.
//    · THE DOOR ACTS: *Start fresh…* is offered only on the pre-design fact and only with its act wired (P-2); pressed
//      after her confirm, it runs the act once and says what the act says.
//    · THE MAC'S FACE renders her lead, her body and her two doors in place of every road, and asks her confirm first
//      (a source pin over `RoadLockView` — the view's composition, as the neighbouring pins read it).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-329 U4 — her pre-design face: her words byte-equal, the door that acts, the Mac's face")
@MainActor
struct PreDesignFaceTests {
    // MARK: - Her words, byte-equal to the plan's §6d

    /// The plan file's §6d, its whitespace runs collapsed (the prose wraps mid-sentence).
    static func section6d() throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("notes/plans/vx-329-release-switch.md")
        let plan = try String(contentsOf: url, encoding: .utf8)
            .split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
        let start = try #require(plan.range(of: "**The ruled face (HER WORDS"))
        let end = try #require(plan.range(of: "**The build:**"))
        return String(plan[start.lowerBound..<end.lowerBound])
    }

    @Test func everyStringTheFaceSaysIsHerWordsByteEqual() throws {
        let words = try Self.section6d()
        for quoted in [ProtectionWords.preDesignLead, ProtectionWords.preDesignBody, ProtectionWords.preDesignStartFreshConfirm] {
            #expect(words.contains("\"\(quoted)\""), "§6d says \"\(quoted)\" — byte-equal")
        }
        for door in [ProtectionWords.preDesignStartFreshDoor, ProtectionWords.preDesignOpenDoor] {
            #expect(words.contains("**\(door)**"), "§6d names the door **\(door)** — byte-equal")
        }
        // The second door IS the standing one (the same words, one constant).
        #expect(ProtectionWords.preDesignOpenDoor == ProtectionWords.noKeyFileOpenDoor)
        // The confirm's button is her door's own words without the door's ellipsis (PROVISIONAL P-VX329-U4-2).
        #expect(ProtectionWords.preDesignStartFreshDoor == ProtectionWords.preDesignStartFreshButton + "\u{2026}")
    }

    // MARK: - The door acts (P-2)

    static func preDesignStanding() -> RoadLobbyFacts {
        let facts = ProtectionFacts(
            scope: "vx329-u4-face", storeFile: .present, containerMarker: false, rememberedLibraryIDs: [],
            rememberedKeyFileCopies: [], custody: [], custodyOpensLibrary: nil, biometry: .none,
            catalog: Catalog.build([CatalogEntry(place: .container, name: "variorum-keys.json")]), now: Date())
        return RoadLobbyFacts(facts: facts, offeredTyped: [])
    }

    @Test func startFreshIsOfferedOnlyOnThePreDesignFactAndOnlyWithItsAct() async throws {
        final class Runs { var count = 0 }
        let runs = Runs()
        func model(_ standing: RoadLobbyFacts, act: (() async -> String?)?) -> ProtectionLobbyModel {
            ProtectionLobbyModel(
                standing: standing, typedRoad: { _ in .refused("") },
                touchIDRoad: { _ in .touchIDNotOpened(press: nil, biometry: .none, itemGone: true) },
                refreshRoad: { standing }, opened: { _ in }, recordMissing: {}, startFresh: act)
        }
        let preDesign = Self.preDesignStanding()
        #expect(ProtectionLobbyFace.derive(preDesign).preDesignStore)
        #expect(!model(preDesign, act: nil).offersStartFresh, "no act wired, no door (P-2)")

        let refusing = model(preDesign, act: { runs.count += 1; return "The act's own sentence." })
        #expect(refusing.offersStartFresh)
        await refusing.startFresh()
        #expect(runs.count == 1 && refusing.message == "The act's own sentence.", "the act's sentence is said")

        // A keyless slot (rule 27's) never offers it, act or not.
        var keyless = preDesign
        keyless.facts?.catalog = Catalog()
        let rule27 = model(keyless, act: { runs.count += 1; return nil })
        #expect(!ProtectionLobbyFace.derive(keyless).preDesignStore && !rule27.offersStartFresh)
        await rule27.startFresh()
        #expect(runs.count == 1, "nothing runs off the fact")
    }

    // MARK: - The Mac's face (a source pin over `RoadLockView`)

    @Test func theMacsFaceIsHerLeadHerBodyAndHerTwoDoorsHerConfirmFirst() throws {
        let code = try RoadLockViewNamesPinTests.roadLockViewCode()
        let branch = try #require(code.range(of: "if face.preDesignStore {"))
        let otherwise = try #require(code.range(of: "} else {", range: branch.upperBound..<code.endIndex))
        let face = code[branch.upperBound..<otherwise.lowerBound]
        #expect(face.contains("Text(ProtectionWords.preDesignLead)"), "her lead heads the card")
        #expect(face.contains("sentence(ProtectionWords.preDesignBody)"), "her body beneath it")
        #expect(face.contains("preDesignDoors"), "her two doors")
        #expect(!face.contains("lobbyTitle") && !face.contains("roads") && !face.contains("noKeyFileAnywhere"),
                "no lobby title, no road, no rule 27 on her face")
        #expect(code.contains("Button(ProtectionWords.preDesignStartFreshDoor) { confirmsStartFresh = true }"),
                "Start fresh… asks first")
        #expect(code.contains(".alert(ProtectionWords.preDesignStartFreshConfirm, isPresented: $confirmsStartFresh)"),
                "her confirm line is the ask")
        #expect(code.contains("Button(ProtectionWords.preDesignStartFreshButton) {\n                Task { await lobby.startFresh() }"),
                "the act runs only on its yes")
        #expect(code.contains("Button(ProtectionWords.preDesignOpenDoor) { openDoor() }"), "Open Library… is the standing door")
    }
}
