//
//  OpenStripMenuTests.swift
//  VariorumTests
//
//  18o U3 — KnownIssues row 73: View ▸ Open Note at TEN open notes and more.
//
//  THE DEFECT (18k UNIT C1's walk, the crash report
//  `notes/plans/18k-screens/c1/open-strip-tenth-note-crash.ips`): the menu
//  built `KeyEquivalent(Character("\(index + 1)"))` for EVERY open note, and
//  since Act 10 item 9 (`a9772471`) the strip holds up to twenty. At the
//  tenth row that asks for `Character("10")` — two graphemes — and
//  `Character.init(_: String)`'s `_debugPrecondition` traps the Debug app
//  (compiled out at -O, so the Release app most likely builds a malformed
//  two-grapheme key instead). And the tenth row's CLICK did nothing either:
//  it asked `openNote(ordinal: 10)`, and the ordinal address stops at nine
//  (`OpenNotes.ordinalCap`, pinned by `WorkspaceNavigationTests`).
//
//  THE PIN'S SHAPE, and why it reds on the old rule without aborting the
//  runner: the menu renders `OpenNotes.menuRows` one row per item — its
//  title, key and act all read the row (the source walk below holds the
//  menu to that) — and the table carries each key as TEXT. So the pins read
//  the rule at ten and twenty notes without ever constructing a `Character`;
//  on the old rule the tenth row's key text is "10" (not nil, and two
//  characters) and its act lands nothing, which is a test FAILURE here, not
//  a `_debugPrecondition` trap. The walk mounts the real menu with ten notes.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("The Open strip's menu at ten notes and more (18o U3 — KnownIssues row 73)")
struct OpenStripMenuTests {
    private func strip(_ count: Int) -> OpenNotes {
        var open = OpenNotes()
        for i in 1...count { open.opened("p\(i)") }
        return open
    }

    /// **THE row-73 pin.** Ten open notes: ten rows (the tenth RENDERS — the
    /// strip hides nothing since Act 10 item 9), keys ⌘⇧1…⌘⇧9 on the first
    /// nine, and NO key on the tenth — the model's own key cap
    /// (`OpenNotes.ordinalCap`: "rows past nine are click/scroll rows"),
    /// which the sidebar's ordinal badges and the ⌘⇧n address already
    /// honoured and only this menu did not.
    @Test func theMenuWithTenOpenNotesKeysOnlyTheFirstNine() {
        let rows = strip(10).menuRows
        #expect(rows.count == 10, "every open note is a row — the tenth renders")
        #expect(rows.map(\.noteID) == (1...10).map { "p\($0)" }, "in strip order")
        #expect(rows.prefix(9).map(\.keyText) == (1...9).map { String($0) },
                "⌘⇧1…⌘⇧9 on the first nine, unchanged")
        #expect(rows[9].keyText == nil, "the tenth row renders WITHOUT a shortcut")
    }

    /// The same rule to the strip's ruled bound (twenty — `trackedCap`):
    /// every key the menu wears is ONE character (the precondition
    /// `Character.init(_: String)` traps on in Debug), and a row carries one
    /// exactly when the ⌘⇧n address reaches it.
    @Test func everyKeyTheMenuWearsIsOneCharacterUpToTheTrackedCap() {
        let rows = strip(OpenNotes.trackedCap).menuRows
        #expect(rows.count == OpenNotes.trackedCap)
        for row in rows {
            if let text = row.keyText {
                #expect(text.count == 1, "row \(row.ordinal)'s key is \"\(text)\" — one character")
            }
            #expect((row.keyText != nil) == (row.ordinal <= OpenNotes.ordinalCap),
                    "row \(row.ordinal) carries a key exactly when ⌘⇧n can address it")
        }
    }

    /// **P-2 (fire-and-DO), the other half of the tenth row:** a row that
    /// renders must act. The menu's rows now open the note they NAME; on the
    /// old road the tenth row asked the ordinal address, which stops at nine,
    /// and the click landed nothing.
    @Test func aRowPastNineStillOpensTheNoteItNames() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        for i in 1...12 { router.workspace.visit(.post("p\(i)")) }
        router.pendingSelection = nil
        let rows = router.workspace.openNotes.menuRows
        #expect(rows.count == 12)

        router.openStripRow(rows[9])
        #expect(router.pendingSelection == .post("p10"), "the tenth row opens the tenth note")
        router.pendingSelection = nil
        router.openStripRow(rows[11])
        #expect(router.pendingSelection == .post("p12"), "and the twelfth the twelfth")
    }

    /// The guard (green on both sides): the nine keyed rows open exactly the
    /// note their ⌘⇧n key has always addressed.
    @Test func theFirstNineRowsOpenWhatTheirKeysAddress() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        for i in 1...12 { router.workspace.visit(.post("p\(i)")) }
        let open = router.workspace.openNotes
        for row in open.menuRows.prefix(OpenNotes.ordinalCap) {
            router.pendingSelection = nil
            router.openStripRow(row)
            let addressed = open.id(atOrdinal: row.ordinal)
            #expect(addressed != nil, "⌘⇧\(row.ordinal) addresses a row")
            #expect(router.pendingSelection == addressed.map { SidebarSelection.post($0) },
                    "row \(row.ordinal) opens what ⌘⇧\(row.ordinal) addresses")
        }
    }

    /// **The ⌘<n> sibling, verdicted SAFE BY ITS CAP** (`EditorCommands`' mode
    /// keys build `KeyEquivalent(Character("\(i + 1)"))` over
    /// `PostMode.allCases`): the same construction, but over a CLOSED enum,
    /// so it can never reach "10" at run time. This pin is the cap — a tenth
    /// mode reds it here, loudly, instead of trapping the Debug app at launch.
    @Test func theModeKeysCanNeverReachTen() {
        #expect(PostMode.allCases.count <= 9, "⌘1…⌘9 are the only single-digit mode keys")
        for (i, mode) in PostMode.allCases.enumerated() {
            #expect(String(i + 1).count == 1, "\(mode.rawValue)'s key is one character")
        }
    }

    /// The menu RENDERS the table — so the pins above are about the menu she
    /// opens, not a parallel list. Title, key and act read the row; nothing
    /// in the file builds a key from a bare index any more.
    @Test func theOpenNoteMenuRendersTheTable() {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum/EditorCommands.swift")
        let file = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        #expect(!file.isEmpty, "the pin found the file it is about")
        #expect(file.contains("ForEach(router?.workspace.openNotes.menuRows ?? [], id: \\.noteID)"),
                "the menu's rows are the table's")
        #expect(file.contains("router?.openStripRow(row)"), "each row acts through the row door")
        #expect(file.contains(".keyboardShortcut(row.keyboardShortcut)"), "each row's key is the row's")
        #expect(!file.contains("Character(\"\\(index + 1)\")"),
                "no key is built from a bare index")
    }
}
