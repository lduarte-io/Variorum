//
//  LineageFaceModelTests.swift
//  VariorumTests
//
//  VX-801 (VX-827 U3b — `notes/plans/fixes/vx-827-lineage.md`, U3b RECORD) —
//  **THE LINEAGE FACE's brain, focused.** The family's order, places and acts
//  are pinned headlessly (`LineageFamilyTests`) and the cross-block operation
//  by its exact transitions (`LineageBringBackTests`); this suite holds what the
//  MODEL does with them over a real store: where it opens, the selection
//  swapping the SAME pane+rail composition to the member (the Commits face's
//  model in its relative role), act availability by state, and each header act
//  through its existing road with its words.
//
//  A PRODUCT row: the face did not exist, so the suite does not compile on the
//  pre-U3b tree. Mac-target — written and compiled at U3b, RUN in the run's
//  closing stage window.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The Lineage face's model (VX-801)", .serialized)
struct LineageFaceModelTests {
    struct World {
        let session: AppSession
        let postID: String
        /// The merged block — "the block you came from".
        let merged: String
        let mergedTake: String
        /// The merge's two sources, kept whole as lineage.
        let left: String
        let leftTake: String
        let right: String
    }

    /// A note whose two paragraphs were merged — the merged block standing,
    /// both sources kept as lineage; the left source has a second take and a
    /// named commit, so its rail has moments to read.
    private func withWorld(_ body: @escaping (World) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 827))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let post = try ops.createPost(title: "On Rereading")
            let left = try ops.newBlock(in: post.id, text: "A book read once is a rumor.")
            let right = try ops.newBlock(in: post.id, text: "Read twice, it starts to become a place.")
            _ = try ops.commit(left.variant.id, message: "the first shape")
            let spare = try ops.branchVariant(left.block.id, from: left.variant.id)
            try ops.autosave(spare.id, text: "A book read once is only a rumor.", charDelta: 5)
            let merged = try ops.merge(left.block.id, right.block.id)
            try await body(World(
                session: session, postID: post.id, merged: merged.block.id,
                mergedTake: merged.variant.id, left: left.block.id, leftTake: left.variant.id,
                right: right.block.id))
        }
    }

    private func face(_ w: World, select: String? = nil) -> LineageFaceModel {
        LineageFaceModel(session: w.session, request: BlockHistoryRequest(
            postID: w.postID, blockID: w.merged, focusedVariantID: w.mergedTake), select: select)
    }

    private func refresh(_ face: LineageFaceModel, _ w: World) async throws {
        face.adopt(try await w.session.database.read { [blockID = w.merged] db in
            try LineageFaceModel.read(db, blockID: blockID)
        })
    }

    private func refreshNode(_ face: LineageFaceModel, _ w: World) async throws {
        let node = try #require(face.node)
        let home: String? = node.isRelative ? node.homeBlockID : nil
        node.adopt(try await w.session.database.read { [blockID = node.blockID, now = w.session.now] db in
            try CommitsFaceModel.read(db, blockID: blockID, homeBlockID: home, now: now)
        })
    }

    private func takes(_ w: World, _ blockID: String) async throws -> [Variant] {
        try await w.session.database.read { try Queries.blockFan($0, blockID: blockID) }
    }

    // MARK: - Where it opens; the selection swaps the composition

    /// "lineage ›" opens on the block it came out of (the first source drawn,
    /// PROVISIONAL P-U3b-1); the family is the two sources above this block;
    /// the pane and rail are that SOURCE's — the Commits face's own machinery,
    /// in its relative role.
    @Test func itOpensOnTheBlockItCameOutOfWithThatBlocksPaneAndRail() async throws {
        try await withWorld { w in
            let face = face(w)
            try await refresh(face, w)
            #expect(face.loaded)
            #expect(face.members.map(\.direction) == [.ancestor, .ancestor, .origin],
                    "older above: both sources, then this block")
            let first = try #require(face.members.first)
            #expect(face.selectedBlockID == first.blockID)
            let node = try #require(face.node)
            #expect(node.blockID == first.blockID && node.isRelative)
            #expect(node.homeBlockID == w.merged, "its acts write onto the block she came from")
            #expect(!face.hasNoLineage)
        }
    }

    /// The origin door's original is selected; selecting another member swaps
    /// the pane and rail to it; this block's own row brings back the Commits
    /// face's whole machinery (its home role).
    @Test func selectingAMemberSwapsThePaneAndRailToIt() async throws {
        try await withWorld { w in
            let face = face(w, select: w.right)
            try await refresh(face, w)
            #expect(face.selectedBlockID == w.right, "the door's original")
            face.select(w.left)
            #expect(face.selectedBlockID == w.left && face.node?.blockID == w.left)
            try await refreshNode(face, w)
            let node = try #require(face.node)
            #expect(node.takeEntries.count == 2, "the left source's own two takes in the dropdown")
            #expect(node.history.savepoints[w.leftTake]?.first?.message == "the first shape",
                    "its commits on the rail — A's reach, two clicks from the face")
            #expect(node.paneActs == [.bringBack, .compare],
                    "a relative's moment is read, compared and brought back — never restored in place")
            face.select(w.merged)
            #expect(face.node?.isRelative == false, "this block: the Commits face's own acts")
            face.select("no-such-block")
            #expect(face.selectedBlockID == w.merged, "an unknown member selects nothing")
        }
    }

    // MARK: - The header's acts, by state

    /// A kept source carries Put back · Bring back as take · Compare with now;
    /// this block's own row carries none.
    @Test func aKeptSourcesHeaderOffersItsThreeActs() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            let selected = try #require(face.selected)
            #expect(selected.acts == [.putBack, .bringBackAsTake, .compareWithNow])
            #expect(face.verb(selected) == "merged")
            #expect(face.place(selected) == LineageFaceCopy.keptAsLineage)
            let this = try #require(face.members.first { $0.direction == .origin })
            #expect(this.acts.isEmpty && face.place(this) == LineageFaceCopy.here)
        }
    }

    /// **Put back** places the source back into its note beside what it
    /// became (`PreservedOriginPutBack` — the tray's road), the receipt the
    /// road's own; the member then reads as placed in this note.
    @Test func putBackPlacesTheSourceAndSaysWhere() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            await face.putBack()
            #expect(face.status == .receipt(TrayPath.putBackBeside))
            let placed = try await w.session.database.read { [post = w.postID] db in
                try Queries.renderPost(db, containerID: post).map(\.blockID)
            }
            #expect(placed.contains(w.left), "the source stands in the note again")
            try await refresh(face, w)
            let landed = try #require(face.selected)
            #expect(face.place(landed) == LineageFaceCopy.thisNote)
            #expect(!landed.acts.contains(.putBack), "placed: no Put back")
        }
    }

    /// **Bring back as take** — the source's shown take becomes a take on the
    /// block she came from, at its fan's end, named by the source take's
    /// label (none here); the receipt says where.
    @Test func bringBackMintsTheSourcesTextOnTheBlockYouCameFrom() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            let before = try await takes(w, w.merged)
            await face.bringBack()
            #expect(face.status == .receipt(CommitsFaceCopy.broughtBackFromLineage(label: nil)))
            let after = try await takes(w, w.merged)
            #expect(after.count == before.count + 1)
            #expect(after.last?.workingText == "A book read once is a rumor.",
                    "the source's active text, on the merged block's fan end")
            #expect(after.last?.parentVariantId == nil)
        }
    }

    /// A relative's COMMIT in the pane, brought back from its foot: the
    /// moment's words, its name the take's label.
    @Test func aRelativesCommitComesBackFromThePanesFoot() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            try await refreshNode(face, w)
            let node = try #require(face.node)
            let moment = try #require(node.history.savepoints[w.leftTake]?.first)
            node.select(.commit(commitID: moment.id))
            await node.bringBackSelected()
            #expect(node.status == .receipt(
                CommitsFaceCopy.broughtBackFromLineage(label: "the first shape")))
            let merged = try await takes(w, w.merged)
            #expect(merged.last?.label == "the first shape" && merged.last?.workingText == moment.text)
        }
    }

    /// **Compare with now** — the source beside the block she came from as it
    /// stands (the same Compare, in the pane's place).
    @Test func compareWithNowSetsTheSourceBesideThisBlockNow() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            try await refreshNode(face, w)
            face.compareWithNow()
            let boxes = try #require(face.node?.compareBoxes)
            #expect(boxes == [.now(takeID: w.leftTake), .now(takeID: w.mergedTake)])
            let node = try #require(face.node)
            #expect(node.text(of: boxes[1])?.contains("Read twice") == true,
                    "the second box is this block's words now")
            #expect(node.takeTitle(w.mergedTake).hasPrefix(CommitsFaceCopy.thisBlock))
        }
    }

    // MARK: - Trash, another wing, nothing at all

    /// A source in the Trash is muted with no acts and is never opened; a
    /// block with no lineage says so.
    @Test func aTrashMemberHasNoActsAndAPlainBlockSaysItHasNoLineage() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            try w.session.operations.deleteBlock(w.right)
            try await refresh(face, w)
            let trashed = try #require(face.members.first { $0.blockID == w.right })
            #expect(trashed.isMuted && trashed.acts.isEmpty && !trashed.selectable)
            #expect(face.place(trashed) == LineageFaceCopy.inTrash)
            face.select(w.right)
            #expect(face.selectedBlockID == w.left, "a Trash member is never selected")

            let plain = try w.session.operations.newBlock(in: w.postID, text: "Nothing before me.")
            let alone = LineageFaceModel(session: w.session, request: BlockHistoryRequest(
                postID: w.postID, blockID: plain.block.id))
            alone.adopt(try await w.session.database.read { db in
                try LineageFaceModel.read(db, blockID: plain.block.id)
            })
            #expect(alone.hasNoLineage)
            #expect(alone.selectedBlockID == plain.block.id, "it opens on this block")
        }
    }

    /// Another wing's member is named with its wing and offers only the go-to,
    /// which goes to that wing.
    @Test func anotherWingsMemberIsNamedAndGoesToItsWing() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let studio = try ops.createWing(name: "Studio")
            let away = try ops.createPost(title: "Elsewhere", wingId: studio.id)
            let source = try ops.newBlock(in: w.postID, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(source.block.id, span: 11..<26)
            try ops.moveBlock(extracted.block.id, to: away.id)
            let face = LineageFaceModel(session: w.session, request: BlockHistoryRequest(
                postID: w.postID, blockID: source.block.id))
            face.adopt(try await w.session.database.read { db in
                try LineageFaceModel.read(db, blockID: source.block.id)
            })
            let across = try #require(face.members.first { $0.blockID == extracted.block.id })
            #expect(across.acts == [.goToWing(studio.id)] && !across.selectable && across.text == nil)
            #expect(face.place(across) == WingCopy.lineageElsewhere("Studio"))
            face.goToWing(studio.id)
            #expect(w.session.wing.currentID == studio.id)
            w.session.wing.switchTo("")
        }
    }

    /// **VX-920 (RED ON OLD — the VX-912 ladder's F-R1-1).** A member whose
    /// note lives in Home, seen from a note in another wing, crosses the fence
    /// as `.otherWing(wingID: "")` — and since VX-892 so does a member whose
    /// note names a DEAD wing (the tree reads it as Home's `''`). Its line names
    /// Home as the wing switcher names it (`WingWords.home`), never the empty
    /// "the wing “”"; an id no live wing carries reads as Home too (the
    /// dangling-wing rule, `Queries.effectiveWingID`); a live wing keeps its
    /// own name.
    @Test func aHomeMemberSeenFromAnotherWingIsNamedHome() {
        func across(_ wingID: String) -> LineageFamily.Member {
            LineageFamily.Member(
                blockID: "b", direction: .descendant, depth: 1, generation: 1, originOp: "extract",
                edgeType: .derivedFrom, place: .otherWing(wingID: wingID), shownTakeID: nil,
                text: nil, counts: nil, acts: [.goToWing(wingID)], selectable: false)
        }
        let live = ["studio": "Studio"]
        #expect(LineageFaceCopy.place(across(""), wingNames: live)
            == WingCopy.lineageElsewhere(WingWords.home))
        #expect(LineageFaceCopy.place(across(""), wingNames: live)
            == "in another library \u{2014} the wing \u{201C}Home\u{201D}",
            "RED ON OLD: \u{201C}the wing \u{201C}\u{201D}\u{201D} \u{2014} Home was never in the names")
        #expect(LineageFaceCopy.place(across("gone"), wingNames: live)
            == WingCopy.lineageElsewhere(WingWords.home), "a wing no live row carries reads as Home")
        #expect(LineageFaceCopy.place(across("studio"), wingNames: live)
            == WingCopy.lineageElsewhere("Studio"), "a live wing keeps its own name")
        // The row's go-to button (`WingCopy.goTo(model.wingName(_:))`) speaks
        // the same name — it read "go to  ›" for Home.
        #expect(LineageFaceCopy.wingName("", wingNames: live) == WingWords.home)
        #expect(LineageFaceCopy.wingName("gone", wingNames: live) == WingWords.home)
        #expect(LineageFaceCopy.wingName("studio", wingNames: live) == "Studio")
    }

    // MARK: - Ladder R1-F1 — a relative's pending typing lands first

    /// A relative placed in ANOTHER note, open with typing the debounce has
    /// not written: the extracted block of this block, moved to "Elsewhere",
    /// its buffer pending there.
    private func pendingRelative(_ w: World) async throws
        -> (face: LineageFaceModel, source: String, relative: String, take: String, note: String)
    {
        let ops = w.session.operations
        let elsewhere = try ops.createPost(title: "Elsewhere")
        let source = try ops.newBlock(in: w.postID, text: "Kept part. Extracted part.")
        let extracted = try ops.extract(source.block.id, span: 11..<26)
        try ops.moveBlock(extracted.block.id, to: elsewhere.id)
        // "She is still typing" in Elsewhere: recorded, nothing written yet.
        let coordinator = w.session.autosave(forPost: elsewhere.id, debounce: .seconds(30))
        coordinator.record(
            variantID: extracted.variant.id, text: "Extracted part, retyped.", charDelta: 9)
        let face = LineageFaceModel(session: w.session, request: BlockHistoryRequest(
            postID: w.postID, blockID: source.block.id, focusedVariantID: source.variant.id))
        face.adopt(try await w.session.database.read { db in
            try LineageFaceModel.read(db, blockID: source.block.id)
        })
        return (face, source.block.id, extracted.block.id, extracted.variant.id, elsewhere.id)
    }

    /// **R1-F1, the bring-back half (RED ON OLD by Revert A, the U3b RECORD's
    /// FIX LEG):** the header's Bring back as take copies the relative's take
    /// AS SHE LEFT IT — the note it is placed in is flushed first, so the
    /// minted take carries her pending words, never the stored ones.
    @Test func aRelativeInAnotherNoteIsFlushedBeforeItsWordsComeBack() async throws {
        try await withWorld { w in
            let staged = try await pendingRelative(w)
            let face = staged.face
            face.select(staged.relative)
            #expect(face.selectedBlockID == staged.relative)
            #expect(face.selected?.acts.contains(.bringBackAsTake) == true)
            await face.bringBack()
            #expect(face.status?.isRefusal == false)
            let minted = try await takes(w, staged.source).last
            #expect(minted?.workingText == "Extracted part, retyped.",
                    "RED ON OLD: the stored \"Extracted part.\" was copied, her typing missed")
        }
    }

    /// **R1-F1, the read half (RED ON OLD by Revert B):** a relative's face
    /// writes its note's pending typing before it reads, so "the take now" on
    /// its pane is now.
    @Test func aRelativesPaneReadsItsNoteAfterItsPendingTypingLands() async throws {
        try await withWorld { w in
            let staged = try await pendingRelative(w)
            let face = staged.face
            face.select(staged.relative)
            let node = try #require(face.node)
            #expect(node.isRelative)
            await node.flushBeforeReading()
            let stored = try await w.session.database.read { [take = staged.take] db in
                try Variant.fetchOne(db, key: take)?.workingText
            }
            #expect(stored == "Extracted part, retyped.",
                    "RED ON OLD: only the face's own note was flushed; the relative's still pends")
        }
    }

    /// The receipt names the note when the put back lands in ANOTHER note.
    @Test func aPutBackIntoAnotherNoteNamesIt() {
        let home = Queries.LineageHome(
            containerID: "other", kind: .post, title: "Night ferry", wingID: "",
            isDeleted: false, isSavedVersion: false)
        #expect(LineageFaceCopy.putBackReceipt(RecoveryCopy.putBackBeside, home: home, faceNoteID: "this")
            == "In \u{201C}Night ferry\u{201D}: \(RecoveryCopy.putBackBeside)")
        #expect(LineageFaceCopy.putBackReceipt(RecoveryCopy.putBackBeside, home: home, faceNoteID: "other")
            == RecoveryCopy.putBackBeside, "this note: the road's own words")
    }

    // MARK: - VX-898 — a lineage member's take, named honestly (N-898 (1), RULED PROVISIONAL)

    /// The rule, pure: an unplaced member (kept as lineage, set aside) names
    /// its rail-top moment "the take as kept"; everything else "the take now".
    @Test func theNowNameIsTheTakeAsKeptExactlyWhereTheMemberStandsUnplaced() {
        #expect(CommitsFaceCopy.nowName(unplacedRelative: true) == "the take as kept")
        #expect(CommitsFaceCopy.nowName(unplacedRelative: false) == "the take now")
        #expect(CommitsFaceCopy.itsOnlyTake == "its only take")
        #expect(LineageFaceCopy.standsUnplaced(.keptAsLineage(home: nil)))
        #expect(LineageFaceCopy.standsUnplaced(.setAside(home: nil)))
        #expect(!LineageFaceCopy.standsUnplaced(.thisBlock))
        #expect(!LineageFaceCopy.standsUnplaced(.inTrash(home: nil)))
        #expect(!LineageFaceCopy.standsUnplaced(.otherWing(wingID: "w")))
        let home = Queries.LineageHome(
            containerID: "n", kind: .post, title: "t", wingID: "", isDeleted: false, isSavedVersion: false)
        #expect(!LineageFaceCopy.standsUnplaced(.placed(home: home, sameNote: true)))
    }

    /// **HER FLAG, pinned** (the Nov 7 walkthrough: the header read "the take
    /// now / this take" on a kept-as-lineage block). A merge's source is kept
    /// as lineage: its rail-top moment is "the take as kept" — headline, the
    /// Compare swapper's line — and its unlabeled one take "its only take";
    /// a two-take source keeps its ordinals; the block she came from's take,
    /// offered in a relative's Compare, is still "the take now". RED ON OLD by
    /// evaluation: the old `headline(.now)` and `menuLine(.now)` returned
    /// "the take now" for every block and `takeTitle` "this take".
    @Test func aKeptSourcesTakeIsTheTakeAsKeptAndItsOnlyTakeIsItsOwn() async throws {
        try await withWorld { w in
            let face = face(w, select: w.right)
            try await refresh(face, w)
            try await refreshNode(face, w)
            let node = try #require(face.node)
            #expect(node.blockID == w.right && node.isRelative)
            #expect(node.relativeStandsUnplaced, "a merge's source stands kept as lineage")
            let rightTake = try #require(try await takes(w, w.right).first?.id)
            #expect(node.nowName == CommitsFaceCopy.theTakeAsKept)
            #expect(node.headline(.now(takeID: rightTake)) == "the take as kept")
            #expect(node.menuLine(.now(takeID: rightTake)) == "the take as kept")
            #expect(node.takeTitle(rightTake) == "its only take", "never \u{201C}this take\u{201D} here")
            #expect(node.meta(.now(takeID: rightTake)).first?.hasPrefix("its only take") == true)
            #expect(node.menuLine(.now(takeID: w.mergedTake)) == CommitsFaceCopy.theTakeNow,
                    "the block she came from lives: its take is the take now")

            face.select(w.left)
            try await refreshNode(face, w)
            let left = try #require(face.node)
            #expect(left.relativeStandsUnplaced)
            #expect(left.headline(.now(takeID: w.leftTake)) == "the take as kept")
            #expect(left.takeTitle(w.leftTake) == "take 1 of 2", "a fanned source keeps its ordinals")
        }
    }

    /// Put back places the source: its pane reads "the take now" again on the
    /// family's next read (live — no re-select).
    @Test func aPutBackSourceReadsTheTakeNowAgain() async throws {
        try await withWorld { w in
            let face = face(w, select: w.left)
            try await refresh(face, w)
            let node = try #require(face.node)
            #expect(node.nowName == CommitsFaceCopy.theTakeAsKept)
            await face.putBack()
            try await refresh(face, w)
            #expect(face.node === node, "the same pane — nothing re-selected")
            #expect(!node.relativeStandsUnplaced, "placed now")
            #expect(node.nowName == CommitsFaceCopy.theTakeNow)
            #expect(node.headline(.now(takeID: w.leftTake)) == "the take now")
        }
    }

    /// The HOME face is byte-unchanged: "the take now" and "this take".
    @Test func theHomeFaceKeepsTheTakeNowAndThisTake() async throws {
        try await withWorld { w in
            let home = CommitsFaceModel(session: w.session, request: BlockHistoryRequest(
                postID: w.postID, blockID: w.merged, focusedVariantID: w.mergedTake))
            home.adopt(try await w.session.database.read { [blockID = w.merged, now = w.session.now] db in
                try CommitsFaceModel.read(db, blockID: blockID, now: now)
            })
            home.relativeStandsUnplaced = true  // never read on the home face
            #expect(!home.isRelative)
            #expect(home.nowName == "the take now")
            #expect(home.headline(.now(takeID: w.mergedTake)) == "the take now")
            #expect(home.takeTitle(w.mergedTake) == "this take")
        }
    }
}
