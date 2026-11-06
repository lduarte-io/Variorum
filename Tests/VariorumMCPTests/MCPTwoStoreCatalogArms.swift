import Foundation
import MCP

@testable import VariorumMCP

// THE CATALOG'S ARMS (VX-825 — the two-store pin's walk; the run record's BATCH 1
// RECORD carries the table). Every tool the door serves, its landed arms and its
// refusals — the not-shared shape on a hidden target (A passes a hidden id, B
// and C the same string naming nothing), the rung, the tool's own refusals, and
// the arms that meet a hidden thing BESIDE a reachable one (the counted arms,
// the name guard, ownership, capacity, a frozen holder, a Private collecting
// book, a tag worn only beyond reach). Ordered: reads first, then the rungs
// upward, each act on rows no later arm needs in their old state.

private func s(_ string: String) -> Value { .string(string) }

extension MCPTwoStoreCatalogServerTests {
    typealias W = CatalogWorld

    static let arms: [CatalogArm] = readArms + suggestArms + writeNewArms + editArms + tailArms

    // MARK: - READ

    static let readArms: [CatalogArm] = [
        CatalogArm(label: "list_books", tool: "list_books") { _, _ in [:] },
        CatalogArm(label: "list_books · include_archived", tool: "list_books") { _, _ in ["include_archived": .bool(true)] },
        CatalogArm(label: "list_notes", tool: "list_notes") { _, _ in [:] },
        CatalogArm(label: "list_notes · a shared book with a Private member", tool: "list_notes") { w, _ in ["book_id": s(w.shared)] },
        CatalogArm(label: "list_notes · a shared book, paged", tool: "list_notes") { w, _ in
            ["book_id": s(w.shared), "limit": .int(1)] },
        CatalogArm(label: "list_notes · the capped book", tool: "list_notes") { w, _ in ["book_id": s(w.capped)] },
        CatalogArm(label: "list_notes · a gathering (a Private note matches its rule)", tool: "list_notes") { w, _ in
            ["book_id": s(w.gathering)] },
        CatalogArm(label: "list_notes · a gathering, paged", tool: "list_notes") { w, _ in
            ["book_id": s(w.gathering), "limit": .int(1)] },
        CatalogArm(label: "list_notes · everything shared, paged", tool: "list_notes") { _, _ in ["limit": .int(2)] },
        CatalogArm(label: "list_notes · the Studio wing, paged", tool: "list_notes") { w, _ in
            ["wing_id": s(w.studio), "limit": .int(1)] },
        CatalogArm(label: "list_notes · the Studio wing (a Private note in its Pool)", tool: "list_notes") { w, _ in
            ["wing_id": s(w.studio)] },
        CatalogArm(label: "list_notes · Home (no wing grant)", tool: "list_notes") { _, _ in ["wing_id": s("")] },
        CatalogArm(label: "list_notes · a hidden wing", tool: "list_notes") { w, _ in ["wing_id": s(w.attic)] },
        CatalogArm(label: "list_notes · a hidden owned book", tool: "list_notes") { w, _ in ["book_id": s(w.vault)] },
        CatalogArm(label: "list_notes · a hidden Private book", tool: "list_notes") { w, _ in ["book_id": s(w.diary)] },
        // VX-827 U2 — VX-810: the list-by-tag road. In A a Private member of the
        // shared book and a hidden note's BLOCK wear #board, a hidden Private
        // Studio note wears #idea (the gathering's rule), #secret-topic is worn
        // only beyond reach and the hidden wing's note wears its own
        // #attic-topic — each absent, never hinted.
        CatalogArm(label: "list_notes · #board in the shared book (its Private member wears it too)", tool: "list_notes") { w, _ in
            ["book_id": s(w.shared), "tag": s("board")] },
        CatalogArm(label: "list_notes · #board in the shared book, paged", tool: "list_notes") { w, _ in
            ["book_id": s(w.shared), "tag": s("board"), "limit": .int(1)] },
        CatalogArm(label: "list_notes · #board, everything shared (hidden wearers, a hidden note's block)", tool: "list_notes") { _, _ in
            ["tag": s("board")] },
        CatalogArm(label: "list_notes · #board, everything shared, paged", tool: "list_notes") { _, _ in
            ["tag": s("board"), "limit": .int(1)] },
        CatalogArm(label: "list_notes · Studio #idea (a hidden Private note wears it)", tool: "list_notes") { w, _ in
            ["wing_id": s(w.studio), "tag": s("idea")] },
        CatalogArm(label: "list_notes · the gathering, #idea (a hidden Private note matches and wears it)", tool: "list_notes") { w, _ in
            ["book_id": s(w.gathering), "tag": s("idea")] },
        CatalogArm(label: "list_notes · #secret-topic (worn only beyond reach)", tool: "list_notes") { _, _ in
            ["tag": s("secret-topic")] },
        CatalogArm(label: "list_notes · a hidden wing's tag path", tool: "list_notes") { _, _ in ["tag": s("attic-topic")] },
        CatalogArm(label: "list_notes · a tag path naming nothing", tool: "list_notes") { _, _ in ["tag": s("no-such-tag")] },
        CatalogArm(label: "list_notes · a hidden wing, by its tag", tool: "list_notes") { w, _ in
            ["wing_id": s(w.attic), "tag": s("attic-topic")] },
        CatalogArm(label: "read_note · card with ids (a hidden board holds it)", tool: "read_note") { w, _ in
            ["note_id": s(w.card), "with_ids": .bool(true)] },
        CatalogArm(label: "read_note · card, text", tool: "read_note") { w, _ in ["note_id": s(w.card)] },
        CatalogArm(label: "read_note · card, everything", tool: "read_note") { w, _ in
            ["note_id": s(w.card), "with_ids": .bool(true), "with_lineage": .bool(true), "with_commits": .bool(true),
             "with_lenses": .bool(true), "with_tray": .bool(true), "with_versions": .bool(true)] },
        // VX-827 U1 (her F-U1-1 ruling, "Retire the stub"): RED ON THE OLD
        // STUB — A's answer carried one `beyond_grant` per edge to a hidden
        // relative (the Pool copy, the Private note, the hidden wing's note,
        // the Journal entry); now each is absent and beyond_reach says so.
        CatalogArm(label: "read_note · kin with lineage (hidden relatives in the Pool, a Private note, a hidden wing, the Journal)",
                   tool: "read_note") { w, _ in ["note_id": s(w.kin), "with_lineage": .bool(true)] },
        // VX-827 U1 — VX-817's list_note_lineage: a peer appears only when both
        // its ends are readable — hidden relatives are absent, never counted.
        CatalogArm(label: "list_note_lineage · kin (hidden relatives beside a readable copy in Studio)",
                   tool: "list_note_lineage") { w, _ in ["note_id": s(w.kin)] },
        CatalogArm(label: "list_note_lineage · kin's Studio copy (its original in the shared book)",
                   tool: "list_note_lineage") { w, _ in ["note_id": s(w.kinCopy)] },
        CatalogArm(label: "list_note_lineage · a hidden note", tool: "list_note_lineage") { w, _ in
            ["note_id": s(w.secretNote)] },
        CatalogArm(label: "list_note_lineage · the daily Journal's entry", tool: "list_note_lineage") { w, _ in
            ["note_id": s(w.journalEntry)] },
        CatalogArm(label: "list_note_lineage · a list mixing readable and hidden notes", tool: "list_note_lineage") { w, _ in
            ["note_ids": .array([s(w.kin), s(w.secretNote), s(w.journalEntry), s(w.kinCopy), s(w.atticNote)])] },
        CatalogArm(label: "list_note_lineage · a list of hidden notes only (an error)", tool: "list_note_lineage") { w, _ in
            ["note_ids": .array([s(w.secretNote), s(w.privateShared)])] },
        CatalogArm(label: "read_note · a note a hidden owned book claims", tool: "read_note") { w, _ in
            ["note_id": s(w.ownedNote), "with_ids": .bool(true)] },
        CatalogArm(label: "read_note · a note a hidden finished book holds", tool: "read_note") { w, _ in
            ["note_id": s(w.stuck), "with_ids": .bool(true)] },
        CatalogArm(label: "read_note · a hidden note", tool: "read_note") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "read_note · the daily Journal's entry", tool: "read_note") { w, _ in ["note_id": s(w.journalEntry)] },
        CatalogArm(label: "read_note · a Private member of a shared book", tool: "read_note") { w, _ in
            ["note_id": s(w.privateShared)] },
        CatalogArm(label: "read_note · a hidden lens on card", tool: "read_note") { w, _ in
            ["note_id": s(w.card), "lens_id": s(w.secretLens)] },
        CatalogArm(label: "search · a word hidden notes hold", tool: "search") { _, _ in ["query": s("zebra")] },
        CatalogArm(label: "search · words", tool: "search") { _, _ in ["query": s("words")] },
        CatalogArm(label: "search · #board", tool: "search") { _, _ in ["query": s("#board")] },
        CatalogArm(label: "search · #secret-topic", tool: "search") { _, _ in ["query": s("#secret-topic")] },
        CatalogArm(label: "search · in the shared book", tool: "search") { w, _ in ["query": s("words"), "book_id": s(w.shared)] },
        CatalogArm(label: "search · in a hidden book", tool: "search") { w, _ in ["query": s("words"), "book_id": s(w.atticBook)] },
        CatalogArm(label: "search · in a hidden note", tool: "search") { w, _ in ["query": s("zebra"), "note_id": s(w.secretNote)] },
        CatalogArm(label: "export_note · card", tool: "export_note") { w, _ in ["note_id": s(w.card)] },
        CatalogArm(label: "export_note · a hidden note", tool: "export_note") { w, _ in ["note_id": s(w.atticNote)] },
        CatalogArm(label: "list_wings", tool: "list_wings") { _, _ in [:] },
        CatalogArm(label: "show_in_app · card", tool: "show_in_app") { w, _ in ["target": s("note"), "note_id": s(w.card)] },
        CatalogArm(label: "show_in_app · a hidden note", tool: "show_in_app") { w, _ in
            ["target": s("note"), "note_id": s(w.secretNote)] },
        CatalogArm(label: "show_in_app · a hidden wing", tool: "show_in_app") { w, _ in ["target": s("wing"), "wing_id": s(w.attic)] },
        CatalogArm(label: "show_in_app · a hidden book", tool: "show_in_app") { w, _ in ["target": s("book"), "book_id": s(w.vault)] },
    ]

    // MARK: - SUGGEST

    static let suggestArms: [CatalogArm] = [
        CatalogArm(label: "add_take · card", tool: "add_take",
                   args: { w, _ in ["block_id": s(w.cardBlock), "text": s("A take.")] },
                   capture: { ["aiTake": $0["take_id"] as? String ?? ""] }),
        CatalogArm(label: "add_take · a hidden block", tool: "add_take") { w, _ in ["block_id": s(w.secretBlock), "text": s("x")] },
        CatalogArm(label: "add_comment · card", tool: "add_comment",
                   args: { w, _ in ["block_id": s(w.cardBlock), "text": s("An AI comment.")] },
                   capture: { ["comment": $0["comment_id"] as? String ?? ""] }),
        CatalogArm(label: "add_comment · a hidden block", tool: "add_comment") { w, _ in
            ["block_id": s(w.secretBlock), "text": s("x")] },
        CatalogArm(label: "add_takes · card", tool: "add_takes") { w, _ in
            ["note_id": s(w.card), "takes": .array([.object(["block_id": s(w.cardBlock2), "text": s("Batch take.")])])] },
        CatalogArm(label: "add_takes · a hidden block inside a shared note's batch", tool: "add_takes") { w, _ in
            ["note_id": s(w.card), "takes": .array([.object(["block_id": s(w.secretBlock), "text": s("x")])])] },
        CatalogArm(label: "add_comments · card", tool: "add_comments") { w, _ in
            ["note_id": s(w.card), "comments": .array([.object(["block_id": s(w.cardBlock), "text": s("Batch comment.")])])] },
        CatalogArm(label: "add_comments · a hidden note", tool: "add_comments") { w, _ in
            ["note_id": s(w.secretNote), "comments": .array([.object(["block_id": s(w.secretBlock), "text": s("x")])])] },
        CatalogArm(label: "delete_comment · its own", tool: "delete_comment") { _, c in ["comment_id": s(c["comment"] ?? "")] },
        CatalogArm(label: "delete_comment · a hidden comment", tool: "delete_comment") { w, _ in ["comment_id": s(w.secretComment)] },
        CatalogArm(label: "save_lens · card, pinned", tool: "save_lens",
                   args: { w, _ in ["note_id": s(w.card), "name": s("AI lens"), "pin_chosen": .bool(true)] },
                   capture: { ["lens": $0["lens_id"] as? String ?? ""] }),
        CatalogArm(label: "save_lens · a hidden note", tool: "save_lens") { w, _ in
            ["note_id": s(w.secretNote), "name": s("x"), "pin_chosen": .bool(true)] },
    ]

    // MARK: - WRITE NEW

    static let writeNewArms: [CatalogArm] = [
        CatalogArm(label: "create_note · in Studio", tool: "create_note",
                   args: { w, _ in ["wing_id": s(w.studio), "text": s("A new studio note.")] },
                   capture: { ["studioNew": $0["note_id"] as? String ?? ""] }),
        CatalogArm(label: "create_note · into the shared book", tool: "create_note",
                   args: { w, _ in ["book_id": s(w.shared), "title": s("filed"), "text": s("Filed words.")] },
                   capture: { ["filed": $0["note_id"] as? String ?? ""] }),
        // VX-814 (batch 3): born wearing a tag a hidden PRIVATE book collects
        // (#idea — the Diary's would-be seat bells, A-809-11) and a path only a
        // HIDDEN wing's tag wears (per-wing vocabulary: Studio mints its own),
        // then the client's next read of it.
        CatalogArm(label: "create_note · in Studio, born tagged #idea and a hidden wing's path", tool: "create_note",
                   args: { w, _ in ["wing_id": s(w.studio), "text": s("Born tagged."),
                                    "tags": .array([s("idea"), s("attic-topic")])] },
                   capture: { ["bornTagged": $0["note_id"] as? String ?? ""] }),
        CatalogArm(label: "read_note · the note born tagged", tool: "read_note") { _, c in
            ["note_id": s(c["bornTagged"] ?? ""), "with_ids": .bool(true)] },
        CatalogArm(label: "create_note · tags naming no tag", tool: "create_note") { w, _ in
            ["wing_id": s(w.studio), "text": s("x"), "tags": .array([s("//")])] },
        CatalogArm(label: "create_note · a hidden wing", tool: "create_note") { w, _ in ["wing_id": s(w.attic), "text": s("x")] },
        CatalogArm(label: "create_note · a hidden book", tool: "create_note") { w, _ in ["book_id": s(w.vault), "text": s("x")] },
        CatalogArm(label: "create_note · a hidden chapter of a shared book", tool: "create_note") { w, _ in
            ["book_id": s(w.shared), "section_id": s(w.hiddenChapter), "text": s("x")] },
        CatalogArm(label: "import_document · in Studio", tool: "import_document") { w, _ in
            ["wing_id": s(w.studio), "document": s("Imported words.")] },
        CatalogArm(label: "import_document · a book named as a hidden one is", tool: "import_document") { w, _ in
            ["wing_id": s(w.studio), "book": .object(["name": s("Twin import"), "documents": .array([s("One.")])])] },
        CatalogArm(label: "apply_tag · card, a new path", tool: "apply_tag") { w, _ in ["note_id": s(w.card), "tag": s("brand-new")] },
        CatalogArm(label: "apply_tag · a hidden note", tool: "apply_tag") { w, _ in ["note_id": s(w.secretNote), "tag": s("x")] },
        // VX-812 (batch 3): the list form — a note it may tag, a note it may
        // only read (the rung's refusal, its ask), a hidden note (the one shape).
        CatalogArm(label: "apply_tag · a list: card, a read-only note, a hidden note", tool: "apply_tag") { w, _ in
            ["note_ids": .array([s(w.card), s(w.loose), s(w.secretNote)]), "tag": s("listed")] },
        CatalogArm(label: "create_book · a name a hidden book wears", tool: "create_book") { w, _ in
            ["name": s("Twin book"), "wing_id": s(w.studio)] },
        CatalogArm(label: "create_book · a hidden wing", tool: "create_book") { w, _ in ["name": s("X"), "wing_id": s(w.attic)] },
        CatalogArm(label: "create_gathering · a name a hidden book wears", tool: "create_gathering") { w, _ in
            ["name": s("Twin gathering"), "wing_id": s(w.studio), "rule": .object(["tag": s("idea")])] },
        CatalogArm(label: "create_gathering · a hidden wing", tool: "create_gathering") { w, _ in
            ["name": s("G"), "wing_id": s(w.attic), "rule": .object(["star": .bool(true)])] },
        CatalogArm(label: "add_note_to_book · a hidden note", tool: "add_note_to_book") { w, _ in
            ["note_id": s(w.secretNote), "book_id": s(w.shared)] },
        CatalogArm(label: "add_note_to_book · into a hidden book", tool: "add_note_to_book") { w, _ in
            ["note_id": s(w.card), "book_id": s(w.vault)] },
        CatalogArm(label: "add_note_to_book · already a member", tool: "add_note_to_book") { w, _ in
            ["note_id": s(w.card), "book_id": s(w.shared)] },
        CatalogArm(label: "create_section · the shared book", tool: "create_section",
                   args: { w, _ in ["book_id": s(w.shared), "name": s("Part two")] },
                   capture: { ["section": $0["section_id"] as? String ?? ""] }),
        CatalogArm(label: "create_section · a hidden book", tool: "create_section") { w, _ in
            ["book_id": s(w.secretBoard), "name": s("x")] },
        CatalogArm(label: "save_version · card", tool: "save_version") { w, _ in ["note_id": s(w.card)] },
        CatalogArm(label: "save_version · a hidden note", tool: "save_version") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "file_note_in_chapter · card", tool: "file_note_in_chapter") { w, c in
            ["note_id": s(w.card), "book_id": s(w.shared), "section_id": s(c["section"] ?? "")] },
        CatalogArm(label: "file_note_in_chapter · a hidden chapter", tool: "file_note_in_chapter") { w, _ in
            ["note_id": s(w.card), "book_id": s(w.shared), "section_id": s(w.hiddenChapter)] },
        CatalogArm(label: "set_book_rule · the shared book collects #board", tool: "set_book_rule") { w, _ in
            ["book_id": s(w.shared), "rule": .object(["tag": s("board")])] },
        CatalogArm(label: "set_book_rule · a hidden book", tool: "set_book_rule") { w, _ in
            ["book_id": s(w.secretBoard), "rule": .object(["tag": s("board")])] },
        // VX-813 (batch 2): create_book's birth order (write new on the wing).
        CatalogArm(label: "create_book · with an order", tool: "create_book") { w, _ in
            ["name": s("Ordered"), "wing_id": s(w.studio),
             "order": .object(["sort_field": s("entry_date"), "sort_dir": s("desc")])] },
        CatalogArm(label: "link_versions · card and second", tool: "link_versions") { w, _ in
            ["note_a": s(w.card), "note_b": s(w.work),
             "pairs": .array([.object(["block_a": s(w.cardBlock), "block_b": s(w.workBlock2)])])] },
        CatalogArm(label: "link_versions · with a hidden note", tool: "link_versions") { w, _ in
            ["note_a": s(w.card), "note_b": s(w.secretNote),
             "pairs": .array([.object(["block_a": s(w.cardBlock), "block_b": s(w.secretBlock)])])] },
        CatalogArm(label: "insert_blocks · card's end", tool: "insert_blocks") { w, _ in
            ["note_id": s(w.card), "blocks": .array([.object(["text": s("Inserted.")])])] },
        CatalogArm(label: "insert_blocks · after a hidden block", tool: "insert_blocks") { w, _ in
            ["note_id": s(w.card), "after_block_id": s(w.secretBlock), "blocks": .array([.object(["text": s("x")])])] },
        CatalogArm(label: "insert_blocks · a hidden note", tool: "insert_blocks") { w, _ in
            ["note_id": s(w.secretNote), "blocks": .array([.object(["text": s("x")])])] },
        CatalogArm(label: "duplicate_note · card into the shared book (a hidden board collects its tag)",
                   tool: "duplicate_note") { w, _ in ["note_id": s(w.card), "book_id": s(w.shared), "brief": .bool(true)] },
        CatalogArm(label: "duplicate_note · a hidden note", tool: "duplicate_note") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "duplicate_note · into a hidden book", tool: "duplicate_note") { w, _ in
            ["note_id": s(w.card), "book_id": s(w.vault)] },
        CatalogArm(label: "copy_note_to_wing · card to Studio", tool: "copy_note_to_wing") { w, _ in
            ["note_id": s(w.card), "wing_id": s(w.studio)] },
        CatalogArm(label: "copy_note_to_wing · to a hidden wing", tool: "copy_note_to_wing") { w, _ in
            ["note_id": s(w.seed), "wing_id": s(w.attic)] },
        CatalogArm(label: "copy_note_to_wing · a hidden note", tool: "copy_note_to_wing") { w, _ in
            ["note_id": s(w.privateStudio), "wing_id": s("")] },
    ]

    // MARK: - EDIT

    static let editArms: [CatalogArm] = [
        CatalogArm(label: "edit_take · card", tool: "edit_take") { w, _ in
            ["take_id": s(w.cardTake), "expected_text": s("The first words of the card."), "text": s("The first words, edited.")] },
        CatalogArm(label: "edit_take · a hidden take", tool: "edit_take") { w, _ in
            ["take_id": s(w.secretTake), "expected_text": s("zebra words, secret."), "text": s("x")] },
        CatalogArm(label: "divide_block · work", tool: "divide_block") { w, _ in
            ["block_id": s(w.workBlock1), "second_half_starts_with": s("Beta")] },
        CatalogArm(label: "divide_block · a hidden block", tool: "divide_block") { w, _ in
            ["block_id": s(w.secretBlock), "second_half_starts_with": s("words")] },
        CatalogArm(label: "merge_blocks · a hidden block", tool: "merge_blocks") { w, _ in
            ["first_block_id": s(w.workBlock2), "second_block_id": s(w.secretBlock)] },
        CatalogArm(label: "move_block · work's last to its start", tool: "move_block") { w, _ in
            ["block_id": s(w.workBlock2), "note_id": s(w.work), "at": s("start")] },
        CatalogArm(label: "move_block · a hidden block", tool: "move_block") { w, _ in ["block_id": s(w.secretBlock), "at": s("start")] },
        CatalogArm(label: "set_block_name · card", tool: "set_block_name") { w, _ in ["block_id": s(w.cardBlock), "name": s("opener")] },
        CatalogArm(label: "set_block_name · a hidden block", tool: "set_block_name") { w, _ in
            ["block_id": s(w.secretBlock), "name": s("x")] },
        CatalogArm(label: "delete_block · work's last", tool: "delete_block") { w, _ in ["block_id": s(w.workBlock2)] },
        CatalogArm(label: "put_back · work's block", tool: "put_back") { w, _ in ["block_id": s(w.workBlock2)] },
        CatalogArm(label: "delete_block · a hidden block", tool: "delete_block") { w, _ in ["block_id": s(w.secretBlock)] },
        CatalogArm(label: "put_back · a hidden block", tool: "put_back") { w, _ in ["block_id": s(w.secretBlock)] },
        CatalogArm(label: "set_entry_date · card", tool: "set_entry_date") { w, _ in ["note_id": s(w.card), "entry_date": s("2026-06-01")] },
        CatalogArm(label: "set_entry_date · a hidden note", tool: "set_entry_date") { w, _ in
            ["note_id": s(w.secretNote), "entry_date": s("2026-06-01")] },
        CatalogArm(label: "move_note_to_wing · mover (a hidden board held it too)", tool: "move_note_to_wing") { w, _ in
            ["note_id": s(w.mover), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_note_to_wing · to a hidden wing", tool: "move_note_to_wing") { w, _ in
            ["note_id": s(w.second), "wing_id": s(w.attic)] },
        CatalogArm(label: "move_note_to_wing · a hidden note", tool: "move_note_to_wing") { w, _ in
            ["note_id": s(w.privateShared), "wing_id": s(w.studio)] },
        // VX-812 (batch 3): the list form — the filed note moves; the hidden
        // Private member answers its item's one shape.
        CatalogArm(label: "move_note_to_wing · a list: the filed note and a hidden note", tool: "move_note_to_wing") { w, c in
            ["note_ids": .array([s(c["filed"] ?? ""), s(w.privateShared)]), "wing_id": s(w.studio)] },
        CatalogArm(label: "save_commit · card", tool: "save_commit") { w, _ in ["take_id": s(w.cardTake), "message": s("saved")] },
        CatalogArm(label: "save_commit · a hidden take", tool: "save_commit") { w, _ in ["take_id": s(w.secretTake), "message": s("x")] },
        CatalogArm(label: "choose_take · card", tool: "choose_take") { w, _ in ["take_id": s(w.cardTake2)] },
        CatalogArm(label: "choose_take · a hidden take", tool: "choose_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "adopt_lens · card's lens", tool: "adopt_lens") { w, _ in ["lens_id": s(w.cardLens)] },
        CatalogArm(label: "adopt_lens · a hidden lens", tool: "adopt_lens") { w, _ in ["lens_id": s(w.secretLens)] },
        CatalogArm(label: "remove_tag · card #board (a hidden board holds it)", tool: "remove_tag") { w, _ in
            ["note_id": s(w.card), "tag": s("board")] },
        CatalogArm(label: "remove_tag · not worn", tool: "remove_tag") { w, _ in ["note_id": s(w.card), "tag": s("nope")] },
        CatalogArm(label: "remove_tag · a hidden note", tool: "remove_tag") { w, _ in
            ["note_id": s(w.secretNote), "tag": s("secret-topic")] },
        // VX-812 (batch 3): the list form — card's #brand-new comes off; the
        // hidden note answers its item's one shape.
        CatalogArm(label: "remove_tag · a list: card #brand-new and a hidden note", tool: "remove_tag") { w, _ in
            ["note_ids": .array([s(w.card), s(w.secretNote)]), "tag": s("brand-new")] },
        CatalogArm(label: "edit_comment · card's", tool: "edit_comment") { w, _ in
            ["comment_id": s(w.cardComment), "expected_text": s("a note to self"), "text": s("a note, edited")] },
        CatalogArm(label: "edit_comment · a hidden comment", tool: "edit_comment") { w, _ in
            ["comment_id": s(w.secretComment), "expected_text": s("secret comment"), "text": s("x")] },
        CatalogArm(label: "restore_comment · its own", tool: "restore_comment") { _, c in ["comment_id": s(c["comment"] ?? "")] },
        CatalogArm(label: "restore_comment · a hidden comment", tool: "restore_comment") { w, _ in ["comment_id": s(w.secretComment)] },
        CatalogArm(label: "set_take_label · card", tool: "set_take_label") { w, _ in ["take_id": s(w.cardTake2), "label": s("other")] },
        CatalogArm(label: "set_take_label · a hidden take", tool: "set_take_label") { w, _ in ["take_id": s(w.secretTake), "label": s("x")] },
        CatalogArm(label: "lock_take · card", tool: "lock_take") { w, _ in ["take_id": s(w.cardTake2)] },
        CatalogArm(label: "unlock_take · card", tool: "unlock_take") { w, _ in ["take_id": s(w.cardTake2)] },
        CatalogArm(label: "lock_take · a hidden take", tool: "lock_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "unlock_take · a hidden take", tool: "unlock_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "archive_take · card", tool: "archive_take") { w, _ in ["take_id": s(w.cardTake2)] },
        CatalogArm(label: "unarchive_take · card", tool: "unarchive_take") { w, _ in ["take_id": s(w.cardTake2)] },
        CatalogArm(label: "archive_take · a hidden take", tool: "archive_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "unarchive_take · a hidden take", tool: "unarchive_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "delete_take · its own take", tool: "delete_take") { _, c in ["take_id": s(c["aiTake"] ?? "")] },
        CatalogArm(label: "delete_take · a hidden take", tool: "delete_take") { w, _ in ["take_id": s(w.secretTake)] },
        CatalogArm(label: "restore_commit · card", tool: "restore_commit") { w, _ in ["commit_id": s(w.cardCommit)] },
        CatalogArm(label: "restore_commit · a hidden commit", tool: "restore_commit") { w, _ in ["commit_id": s(w.secretCommit)] },
        CatalogArm(label: "rename_commit · card", tool: "rename_commit") { w, _ in ["commit_id": s(w.cardCommit), "message": s("renamed")] },
        CatalogArm(label: "rename_commit · a hidden commit", tool: "rename_commit") { w, _ in
            ["commit_id": s(w.secretCommit), "message": s("x")] },
        CatalogArm(label: "rename_note · card", tool: "rename_note") { w, _ in ["note_id": s(w.card), "title": s("card, renamed")] },
        CatalogArm(label: "rename_note · a hidden note", tool: "rename_note") { w, _ in ["note_id": s(w.secretNote), "title": s("x")] },
        CatalogArm(label: "delete_lens · its own", tool: "delete_lens") { _, c in ["lens_id": s(c["lens"] ?? "")] },
        CatalogArm(label: "delete_lens · a hidden lens", tool: "delete_lens") { w, _ in ["lens_id": s(w.secretLens)] },
        CatalogArm(label: "rename_book · toward a name a hidden book wears", tool: "rename_book") { w, _ in
            ["book_id": s(w.studioBook), "name": s("Twin rename")] },
        CatalogArm(label: "rename_book · a hidden book", tool: "rename_book") { w, _ in ["book_id": s(w.vault), "name": s("x")] },
        CatalogArm(label: "move_note_in_book · second to the start", tool: "move_note_in_book") { w, _ in
            ["book_id": s(w.shared), "note_id": s(w.second), "at": s("start")] },
        CatalogArm(label: "move_note_in_book · after a hidden member", tool: "move_note_in_book") { w, _ in
            ["book_id": s(w.shared), "note_id": s(w.second), "after_note_id": s(w.privateShared)] },
        CatalogArm(label: "rename_chapter · Part one", tool: "rename_chapter") { w, _ in ["section_id": s(w.chapter), "name": s("Part 1")] },
        CatalogArm(label: "rename_chapter · a hidden chapter", tool: "rename_chapter") { w, _ in
            ["section_id": s(w.hiddenChapter), "name": s("x")] },
        CatalogArm(label: "move_chapter · Part 1 to the end", tool: "move_chapter") { w, _ in ["section_id": s(w.chapter), "at": s("end")] },
        CatalogArm(label: "move_chapter · a hidden chapter", tool: "move_chapter") { w, _ in
            ["section_id": s(w.hiddenChapter), "at": s("end")] },
        CatalogArm(label: "delete_chapter · Part two", tool: "delete_chapter") { _, c in ["section_id": s(c["section"] ?? "")] },
        CatalogArm(label: "delete_chapter · a hidden chapter", tool: "delete_chapter") { w, _ in ["section_id": s(w.hiddenChapter)] },
        CatalogArm(label: "remove_note_from_book · second", tool: "remove_note_from_book") { w, _ in
            ["book_id": s(w.shared), "note_id": s(w.second)] },
        CatalogArm(label: "remove_note_from_book · a hidden member", tool: "remove_note_from_book") { w, _ in
            ["book_id": s(w.shared), "note_id": s(w.privateShared)] },
        CatalogArm(label: "set_starred · card", tool: "set_starred") { w, _ in ["note_id": s(w.card), "starred": .bool(true)] },
        CatalogArm(label: "set_starred · the shared book", tool: "set_starred") { w, _ in ["book_id": s(w.shared), "starred": .bool(true)] },
        CatalogArm(label: "set_starred · a hidden note", tool: "set_starred") { w, _ in ["note_id": s(w.secretNote), "starred": .bool(true)] },
        CatalogArm(label: "set_starred · a hidden book", tool: "set_starred") { w, _ in ["book_id": s(w.vault), "starred": .bool(true)] },
        // VX-813 (batch 2): the book's order — on a book whose hidden members
        // exist (the answer must not vary), the same order again, a gathering
        // (edit on its wing), set_book_rule's order option (edit on the book),
        // and the one shape on a hidden book.
        CatalogArm(label: "set_book_order · the shared book (Private members inside)", tool: "set_book_order") { w, _ in
            ["book_id": s(w.shared), "sort_field": s("entry_date"), "sort_dir": s("desc")] },
        CatalogArm(label: "set_book_order · the shared book, the same order", tool: "set_book_order") { w, _ in
            ["book_id": s(w.shared), "sort_field": s("entry_date"), "sort_dir": s("desc")] },
        CatalogArm(label: "set_book_order · the gathering", tool: "set_book_order") { w, _ in
            ["book_id": s(w.gathering), "sort_field": s("last_touched"), "sort_dir": s("desc")] },
        CatalogArm(label: "set_book_order · a hidden book", tool: "set_book_order") { w, _ in
            ["book_id": s(w.vault), "sort_field": s("manual")] },
        CatalogArm(label: "set_book_order · a hidden Private book", tool: "set_book_order") { w, _ in
            ["book_id": s(w.diary), "sort_field": s("manual")] },
        CatalogArm(label: "set_book_rule · an order on the shared book", tool: "set_book_rule") { w, _ in
            ["book_id": s(w.shared), "order": .object(["sort_field": s("created_at")])] },
        CatalogArm(label: "archive_note · mover", tool: "archive_note") { w, _ in ["note_id": s(w.mover)] },
        CatalogArm(label: "unarchive_note · mover", tool: "unarchive_note") { w, _ in ["note_id": s(w.mover)] },
        CatalogArm(label: "archive_note · a hidden note", tool: "archive_note") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "unarchive_note · a hidden note", tool: "unarchive_note") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "finish_book · the shared book (a Private member inside)", tool: "finish_book") { w, _ in
            ["book_id": s(w.shared)] },
        CatalogArm(label: "reopen_book · the shared book", tool: "reopen_book") { w, _ in ["book_id": s(w.shared)] },
        CatalogArm(label: "finish_book · a hidden book", tool: "finish_book") { w, _ in ["book_id": s(w.vault)] },
        CatalogArm(label: "reopen_book · a hidden book", tool: "reopen_book") { w, _ in ["book_id": s(w.finished)] },
        CatalogArm(label: "archive_book · a book with a Private member", tool: "archive_book") { w, _ in
            ["book_id": s(w.doomed)] },
        CatalogArm(label: "unarchive_book · that book", tool: "unarchive_book") { w, _ in ["book_id": s(w.doomed)] },
        CatalogArm(label: "archive_book · a hidden book", tool: "archive_book") { w, _ in ["book_id": s(w.vault)] },
        CatalogArm(label: "unarchive_book · a hidden book", tool: "unarchive_book") { w, _ in ["book_id": s(w.atticBook)] },
        // VX-807 (batch 2): the book move — Traveler carries a Private member,
        // a member a hidden book also holds, a hidden waiting note, and a hidden
        // twin of its name waits in Studio (A); the one shape on a hidden book,
        // a hidden wing and the daily Journal; a gathering's own sentence.
        CatalogArm(label: "move_book_to_wing · Traveler to Studio (hidden members, books, waiters, twin)",
                   tool: "move_book_to_wing") { w, _ in ["book_id": s(w.traveler), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_book_to_wing · a hidden book", tool: "move_book_to_wing") { w, _ in
            ["book_id": s(w.vault), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_book_to_wing · to a hidden wing", tool: "move_book_to_wing") { w, _ in
            ["book_id": s(w.doomed), "wing_id": s(w.attic)] },
        CatalogArm(label: "move_book_to_wing · the daily Journal", tool: "move_book_to_wing") { w, _ in
            ["book_id": s(w.journalBook), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_book_to_wing · a hidden Private book", tool: "move_book_to_wing") { w, _ in
            ["book_id": s(w.locket), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_book_to_wing · the gathering", tool: "move_book_to_wing") { w, _ in
            ["book_id": s(w.gathering), "wing_id": s("")] },
        CatalogArm(label: "list_my_activity", tool: "list_my_activity") { _, _ in ["limit": .int(200)] },
        CatalogArm(label: "list_books · after the acts", tool: "list_books") { _, _ in [:] },
        CatalogArm(label: "list_notes · the shared book after the acts", tool: "list_notes") { w, _ in ["book_id": s(w.shared)] },
        CatalogArm(label: "list_wings · after the acts", tool: "list_wings") { _, _ in [:] },
        // VX-812 (batch 3): the list form — the new studio note goes to the
        // Trash; the hidden note answers its item's one shape.
        CatalogArm(label: "delete_note · a list: the new studio note and a hidden note", tool: "delete_note") { w, c in
            ["note_ids": .array([s(c["studioNew"] ?? ""), s(w.secretNote)])] },
        CatalogArm(label: "delete_note · mover", tool: "delete_note") { w, _ in ["note_id": s(w.mover)] },
        CatalogArm(label: "delete_note · a hidden note", tool: "delete_note") { w, _ in ["note_id": s(w.secretNote)] },
        CatalogArm(label: "delete_book · a book with a Private member", tool: "delete_book") { w, _ in
            ["book_id": s(w.doomed)] },
        CatalogArm(label: "delete_book · a hidden book", tool: "delete_book") { w, _ in ["book_id": s(w.vault)] },
    ]

    // MARK: - THE TAIL — arms whose act lands in one store and not the other,
    // or changes what the client reaches (each a recorded exception or
    // finding — the record's catalog), walked LAST so the state they fork never
    // reaches an arm compared byte for byte.

    static let tailArms: [CatalogArm] = [
        CatalogArm(label: "create_note · a capped book (a Private member fills it)", tool: "create_note") { w, _ in
            ["book_id": s(w.cappedToo), "text": s("Over the cap?")] },
        CatalogArm(label: "apply_tag · card, a path only a hidden note wears", tool: "apply_tag") { w, _ in
            ["note_id": s(w.card), "tag": s("secret-topic")] },
        CatalogArm(label: "apply_tag · a studio note, a Private book's tag", tool: "apply_tag") { w, _ in
            ["note_id": s(w.studioMember), "tag": s("idea")] },
        // A-809-11 (batch 3): the client's next read of the note it just tagged
        // — the Private book's would-be seat bells, so it still reads.
        CatalogArm(label: "read_note · that studio note after the Private book's tag", tool: "read_note") { w, _ in
            ["note_id": s(w.studioMember), "with_ids": .bool(true)] },
        CatalogArm(label: "add_note_to_book · a note an unreadable owned book claims", tool: "add_note_to_book") { w, _ in
            ["note_id": s(w.ownedNote), "book_id": s(w.shared)] },
        CatalogArm(label: "add_note_to_book · the capped book (a Private member fills it)", tool: "add_note_to_book") { w, _ in
            ["note_id": s(w.work), "book_id": s(w.capped)] },
        CatalogArm(label: "duplicate_note · seed in Studio (a Private book collects its tag)", tool: "duplicate_note",
                   args: { w, _ in ["note_id": s(w.seed), "brief": .bool(true)] },
                   capture: { ["seedCopy": $0["note_id"] as? String ?? ""] }),
        CatalogArm(label: "read_note · the seed's copy (a Private book collects its tag)", tool: "read_note") { _, c in
            ["note_id": s(c["seedCopy"] ?? ""), "with_ids": .bool(true)] },
        CatalogArm(label: "move_note_to_wing · a note an unreadable finished book holds", tool: "move_note_to_wing") { w, _ in
            ["note_id": s(w.stuck), "wing_id": s(w.studio)] },
        // VX-807 (batch 2): the book move's hidden causes (each lands in B only),
        // AFTER the note move above (B's stuck has left the Stuck book there).
        CatalogArm(label: "move_book_to_wing · a book whose note an unreadable finished book holds",
                   tool: "move_book_to_wing") { w, _ in ["book_id": s(w.stuckBook), "wing_id": s(w.studio)] },
        CatalogArm(label: "move_book_to_wing · a book a hidden note in a Private book sits in (its fence would drop)",
                   tool: "move_book_to_wing") { w, _ in ["book_id": s(w.fencedBook), "wing_id": s(w.studio)] },
        CatalogArm(label: "remove_tag · card #secret-topic (only a hidden note wears it after)", tool: "remove_tag") { w, _ in
            ["note_id": s(w.card), "tag": s("secret-topic")] },
        // A-809-11 (batch 3): a client's STAR on a Studio note a hidden Private
        // ★ book collects, then its next read (last: before the build, the seat
        // fenced the seed in A).
        CatalogArm(label: "set_starred · seed (a Private book collects stars)", tool: "set_starred") { w, _ in
            ["note_id": s(w.seed), "starred": .bool(true)] },
        CatalogArm(label: "read_note · seed after its star", tool: "read_note") { w, _ in
            ["note_id": s(w.seed), "with_ids": .bool(true)] },
        // VX-812 (batch 3): replace_tag across the client's reach — LAST (it
        // takes #idea off every Studio note the client may edit; a hidden
        // PRIVATE Studio note wears #idea in A, untouched, unmentioned and
        // uncounted); a tag only a hidden note wears (Home's #secret-topic,
        // card's taken off above); a hidden wing.
        CatalogArm(label: "replace_tag · Studio #idea with #idea-swapped (a hidden Private note wears it)",
                   tool: "replace_tag") { w, _ in ["wing_id": s(w.studio), "tag": s("idea"), "with": s("idea-swapped")] },
        CatalogArm(label: "replace_tag · a tag only a hidden note wears", tool: "replace_tag") { _, _ in
            ["wing_id": s(""), "tag": s("secret-topic"), "with": s("swapped")] },
        CatalogArm(label: "replace_tag · a hidden wing", tool: "replace_tag") { w, _ in
            ["wing_id": s(w.attic), "tag": s("attic-topic"), "with": s("swapped")] },
    ]
}
