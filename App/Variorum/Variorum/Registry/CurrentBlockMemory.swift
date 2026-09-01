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
    func current(for postID: String, defaults: UserDefaults = .standard) -> FocusedBlock? {
        if let fact = facts[postID] { return fact }
        guard let stored = defaults.string(forKey: Self.key(postID)) else { return nil }
        let parts = stored.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        guard let blockID = parts.first, !blockID.isEmpty else { return nil }
        let variantID = parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil
        return FocusedBlock(postID: postID, blockID: String(blockID), variantID: variantID)
    }

    /// A surface reported where she is — remember it for its note.
    mutating func remember(_ fact: FocusedBlock, defaults: UserDefaults = .standard) {
        facts[fact.postID] = fact
        defaults.set("\(fact.blockID)|\(fact.variantID ?? "")", forKey: Self.key(fact.postID))
    }

    /// A note's memory is dropped (the note was deleted, or a pin resets).
    mutating func forget(postID: String, defaults: UserDefaults = .standard) {
        facts[postID] = nil
        defaults.removeObject(forKey: Self.key(postID))
    }
}
