//
//  SavepointNamingTests.swift
//  VariorumTests
//
//  13u3 UNIT D — **named commits** (master plan item 14; her ruling
//  R-13u3-1, *"Editable"*).
//
//  The op's own transitions are core's (`SavepointNameTests`). What is
//  pinned here is everything the APP decides: what a savepoint row SAYS once
//  a name exists, what the name field's two keys mean, and that the commit
//  door's skip road is still two keys and exactly one savepoint.
//
//  **These are a new capability's pins, not a defect's** — the brief says so
//  and says not to manufacture reds for one. The single cell here that IS
//  defect-shaped names itself.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("A savepoint's name (13u3 UNIT D — item 14)")
struct SavepointNameFaceTests {
    private let when = Date(timeIntervalSince1970: 1_782_864_000)

    private func savepoint(
        _ id: String = "c1", kind: CommitKind = .manual, message: String? = nil
    ) -> CommitPoint {
        CommitPoint(
            id: id, variantId: "v1", text: "a saved moment", kind: kind,
            message: message, createdAt: when)
    }

    /// **THE NAME LEADS** — her ruling's display half, as a value.
    @Test func theNameIsTheFirstThingTheRowSays() {
        let named = savepoint(message: "before the AI edit")
        #expect(SavepointRowFace.name(named) == "before the AI edit")
        #expect(SavepointRowFace.meta(named, predatesSplit: false).first == "before the AI edit",
                "a name she can only find past a date is a name the row is hiding")
        // The details follow it, whole and in their shipped order.
        #expect(SavepointRowFace.meta(named, predatesSplit: false).dropFirst()
            == SavepointRowFace.details(named, predatesSplit: false)[...])
    }

    /// An unnamed savepoint reads EXACTLY as it always has — the ordering
    /// change costs the shipped rows nothing.
    @Test func anUnnamedSavepointReadsExactlyAsItAlwaysHas() {
        let plain = savepoint()
        #expect(SavepointRowFace.name(plain) == nil)
        #expect(SavepointRowFace.meta(plain, predatesSplit: false)
            == SavepointRowFace.details(plain, predatesSplit: false))
        #expect(SavepointRowFace.meta(plain, predatesSplit: false).contains("saved by hand"))
        #expect(SavepointRowFace.meta(plain, predatesSplit: true)
            .contains(BlockHistoryCopy.predatesSplitMark))
    }

    /// **THE OCCASION IS NEVER OVERWRITTEN BY THE NAME** (her ruling's own
    /// note): a renamed QUIET savepoint still says *quiet*, because the
    /// rename writes `message` and leaves `kind` alone.
    @Test func aNamedQuietSavepointStillSaysQuiet() {
        let quiet = savepoint(kind: .auto, message: "the one before I left")
        let meta = SavepointRowFace.meta(quiet, predatesSplit: false)
        #expect(meta.first == "the one before I left")
        #expect(meta.contains("quiet"))
        #expect(SavepointRowFace.details(quiet, predatesSplit: false).contains("quiet"))
    }

    /// A face can never show a name the store would have normalised away —
    /// both roads read the ONE rule.
    @Test func theFaceReadsTheSameNameRuleTheStoreWritesBy() {
        #expect(SavepointRowFace.name(savepoint(message: "   ")) == nil)
        #expect(SavepointRowFace.name(savepoint(message: "")) == nil)
        #expect(SavepointRowFace.name(savepoint(message: "  padded  ")) == "padded")
    }

    /// The door's verb says what it does on THIS row (the `putBackHelp`
    /// rule, one region up), and the receipts quote the name back.
    @Test func theRenameDoorWordsItselfToItsRow() {
        #expect(BlockHistoryCopy.nameVerb(savepoint()) == BlockHistoryCopy.nameSavepointVerb)
        #expect(BlockHistoryCopy.nameVerb(savepoint(message: "named"))
            == BlockHistoryCopy.renameSavepointVerb)
        #expect(BlockHistoryCopy.nameHelp(savepoint()) != BlockHistoryCopy.nameHelp(
            savepoint(message: "named")))
        #expect(BlockHistoryCopy.renamed("before the AI edit").contains("before the AI edit"))
        #expect(BlockHistoryCopy.renamed(nil) == BlockHistoryCopy.savepointNameCleared)
    }
}
