//
//  ShortcutCatalogTests.swift
//  VariorumTests
//
//  VX-572 (the VX-677 run, batch 4) — the ⌘/ helper's list ON THE REGISTRY
//  (P-1) and its one filter rule. Her wants (the ticket, both passes): "I
//  NEED the ability to search shortcuts", helpful headings "default to not
//  being expanded", collapsible group headers, "easy to see which chord does
//  what".
//
//  Two kinds of pin here:
//  · THE REGISTRY WALK, at the ID level (GUARDS — structural, green on both
//    trees): every chord a row shows is READ from the act it names; every
//    chord the registry declares is shown by a row naming its act; no
//    gesture re-types a declared chord; the headings are declared once, in
//    order. These replace the hand-kept list's string-match drift guard
//    (which stays green as a projection — `CapabilityRegistryTests`).
//  · THE FILTER (RED on `rev572`, whose revert makes `sections` the old
//    list — every group open, every row, the query ignored): folded at
//    rest, her own opening, the word search, the heading search, the chord
//    search, a fold that lasts one query, no match. The chord READER
//    (`ShortcutChord`) is new capability — its pins are guards.
//
//  VX-692 (F-B3-1): no closure-bearing expression sits inside `#expect` or
//  `#require` — every value is bound to a local first.
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-572 — the shortcut catalog on the registry, and its filter")
struct ShortcutCatalogTests {
    private typealias Group = ShortcutCatalog.Group

    private static func rows(_ sections: [ShortcutCatalogFilter.Section]) -> [ShortcutCatalog.Row] {
        sections.flatMap(\.rows)
    }

    private static func keyTexts(_ sections: [ShortcutCatalogFilter.Section]) -> [String] {
        rows(sections).map(\.keysText)
    }

    // MARK: - The registry walk (GUARDS)

    /// **Every chord a row shows is READ from the act it names** — never
    /// typed: a `.chords` row's tokens are its acts' `shortcutLabel`s (every
    /// one of them declares one), `.alternates` the alternates, `.system` the
    /// system chord, and a `.menu` row's token is "‹menu› ▸ ‹verb›" of an act
    /// whose doors include the menu bar.
    @Test func everyChordShownIsReadFromTheActItNames() {
        for row in ShortcutCatalog.rows {
            switch row.keys {
            case .chords(let ids):
                let labels = ids.map { CapabilityRegistry.capability($0).shortcutLabel }
                let declared = labels.compactMap { $0 }
                #expect(declared.count == ids.count, "\(row.id): every act it cites declares a chord")
                #expect(row.tokens == declared, "\(row.id): the chords are the declarations'")
            case .alternates(let ids):
                let labels = ids.compactMap { CapabilityRegistry.capability($0).alternateShortcutLabel }
                #expect(labels.count == ids.count, "\(row.id): every act it cites declares an alternate")
                #expect(row.tokens == labels)
            case .system(let id):
                let label = CapabilityRegistry.capability(id).systemShortcutLabel
                #expect(label != nil && row.tokens == [label ?? ""], "\(row.id): the system chord")
            case .menu(let menu, let id):
                let capability = CapabilityRegistry.capability(id)
                #expect(row.tokens == ["\(menu) \u{25B8} \(capability.verb)"], "\(row.id): the verb")
                #expect(capability.doors.contains(.menuBar), "\(row.id): a menu path names a menu door")
                #expect(capability.shortcutLabel == nil, "\(row.id): a keyed act shows its key instead")
            case .gesture(let tokens, _):
                #expect(!tokens.isEmpty, "\(row.id): a gesture says its keys")
            }
            #expect(!row.words.isEmpty && !row.tokens.isEmpty, "\(row.id)")
        }
    }

    /// **Every chord the registry declares is SHOWN by a row naming its act**
    /// — the ID-level twin of the old string guard: an in-app chord by a
    /// `.chords` row, an alternate by an `.alternates` row, a system chord by
    /// a `.system` row.
    @Test func everyDeclaredChordIsShownByARowNamingItsAct() {
        var chordActs = Set<CapabilityID>()
        var alternateActs = Set<CapabilityID>()
        var systemActs = Set<CapabilityID>()
        for row in ShortcutCatalog.rows {
            switch row.keys {
            case .chords(let ids): chordActs.formUnion(ids)
            case .alternates(let ids): alternateActs.formUnion(ids)
            case .system(let id): systemActs.insert(id)
            case .menu, .gesture: break
            }
        }
        for capability in CapabilityRegistry.all {
            if capability.shortcutLabel != nil {
                #expect(chordActs.contains(capability.id),
                        "\(capability.id) declares \(capability.shortcutLabel ?? "") — a row must show it")
            }
            if capability.alternateShortcutLabel != nil {
                #expect(alternateActs.contains(capability.id), "\(capability.id)'s alternate")
            }
            if capability.systemShortcutLabel != nil {
                #expect(systemActs.contains(capability.id), "\(capability.id)'s system chord")
            }
        }
    }

    /// **No gesture re-types a declared chord** — a key some act declares
    /// is read from it (a `.chords` row), never spelled by hand again.
    @Test func noGestureRetypesADeclaredChord() {
        var declared = Set<String>()
        for capability in CapabilityRegistry.all {
            for label in [
                capability.shortcutLabel, capability.alternateShortcutLabel,
                capability.systemShortcutLabel,
            ] {
                if let label { declared.insert(label) }
            }
        }
        for row in ShortcutCatalog.rows {
            guard case .gesture(let tokens, _) = row.keys else { continue }
            for token in tokens {
                #expect(!declared.contains(token), "\(row.id): \(token) is a declared chord — read it")
            }
        }
    }

    /// **The headings are declared once, in order** (PROVISIONAL P-572-1):
    /// her nine titles, each with ONE line of what it holds, every group
    /// holding rows, and the rows filed group by group in that order.
    @Test func theHeadingsAreHerNineInTheirDeclaredOrderEachWithItsLine() {
        let titles = Group.allCases.map(\.title)
        #expect(titles == [
            "Writing", "Formatting", "Structure", "Takes", "Find in a note",
            "Navigation", "Windows & panes", "The note's bars", "MCP",
        ])
        for group in Group.allCases {
            let count = ShortcutCatalog.rows(in: group).count
            #expect(count > 0, "\(group.title) holds rows")
            #expect(!group.line.isEmpty && !group.line.contains("\n"), "\(group.title): one line")
        }
        let order = ShortcutCatalog.rows.map(\.group)
        let sorted = order.sorted {
            Group.allCases.firstIndex(of: $0)! < Group.allCases.firstIndex(of: $1)!
        }
        #expect(order == sorted, "filed group by group, in the declared order")
        let ids = ShortcutCatalog.rows.map(\.id)
        #expect(Set(ids).count == ids.count, "row ids are unique")
    }

    // MARK: - The filter (RED on rev572)

    /// **At rest every heading shows and every group is FOLDED** — her
    /// "default to not being expanded".
    @Test func atRestEveryHeadingShowsAndEveryGroupIsFolded() {
        let sections = ShortcutCatalogFilter.sections(query: "", expanded: [])
        #expect(sections.map(\.group) == Group.allCases)
        let open = sections.filter(\.isExpanded).map(\.group)
        #expect(open.isEmpty, "nothing open at rest: \(open)")
        let searching = sections.filter(\.isSearching).count
        #expect(searching == 0)
        let total = sections.map(\.total).reduce(0, +)
        #expect(total == ShortcutCatalog.rows.count)
    }

    /// A group she opens shows ALL its rows — and only that group opens.
    @Test func aGroupSheOpensShowsAllItsRowsAndOnlyThatGroup() {
        let sections = ShortcutCatalogFilter.sections(query: "", expanded: [.takes])
        let open = sections.filter(\.isExpanded).map(\.group)
        #expect(open == [.takes])
        let takes = sections.first { $0.group == .takes }
        let shown = takes?.rows.count
        let all = ShortcutCatalog.rows(in: .takes).count
        #expect(shown == all)
    }

    /// **A word search shows only the matching rows, each group it touches
    /// OPEN, the rest hidden** — case- and accent-blind, terms ANDed, the
    /// registry's verbs searched too.
    @Test func aWordSearchShowsOnlyMatchingRowsInOpenGroups() {
        // Her own word for outdent (13u4 S1) — one row says it.
        let unindent = ShortcutCatalogFilter.sections(query: "unindent", expanded: [])
        let unindentKeys = Self.keyTexts(unindent)
        #expect(unindentKeys == ["\u{2318}] / \u{2318}["], "\(unindentKeys)")
        let unindentGroups = unindent.map(\.group)
        #expect(unindentGroups == [.formatting])
        let allOpen = unindent.allSatisfy { $0.isExpanded && $0.isSearching }
        #expect(allOpen, "the search opens the group it matches")
        let ofTotal = unindent.first.map(ShortcutsCopy.count)
        let formattingTotal = ShortcutCatalog.rows(in: .formatting).count
        #expect(ofTotal == "1 of \(formattingTotal)")

        // The registry's verb reaches a row whose words don't say it twice;
        // case and accents fold.
        for query in ["callout", "CALLOUT", "call\u{F3}ut"] {
            let hits = Self.keyTexts(ShortcutCatalogFilter.sections(query: query, expanded: []))
            #expect(hits.contains("\u{2325}\u{2318}C"), "\(query) finds \u{2325}\u{2318}C: \(hits)")
        }

        // Terms are ANDed across the row.
        let next = ShortcutCatalogFilter.sections(query: "next match", expanded: [])
        let nextKeys = Self.keyTexts(next)
        #expect(nextKeys == ["\u{2318}G / \u{21E7}\u{2318}G"], "\(nextKeys)")

        // Every row shown carries every term; a group it doesn't touch hides.
        let merge = ShortcutCatalogFilter.sections(query: "merge", expanded: [])
        let mergeRows = Self.rows(merge)
        let everyHit = mergeRows.allSatisfy { ShortcutCatalogFilter.matches($0, terms: ["merge"]) }
        #expect(everyHit && !mergeRows.isEmpty)
        let mergeGroups = Set(merge.map(\.group))
        #expect(mergeGroups.contains(.structure) && !mergeGroups.contains(.find),
                "\(mergeGroups)")
    }

    /// A heading's own title finds its whole group ("formatting").
    @Test func aHeadingsTitleFindsItsWholeGroup() {
        let sections = ShortcutCatalogFilter.sections(query: "formatting", expanded: [])
        let formatting = sections.first { $0.group == .formatting }
        let shown = formatting?.rows.count
        let all = ShortcutCatalog.rows(in: .formatting).count
        #expect(shown == all)
    }

    /// **A chord by name** (PROVISIONAL P-572-3): "cmd shift d" is the
    /// divide's ⌘⇧D and NOT the ceremony's ⌥⌘⇧D; a pasted glyph chord
    /// reads the same; a digit falls in a span; modifiers alone list every
    /// chord carrying them; a capture box's ⇧⏎ answers "shift return".
    @Test func aChordSearchFindsTheChordByItsModifiersAndKey() {
        let divide = Self.keyTexts(ShortcutCatalogFilter.sections(query: "cmd shift d", expanded: []))
        #expect(divide == ["\u{2318}\u{21E7}D"], "\(divide)")
        let ceremony = Self.keyTexts(ShortcutCatalogFilter.sections(query: "opt cmd shift d", expanded: []))
        #expect(ceremony == ["\u{2325}\u{2318}\u{21E7}D"], "\(ceremony)")
        let pasted = Self.keyTexts(ShortcutCatalogFilter.sections(query: "\u{21E7}\u{2318}D", expanded: []))
        #expect(pasted == ["\u{2318}\u{21E7}D"], "a label's modifier order never matters: \(pasted)")
        let plus = Self.keyTexts(ShortcutCatalogFilter.sections(query: "cmd+shift+d", expanded: []))
        #expect(plus == ["\u{2318}\u{21E7}D"], "\(plus)")
        let previous = Self.keyTexts(ShortcutCatalogFilter.sections(query: "shift cmd g", expanded: []))
        #expect(previous == ["\u{2318}G / \u{21E7}\u{2318}G"], "\(previous)")
        let third = Self.keyTexts(ShortcutCatalogFilter.sections(query: "cmd shift 3", expanded: []))
        #expect(third == ["\u{2318}\u{21E7}1\u{2013}9"], "⌘⇧3 is in the Open list's span: \(third)")
        let system = Self.keyTexts(ShortcutCatalogFilter.sections(query: "ctrl opt cmd n", expanded: []))
        #expect(system == ["\u{2303}\u{2325}\u{2318}N"], "\(system)")
        let capture = Self.keyTexts(ShortcutCatalogFilter.sections(query: "shift return", expanded: []))
        #expect(capture == ["\u{23CE} / \u{21E7}\u{23CE}"], "\(capture)")

        let optCmd = Self.rows(ShortcutCatalogFilter.sections(query: "opt cmd", expanded: []))
        let everyOne = optCmd.allSatisfy { row in
            row.tokens.contains { token in
                let chord = ShortcutChord.token(token)
                return chord.modifiers.isSuperset(of: ["\u{2325}", "\u{2318}"])
            }
        }
        #expect(everyOne && optCmd.count > 5, "modifiers alone list every chord carrying them")
    }

    /// A query that matches nothing shows no section at all (the tab then
    /// says so).
    @Test func aSearchThatMatchesNothingShowsNoGroup() {
        let none = ShortcutCatalogFilter.sections(query: "zzqx", expanded: [.takes])
        #expect(none.isEmpty)
    }

    /// **A heading folded while searching folds for THAT query only** — a
    /// new query opens it again, and her own folding at rest is never
    /// touched by a search.
    @MainActor
    @Test func aHeadingFoldedWhileSearchingFoldsForThatQueryOnly() {
        let model = ShortcutsTabModel()
        model.toggle(.writing)
        let herOpen = model.expanded
        #expect(herOpen == [.writing], "her own opening, at rest")

        model.setQuery("take")
        let before = model.sections.first { $0.group == .takes }?.isExpanded
        #expect(before == true, "the search opens what it matches")
        model.toggle(.takes)
        let folded = model.sections.first { $0.group == .takes }?.isExpanded
        #expect(folded == false, "she folds it for this query")
        let herStill = model.expanded
        #expect(herStill == [.writing], "a search's fold never touches hers")

        model.setQuery("takes")
        let reopened = model.sections.first { $0.group == .takes }?.isExpanded
        #expect(reopened == true, "a new query opens it again")

        model.setQuery("")
        let rest = model.sections.filter(\.isExpanded).map(\.group)
        #expect(rest == [.writing], "back at rest: exactly what she had opened")
    }

    // MARK: - The chord reader (GUARDS — new capability)

    @Test func theChordReaderReadsLabelsAndQueries() {
        let label = ShortcutChord.token("\u{21E7}\u{2325}\u{2318}T")
        #expect(label == ShortcutChord(modifiers: ["\u{21E7}", "\u{2325}", "\u{2318}"], key: "T"))
        let tab = ShortcutChord.token("\u{21E7}Tab")
        #expect(tab == ShortcutChord(modifiers: ["\u{21E7}"], key: "TAB"))
        let prose = ShortcutChord.token("Format \u{25B8} Strikethrough")
        #expect(prose.modifiers.isEmpty, "a menu path carries no modifier")

        let typed = ShortcutChord.query("cmd shift d")
        #expect(typed == ShortcutChord(modifiers: ["\u{2318}", "\u{21E7}"], key: "D"))
        let named = ShortcutChord.query("control escape")
        #expect(named == ShortcutChord(modifiers: ["\u{2303}"], key: "\u{238B}"))
        let modsOnly = ShortcutChord.query("cmd")
        #expect(modsOnly == ShortcutChord(modifiers: ["\u{2318}"], key: nil))
        // Not chords: a lone key, a word, two keys — these are word searches.
        let lone = ShortcutChord.query("d")
        let word = ShortcutChord.query("right click")
        let twoKeys = ShortcutChord.query("cmd d e")
        #expect(lone == nil && word == nil && twoKeys == nil)
        let span = ShortcutChord.span("1\u{2013}9", contains: "3")
        let outside = ShortcutChord.span("1\u{2013}7", contains: "8")
        #expect(span && !outside)
    }
}
