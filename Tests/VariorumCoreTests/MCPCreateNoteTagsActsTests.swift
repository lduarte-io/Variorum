import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-814 — `create_note` TAKES TAGS AT BIRTH (the VX-809 run, batch 3; the
// agent's ask: "A new note outside a book can't be tagged when it's created.
// It takes a second call."). The ticket's shape: a `tags` argument applied
// through the one application road IN THE SAME TRANSACTION, so living books hear
// the birth exactly as they hear her capture microsyntax's `{#tag/path}` — the
// same adopt-or-mint-by-path rule, the same intake consequences. The build rides
// the document HEADER's road (`applyDocumentTags` — the road `import_document`'s
// `{#…}` header already takes): these pins assert the rows it writes, the order
// it answers, the one undo entry, and that intake hears the birth — existing
// semantics, asserted, never re-implemented. Features: no red-on-old owed (the
// argument did not exist).

@Suite("VX-814 — create_note's tags at birth: the header road, one entry")
struct MCPCreateNoteTagsActsTests {
    private let label = Operations.MCPWriteAct.note.undoLabel(client: "claude-code")

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack).heardAsWireClient(), stack, db)
        }
    }

    /// The note's live applications' paths, in application order.
    private func worn(_ db: AppDatabase, _ postID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY pt.created_at, pt.rowid
                    """,
                arguments: [postID])
        }
    }

    /// Every live tag row's shape: path, name, parent's path, wing — the
    /// vocabulary a capture or an import would write.
    private func vocabulary(_ db: AppDatabase) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path || ' · ' || t.name || ' · ' || COALESCE(p.path, '-') || ' · [' || t.wing_id || ']'
                    FROM tag t LEFT JOIN tag p ON p.id = t.parent_id
                    WHERE t.deleted_at IS NULL ORDER BY t.wing_id, t.path
                    """)
        }
    }

    private func status(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> String? {
        try db.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    // MARK: - The act

    /// Born wearing the tags, in the SAME transaction and the ONE entry: the
    /// missing chain minted in the note's wing (an existing ancestor adopted),
    /// a path given twice (slash noise and all) applied once, the answer in the
    /// given order; the undo takes the note and its applications (the tags stay
    /// as vocabulary), the redo returns them.
    @Test func aNoteIsBornWearingItsTagsInOneActAndOneEntry() throws {
        try withUndo { ops, stack, db in
            _ = try ops.createTag(name: "life")
            let minted = try ops.createNote(
                title: "born tagged", text: "Words.", in: .wing(""),
                tags: ["life/goals", "fresh", "/life//goals/"], undoLabel: label)
            #expect(minted.tagPaths == ["life/goals", "fresh"], "the given order, each once")
            #expect(try worn(db, minted.post.id) == ["life/goals", "fresh"])
            #expect(try vocabulary(db) == [
                "fresh · fresh · - · []", "life · life · - · []", "life/goals · goals · life · []",
            ])
            #expect(stack.depth == 1 && stack.topLabel == label, "ONE entry — the mint's own")
            #expect(try stack.undo(with: ops) == label)
            #expect(try worn(db, minted.post.id).isEmpty, "the applications die with the note")
            #expect(try vocabulary(db).count == 3, "a tag the act minted stays as vocabulary")
            #expect(try stack.redo(with: ops) == label)
            #expect(try worn(db, minted.post.id) == ["life/goals", "fresh"], "the redo revives exact rows")
        }
    }

    /// The structured payload takes the same tags, the same way.
    @Test func theStructuredPayloadIsBornTaggedTheSameWay() throws {
        try withUndo { ops, stack, db in
            let minted = try ops.createStructuredNote(
                title: nil, entryDate: nil, blocks: [.init(text: "One.")], in: .wing(""),
                tags: ["b", "a"], undoLabel: label)
            #expect(minted.tagPaths == ["b", "a"])
            #expect(try worn(db, minted.post.id) == ["b", "a"])
            #expect(stack.depth == 1)
        }
    }

    /// MICROSYNTAX PARITY — the same rows as a `{#tag/path}` capture. The
    /// capture grammar's core home (`CaptureTokens`, the brace grammar her
    /// capture boxes and the document header share) reads the paths; the
    /// document header's road applies them; `create_note`'s `tags` must write
    /// the SAME vocabulary and the SAME applications as that road and as
    /// `apply_tag`'s, path for path.
    @Test func theRowsAreACapturesRows() throws {
        let capture = CaptureTokens.parse("{#/notes//on/} {#reading} Words.")
        #expect(capture.tagPaths == ["/notes//on/", "reading"])
        func rows(_ mint: (Operations) throws -> String) throws -> ([String], [String]) {
            try withOperations { ops, db in
                _ = try ops.createTag(name: "notes")
                let postID = try mint(ops.heardAsWireClient())
                return (try vocabulary(db), try worn(db, postID))
            }
        }
        let viaTags = try rows {
            try $0.createNote(title: nil, text: "Words.", in: .wing(""), tags: capture.tagPaths, undoLabel: label).post.id
        }
        let viaHeader = try rows {
            try $0.importNote(
                VariorumDocument.NamedDocument(
                    fallbackTitle: "", document: try VariorumDocument.parse("{#/notes//on/} {#reading}\n\nWords.")),
                in: .wing(""), undoLabel: label).post.id
        }
        let viaApplyTag = try rows { ops in
            let post = try ops.createPost(title: nil)
            for path in capture.tagPaths { _ = try ops.applyTagPath(path, toPost: post.id, undoLabel: "x") }
            return post.id
        }
        #expect(viaTags == viaHeader)
        #expect(viaTags == viaApplyTag)
        #expect(viaTags.1 == ["notes/on", "reading"])
    }

    /// PER-WING VOCABULARY: a path another wing's tag wears is no match — the
    /// note's wing mints its own (the two-store non-event: a hidden wing's tag
    /// of the same path changes nothing here).
    @Test func aSamePathTagInAnotherWingIsNeverAdopted() throws {
        try withUndo { ops, _, db in
            let attic = try ops.createWing(name: "Attic")
            let theirs = try ops.createTag(name: "topic", wingID: attic.id)
            let studio = try ops.createWing(name: "Studio")
            let minted = try ops.createNote(
                title: nil, text: "x", in: .wing(studio.id), tags: ["topic"], undoLabel: label)
            let ours = try #require(minted.tagIDs.first)
            #expect(ours != theirs.id)
            let wing = try db.read { try String.fetchOne($0, sql: "SELECT wing_id FROM tag WHERE id = ?", arguments: [ours]) }
            #expect(wing == studio.id)
        }
    }

    // MARK: - Intake hears the birth (existing semantics, asserted)

    /// A living book collecting a birth tag seats the note; one whose dial
    /// waits bells it; a PRIVATE one bells it (A-809-11 — the wire's hand); a
    /// book whose rule does not match never hears it.
    @Test func livingBooksHearTheBirth() throws {
        try withUndo { ops, _, db in
            let topic = try ops.createTag(name: "topic")
            let other = try ops.createTag(name: "other")
            let seats = try ops.createReading(name: "seats", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let waits = try ops.createReading(
                name: "waits", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)), intakeSeating: .arrivals)
            let diary = try ops.createReading(name: "diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            _ = try ops.setBookPrivate(diary.id, true)
            let deaf = try ops.createReading(name: "deaf", kind: .book, querySpec: try RuleGrammar.encode(.tag(other.id)))
            let minted = try ops.createNote(title: nil, text: "x", in: .wing(""), tags: ["topic"], undoLabel: label)
            #expect(try status(db, seats.id, minted.post.id) == "member")
            #expect(try status(db, waits.id, minted.post.id) == "arrival")
            #expect(try status(db, diary.id, minted.post.id) == "arrival", "A-809-11: never a fencing seat")
            #expect(try status(db, deaf.id, minted.post.id) == nil)
        }
    }

    // MARK: - The answer's order with a destination's own tags (VX-361's rule)

    @Test func theAnswerListsTheBirthTagsFirstThenTheOutflowEachOnce() throws {
        try withUndo { ops, _, db in
            let out = try ops.createTag(name: "out")
            let book = try ops.createReading(name: "Filed", kind: .book)
            try ops.setReadingOutflow(book.id, tagIDs: [out.id])
            let first = try ops.createNote(title: nil, text: "x", in: .book(book.id), tags: ["mine"], undoLabel: label)
            #expect(first.tagPaths == ["mine", "out"])
            let second = try ops.createNote(
                title: nil, text: "y", in: .book(book.id), tags: ["out", "mine"], undoLabel: label)
            #expect(second.tagPaths == ["out", "mine"], "an outflow tag named first is listed at its place, once")
            #expect(try worn(db, second.post.id).sorted() == ["mine", "out"])
        }
    }

    /// A gathering's rule tags ride the outflow slot; a birth tag that breaks
    /// the rule (its NOT) unwinds the whole mint in her door's words — the
    /// gathering's belt, unchanged.
    @Test func intoAGatheringTheBirthTagsLeadAndABreakingTagUnwindsTheMint() throws {
        try withUndo { ops, stack, db in
            let g = try ops.createTag(name: "g")
            let no = try ops.createTag(name: "no")
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try RuleGrammar.encode(.and([.tag(g.id), .not(.tag(no.id))])))
            let minted = try ops.createNote(
                title: nil, text: "x", in: .gathering(gathering.id), tags: ["extra"], undoLabel: label)
            #expect(minted.tagPaths == ["extra", "g"])
            let before = try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") }
            #expect(throws: OperationError.smartFilterUnsatisfiable(
                readingID: gathering.id, reason: GatheringMint.unmatchedReason)) {
                try ops.createNote(title: nil, text: "y", in: .gathering(gathering.id), tags: ["no"], undoLabel: label)
            }
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") } == before)
            #expect(stack.depth == 1, "the refused mint registered nothing")
        }
    }
}
