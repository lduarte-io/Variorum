//
//  LifecyclePageTests.swift
//  VariorumCoreTests — VX-378 U3: THE COMMITTED PAGE IS THE RENDERED ONE.
//  `notes/plans/vx-266/castle-lifecycle.html` must equal `LifecyclePage.render()`
//  byte for byte, so the page can never drift from the fixture the lifecycle
//  scenario asserts against. To regenerate: `CASTLE_LIFECYCLE_PAGE_OUT=<path>
//  swift test --filter LifecyclePageTests` writes the render to <path> (then
//  `cmp` it with the committed page, and copy it over when the change is
//  meant). The page stays a LOCAL file — never published.
//

import Foundation
import Testing

@Suite("VX-378 U3 — the lifecycle page is rendered from the fixture")
struct LifecyclePageTests {
    static var pageURL: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<6 { url.deleteLastPathComponent() }  // …/Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/<file>
        return url.appendingPathComponent("notes/plans/vx-266/castle-lifecycle.html")
    }

    @Test func theCommittedPageIsTheRenderedOne() throws {
        let rendered = LifecyclePage.render()
        if let out = ProcessInfo.processInfo.environment["CASTLE_LIFECYCLE_PAGE_OUT"] {
            try Data(rendered.utf8).write(to: URL(fileURLWithPath: out))
        }
        let committed = try String(contentsOf: Self.pageURL, encoding: .utf8)
        #expect(committed == rendered, "the committed page drifted from the fixture — regenerate it (see the file's header)")
    }

    /// Every chip's class is the fact's: typed secrets that open are `s`, quiet
    /// roads that open `q`, anything gone `x` — as the page's legend says.
    @Test func everyChipIsRenderedFromItsFact() {
        for stage in Lifecycle.stages {
            for case .chips(_, let chips) in stage.rows.map(\.content) {
                for chip in chips {
                    let html = LifecyclePage.chip(chip)
                    switch (chip.road, chip.state) {
                    case (_, .gone): #expect(html.hasPrefix(#"<span class="x">"#))
                    case (.typed, .opens): #expect(html.hasPrefix(#"<span class="s">"#))
                    case (_, .opens): #expect(html.hasPrefix(#"<span class="q">"#))
                    }
                }
            }
        }
    }
}
