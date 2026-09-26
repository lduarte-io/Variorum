// vis-win <pid> — the pid's largest on-screen layer-0 window: "<id> <x> <y> <w> <h>"
// (points, Quartz global), or "none". `screencapture -l <id>` takes the id.
import CoreGraphics
import Foundation
let pid = Int(CommandLine.arguments[1])!
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
var best: (Int, Double, Double, Double, Double)?
for w in list where (w[kCGWindowOwnerPID as String] as? Int) == pid && (w[kCGWindowLayer as String] as? Int) == 0 {
    let b = w[kCGWindowBounds as String] as! [String: Double]
    let r = (w[kCGWindowNumber as String] as! Int, b["X"]!, b["Y"]!, b["Width"]!, b["Height"]!)
    if r.3 * r.4 > (best.map { $0.3 * $0.4 } ?? 0) { best = r }
}
if let b = best { print("\(b.0) \(Int(b.1)) \(Int(b.2)) \(Int(b.3)) \(Int(b.4))") } else { print("none") }
