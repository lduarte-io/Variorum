//
//  BookNameCopy.swift
//  Shared
//
//  **HOISTED, NOT COPIED** (Mobile Round 2, batch 4.5d's tail — PL-10(b)).
//  This enum was born Mac-app-local in
//  `Variorum/Registry/OpsRefusalCopy.swift` at Phase 13e (E13). The phone's
//  two book-naming doors — `MobileCreateBookSheet` and
//  `MobileBookDetailsSheet`'s rename — now consult `assertBookNameIsFree`
//  too, and a second copy of her sentence is exactly the drift class
//  MobileSoul §3 forbids: *"A capability built Mac-side with its brain in
//  app-local code is a parity defect at birth."* So the address moved and
//  nothing else did — the Mac's callers, and its `DoorSetTests` pins that
//  compare against `BookNameCopy.refusal(existing:)`, ride byte-unmodified.
//  (The KnownIssues forked-brains row is the standing ledger; this is one
//  more entry discharged the way that row prescribes — a hoist at the moment
//  the second platform needs the brain.)
//

import Foundation

/// 13e E13 — what a door says when the name is taken. ONE sentence, in ONE
/// place, for the same reason `DivergeCopy` and `StarCopy` are enums rather
/// than string literals: **seven** doors name a book — the Mac's five (the
/// shelf's New Book and Rename, the navigator's Rename, Settings' Promote to
/// Book, and the conversion offer's fresh collector) plus the phone's two
/// (New Book, and Book Details' rename) — and a promise made in seven `Text`
/// literals is a promise no test can keep.
///
/// Her ruled wording is the model — *"A book named 'Ideas' already exists"* —
/// with the road named after it, because a refusal that does not say what to
/// do instead is the lecture-without-a-door class P-2 retired. The name
/// quoted is the EXISTING book's, in its own casing, which is the answer to
/// "but I don't have a book called that" when she typed different capitals.
///
/// The store-truthful half is `Operations.assertBookNameIsFree`; the pure
/// comparison rule is `BookNaming` in core. This is only the sentence.
nonisolated enum BookNameCopy {
    static func refusal(existing: String) -> String {
        "A book named \u{201c}\(existing)\u{201d} already exists — pick a different "
            + "name, or rename that one first."
    }
}
