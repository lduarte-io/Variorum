import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-440 batch 1 — SAVED VERSIONS IN COMPARE** (VX-130 · VX-437 · VX-432; the
/// record is `notes/plans/fixes/vx-440-sheets-history-clarity.md`).
///
/// Her VX-437 redirect (2026-10-28), the contract these pins hold at the core
/// layer: *"doesn't it seem wrong for the older version of a note to NOT show up
/// in compare?? … you should be allowed to stop counting it as a version but i
/// think that should mean that it is automatically promoted."*
///
/// **The live check (the record's B1-1), traced first, pinned here where the
/// core decides it.** Compare's auto-fill reads `Queries.versionPeerSplit(…)
/// .sameWing`, which is `versionPeerPosts` split by wing — and that read follows
/// live `version_of` edges with NO version-history or archive fence. A saved
/// version is minted by the copy machine with exactly such an edge, in the
/// source's wing, so it IS a same-wing peer: Compare already seats it and its
/// card already wears "unmark". What "unmark" then does to it at the op level is
/// `NoteVersionsTests.adeliberateUnmarkStillUnlinksAVersion`'s documented
/// behaviour — the pair comes apart and the moment leaks onto the Archived
/// surface. The DOOR that reached that op on a saved version is the defect; its
/// red-on-old pin lives with the door (`CompareViewModelTests
/// .unmarkOnASavedVersionNeverDeclassifiesIt`, Mac suite).
@Suite("VX-440 batch 1 — saved versions in Compare")
struct VersionsInCompareTests {
    // MARK: - The live check: what Compare's auto-fill reads today

    /// **A SAVED VERSION IS A SAME-WING VERSION PEER** — the input Compare's
    /// auto-fill seats from, so a note whose only `version_of` peer is a saved
    /// moment opens Compare with that moment beside it. Her VX-437 ruling makes
    /// this the CONTRACT ("never filtered out of auto-fill"); before it, it was
    /// the unexamined behaviour the scout flagged. Green on both sides by
    /// design: it documents the input, it is not a bug pin.
    @Test func aSavedVersionIsASameWingVersionPeerSoCompareSeatsIt() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post

            let split = try db.read { try Queries.versionPeerSplit($0, of: note.id) }
            #expect(split.sameWing == [version.id],
                    "the moment rides the copy's version_of edge in the note's own wing")
            #expect(split.otherWings.isEmpty)
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) },
                    "…and the classifier still names it this note's saved version")
        }
    }
}
