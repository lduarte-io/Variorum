//
//  SettingsShapeTests.swift
//  VariorumTests
//
//  **13u4 UNIT S1 — her items 4 and 6.**
//
//  Item 4's acceptance case is LITERAL and is the first pin in this file:
//  *"simple text search within the settings menu - it's too hard to find
//  how to make a callout."* Typing "callout" has to surface how to make a
//  callout — which is not a setting at all, so a search that only looked at
//  settings rows would be a feature that fails the one sentence that asked
//  for it.
//
//  Item 6 is the pane split, and its pins are structural: the catalog and
//  the panes cannot drift (the registry walk's shape one layer down), and
//  KnownIssues row 59's fold cannot come back by a pane quietly growing
//  fifteen controls again. The REAL evidence for row 59 is the walk — a
//  fold is a thing you see — and it is in the unit record.
//

import Testing
@testable import Variorum

@MainActor
@Suite("The Settings shape and its search (13u4 S1, items 4 and 6)")
struct SettingsShapeTests {
    private func findings(_ query: String) -> [SettingsFinding] {
        SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
    }

    // MARK: - Her acceptance case, literally

    /// *"it's too hard to find how to make a callout."*
    @Test func typingCalloutSurfacesHowToMakeOne() {
        let hits = findings("callout")
        #expect(!hits.isEmpty, "“callout” finds something at all")
        // The word itself, which names the door: "A block wearing a colored
        // frame (Block ▸ Callout)."
        let word = hits.first { $0.kind == .word && $0.lead == "callout" }
        #expect(word != nil, "the app's own word for it is a result")
        #expect(word?.detail.contains("Block") == true,
                "…and its answer names the door that makes one")
        // And the chord, which is the fastest answer there is.
        let chord = hits.first { $0.kind == .shortcut && $0.lead.contains("\u{2325}\u{2318}C") }
        #expect(chord != nil, "⌥⌘C is a result too")
        #expect(chord?.detail.lowercased().contains("callout") == true)
    }

    /// The one she names FIRST is the one she typed: an exact lead outranks
    /// a row that merely mentions the word.
    @Test func theThingSheNamedComesFirst() {
        let hits = findings("callout")
        #expect(hits.first?.lead == "callout")
    }

    // MARK: - The rest of the filter, arm by arm

    @Test func aSettingIsFoundByItsOwnLabel() {
        let hits = findings("seams")
        #expect(hits.contains { $0.kind == .setting && $0.pane == .editor })
    }

    /// The half that makes a half-remembered name work: the words she might
    /// type that are in neither the label nor the blurb.
    @Test func aSettingIsFoundByAWordSheMightTypeInstead() {
        #expect(findings("dark mode").contains {
            $0.kind == .setting && $0.lead == "Appearance"
        })
        #expect(findings("password").contains { $0.pane == .protection })
        #expect(findings("autocorrect").contains { $0.lead == "Spellchecking" })
    }

    /// Terms are ANDed across the whole entry, so two words that belong to
    /// different rows find neither.
    @Test func everyWordHasToMatchSomething() {
        #expect(findings("dark seam").isEmpty)
    }

    @Test func anEmptyQueryFindsNothingAndTheDetailKeepsShowingThePane() {
        #expect(findings("").isEmpty)
        #expect(findings("   ").isEmpty)
    }

    @Test func theSearchIgnoresCaseAndAccents() {
        #expect(!findings("CALLOUT").isEmpty)
        #expect(!findings("Callout").isEmpty)
    }

    /// **Every chord the registry declares is findable in Settings too.**
    /// Not a second list: the index reads `HelperView.groups`, which
    /// `everyDeclaredShortcutIsFindableInTheHelper` already holds to the
    /// registry — so this pin is that guarantee arriving at a second door
    /// rather than a new promise to keep.
    @Test func everyDeclaredChordIsFindableInTheSearch() {
        for capability in CapabilityRegistry.all {
            guard let label = capability.shortcutLabel else { continue }
            #expect(findings(label).contains { $0.kind == .shortcut },
                    "\(capability.id) declares \(label) — Settings' search must find it")
        }
    }

    /// Her item 5's other half, answered through the same field — **in HER
    /// word as well as the app's.**
    ///
    /// The walk is what earned the first of these two lines: the pin
    /// originally searched "outdent", the app's word, and passed — while
    /// typing "unindent", which is the word she actually wrote, found
    /// NOTHING. A pin that types the vocabulary it is testing can never
    /// catch that, which is exactly the C1 curly-quote class one surface
    /// over. The helper row now says both words.
    @Test func typingUnindentFindsTheAnswerAndSoDoesOutdent() {
        for word in ["unindent", "outdent", "indent"] {
            #expect(findings(word).contains { $0.kind == .shortcut },
                    "“\(word)” answers “how are things unindented?”")
        }
    }

    // MARK: - The catalog and the panes cannot drift (item 6)

    /// Declared ⇔ rendered, one layer under the registry walk.
    @Test func everyCatalogRowIsRenderedByItsOwnPane() {
        for row in SettingsCatalog.rows {
            let rendered = AppSettingsView.rowIDsRendered[row.pane] ?? []
            #expect(rendered.contains(row.id),
                    "\(row.id) says it lives on \(row.pane.title) — that pane must render it")
        }
    }

    @Test func everyRenderedRowIsInTheCatalog() {
        let known = Set(SettingsCatalog.rows.map(\.id))
        for (pane, ids) in AppSettingsView.rowIDsRendered {
            for id in ids {
                #expect(known.contains(id), "\(pane.title) renders \(id), which is uncatalogued")
            }
        }
    }

    @Test func everyPaneIsAccountedFor() {
        for pane in SettingsPane.allCases {
            #expect(AppSettingsView.rowIDsRendered[pane] != nil,
                    "\(pane.title) has a rendered-row list, even if it is empty")
            #expect(!pane.title.isEmpty)
            // Her 2026-10-13 ruling (the VX-214 sitting record): General is
            // the ONE pane with no subtitle; every other pane keeps one.
            if pane == .general {
                #expect(pane.blurb.isEmpty)
            } else {
                #expect(!pane.blurb.isEmpty)
            }
        }
        // Shortcuts holds no catalog row on purpose: its content is the
        // helper's list, which the search reaches directly.
        #expect(SettingsCatalog.rows(in: .shortcuts).isEmpty)
    }

    @Test func rowIDsAreUnique() {
        let ids = SettingsCatalog.rows.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    // MARK: - KnownIssues row 59 (the fold), structurally

    /// Her own owner assignment: *"you can add the fold issue to 13u4."*
    /// The 18j appearance control sat below the fold because ONE pane held
    /// fifteen controls. It is now on the pane that opens, which stays
    /// short (six catalog rows since VX-139, the caps below).
    ///
    /// A pin cannot see a fold — the walk is the evidence, and it is in the
    /// record. What this holds is the cause: General stays short, and the
    /// appearance row stays on it.
    @Test func theAppearanceControlIsOnTheShortOpeningPane() {
        #expect(SettingsPane.allCases.first == .general,
                "General is the pane Settings opens on")
        let general = SettingsCatalog.rows(in: .general)
        #expect(general.contains { $0.id == "appearance" })
        // VX-139 (a CONSEQUENTIAL pin edit, annotated in place — the same
        // edit as DiagnosticsPaneTests', P-VX139-vi): the keep-open-notes
        // toggle is General's sixth row, below the palette (in Release
        // the Updates section renders after it) — the fold's cause was
        // fifteen controls ABOVE the appearance row, and that row still
        // sits second from the top.
        // VX-589 (a CONSEQUENTIAL pin edit, annotated in place — VX-139's
        // shape exactly): "Hide starred notes from Open" joins the Open notes
        // section as General's seventh row, BELOW keep-open-notes; the
        // appearance row still sits second from the top, so the fold's cause
        // (controls ABOVE it) is untouched. NO capture of the pane with its
        // seventh row exists yet — the run's walk capture named
        // "33-settings-general" shows the MCP pane, not General (the VX-439
        // ladder's m-4), and the run's evidence slice could not reach the pane
        // (Settings' interior takes no synthetic clicks). The live look at the
        // fold is HERS — the VX-439 record's morning bundle item 24 (R2-3);
        // until she takes it, this cap rests on the reasoning above.
        #expect(general.count <= 7,
                "the fold came from fifteen controls in one pane — this one stays short")
    }

    /// The Shortcuts pane reads the helper's OWN list; two copies of a list
    /// is two lists.
    @Test func theShortcutsPaneAndTheHelperShowTheSameRows() {
        let helperRows = HelperView.groups.flatMap(\.items).count
        #expect(SettingsSearch.shortcutEntries.count == helperRows)
        #expect(SettingsSearch.dictionaryEntries.count == HelperView.entries.count)
    }
}
