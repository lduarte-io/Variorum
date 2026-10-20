//
//  SettingsAccountSurfaceTests.swift
//  VariorumTests
//
//  VX-309 U2 piece 10 — RIDER VX-453, the road half (`SettingsAccountSearchTests` is the search half). The account section
//  renders only on the new road (`ProtectionPane`: `roadStanding?.account`), so its catalog row joins only there: the
//  catalog, the rendered map and the search's index each take the road, and today's road — Release included — keeps its
//  catalog byte for byte (no row the pane does not show — P-1's declared ⇔ rendered, one layer down). At runtime the
//  results pane asks the index for the road the window is on (the section's presence), so a Debug build over the real
//  store's variant (today's road) never names it either. Mac only (it reads `AppSettingsView` and the faces' sources).
//  New API (`rows(newRoad:)`, `rowIDsRendered(newRoad:)`, `wholeIndex(newRoad:)`): red by construction on the old tree.
//

import Foundation
import Testing

@testable import Variorum

@MainActor
@Suite("VX-453 — the account section's row joins only on the new road")
struct SettingsAccountSurfaceTests {
    @Test func todaysRoadKeepsTodaysCatalogAndTheNewRoadAddsOneRow() throws {
        let today = SettingsCatalog.rows(newRoad: false)
        let newRoad = SettingsCatalog.rows(newRoad: true)
        #expect(!today.contains { $0.id == "account" }, "today's road names no section it does not render")
        #expect(newRoad.filter { $0.id != "account" } == today, "the new road adds ONE row and changes none")
        let row = try #require(newRoad.first { $0.id == "account" })
        #expect(row.pane == .protection && row.title == ProtectionWords.accountSectionTitle,
                "the section's own title — one text, the face's and the search's")
        let protection = newRoad.filter { $0.pane == .protection }.map(\.id)
        #expect(protection == ["protection", "account"], "beside the pane's own row")
        #expect(SettingsCatalog.rows == SettingsCatalog.rows(newRoad: ProtectionRoad.newRoadIsLive), "the build's catalog")
        #expect(SettingsSearch.findings(matching: "account", in: SettingsSearch.wholeIndex(newRoad: false)).isEmpty,
                "today's road answers as before")
    }

    @Test func theRowIsRenderedWhereItIsDeclared() {
        #expect(AppSettingsView.rowIDsRendered(newRoad: true)[.protection] == ["protection", "account"])
        #expect(AppSettingsView.rowIDsRendered(newRoad: false)[.protection] == ["protection"])
        #expect(AppSettingsView.rowIDsRendered == AppSettingsView.rowIDsRendered(newRoad: ProtectionRoad.newRoadIsLive))
        for newRoad in [false, true] {
            let declared = Set(SettingsCatalog.rows(newRoad: newRoad).map(\.id))
            let rendered = Set(AppSettingsView.rowIDsRendered(newRoad: newRoad).values.flatMap { $0 })
            #expect(declared == rendered, "declared ⇔ rendered on \(newRoad ? "the new road" : "today's road")")
        }
    }

    /// The faces, by source: the results pane asks the index for the window's road (the section's presence), and the
    /// section renders its title from the one constant the row carries.
    @Test func theResultsPaneAsksForTheWindowsRoad() throws {
        let features = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features")
        let view = try String(contentsOf: features.appendingPathComponent("Settings/AppSettingsView.swift"), encoding: .utf8)
        #expect(view.contains("SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex(newRoad: newRoad))"))
        #expect(view.contains("newRoad: roadStanding?.account != nil"))
        let section = try String(contentsOf: features.appendingPathComponent("Protection/RoadAccountSheet.swift"),
                                 encoding: .utf8)
        #expect(section.contains("Section(ProtectionWords.accountSectionTitle)"))
    }
}
