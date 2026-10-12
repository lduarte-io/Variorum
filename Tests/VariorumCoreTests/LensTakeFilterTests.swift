import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// VX-170 — lens-aware Takes' ONE rule (`Domain/LensTakeFilter`): the four
/// forms of R-VX170-1, the expand set of R-VX170-3, P-VX170-1's blank takes,
/// and the dangling-pick reading (PROVISIONAL P-VX168-U4-2). The pure arms are
/// pinned exactly; then the same rule over REAL projections
/// (`Queries.takesProjection`), the facts the Takes board draws from.
@Suite("Lens-aware Takes: the four forms (VX-170, R-VX170-1/3)")
struct LensTakeFilterTests {
    // MARK: - The pure arms, exactly

    /// A pick table for one block: lens → the take it names here.
    private func picks(_ table: [String: String]) -> (String) -> String? {
        { table[$0] }
    }

    @Test func inLensMatchesExactlyWhereTheLensNamesATake() {
        let filter = LensTakeFilter.inLens("X")
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "t"])) == ["t"])
        // A lens naming the SHOWN take still names a take — `in X` is about
        // the lens, never about agreement (the shape's own semantics).
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "c"])) == ["c"])
        #expect(filter.namedTakes(shown: "c", pick: picks([:])) == nil)
        #expect(filter.namedTakes(shown: "c", pick: picks(["Y": "t"])) == nil)
    }

    @Test func inButNotInNeedsTheFirstAndNotTheSecond() {
        let filter = LensTakeFilter.inLensNotIn("A", "B")
        #expect(filter.namedTakes(shown: "c", pick: picks(["A": "a"])) == ["a"])
        #expect(filter.namedTakes(shown: "c", pick: picks(["A": "a", "B": "b"])) == nil)
        #expect(filter.namedTakes(shown: "c", pick: picks(["A": "a", "B": "a"])) == nil,
                "B naming ANY take — even A's — means B is in")
        #expect(filter.namedTakes(shown: "c", pick: picks(["B": "b"])) == nil)
        #expect(filter.namedTakes(shown: "c", pick: picks([:])) == nil)
    }

    @Test func disagreeNeedsBothAndDifferentTakes() {
        let filter = LensTakeFilter.disagree("X", "Y")
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "x", "Y": "y"])) == ["x", "y"])
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "c", "Y": "y"])) == ["c", "y"])
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "t", "Y": "t"])) == nil,
                "the same take is agreement")
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "x"])) == nil,
                "only one names a take — no disagreement to show")
        #expect(filter.namedTakes(shown: "c", pick: picks(["Y": "y"])) == nil)
        #expect(filter.namedTakes(shown: "c", pick: picks([:])) == nil)
    }

    @Test func disagreeWithChosenComparesAgainstTheShownTake() {
        let filter = LensTakeFilter.disagreeWithChosen("X")
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "x"])) == ["x"])
        #expect(filter.namedTakes(shown: "c", pick: picks(["X": "c"])) == nil)
        #expect(filter.namedTakes(shown: "c", pick: picks([:])) == nil,
                "a lens with no pick here shows the chosen take — it agrees")
    }

    @Test func aGapSlotNeverMatchesAnyForm() {
        let table = picks(["X": "x", "Y": "y", "A": "a"])
        for filter: LensTakeFilter in [
            .inLens("X"), .inLensNotIn("A", "B"), .disagree("X", "Y"), .disagreeWithChosen("X"),
        ] {
            #expect(filter.namedTakes(shown: nil, pick: table) == nil, "\(filter)")
        }
    }

    @Test func theExpandSetIsTheNamedTakesPlusTheShownOneInFanOrder() {
        let fan = ["c", "x", "y", "z"]
        #expect(LensTakeFilter.disagree("Y", "X").expandSet(
            shown: "c", fan: fan, pick: picks(["X": "x", "Y": "y"])) == ["c", "x", "y"],
            "fan order, never the expression's order")
        #expect(LensTakeFilter.inLens("X").expandSet(
            shown: "c", fan: fan, pick: picks(["X": "c"])) == ["c"],
            "a lens naming the shown take expands to that take alone")
        #expect(LensTakeFilter.disagreeWithChosen("X").expandSet(
            shown: "y", fan: fan, pick: picks(["X": "z"])) == ["y", "z"])
        #expect(LensTakeFilter.inLens("X").expandSet(
            shown: "c", fan: fan, pick: picks([:])) == nil)
    }

    @Test func theFormsAreHerFourInHerOrderWithTheirOperandCounts() {
        #expect(LensTakeFilter.Form.allCases
                == [.inLens, .inLensNotIn, .disagree, .disagreeWithChosen])
        #expect(LensTakeFilter.Form.allCases.map(\.lensCount) == [1, 2, 2, 1])
        for filter: LensTakeFilter in [
            .inLens("X"), .inLensNotIn("A", "B"), .disagree("X", "Y"), .disagreeWithChosen("X"),
        ] {
            #expect(LensTakeFilter(form: filter.form, lenses: filter.lensIDs) == filter)
        }
    }

    @Test func aFormThatCouldOnlyMatchNothingIsNeverBuilt() {
        #expect(LensTakeFilter(form: .inLensNotIn, lenses: ["A", "A"]) == nil)
        #expect(LensTakeFilter(form: .disagree, lenses: ["A", "A"]) == nil)
        #expect(LensTakeFilter(form: .inLens, lenses: []) == nil)
        #expect(LensTakeFilter(form: .inLens, lenses: ["A", "B"]) == nil)
        #expect(LensTakeFilter(form: .disagree, lenses: ["A"]) == nil)
    }

    // MARK: - Over a REAL projection (the board's own facts)

    /// Four blocks, two lenses (“claude's cut” = X, “mine” = Y):
    ///   B1: c1 (chosen) · a1 · blank1 (a BLANK take) — X picks blank1, Y picks a1
    ///   B2: c2 (chosen) · a2                         — X and Y both pick a2
    ///   B3: c3 (chosen) · twin3 (byte-identical text) — Y picks c3, W picks twin3
    ///   B4: c4 (chosen) · a4                         — X picks a4 (archived later)
    private struct World {
        let postID: String
        let b1, b2, b3, b4: String
        let c1, a1, blank1, c2, a2, c3, twin3, c4, a4: String
        let x, y, w, z: String
    }

    private func makeWorld(_ ops: Operations) throws -> World {
        let post = try ops.createPost(title: "readme review", profile: .blog)
        let m1 = try ops.newBlock(in: post.id, text: "Block one.", at: .end)
        let m2 = try ops.newBlock(in: post.id, text: "Block two.", at: .end)
        let m3 = try ops.newBlock(in: post.id, text: "Block three.", at: .end)
        let m4 = try ops.newBlock(in: post.id, text: "Block four.", at: .end)
        let a1 = try ops.branchVariant(m1.block.id, from: m1.variant.id)
        try ops.autosave(a1.id, text: "Block one, rewritten.", charDelta: 11)
        let blank1 = try ops.newBlankVariant(m1.block.id)
        let a2 = try ops.branchVariant(m2.block.id, from: m2.variant.id)
        try ops.autosave(a2.id, text: "Block two, tightened.", charDelta: 10)
        // A branch copies the buffer: the twin's text IS the chosen take's.
        let twin3 = try ops.branchVariant(m3.block.id, from: m3.variant.id)
        let a4 = try ops.branchVariant(m4.block.id, from: m4.variant.id)
        try ops.autosave(a4.id, text: "Block four, cut.", charDelta: 4)

        let x = try ops.createLens(post: post.id, name: "claude's cut")
        try ops.setLensChoice(lens: x.id, block: m1.block.id, variant: blank1.id)
        try ops.setLensChoice(lens: x.id, block: m2.block.id, variant: a2.id)
        try ops.setLensChoice(lens: x.id, block: m4.block.id, variant: a4.id)
        let y = try ops.createLens(post: post.id, name: "mine")
        try ops.setLensChoice(lens: y.id, block: m1.block.id, variant: a1.id)
        try ops.setLensChoice(lens: y.id, block: m2.block.id, variant: a2.id)
        try ops.setLensChoice(lens: y.id, block: m3.block.id, variant: m3.variant.id)
        let w = try ops.createLens(post: post.id, name: "twin")
        try ops.setLensChoice(lens: w.id, block: m3.block.id, variant: twin3.id)
        let z = try ops.createLens(post: post.id, name: "empty")
        return World(
            postID: post.id,
            b1: m1.block.id, b2: m2.block.id, b3: m3.block.id, b4: m4.block.id,
            c1: m1.variant.id, a1: a1.id, blank1: blank1.id, c2: m2.variant.id, a2: a2.id,
            c3: m3.variant.id, twin3: twin3.id, c4: m4.variant.id, a4: a4.id,
            x: x.id, y: y.id, w: w.id, z: z.id)
    }

    private func projection(_ db: AppDatabase, _ postID: String) throws -> Queries.TakesProjection {
        try db.read { try Queries.takesProjection($0, post: postID) }
    }

    @Test func theFourFormsOverARealNote() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops)
            let p = try projection(db, w.postID)

            // in X — the blanked block IS in X (P-VX170-1); B3 has no X pick.
            let inX = p.evaluate(.inLens(w.x))
            #expect(inX.expanded == [w.b1: [w.c1, w.blank1], w.b2: [w.c2, w.a2], w.b4: [w.c4, w.a4]])
            #expect(inX.blockCount == 4)
            #expect(inX.matchCount == 3)

            // in Y — B3's pick IS the chosen take: a match whose expand set is
            // that take alone.
            #expect(p.evaluate(.inLens(w.y)).expanded
                    == [w.b1: [w.c1, w.a1], w.b2: [w.c2, w.a2], w.b3: [w.c3]])

            // in X, not in Y — only B4 (X picks, Y names nothing there).
            #expect(p.evaluate(.inLensNotIn(w.x, w.y)).expanded == [w.b4: [w.c4, w.a4]])
            // in Y, not in X — only B3.
            #expect(p.evaluate(.inLensNotIn(w.y, w.x)).expanded == [w.b3: [w.c3]])

            // X disagrees with Y — B1 (the blank vs a1); B2 agrees (both a2).
            #expect(p.evaluate(.disagree(w.x, w.y)).expanded == [w.b1: [w.c1, w.a1, w.blank1]])

            // X disagrees with the chosen takes — every block X names that the
            // note does not show, the blank included (blank-vs-chosen IS a
            // disagreement: a lens's proposed deletion surfaces).
            #expect(p.evaluate(.disagreeWithChosen(w.x)).expanded
                    == [w.b1: [w.c1, w.blank1], w.b2: [w.c2, w.a2], w.b4: [w.c4, w.a4]])
            // Y on B3 picks the chosen take — agreement, no match.
            #expect(p.evaluate(.disagreeWithChosen(w.y)).expanded
                    == [w.b1: [w.c1, w.a1], w.b2: [w.c2, w.a2]])
        }
    }

    @Test func disagreementIsTakeIdentityNeverText() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops)
            let p = try projection(db, w.postID)
            let twin = p.fans[w.b3]?.first { $0.id == w.twin3 }
            let chosen = p.fans[w.b3]?.first { $0.id == w.c3 }
            #expect(twin?.workingText == chosen?.workingText, "fixture: byte-identical twins")
            // R-VX170-1: "both name takes, DIFFERENT ONES" — the twin is a
            // different take, so it disagrees with the chosen one.
            #expect(p.evaluate(.disagreeWithChosen(w.w)).expanded == [w.b3: [w.c3, w.twin3]])
            #expect(p.evaluate(.disagree(w.w, w.y)).expanded == [w.b3: [w.c3, w.twin3]])
        }
    }

    @Test func aDanglingPickNamesNothing() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops)
            try ops.archiveVariant(w.a4)
            let p = try projection(db, w.postID)
            #expect(p.lensDangles[w.x]?[w.b4] != nil, "fixture: X's B4 pick dangles")
            // PROVISIONAL P-VX168-U4-2: the dangle names nothing — B4 leaves
            // every X form, exactly as the board falls through to chosen there.
            #expect(!p.evaluate(.inLens(w.x)).matches(w.b4))
            #expect(!p.evaluate(.disagreeWithChosen(w.x)).matches(w.b4))
            #expect(p.evaluate(.inLensNotIn(w.x, w.y)).matchCount == 0)
            // …and an X that names nothing there leaves Y's `not in X` arm open.
            #expect(p.evaluate(.inLensNotIn(w.y, w.x)).expanded == [w.b3: [w.c3]])
        }
    }

    @Test func theChosenSideFollowsTheRenderedTake() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops)
            try ops.chooseVariant(w.b1, variantID: w.a1)
            let p = try projection(db, w.postID)
            // Y picks a1, which the note now shows: agreement on B1.
            #expect(!p.evaluate(.disagreeWithChosen(w.y)).matches(w.b1))
            // The expand set carries the NEW shown take beside X's blank.
            #expect(p.evaluate(.disagreeWithChosen(w.x)).expanded[w.b1] == [w.a1, w.blank1])
        }
    }

    @Test func aLensThatNamesNothingMatchesNothingHonestly() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops)
            let p = try projection(db, w.postID)
            let empty = p.evaluate(.inLens(w.z))
            #expect(empty.matchCount == 0)
            #expect(empty.blockCount == 4, "the denominator stays the whole note")
            #expect(p.evaluate(.disagreeWithChosen(w.z)).matchCount == 0)
            #expect(p.evaluate(.disagree(w.z, w.x)).matchCount == 0)
        }
    }
}
