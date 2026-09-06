//
//  SampleLibraryEncryptionBook.swift
//  Shared (Variorum + VariorumMobile)
//
//  pre-13x batch 5a — *ENCRYPTION EXPLAINED*'s reserved identities and its
//  front-matter note (the postures design §1.22 / §8; copy §7b). The book's
//  text itself is `EncryptionExplained.txt`, copy §7b VERBATIM: one note
//  per chapter in Chapter 1 → 8 order, each chapter heading its note's
//  title. It seeds through `SampleLibrarySeeder` (`Book.encryptionExplained`)
//  — the same discovery, the same resumable seed, the same manifest and
//  dedupe facts as Sherlock — in Home beside the tutorial, on BOTH
//  platforms, restorable from Help on the Mac like the tutorial and
//  Sherlock. The tutorial's short chapter (copy §7) points at it by name.
//
//  THE REGISTER (copy §7b's head, the book's own rule): plain credential
//  words, each defined the first time it appears — the front-matter note
//  below carries those definitions so a reader meets them before Chapter 1.
//  The copy file's "Never: …" list is an instruction to the writers, not
//  reader text, and does not ship (recorded in the 5a record).
//

import Foundation

nonisolated enum SampleLibraryEncryptionBook {
    /// The book's reserved name — the copy's own quoted name (copy §7's
    /// tutorial sentence: *the book "Encryption Explained" on this shelf*),
    /// EXACT and case-sensitive for discovery. Deliberately not the shelf's
    /// lowercase idiom: the copy wins, and the tutorial quotes it.
    static let name = "Encryption Explained"
    /// The reserved tag path — a top-level sibling of `sherlock holmes` and
    /// `tutorial`, so the whole book is findable and removable as a set.
    static let tagName = "encryption explained"
    static let frontMatterChapter = "about this book"
    static let frontMatterTitle = "About this book"
    /// The bundled resource (`%%% <chapter heading>` lines separate the
    /// chapters and are never stored).
    static let resourceName = "EncryptionExplained"
    /// The defaults mark's suffix: `SampleLibrarySeeded.<variant>.encryption-explained`
    /// — its OWN mark, so an existing store whose Sherlock mark is set still
    /// seeds this book at its next occasion.
    static let markSuffix = "encryption-explained"

    /// The front-matter note: copy §7b's register rule, the definitions half
    /// (verbatim), then the tag sentence (true on both platforms — the
    /// phone has no restore door for seeded books, so no restore promise).
    static let aboutThisBook = """
        This book uses plain credential words, each defined the first time it \
        appears: encrypted (scrambled so that only a key unscrambles it) \u{B7} key \
        (a long random number) \u{B7} wrapped (a key that has itself been encrypted \
        under another key or under your passphrase, so the wrapped copy is useless \
        without what wraps it) \u{B7} the library key \u{B7} the master key \u{B7} the \
        corpus key \u{B7} the iCloud key \u{B7} your passphrase \u{B7} your twelve \
        words \u{B7} the key file.

        Every note here is tagged \u{201C}\(tagName)\u{201D}, so the whole book is \
        findable and removable as a set.
        """
}
