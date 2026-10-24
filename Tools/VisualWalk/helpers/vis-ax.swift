// vis-ax <pid> <label> [role|-] [press] — find an on-screen control of the pid's windows by its accessibility
// LABEL (AXTitle / AXDescription / a static text's AXValue, exact, case-insensitive), breadth-first,
// and print "<x> <y> <w> <h> <role>" (points, Quartz global) for the FIRST match; exit 1 if none.
// Chrome controls (a book's mode row, Settings' voice radios) move with widths and voices — found by
// what they are called, a walk never guesses their coordinates (the WalkKit voice-flip facts).
// `press` performs AXPress on the match instead of printing only — the 18k walker fact: SwiftUI
// Settings controls ignore synthetic clicks and answer AXPress; and an AX press cannot land on a
// system dialog that happens to cover the control's screen point.
import ApplicationServices
import Foundation
let args = CommandLine.arguments
let pid = pid_t(Int32(args[1])!)
let label = args[2].lowercased()
let wantRole = args.count > 3 && args[3] != "-" ? args[3] : nil
let press = args.count > 4 && args[4] == "press"
// VIS_AX_MINX: only matches whose left edge is at or right of this x (skip the sidebar's twin label).
let minX = Double(ProcessInfo.processInfo.environment["VIS_AX_MINX"] ?? "") ?? -1e9
// VIS_AX_PREFIX=1: a label that STARTS with the query matches (SwiftUI folds a card's title and its
// preview into one label: "About this book, “The Adventures…”").
let prefix = ProcessInfo.processInfo.environment["VIS_AX_PREFIX"] == "1"
func attr(_ e: AXUIElement, _ name: String) -> AnyObject? {
    var v: AnyObject?; return AXUIElementCopyAttributeValue(e, name as CFString, &v) == .success ? v : nil
}
let app = AXUIElementCreateApplication(pid)
var queue: [AXUIElement] = (attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []
var visited = 0
while !queue.isEmpty, visited < 20000 {
    let e = queue.removeFirst(); visited += 1
    let role = attr(e, kAXRoleAttribute) as? String ?? ""
    // VX-510 (the walk's first live run): a SwiftUI text field exposes its placeholder as AXPlaceholderValue and
    // often no title — the walk's field probes address fields by that placeholder.
    let names = [attr(e, kAXTitleAttribute), attr(e, kAXDescriptionAttribute), attr(e, "AXPlaceholderValue" as String),
                 role == "AXStaticText" ? attr(e, kAXValueAttribute) : nil]
        .compactMap { $0 as? String }.map { $0.lowercased() }
    if names.contains(where: { $0 == label || (prefix && $0.hasPrefix(label)) }),
       wantRole == nil || wantRole == role,
       let pv = attr(e, kAXPositionAttribute), let sv = attr(e, kAXSizeAttribute) {
        var p = CGPoint.zero, s = CGSize.zero
        AXValueGetValue(pv as! AXValue, .cgPoint, &p); AXValueGetValue(sv as! AXValue, .cgSize, &s)
        if s.width > 0, s.height > 0, Double(p.x) >= minX {
            print("\(Int(p.x)) \(Int(p.y)) \(Int(s.width)) \(Int(s.height)) \(role)")
            if press { exit(AXUIElementPerformAction(e, kAXPressAction as CFString) == .success ? 0 : 2) }
            exit(0)
        }
    }
    queue += (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}
exit(1)
