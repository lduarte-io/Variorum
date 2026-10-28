import Foundation
import VariorumCore

/// **THE DOOR SAYS IT: U+0000 REMOVED BEFORE THE WRITE** (VX-357 — her ruling
/// 2026-10-15, the shape she approved; the run record
/// `notes/plans/fixes/vx-348-prelaunch-sweep.md`, U1 UNIT RECORD).
///
/// The operations layer removes every U+0000 from the text it stores
/// (`StoredText` — the store cannot hold one: a bind stopped at it and the
/// rest of the take was lost). On her own doors the strip is quiet — the
/// character is invisible and means nothing in prose. On the MCP door it is
/// ALWAYS said: a landed write whose sent text held null characters answers
/// `null_characters_removed` — how many were removed from the text the call
/// wrote — beside its usual keys, so a client that digests its own source
/// knows why VX-254's `sha256` (the digest of the text AS STORED, never as
/// sent) differs, and by how much. A write with none answers byte-unchanged
/// (the key is absent, never 0).
///
/// **The one place on the wire:** `MCPWriteTools.land` — every landed write's
/// answer passes through it — reads `Job.nullCharactersWritten`, an EXHAUSTIVE
/// switch over every tool's parsed call (`flushesHerEditorFirst`'s shape), so
/// a new tool cannot compile without saying which of its texts it writes.
/// Counted: the texts a call WRITES — a take's text and label, a comment, a
/// title, a name (block, book, chapter, lens), a commit message, a tag path
/// (applied, or named in a book's rule or outflow — a path that adopts or
/// mints a tag), a document or book import's every text. Not counted: ids,
/// preconditions (`expected_text` compares with what is stored and is never
/// written), locators (`second_half_starts_with`, a lens rule's `label`
/// match, `remove_tag`'s path — each finds what is stored and writes no
/// text), and the validated day keys (a null character fails the parse).
enum MCPNullCharacters {
    /// The answer key (PROVISIONAL P-VX357-1 — the run record).
    static let answerKey = "null_characters_removed"

    static func count(_ texts: String?...) -> Int {
        texts.reduce(0) { $0 + StoredText.nullCount($1) }
    }

    static func count(_ document: VariorumDocument.NamedDocument) -> Int {
        let parsed = document.document
        return count(document.fallbackTitle, parsed.title)
            + parsed.tagPaths.reduce(0) { $0 + StoredText.nullCount($1) }
            + parsed.blocks.reduce(0) { total, block in
                total + StoredText.nullCount(block.text)
                    + block.alternates.reduce(0) { $0 + count($1.text, $1.label) }
            }
    }

    static func count(_ book: VariorumDocument.Book) -> Int {
        StoredText.nullCount(book.name)
            + book.chapters.reduce(0) { total, chapter in
                total + StoredText.nullCount(chapter.name) + chapter.notes.reduce(0) { $0 + count($1) }
            }
            + book.unfiled.reduce(0) { $0 + count($1) }
    }

    static func count(_ blocks: [Operations.MCPNoteBlock]) -> Int {
        blocks.reduce(0) { total, block in
            total + count(block.text, block.name) + block.takes.reduce(0) { $0 + count($1.text, $1.label) }
        }
    }

    /// A book rule's tag terms — every path it names adopts or mints a tag.
    static func count(_ rule: RuleTerm) -> Int {
        var total = 0
        _ = rule.mappingTags { path in
            total += StoredText.nullCount(path)
            return path
        }
        return total
    }
}

extension MCPWriteTools.Job {
    /// How many U+0000 the act removes from the text it writes (above).
    var nullCharactersWritten: Int {
        switch self {
        case .addTake(_, let text, let label): MCPNullCharacters.count(text, label)
        case .addComment(_, let text): MCPNullCharacters.count(text)
        case .saveLens(_, let name, _, _): MCPNullCharacters.count(name)
        case .createNote(let title, let payload, _, _, _):
            switch payload {
            case .text(let text): MCPNullCharacters.count(title, text)
            case .blocks(let blocks): MCPNullCharacters.count(title) + MCPNullCharacters.count(blocks)
            }
        case .importNote(let named, _, _): MCPNullCharacters.count(named)
        case .importBook(let book, _): MCPNullCharacters.count(book)
        case .applyTag(_, let path): MCPNullCharacters.count(path)
        case .createBook(let name, _): MCPNullCharacters.count(name)
        case .insertBlocks(_, _, let blocks): MCPNullCharacters.count(blocks)
        case .edit(let job): job.nullCharactersWritten
        case .carriage(let job): job.nullCharactersWritten
        case .deliberate(let job): job.nullCharactersWritten
        case .batch(let job): job.nullCharactersWritten
        case .noteEdit(let job): job.nullCharactersWritten
        case .libraryEdit(let job): job.nullCharactersWritten
        // A membership, a deletion, a tag taken off by its path (a lookup),
        // a version link, a copy of stored text, a star (VX-596): no text written.
        case .addNoteToBook, .deleteComment, .removeTag, .linkVersions, .duplicateNote, .setStarred: 0
        }
    }
}

extension MCPWriteTools.EditJob {
    var nullCharactersWritten: Int {
        switch self {
        // `expected_text` is a precondition, never written.
        case .editTake(_, let text, _): MCPNullCharacters.count(text)
        case .name(_, let name): MCPNullCharacters.count(name)
        case .createSection(_, let name): MCPNullCharacters.count(name)
        // `second_half_starts_with` locates the cut in the stored text.
        case .divide, .merge, .move, .delete, .moveToWing: 0
        }
    }
}

extension MCPWriteTools.CarriageJob {
    var nullCharactersWritten: Int {
        switch self {
        case .setBookRule(_, let write):
            (write.outflowPaths ?? []).reduce(0) { $0 + StoredText.nullCount($1) }
                + ((write.rule ?? nil).map(MCPNullCharacters.count) ?? 0)
        // A day key holding one fails its parse; the rest write no text.
        case .putBackBlock, .putBackTake, .setEntryDate, .saveVersion, .fileInChapter: 0
        }
    }
}

extension MCPWriteTools.DeliberateJob {
    var nullCharactersWritten: Int {
        switch self {
        case .commit(_, let message): MCPNullCharacters.count(message)
        case .choose, .adoptLens: 0
        }
    }
}

extension MCPWriteTools.BatchJob {
    var nullCharactersWritten: Int {
        switch self {
        case .takes(_, let items): items.reduce(0) { $0 + MCPNullCharacters.count($1.text, $1.label) }
        case .comments(_, let items): items.reduce(0) { $0 + MCPNullCharacters.count($1.text) }
        }
    }
}

extension MCPWriteTools.NoteEditJob {
    var nullCharactersWritten: Int {
        switch self {
        // `expected_text` is a precondition, never written.
        case .editComment(_, let text, _): MCPNullCharacters.count(text)
        case .setTakeLabel(_, let label): MCPNullCharacters.count(label)
        case .renameCommit(_, let message): MCPNullCharacters.count(message)
        case .renameNote(_, let title): MCPNullCharacters.count(title)
        case .restoreComment, .deleteTake, .archiveTake, .unarchiveTake, .lockTake, .restoreCommit, .deleteLens: 0
        }
    }
}

extension MCPWriteTools.LibraryEditJob {
    var nullCharactersWritten: Int {
        switch self {
        case .renameBook(_, let name): MCPNullCharacters.count(name)
        case .renameChapter(_, let name): MCPNullCharacters.count(name)
        case .setFinished, .archiveBook, .unarchiveBook, .deleteBook, .removeNote, .moveNote, .deleteChapter,
             .moveChapter, .deleteNote, .setNoteArchived:
            0
        }
    }
}
