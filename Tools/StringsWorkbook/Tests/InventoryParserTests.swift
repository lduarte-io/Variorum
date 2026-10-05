// BRANCH-ONLY tests (`tools/strings-workbook`; never merges).

import Foundation
import Testing
@testable import StringsWorkbook

@Suite("StringsWorkbook — the inventory parser against the real 2026-10-04 compile")
struct InventoryParserTests {
    @Test func everySurfaceMatchesItsFooterAndTheTotalIs3630() {
        let inventory = RealDocs.inventory
        #expect(inventory.surfaces.count == 37)
        #expect(inventory.bulletCount == 3630)
        #expect(inventory.declaredTotal == 3630)
        for surface in inventory.surfaces {
            #expect(surface.bullets.count == surface.footerCount, "\(surface.name)")
        }
    }

    @Test func surfacesAreTheHeadingsInDocOrderWithSettingsSplitIntoItsPanes() {
        let names = RealDocs.inventory.surfaces.map(\.name)
        #expect(names.first == "Onboarding, first run & the locked lobby")
        #expect(names.last == "Anything else user-visible")
        #expect(!names.contains("Settings panes"))  // a container heading, not a surface
        #expect(!names.contains("Totals"))
        #expect(!names.contains("Sweep notes"))
        let settings = names.filter { $0.hasPrefix("Settings — ") }
        #expect(settings == [
            "Settings — window chrome, pane list & search", "Settings — General", "Settings — Editor",
            "Settings — Takes", "Settings — Writing", "Settings — Shortcuts", "Settings — Tags",
            "Settings — Protection", "Settings — Data Safety", "Settings — Acknowledgments",
        ])
        #expect(RealDocs.inventory.surfaces.first { $0.name == "Settings — Protection" }?.bullets.count == 2)
    }

    @Test func aMultiSiteBulletStaysOneBulletWithEverySite() throws {
        let cancel = try #require(RealDocs.bullet(firstSite: "App/Variorum/Shared/AuthViews.swift:255"))
        #expect(cancel.current == "Cancel")
        #expect(cancel.sites.count == 21)
        let passphrase = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/StoreFailureView.swift:83"))
        #expect(passphrase.current == "Encryption passphrase")
        #expect(passphrase.sites == [
            "App/Variorum/Variorum/StoreFailureView.swift:83",
            "App/Variorum/Variorum/StoreLockView.swift:196",
        ])
        #expect(passphrase.ruled == .ruled)
        // Every bullet's site count: 3,621 literals carry ≥ 1; the seeded
        // documents each carry their own locators.
        #expect(RealDocs.bullets.allSatisfy { !$0.sites.isEmpty })
    }

    @Test func tagsParseExactly() throws {
        let unlock = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/StoreFailureView.swift:87"))
        #expect(unlock.current == "Unlock")
        #expect(unlock.ruled == .provisional)
        #expect(unlock.tags.isEmpty)
        let skips = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Library/RecoveryView.swift:976"))
        #expect(skips.tags == ["(tooltip)", "(templated)"])
        #expect(skips.ruled == nil)
        // The doc's tag census (the survey, 2026-10-05): 95 §11-provisional,
        // 252 plain-ruled literals, 1 ruled seeded document group of 3.
        let literals = RealDocs.bullets.filter { $0.kind == .literal }
        #expect(literals.filter { $0.ruled == .provisional }.count == 95)
        #expect(literals.filter { $0.ruled == .ruled }.count == 252)
        #expect(literals.filter { $0.tags.contains("(templated)") }.count == 771)
        #expect(literals.filter { $0.tags.contains("(tooltip)") }.count == 219)
    }

    @Test func swiftEscapesRenderAndInterpolationsStayVerbatim() throws {
        let delete = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift:557"))
        #expect(delete.docBody == #"Delete \(selectedPosts.count) notes\u{2026}"#)
        #expect(delete.current == #"Delete \(selectedPosts.count) notes…"#)
        let comment = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Editor/CommentsPanel.swift:344"))
        #expect(comment.current == "Comment deleted — it is under \"deleted\" below, restorable.")
        let diff = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Takes/DiffView.swift:93"))
        #expect(diff.current == #"diff — \(leftTitle) → \(rightTitle)"# + "\n")
        // No rendered literal keeps a \u{…} escape.
        #expect(!RealDocs.bullets.contains { $0.current.contains(#"\u{"#) })
    }

    @Test func aLiteralHoldingABacktickParsesFromItsDoubleBacktickSpan() throws {
        // Two literals share each of these source lines; the lookup refuses
        // the ambiguity, so the body fragment picks the one under test.
        #expect(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Help/HelperView.swift:118") == nil)
        let code = try #require(RealDocs.bullet(
            firstSite: "App/Variorum/Variorum/Features/Help/HelperView.swift:118", containing: "`"))
        #expect(code.current == "`like this`")
        let format = try #require(RealDocs.bullet(
            firstSite: "App/Variorum/Variorum/Features/Help/HelperView.swift:131", containing: "`"))
        #expect(format.current.hasPrefix("B · I · S · ` · link"))
    }

    // MARK: - The ⏎ finding (F-1)

    @Test func returnGlyphsStayGlyphsAndOnlyTrueMultiLineLiteralsBreakLines() throws {
        let corrected = RealDocs.bullets.filter(\.correctedFromSource)
        #expect(corrected.count == 25)
        #expect(corrected.count == ReturnGlyphCorrections.all.count)
        #expect(Set(corrected.map { $0.sites[0] }) == Set(ReturnGlyphCorrections.all.map(\.site)))
        // Every ⏎-bearing doc body was corrected — none fell to a guess.
        #expect(RealDocs.bullets.filter { $0.kind == .literal && $0.docBody.contains("⏎") }.count == 25)

        // The Return glyph, in a single-line literal: no line break, glyph kept.
        let makes = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Tags/NoteTagChips.swift:357"))
        #expect(makes.current == "No tags yet — type one and ⏎ makes it.")
        // The leading glyph the sweep dropped is back.
        let quick = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:547"))
        #expect(quick.docBody == "files it · ⇧ ⏎ new paragraph · closing files it too")
        #expect(quick.current == "⏎ files it · ⇧⏎ new paragraph · closing files it too")
        // The sweep's padding inside a chord is undone.
        let below = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Editor/CommitBar.swift:691"))
        #expect(below.current == "＋ New block below this one (⌘⇧⏎)")

        // A true """ literal: real line breaks (I4 — content), and in the
        // second one two Return glyphs survive among the three breaks.
        let bip = try #require(RealDocs.bullet(firstSite: "App/Variorum/Shared/AcknowledgmentsCopy.swift:149"))
        #expect(bip.current.components(separatedBy: "\n").count == 4)
        #expect(!bip.current.contains("⏎"))
        let summary = try #require(RealDocs.bullet(firstSite: "App/Variorum/Variorum/Features/Help/HelperView.swift:494"))
        #expect(summary.current == """
            ⌘⇧T open/close takes · ⎋ close all
            ⌘T new take · ⌥⌘T blank · ⇧⌥⌘T blank & choose
            ⌘⏎ choose · ⌃⌘←/→ step takes · ⌘⇧A archive
            ⌘⇧L save as lens · ⌘S commit (⏎ saves it unnamed) · ⌘/ full list
            """)
        // Exactly those two literals carry line breaks among the corrected.
        #expect(corrected.filter { $0.current.contains("\n") }.map { $0.sites[0] }.sorted() == [
            "App/Variorum/Shared/AcknowledgmentsCopy.swift:149",
            "App/Variorum/Variorum/Features/Help/HelperView.swift:494",
        ])
    }

    @Test func everyCorrectionReproducesTheInventoryTextExactly() {
        // Keyed off the corrected bullets themselves (a first site can be
        // shared by two literals on one source line).
        for bullet in RealDocs.bullets where bullet.correctedFromSource {
            let entry = ReturnGlyphCorrections.entry(forSite: bullet.sites[0])
            #expect(entry.map(ReturnGlyphCorrections.inventoryForm(of:)) == bullet.docBody, "\(bullet.sites[0])")
        }
        #expect(Set(ReturnGlyphCorrections.all.map(\.site)).count == ReturnGlyphCorrections.all.count)
    }

    // MARK: - Seeded content

    @Test func seededDocumentsAreSevenBlocksWithTheirSubBulletsAndLocators() throws {
        let seeded = try #require(RealDocs.inventory.surfaces.first { $0.name == "Seeded content" })
        #expect(seeded.bullets.count == 7)
        #expect(seeded.bullets.allSatisfy { $0.kind == .document && $0.tags == ["(seeded document)"] })
        let guide = seeded.bullets[0]
        #expect(guide.current.hasPrefix("**The tutorial book** — title `\"the field guide\"`"))
        // The ten indented sub-bullets ride inside the first block.
        #expect(guide.current.components(separatedBy: "\n").count == 12)
        #expect(guide.current.contains("- chapter `\"deleting & getting it back\"`"))
        #expect(guide.current.contains("`\"archive · delete · scraps\"`"))  // \u{B7} rendered
        #expect(guide.sites.first == "App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift:39")
        #expect(guide.sites.contains("App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift:323"))  // `:323` shorthand
        #expect(guide.ruled == .ruled)
        let sherlock = seeded.bullets[1]
        #expect(sherlock.sites.contains("App/Variorum/Shared/SampleLibrary/SampleLibrarySeeder.swift:214"))
        #expect(sherlock.sites.contains("App/Variorum/Shared/SampleLibrary/SherlockAdventures.txt"))
        #expect(sherlock.ruled == nil)
        #expect(seeded.bullets.filter { $0.ruled == .ruled }.count == 2)  // the guide, Encryption Explained
    }

    // MARK: - Strictness (synthetic docs)

    static func doc(_ body: String, footer: Int, total: Int) -> String {
        """
        # header

        prose before any surface

        ## Alpha

        \(body)

        — \(footer) strings

        ## Totals

        | **All groups** | **\(total)** |

        ## Sweep notes

        - `"not a string"` — `x/y.swift:1`
        """
    }

    @Test func aSyntheticDocParsesAndStopsAtTotals() throws {
        let inventory = try StringsInventory.parse(Self.doc(
            #"- `"Hello \u{2014} \(name)"` — `a/B.swift:3`, `a/C.swift:9` (templated) ⚠RULED"#,
            footer: 1, total: 1))
        #expect(inventory.surfaces.map(\.name) == ["Alpha"])
        let bullet = try #require(inventory.surfaces.first?.bullets.first)
        #expect(bullet.current == #"Hello — \(name)"#)
        #expect(bullet.sites == ["a/B.swift:3", "a/C.swift:9"])
        #expect(bullet.tags == ["(templated)"])
        #expect(bullet.ruled == .ruled)
        #expect(inventory.declaredTotal == 1)
    }

    @Test func anUnknownTagRefuses() {
        #expect(throws: StringsInventory.ParseError.self) {
            _ = try StringsInventory.parse(Self.doc(#"- `"Hi"` — `a/B.swift:3` (mystery)"#, footer: 1, total: 1))
        }
    }

    @Test func aNonSiteLocatorRefuses() {
        #expect(throws: StringsInventory.ParseError.self) {
            _ = try StringsInventory.parse(Self.doc(#"- `"Hi"` — `somewhere`"#, footer: 1, total: 1))
        }
    }

    @Test func aReturnGlyphWithNoVerifiedCorrectionRefusesRatherThanGuessing() {
        #expect(throws: StringsInventory.ParseError.unresolvedReturnGlyph(line: 7, site: "a/B.swift:3")) {
            _ = try StringsInventory.parse(Self.doc(#"- `"press ⏎ now"` — `a/B.swift:3`"#, footer: 1, total: 1))
        }
    }

    @Test func aCorrectionThatNoLongerMatchesTheDocRefuses() {
        // A real corrected site, but the doc's text changed under it.
        let site = "App/Variorum/Variorum/Features/Tags/NoteTagChips.swift:357"
        #expect(throws: StringsInventory.ParseError.returnGlyphCorrectionMismatch(line: 7, site: site)) {
            _ = try StringsInventory.parse(Self.doc(
                "- `\"No tags — ⏎ makes it.\"` — `\(site)`", footer: 1, total: 1))
        }
    }

    @Test func anUnknownEscapeRefuses() {
        #expect(throws: StringsInventory.ParseError.self) {
            _ = try StringsInventory.parse(Self.doc(#"- `"bad \q escape"` — `a/B.swift:3`"#, footer: 1, total: 1))
        }
    }
}

@Suite("StringsWorkbook — the Swift-escape renderer")
struct SwiftLiteralTextTests {
    @Test func rendersEveryKnownEscape() throws {
        #expect(try SwiftLiteralText.render(#"a\u{2014}b\u{1F600}"#) == "a—b😀")
        #expect(try SwiftLiteralText.render(#"\"q\" \'s\' back\\slash"#) == "\"q\" 's' back\\slash")
        #expect(try SwiftLiteralText.render(#"x\ny\tz"#) == "x\ny\tz")
    }

    @Test func interpolationsStayVerbatimIncludingNestedParensAndStrings() throws {
        let body = #"Tagged \(n - f) of \(n) — \(f) refused (\(last ?? "a note (may) be gone"))."#
        #expect(try SwiftLiteralText.render(body) == body)
        #expect(try SwiftLiteralText.render(#"\(String(describing: error))\u{2026}"#)
                == #"\(String(describing: error))…"#)
    }

    @Test func malformedEscapesRefuse() {
        #expect(throws: SwiftLiteralText.RenderError.self) { try SwiftLiteralText.render(#"\u{ZZ}"#) }
        #expect(throws: SwiftLiteralText.RenderError.self) { try SwiftLiteralText.render(#"\(open"#) }
        #expect(throws: SwiftLiteralText.RenderError.self) { try SwiftLiteralText.render(#"trailing\"#) }
    }
}
