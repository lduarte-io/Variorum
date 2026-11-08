//
//  MCPPaneStampsTickTests.swift
//  VariorumTests (Mac)
//
//  VX-401 (the VX-914 run, batch 1 — rider; born at VX-348 U5's live round,
//  the record `notes/plans/fixes/vx-348-prelaunch-sweep.md`): Settings ▸ MCP's
//  relative stamps RECOMPUTE. `MCPActivityRowView` rendered
//  `MCPPane.relative(line.at)` once against `Date()` with no `TimelineView`, so
//  "39 seconds ago" stuck until the next activity line landed (it misread as a
//  stale list during the round); the request's first-seen and the client's
//  last-seen stamps had the same shape. The fix is the wrapper Waiting's row
//  already wears — `TimelineView(.periodic(from: .now, by: 30))`, every
//  half-minute, never per frame — at all three.
//
//  An Improvement, pinned by CODE SHAPE (a timeline's tick cannot be waited
//  out headlessly — the walk is the use evidence) plus the pure brain the
//  tick feeds. RED ON OLD: the three sites had no `TimelineView`, and each
//  called `relative` without `now:`.
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-401 — Settings ▸ MCP's relative stamps read live")
struct MCPPaneStampsTickTests {
    private static func paneSource() throws -> String {
        let app = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        return try String(
            contentsOf: app.appendingPathComponent("Variorum/Features/MCP/MCPPane.swift"), encoding: .utf8)
    }

    /// The text between `start` and the next `end` after it (the site's body).
    private static func slice(_ source: String, from start: String, to end: String) throws -> String {
        let head = try #require(source.range(of: start), "the site exists: \(start)")
        let tail = source.range(of: end, range: head.upperBound..<source.endIndex)?.lowerBound ?? source.endIndex
        return String(source[head.upperBound..<tail])
    }

    private static let tick = "SwiftUI.TimelineView(.periodic(from: .now, by: 30)) { context in"

    /// The pure brain: the same stored stamp reads its age against the tick's
    /// date — so a tick that moves `now` moves the words.
    @Test func theStampReadsItsAgeAgainstTheTicksDate() {
        let at = Date(timeIntervalSince1970: 1_782_864_000)
        let stamp = DateFormatter.variorumISO8601.string(from: at)
        let early = MCPPane.relative(stamp, now: at.addingTimeInterval(39))
        let later = MCPPane.relative(stamp, now: at.addingTimeInterval(60 * 7))
        #expect(early != later, "a later tick says a later age (\(early) → \(later))")
        #expect(later == MCPPane.relative(at, now: at.addingTimeInterval(60 * 7)), "one brain for stamps and dates")
        #expect(MCPPane.relative("not a stamp", now: at) == "not a stamp", "an unreadable stamp shows as stored")
    }

    /// **The three sites wear the tick** — the Activity line, the connection
    /// request's first-seen, the client's last-seen — each reading the tick's
    /// own date, never a frozen `Date()`.
    @Test func theThreeStaleSitesTickEveryHalfMinute() throws {
        let source = try Self.paneSource()
        let activity = try Self.slice(source, from: "struct MCPActivityRowView: View {", to: "\nstruct ")
        #expect(activity.contains(Self.tick), "the Activity line ticks")
        #expect(activity.contains("MCPPane.relative(line.at, now: context.date)"), "…against the tick's date")
        #expect(activity.contains(".stampHelp(MCPPane.whole(line.at))"), "VX-351's whole fact still hovers it")

        let request = try Self.slice(source, from: "private func requestRow(_ request: MCPClient)", to: "private func ")
        #expect(request.contains(Self.tick), "the connection request's first-seen ticks")
        #expect(request.contains("Self.relative(request.firstSeenAt, now: context.date)"), "…against the tick's date")

        let client = try Self.slice(source, from: "struct MCPClientRow: View {", to: "\nstruct ")
        #expect(client.contains(Self.tick), "the client's last-seen ticks")
        #expect(client.contains("Text(detail(now: context.date))"), "…against the tick's date")
        #expect(client.contains("MCPPane.relative(row.client.lastSeenAt, now: now)"))
    }

    /// The sweep that keeps the class closed: every `relative(` the pane calls
    /// passes a `now:` (a tick's date, or a caller's), so no stamp in it is
    /// drawn once against a frozen clock again. Declarations are the only
    /// exception.
    @Test func noStampInThePaneIsDrawnAgainstAFrozenClock() throws {
        let source = try Self.paneSource()
        for (index, line) in source.components(separatedBy: "\n").enumerated() {
            let code = line.trimmingCharacters(in: .whitespaces)
            guard !code.hasPrefix("//"), !code.hasPrefix("///"), code.contains("relative("),
                  !code.contains("static func relative(")
            else { continue }
            #expect(code.contains("now:"), "MCPPane.swift:\(index + 1) draws a stamp with no tick: \(code)")
        }
    }
}
