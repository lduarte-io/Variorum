//
//  RefusalWords.swift
//  Variorum (shared: Mac + Mobile)
//
//  **VM-277 — A REFUSAL'S TWO HALVES, FROM ONE ARM** (the VM-260 run, batch 1b;
//  ruled A-260-4 (a)). Her ruling: "refusals should be dismissable and they
//  should be much shorter. maybe you even have to click on it for the reason".
//  So a refusal the phone's one line says has a SHORT FORM — a headline — and
//  its whole sentence, the reason opened on demand.
//
//  The one-brain law holds literally: a composer answers BOTH halves from the
//  same switch arm (`OpsRefusalCopy.refusal(for:roads:)`), so a headline can
//  never drift from its sentence, and nothing anywhere derives a headline from
//  a sentence's words. The sentence is the row's existing words, byte for byte
//  — what the Mac and the MCP door keep reading (`words(for:roads:)` forwards
//  `.sentence`). A row with no authored headline (`headline == nil`) draws its
//  sentence clipped to one line with "…" on the phone, until her wording pass
//  (the headline list joins the run's closeout Wording bundle). Every authored
//  headline is a DRAFT for that pass.
//

import Foundation

nonisolated struct RefusalWords: Equatable, Sendable {
    /// The whole sentence — the reason, and what every non-phone reader reads.
    let sentence: String
    /// The short form the phone's one line draws; nil = unauthored.
    let headline: String?

    init(_ sentence: String, headline: String? = nil) {
        self.sentence = sentence
        self.headline = headline
    }
}
