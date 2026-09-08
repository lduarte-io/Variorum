//
//  CurrentBlockMemory.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch C — **ONE current block per note**
//  (ledger row 39; her words: *"I haven't even gotten into blocks and index
//  and how clicking through them is impacting the regular write and takes
//  mode"*; the triage walk's finding: position was PER-MODE memory — Index
//  kept block 03 while Takes made block 1 live). W8-1's letter rules it:
//  one current block follows you across Write · Takes · Read(edit) ·
//  Blocks. Every mode ENTERS on it and LEAVES to it.
//
//  The LIVE fact is `CommandRouter.focusedBlock` (the post-13l row-33 fact
//  every surface already reports — Write's caret block, Takes' live pane,
//  Read's selection, Blocks' focused row). This is its MEMORY: the last
//  fact per note, kept when the detail unmounts and restored when the note
//  mounts again — so a note reopened from the Library (batch E's "Open lands
//  where the caret was") and a mode entered a week later both know where
//  she was. Persisted per note like the mode memory (`postMode.<id>` — the
//  scroll-position class: local, never synced).
//
//  Pure: a value type over a dictionary plus the defaults it persists to.
//  The router owns one and writes through it; nothing else decides.
//

import Foundation

struct CurrentBlockMemory {
    static func key(_ postID: String) -> String { "currentBlock.\(postID)" }

    private var facts: [String: FocusedBlock] = [:]

    init() {}

    /// The remembered current block of a note, if any — the session's
    /// memory first, the persisted one behind it.
    ///
    /// The persisted form is `blockID|variantID|utf16Offset`. A memory
    /// written before 17o batch b carries two fields; it reads back with an
    /// UNKNOWN offset, which every landing spells "the block's start" — the
    /// behaviour it had when it was written.
    func current(for postID: String, defaults: UserDefaults = .standard) -> FocusedBlock? {
        if let fact = facts[postID] { return fact }
        guard let stored = defaults.string(forKey: Self.key(postID)) else { return nil }
        let parts = stored.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        guard let blockID = parts.first, !blockID.isEmpty else { return nil }
        let variantID = parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil
        let offset = parts.count > 2 ? Int(parts[2]) : nil
        return FocusedBlock(
            postID: postID, blockID: String(blockID), variantID: variantID,
            utf16Offset: offset)
    }

    /// A surface reported where she is — remember it for its note.
    ///
    /// **nil means UNKNOWN, never zero** (17o batch b, her ruling U-20). A
    /// surface that holds no caret — Blocks' focused row, the outline's card,
    /// the Library's Open — reports the block and nothing more; erasing a
    /// known offset on its say-so would land her at the top of the paragraph
    /// she was standing in the middle of, which is the whole complaint. So a
    /// nil offset for the SAME block keeps what is known, and a report for
    /// ANOTHER block resets it (an offset inside block one means nothing
    /// inside block two).
    mutating func remember(_ fact: FocusedBlock, defaults: UserDefaults = .standard) {
        var fact = fact
        if fact.utf16Offset == nil,
           let known = current(for: fact.postID, defaults: defaults),
           known.blockID == fact.blockID {
            fact.utf16Offset = known.utf16Offset
        }
        let previous = facts[fact.postID]
        facts[fact.postID] = fact
        // **The session dict takes every report; the PERSISTED copy is written
        // when the block (or its take) changes, and once more when the note
        // leaves the screen (`persist`).** Measured on this machine (17o batch
        // b): `UserDefaults.standard.set` costs ~100 µs — fine per block
        // change, not a price worth paying on every keystroke for a value
        // nothing reads until a landing. The only thing a hard quit can cost
        // is the offset's drift within the block she was last in; the BLOCK is
        // always current, so a relaunch still lands in the right paragraph.
        guard previous?.blockID != fact.blockID || previous?.variantID != fact.variantID
        else { return }
        write(fact, defaults)
    }

    /// The note is leaving the screen — write what the session dict holds.
    mutating func persist(postID: String, defaults: UserDefaults = .standard) {
        guard let fact = facts[postID] else { return }
        write(fact, defaults)
    }

    private func write(_ fact: FocusedBlock, _ defaults: UserDefaults) {
        defaults.set(
            "\(fact.blockID)|\(fact.variantID ?? "")|\(fact.utf16Offset.map(String.init) ?? "")",
            forKey: Self.key(fact.postID))
    }

    /// A note's memory is dropped (the note was deleted, or a pin resets).
    mutating func forget(postID: String, defaults: UserDefaults = .standard) {
        facts[postID] = nil
        defaults.removeObject(forKey: Self.key(postID))
    }
}
