import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13n-a — THE ROUND-TRIP PINS (the plan's acceptance, first bullet):
/// export → parse → serialize is BYTE-IDENTICAL on (a) a fanless note,
/// (b) a fanned note with labeled AND unlabeled takes, (c) a note with
/// internal newlines inside a take. And Copy for AI is the header line over
/// exactly that export — one serializer, two faces.
@Suite("Document format round trip (13n-a)")
struct DocumentFormatRoundTripTests {
    /// export → parse → serialize, asserted byte-identical, returning the
    /// parsed document for the caller's own looks.
    @discardableResult
    private func roundTrips(
        _ db: AppDatabase, _ postID: String
    ) throws -> (export: String, parsed: VariorumDocument.Document) {
        let export = try db.read { try Queries.exportPost($0, postID: postID, includeVariants: true) }
        let parsed = try VariorumDocument.parse(export)
        #expect(VariorumDocument.serialize(parsed) == export)
        return (export, parsed)
    }

    /// A take on `blockID` with `text`, optionally labeled — never chosen.
    @discardableResult
    private func take(
        _ ops: Operations, on blockID: String, from variantID: String,
        _ text: String, label: String? = nil
    ) throws -> Variant {
        let take = try ops.branchVariant(blockID, from: variantID)
        try ops.autosave(take.id, text: text, charDelta: text.count)
        if let label { try ops.setTakeLabel(take.id, label: label) }
        return take
    }

    @Test func aFanlessNoteRoundTrips() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Plain")
            try ops.seedBlock(in: post.id, text: "Alpha.")
            try ops.seedBlock(in: post.id, text: "Beta.\n")  // stored spacing rides
            try ops.seedBlock(in: post.id, text: "Gamma.")
            let (export, parsed) = try roundTrips(db, post.id)
            #expect(export == "Alpha.\n\nBeta.\n\nGamma.")
            #expect(parsed.alternateCount == 0)
        }
    }

    @Test func aFannedNoteWithLabeledAndUnlabeledTakesRoundTrips() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Fanned")
            let first = try ops.seedBlock(in: post.id, text: "Eu não pedi para herdar o observatório.")
            try take(ops, on: first.block.id, from: first.variant.id,
                     "Honestly, I never asked for the observatory.", label: "english")
            try take(ops, on: first.block.id, from: first.variant.id, "Une autre version.")
            try ops.seedBlock(in: post.id, text: "A plain block between.")
            let third = try ops.seedBlock(in: post.id, text: "Cuidar de um observatório dá trabalho.")
            try take(ops, on: third.block.id, from: third.variant.id, "unlabeled one")
            try take(ops, on: third.block.id, from: third.variant.id,
                     "Running an observatory is hard work.", label: "english")

            let (export, parsed) = try roundTrips(db, post.id)
            // Fan order: a branch lands right after its source, so each
            // block's SECOND branch sits first among its alternates — and an
            // unlabeled take numbers by its place in the section.
            #expect(export.contains("take: 1\n\nUne autre version."))
            #expect(export.contains("take: \"english\"\n\nHonestly, I never asked for the observatory."))
            #expect(export.contains("take: \"english\"\n\nRunning an observatory is hard work."))
            #expect(export.contains("take: 2\n\nunlabeled one"))
            #expect(parsed.blocks.map(\.alternates) == [
                [.init(label: nil, text: "Une autre version."),
                 .init(label: "english", text: "Honestly, I never asked for the observatory.")],
                [],
                [.init(label: "english", text: "Running an observatory is hard work."),
                 .init(label: nil, text: "unlabeled one")],
            ])
        }
    }

    @Test func internalNewlinesInsideATakeRoundTrip() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Newlines")
            let block = try ops.seedBlock(in: post.id, text: "The poem, as written.")
            let poem = "Roses are red,\nviolets are blue,\n\nand a blank line\nbetween.\n"
            try take(ops, on: block.block.id, from: block.variant.id, poem, label: "verse")
            try ops.seedBlock(in: post.id, text: "After.")
            let (_, parsed) = try roundTrips(db, post.id)
            #expect(parsed.blocks.first?.alternates == [.init(label: "verse", text: poem)])
        }
    }

    @Test func copyForAIIsTheHeaderLineOverExactlyTheFanExport() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "o ladrão de raios — ch 1")
            let block = try ops.seedBlock(in: post.id, text: "Eu não pedi para herdar o observatório.")
            try take(ops, on: block.block.id, from: block.variant.id,
                     "Honestly, I never asked for the observatory.", label: "english")
            let parent = try ops.createTag(name: "percy")
            let leaf = try ops.createTag(parent: parent.id, name: "pt-en")
            try ops.applyTag(leaf.id, toPost: post.id)
            try ops.applyTag(try ops.createTag(name: "bilingual").id, toPost: post.id)

            let (copied, export) = try db.read { database in
                (try Queries.variorumDocumentText(database, postID: post.id),
                 try Queries.exportPost(database, postID: post.id, includeVariants: true))
            }
            // Tags by path order (the per-post listing's own order).
            #expect(copied == "{t:\"o ladrão de raios — ch 1\"} {#bilingual} {#percy/pt-en}\n\n" + export)
            let parsed = try VariorumDocument.parse(copied)
            #expect(parsed.title == "o ladrão de raios — ch 1")
            #expect(parsed.tagPaths == ["bilingual", "percy/pt-en"])
            #expect(VariorumDocument.serialize(parsed) == copied)
        }
    }

    @Test func anUntitledUntaggedNoteCopiesAsTheBareExport() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: nil)
            try ops.seedBlock(in: post.id, text: "Just prose.")
            let copied = try db.read { try Queries.variorumDocumentText($0, postID: post.id) }
            #expect(copied == "Just prose.")
            // The export pin: reading for the clipboard wrote nothing.
            try db.clearOutbox()
            _ = try db.read { try Queries.variorumDocumentText($0, postID: post.id) }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }

    // MARK: - VX-126 — the LIBRARY export round-trips whole (her option A)

    /// **Export Library's note files ARE Copy full text's text, and they
    /// re-import whole** (VX-126, option A ruled 2026-10-27). A library is
    /// exported, every note file is read back the import door's own way
    /// (`VariorumDocumentFolder.note` → `importDocument`), and the imported
    /// note re-exports to the very bytes of its file — so its title, its tags
    /// and every take rode the file. RED ON OLD: the note files carried no
    /// header, so the imported note was named by its file ("2026-07-10 o
    /// ladrão…") and wore no tag. The scraps area's file and the book's view
    /// keep the plain projection (C-126-1), byte for byte.
    @Test func aLibraryExportReimportsEveryNoteWithItsTitleTagsAndTakes() throws {
        try withOperations { ops, db in
            let fanned = try ops.createPost(title: "o ladrão de raios — ch 1", entryDate: "2026-07-10")
            let first = try ops.seedBlock(in: fanned.id, text: "Eu não pedi para herdar o observatório.")
            try take(ops, on: first.block.id, from: first.variant.id,
                     "Honestly, I never asked for the observatory.", label: "english")
            try take(ops, on: first.block.id, from: first.variant.id, "Je ne voulais pas.")
            try ops.seedBlock(in: fanned.id, text: "Cuidar de um observatório dá trabalho.")
            let percy = try ops.createTag(name: "percy")
            try ops.applyTag(try ops.createTag(parent: percy.id, name: "pt-en").id, toPost: fanned.id)
            try ops.applyTag(try ops.createTag(name: "bilingual").id, toPost: fanned.id)

            let plain = try ops.createPost(title: "Kept", entryDate: "2026-07-11")
            try ops.seedBlock(in: plain.id, text: "Kept body.")
            let shelved = try ops.createPost(title: "Shelved", entryDate: "2026-07-12")
            try ops.seedBlock(in: shelved.id, text: "Shelved body.")
            try ops.applyTag(try ops.createTag(name: "old").id, toPost: shelved.id)
            try ops.archiveContainer(shelved.id)
            let unnamed = try ops.createPost(title: nil, entryDate: "2026-07-13")
            try ops.seedBlock(in: unnamed.id, text: "Dated body.")

            let pool = try ops.createPool(title: "Scraps")
            let scrap = try ops.seedBlock(in: pool.id, text: "Scrap one.")
            try take(ops, on: scrap.block.id, from: scrap.variant.id, "Scrap alt.")
            let reading = try ops.createReading(name: "Shelf", kind: .book)
            try ops.addPostToReading(fanned.id, to: reading.id)

            let manifest = try db.read { try Queries.bulkExportManifest($0) }
            let byPath = Dictionary(uniqueKeysWithValues: manifest.map { ($0.relativePath, $0.contents) })
            let notes: [(path: String, id: String)] = [
                ("2026-07-10 o ladrão de raios — ch 1.md", fanned.id),
                ("2026-07-11 Kept.md", plain.id),
                ("Archived/2026-07-12 Shelved.md", shelved.id),
                ("2026-07-13.md", unnamed.id),
            ]

            // (1) Every note file is Copy full text's text, byte for byte.
            for note in notes {
                let file = try #require(byPath[note.path], "\(note.path) is exported")
                #expect(file == (try db.read { try Queries.variorumDocumentText($0, postID: note.id) }),
                        "\(note.path) is byte-identical to Copy full text")
            }
            #expect(byPath["2026-07-11 Kept.md"] == "{t:\"Kept\"}\n\nKept body.",
                    "fanless: the header over plain Markdown")
            #expect(byPath["2026-07-13.md"] == "Dated body.",
                    "a name she never typed rides no title token (IC-11)")

            // (2) …and each re-imports whole: title, tags, takes.
            for note in notes {
                let file = try #require(byPath[note.path])
                let name = String(note.path.split(separator: "/").last ?? "")
                let imported = try ops.importDocument(
                    try VariorumDocumentFolder.note(named: name, contents: file))
                let source = try #require(try db.read { try Container.fetchOne($0, key: note.id) })
                let sourceTags = try db.read { try Queries.postTags($0, postID: note.id).map(\.path) }
                let importedTags = try db.read {
                    try Queries.postTags($0, postID: imported.post.id).map(\.path)
                }
                #expect(importedTags == sourceTags, "\(note.path): the tags ride the file")
                let body = { (id: String) in
                    try db.read { try Queries.exportPost($0, postID: id, includeVariants: true) }
                }
                #expect(try body(imported.post.id) == (try body(note.id)), "\(note.path): every take rides")
                if DisplayTitle.isAbsent(source.title) {
                    // The format's recorded limit (IC-11): the importer names
                    // an untitled note by its file — here, its date.
                    #expect(imported.post.title == "2026-07-13")
                } else {
                    #expect(imported.post.title == source.title, "\(note.path): the title rides the file")
                    #expect(try db.read { try Queries.variorumDocumentText($0, postID: imported.post.id) } == file,
                            "\(note.path): the imported note re-exports to its file's bytes")
                }
            }

            // (3) C-126-1: the scraps area's file and the book's view are the
            // plain projections, unchanged.
            #expect(byPath["Pools/Scraps.md"] == (try db.read { try Queries.exportPost($0, postID: pool.id) }))
            #expect(byPath["Pools/Scraps.md"] == "Scrap one.")
            #expect(byPath["Readings/Shelf.md"]
                    == (try db.read { try Queries.exportReading($0, readingID: reading.id) }))
        }
    }
}
