//
//  LifecyclePage.swift
//  VariorumCoreTests — VX-378 U3: THE PAGE RENDERER. Renders
//  `notes/plans/vx-266/castle-lifecycle.html` from the SAME value the lifecycle
//  scenario asserts against (`Lifecycle.stages`, `Lifecycle.factsDiff`), its
//  prose riding as data (`LifecycleProse`, the stages' own words). The renderer
//  owns the facts: every road chip's class is computed from its typed road and
//  state (a secret you type · a quiet road · gone), and every FACTS DIFF is
//  shown on its stage as a fact under review. The committed page is the
//  rendered one (`LifecyclePageTests`).
//
//  The call (the plan's U3 RECORD): test-side, not `Tools/castle-lifecycle-page`
//  — a tool needs a `Package.swift` target (outside this unit's scope diff),
//  and here the renderer reads the fixture's own types with no second copy.
//

import Foundation

enum LifecyclePage {
    /// The page, from the fixture.
    static func render(
        _ stages: [LStage] = Lifecycle.stages, diffs: [LFactsDiff] = Lifecycle.factsDiff,
        lead: String = LifecycleProse.lead, footer: String = LifecycleProse.footer,
        topBeforeLead: String = LifecycleProse.topBeforeLead
    ) -> String {
        var html = topBeforeLead + #"<p class="lead">"# + lead + "</p>" + LifecycleProse.topAfterLead
        html += stages.map { stage in render(stage, diffs: diffs.filter { $0.stage == stage.number }) }.joined(separator: "\n\n")
        html += "\n\n" + LifecycleProse.bottom + "<footer>" + footer + "</footer>" + LifecycleProse.end
        return html
    }

    static func render(_ stage: LStage, diffs: [LFactsDiff]) -> String {
        var html = #"<div class="stage \#(stage.posture.rawValue)"><h3>\#(stage.number) · \#(stage.title) <small>\#(stage.postureLabel)</small></h3>"#
        html += "\n<dl>\n"
        for row in stage.rows {
            switch row.content {
            case .text(let text), .textStating(let text, _, _):
                html += "<dt>\(row.term)</dt><dd>\(text)</dd>\n"
            case .chips(_, let chips):
                html += #"<dt>\#(row.term)</dt><dd class="roads">"# + chips.map(chip).joined() + "</dd>\n"
            }
        }
        html += "</dl>"
        if let note = stage.note { html += #"<p class="note">\#(note)</p>"# }
        for diff in diffs {
            html += #"<p class="note diff"><b>Under review (\#(diff.id)) — the build differs from this line:</b> \#(prose(diff.page)). As built: \#(prose(diff.model)) Why: \#(prose(diff.reason))</p>"#
        }
        return html + "</div>"
    }

    /// A road chip: its class from the FACT (a typed secret that opens — `s`;
    /// a quiet road that opens — `q`; any road gone — `x`), its words from the
    /// fixture.
    static func chip(_ chip: LChip) -> String {
        let cls: String
        switch (chip.road, chip.state) {
        case (_, .gone): cls = "x"
        case (.typed, .opens): cls = "s"
        case (_, .opens): cls = "q"
        }
        return #"<span class="\#(cls)">\#(chip.label)</span>"#
    }

    /// A diff's words for HTML: escaped, `code` spans set.
    static func prose(_ text: String) -> String {
        var escaped = text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;")
        var out = "", inCode = false
        for character in escaped {
            if character == "`" {
                out += inCode ? "</code>" : "<code>"
                inCode.toggle()
            } else {
                out.append(character)
            }
        }
        escaped = out
        return escaped
    }
}
