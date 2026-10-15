//
//  MCPWireRefusalSweepTests.swift
//  VariorumTests
//
//  VX-362 (b) — **NO WIRE ANSWER SHOWS A RAW SWIFT CASE** (the VX-336 run
//  record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`, the U9 UNIT
//  RECORD's SWEEP TABLE and THE ORCHESTRATOR'S RULINGS ON U9's FORKS).
//
//  Seen live in U8's real-client round: `apply_tag` on a worn tag answered
//  `Refused: alreadyTagged(tagID: "…", targetID: "…")` — the shared table's
//  fallthrough (`OpsRefusalCopy.message(for:roads:)`). The sweep traced every
//  `OperationError` case a wire tool can reach (an over-approximate call graph
//  rooted at every core call the MCP target makes, then the candidates by
//  hand): 65 worded, 2 worded by their tool on their only road, 17 + 13 proven
//  unreachable, 1 closed by `apply_tag`'s posture (F-2), and 10 reachable with
//  no words — worded in this unit (D3: the shared table for a refusal her
//  doors can meet, `MCPWireRefusalCopy` for one only a client can type).
//
//  This pin walks the class, not the instance: it reads `OperationError.swift`
//  by `#filePath`, holds ONE sample per case (the two sets must be EQUAL — a
//  new case fails here until it is swept), and runs every case not proven
//  unreachable through the door's EXACT chain — `MCPWireRefusalCopy.spoken`
//  with the Mac door's hook (`MCPDoor`: `OpsRefusalCopy.message(for:)`). No
//  answer may start "Refused:", carry the case's name followed by "(", or be
//  the error's bare description.
//
//  Red on the old tree: the ten unworded cases (two issues each — the
//  "Refused:" prefix and the case's name).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum
@testable import VariorumMCP

@Suite("VX-362 — no wire answer shows a raw Swift case (the sweep, every OperationError)")
struct MCPWireRefusalSweepTests {
    /// The repo root, from this file's own path (App/Variorum/VariorumTests/…).
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // the repo
    }

    /// The enum's cases as its source declares them (one `case` per line —
    /// the file's own style; the sweep tool reads it the same way).
    private static func declaredCases() throws -> [String] {
        let url = repoRoot.appendingPathComponent("Sources/VariorumCore/Operations/OperationError.swift")
        let source = try String(contentsOf: url, encoding: .utf8)
        return source.components(separatedBy: "\n").compactMap { line in
            guard line.hasPrefix("    case ") else { return nil }
            let name = line.dropFirst("    case ".count).prefix { $0.isLetter || $0.isNumber }
            return name.isEmpty ? nil : String(name)
        }
    }

    /// A case's name — its description up to the payload.
    private static func name(_ error: OperationError) -> String {
        String(String(describing: error).prefix { $0 != "(" })
    }

    /// ONE sample per case, in the source's order.
    static let samples: [OperationError] = [
        .containerNotFound(id: "c"), .containerNotDeleted(id: "c"), .blockNotFound(id: "b"),
        .variantNotFound(id: "v"), .commitNotFound(id: "m"), .readingNotFound(id: "r"),
        .readingNotDeleted(id: "r"), .tagNotFound(id: "t"), .referenceNotFound(id: "f"),
        .wrongContainerKind(id: "c", expected: .post), .wrongReadingKind(id: "r", expected: .book),
        .invalidEntryDate("2019-02-30"),
        .lockedPost(id: "p"), .lockedVariant(id: "v"), .lockedReading(id: "r"),
        .dailyJournalTraitIsConstitutive(id: "r"),
        .lastActiveVariant(id: "v"), .variantIsChosen(id: "v"), .archivedVariant(id: "v"),
        .variantNotDeleted(id: "v"), .blockCarriesUnshownText(id: "b"),
        .blockAlreadyPlaced(id: "b"), .blockNotPlaced(id: "b"), .blockNotDeleted(id: "b"),
        .blockAlreadyArchived(id: "b"), .blockNotArchived(id: "b"),
        .postNotInReading(postID: "p", readingID: "r"), .alreadyInReading(postID: "p", readingID: "r"),
        .readingAtCapacity(id: "r"), .arrivalNotFound(id: "a"), .readingHasNoAutoTag(id: "r"),
        .gatheringRequiresRule(id: "r"),
        .noteMemberedElsewhere(postID: "p", readingID: "r", elsewhere: ["s"]),
        .noteOwnedElsewhere(postID: "p", readingID: "r", owner: "o"),
        .readingSealed(id: "r"), .noteInSealedBook(postID: "p", readingID: "r"), .readingNotSealed(id: "r"),
        .ownedBookDuplicatesDeep(id: "r"),
        .readingAlreadyArchived(id: "r"), .readingNotArchived(id: "r"), .dailyJournalCannotBeDeleted(id: "r"),
        .spanNotExtractable(blockID: "b"), .invalidCut(variantID: "v", cut: 3), .fannedBlock(id: "b"),
        .noMarkedVariants(blockID: "b"), .divideSideWouldBeEmpty(blockID: "b"),
        .blocksNotAdjacent(first: "b", second: "c"), .mergedBlockWouldHaveNoTake(first: "b", second: "c"),
        .takePairedTwice(variantID: "v"), .blockNotInPool(id: "b"), .emptyTakeCannotBecomeABlock(variantID: "v"),
        .noConvertibleTakes(blockID: "b"), .noRenderableVariant(blockID: "b"),
        .duplicateTagPath(path: "a/b"), .invalidTagName(name: "a b"), .alreadyTagged(tagID: "t", targetID: "p"),
        .tagNotApplied(tagID: "t", targetID: "p"),
        .noOwnerIdentity,
        .cannotVersionLinkBlockToItself(id: "b"), .versionLinkExists(a: "b", b: "c"),
        .versionLinkNotFound(a: "b", b: "c"), .postHasNoBlocks(id: "p"), .postsAlreadyVersionLinked(a: "p", b: "q"),
        .notVersionHistory(version: "v", note: "p"),
        .bufferChangedSinceGesture(variantID: "v"),
        .lensNotFound(id: "l"), .invalidLensName(name: ""), .lensChoiceNotFound(lensID: "l", blockID: "b"),
        .blockNotInContainer(blockID: "b", containerID: "c"), .canvasPositionNotFound(blockID: "b", containerID: "c"),
        .emptyImport,
        .invalidPresentationKind,
        .commentNotFound(id: "m"), .invalidCommentText, .commentNotDeleted(id: "m"),
        .invalidExtent(value: 0),
        .invalidTint(value: "zz"),
        .sectionNotFound(id: "s"), .invalidSectionName(name: ""), .sectionNotInReading(sectionID: "s", readingID: "r"),
        .sectionNotDeleted(id: "s"),
        .shelfNotFound(id: "s"), .invalidShelfName(name: ""), .invalidShelfGlyph(value: "ab"), .wingNotFound(id: "w"),
        .invalidWingName(name: ""), .duplicateWingName(name: "work"),
        .wingNotEmpty(id: "w", contents: .init(notes: 1, books: 1, gatherings: 0, tags: 0)),
        .postAlreadyInWing(postID: "p", wingID: "w"), .crossWingMembership(postID: "p", readingID: "r"),
        .wingMoveChangedSince(postID: "p"), .dailyJournalIsHomeOnly(id: "r"),
        .readingAlreadyInWing(readingID: "r", wingID: "w"), .wingMoveIntoItself(wingID: "w"),
        .placementAnchorNotOnShelf(readingID: "r", anchorID: "a"),
        .starLimitReached(limit: 5),
        .duplicateBookName(name: "letters"),
        .purgeTargetNotDeleted(table: "container", id: "p"), .unsupportedPurgeTarget(table: "tag"),
        .deliberateSavepointNeverPruned(id: "m"),
        .smartFilterUnsatisfiable(readingID: "r", reason: "a date bound"),
        .mcpInvalidClientName(name: ""), .mcpClientNotFound(id: "c"), .mcpGrantNotFound(id: "g"),
        .mcpClientNotApproved(id: "c"), .mcpGrantScopeNotFound(kind: "note", id: "p"),
        .mcpGrantScopeFenced(kind: "book", id: "r"), .mcpRebindRequestNotFound(id: "k"),
    ]

    /// **The cases no wire answer can carry as a refusal**, each with its proof
    /// (the SWEEP TABLE's U-graph, U-hand, X and C rows, verbatim in short).
    static let unspokenOnTheWire: [String: String] = [
        // U-graph (17): no function a wire tool reaches throws it (the sweep's
        // call graph, `notes/plans/fixes/vx-336-u9-sweep/callgraph-35f9cd70.json`).
        "arrivalNotFound": "graph: unreachable",
        "blockAlreadyArchived": "graph: unreachable",
        "blockNotArchived": "graph: unreachable",
        "blockNotInPool": "graph: unreachable",
        "canvasPositionNotFound": "graph: unreachable",
        "invalidPresentationKind": "graph: unreachable",
        "lensChoiceNotFound": "graph: unreachable",
        "mcpClientNotApproved": "graph: unreachable",
        "mcpGrantScopeFenced": "graph: unreachable",
        "mcpGrantScopeNotFound": "graph: unreachable",
        "mcpRebindRequestNotFound": "graph: unreachable",
        "noOwnerIdentity": "graph: unreachable",
        "notVersionHistory": "graph: unreachable",
        "readingHasNoAutoTag": "graph: unreachable",
        "referenceNotFound": "graph: unreachable",
        "smartFilterUnsatisfiable": "graph: unreachable",
        "spanNotExtractable": "graph: unreachable",
        // U-hand (13): reachable by name, proven unreachable by hand.
        "duplicateTagPath": "adoptPath mints a segment only after reading no live tag holds the path, same transaction",
        "noMarkedVariants": "divideBlock's KeepOnTopDivide always carries the shown take's cut",
        "cannotVersionLinkBlockToItself": "link_versions refuses sameNote first; duplicate_note links FRESH copies",
        "lensNotFound": "delete_lens / adopt_lens decide on a live lens, again first in the transaction",
        "invalidLensName": "save_lens' name is requiredText at the parse (the op's trim)",
        "emptyImport": "insert_blocks and the import's book form refuse emptiness at the parse",
        "commentNotFound": "the comment acts decide on a live comment's note, again first in the transaction",
        "sectionNotDeleted": "no wire tool restores a chapter",
        "containerNotDeleted": "restoreContainerRows runs only inside her undo's inverses",
        "wrongContainerKind": "kind is never rewritten, and every wire id was decided as a live post",
        "mcpInvalidClientName": "admission's catch answers the handshake's own sentence, never a tool answer",
        "mcpClientNotFound": "admission's catch answers the handshake's own sentence, never a tool answer",
        "mcpGrantNotFound": "a once grant is consumed in the transaction that found it live; land's spend is try?",
        // X (1): closed by the act's posture (F-2, PROVISIONAL P-VX362-1).
        "alreadyTagged": "apply_tag (its only wire road) answers changed: false",
        // C (2): worded by the tool on its only wire road.
        "tagNotApplied": "remove_tag words it (notWornWords) on its one road",
        "versionLinkExists": "link_versions words it (alreadyLinked); duplicate_note links fresh blocks",
    ]

    @Test func theSamplesNameEveryCaseExactlyOnce() throws {
        let declared = try Self.declaredCases()
        #expect(declared.count > 100, "the walk read the real enum (\(declared.count) cases)")
        let sampled = Self.samples.map(Self.name)
        #expect(sampled.count == Set(sampled).count, "a case sampled twice")
        let unsampled = Set(declared).subtracting(sampled).sorted()
        let undeclared = Set(sampled).subtracting(declared).sorted()
        #expect(Set(sampled) == Set(declared),
                "unsampled: \(unsampled) · not declared: \(undeclared) — sweep the new case first")
    }

    @Test func theUnspokenCasesAreRealCasesWithTheirProofs() throws {
        let declared = Set(try Self.declaredCases())
        #expect(Set(Self.unspokenOnTheWire.keys).isSubset(of: declared),
                "\(Set(Self.unspokenOnTheWire.keys).subtracting(declared).sorted())")
        #expect(Self.unspokenOnTheWire.count == 33, "17 graph + 13 by hand + 1 posture + 2 by their tool")
        #expect(Self.unspokenOnTheWire.values.allSatisfy { !$0.isEmpty })
    }

    /// The door's exact chain (`MCPWriteTools.land` / `itemized` with the Mac
    /// door's hook) for every case a wire tool can carry.
    @Test func everyCaseTheWireCanCarrySpeaksWordsNeverARawCase() {
        var walked = 0
        for error in Self.samples where Self.unspokenOnTheWire[Self.name(error)] == nil {
            walked += 1
            let name = Self.name(error)
            let spoken = MCPWireRefusalCopy.spoken(error) { OpsRefusalCopy.message(for: $0) }
            #expect(!spoken.hasPrefix("Refused:"), "\(name): \(spoken)")
            #expect(!spoken.contains(name + "("), "\(name): \(spoken)")
            #expect(spoken != String(describing: error), "\(name): \(spoken)")
        }
        #expect(walked == 75, "65 worded + the 10 this unit words")
    }
}
