// vis-foreign <pid> [x y] — on-screen windows ABOVE the normal level (any layer ≥ 1 — round 1, N8:
// a prompt drawn above the old 1…23 band must not be invisible to the rule) that another process
// owns: system alerts and consent prompts (UserNotificationCenter's TCC prompt sits at 8), floating
// panels. One line each: "<x> <y> <w> <h> <layer> <owner>". With a point, prints only the windows
// that COVER it and exits 1 when any does. Not dialogs: the Window Server's own (menu bar, cursor),
// the Dock, and the Screenshot service's full-screen capture surface (layer 24 — measured standing
// through every U-VIS run while every click reached the app beneath it).
// Why (18l U-VIS, 2026-09-26): a stale "… wants access to control Finder" prompt sat over the dev
// window, a walk click landed on it, and it then held keyboard focus — a ⏎ would have pressed Allow.
import CoreGraphics
import Foundation
let args = CommandLine.arguments
let pid = Int(args[1])!
let point: CGPoint? = args.count >= 4 ? CGPoint(x: Double(args[2])!, y: Double(args[3])!) : nil
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
var covering = false
for w in list {
    let layer = w[kCGWindowLayer as String] as? Int ?? 0
    let owner = w[kCGWindowOwnerName as String] as? String ?? "?"
    guard layer >= 1, (w[kCGWindowOwnerPID as String] as? Int) != pid,
          !["Dock", "Window Server", "Screenshot"].contains(owner) else { continue }
    let b = w[kCGWindowBounds as String] as! [String: Double]
    let r = CGRect(x: b["X"]!, y: b["Y"]!, width: b["Width"]!, height: b["Height"]!)
    if let point, !r.contains(point) { continue }
    if point != nil { covering = true }
    print("\(Int(r.minX)) \(Int(r.minY)) \(Int(r.width)) \(Int(r.height)) \(layer) \(owner.replacingOccurrences(of: " ", with: "_"))")
}
exit(covering ? 1 : 0)
