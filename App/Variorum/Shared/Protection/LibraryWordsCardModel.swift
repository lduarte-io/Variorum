//
//  LibraryWordsCardModel.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE ONCE-SHOWN WORDS CARD's brain (rule 2: "Every library has twelve words from the moment it
//  is created. They are shown once, with 'write these down now'"; §7c (1); P-VX306-K7). The library already
//  exists when the card shows (the creation minted the words); the card holds them only until its ONE button
//  — "I've written them down" — which forgets them and opens the library. No Copy door, no "later": the words
//  are never stored, so there is no later, and the clipboard never holds them.
//

import Foundation
import Observation

@MainActor
@Observable
final class LibraryWordsCardModel {
    /// The twelve words, numbered in reading order — empty once the button was pressed.
    private(set) var words: [String]
    @ObservationIgnored private let writtenDown: () -> Void

    init(words: [String], writtenDown: @escaping () -> Void) {
        self.words = words
        self.writtenDown = writtenDown
    }

    /// The two columns the card lays the words out in: 1–6, then 7–12 (each entry its number and word).
    var columns: [[(number: Int, word: String)]] {
        let numbered = words.enumerated().map { (number: $0.offset + 1, word: $0.element) }
        let half = (numbered.count + 1) / 2
        return [Array(numbered.prefix(half)), Array(numbered.dropFirst(half))]
    }

    /// The one button: the words are forgotten, then the library opens. A second press does nothing.
    func iveWrittenThemDown() {
        guard !words.isEmpty else { return }
        words = []
        writtenDown()
    }
}
