//
//  SeededBookReceipt.swift
//  Variorum
//
//  VX-631 — what a seeded book's restore receipt says came back. The door
//  (`ShellActions.restoreSeededBook`) used to build the plural as `noun + "s"`,
//  so Sherlock's restore read "12 storys came back." The unit now carries BOTH
//  forms spelled whole; no suffix rule is ever applied to a word. (No
//  app-wide plural brain exists to route through — every copy home spells its
//  own counts — so the fix stays local to this receipt.)
//
//  Pure Foundation-free strings, no app imports: the pin reads it without a
//  window, and it compiles standalone.
//

/// The unit a seeded book counts its restored notes in, singular and plural
/// spelled whole.
nonisolated struct SeededBookUnit: Sendable, Equatable {
    var one: String
    var many: String

    /// Sherlock's notes are its stories.
    static let story = SeededBookUnit(one: "story", many: "stories")
    /// Every other seeded book's notes are its chapters.
    static let chapter = SeededBookUnit(one: "chapter", many: "chapters")

    /// "1 story" · "12 stories".
    func counted(_ n: Int) -> String {
        "\(n) \(n == 1 ? one : many)"
    }
}

/// The restore door's receipt words (sentence case; the shelf tail is
/// `WelcomeDoorCopy.onTheShelfSuffix`, appended by the door).
nonisolated enum SeededBookReceipt {
    /// "Restored “the adventures of sherlock holmes” — 12 stories came back."
    static func restored(book: String, unit: SeededBookUnit, minted: Int) -> String {
        "Restored \u{201C}\(book)\u{201D} \u{2014} \(unit.counted(minted)) came back."
    }
}
