import CoreGraphics
import Foundation
// usage: wl2 <pid>  → prints "onscreen X Y W H" for the pid's largest layer-0 window, or "offscreen"
let pid = Int(CommandLine.arguments[1])!
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
var best: (Double, Double, Double, Double)? = nil
for w in list where (w[kCGWindowOwnerPID as String] as? Int) == pid && (w[kCGWindowLayer as String] as? Int) == 0 {
  let b = w[kCGWindowBounds as String] as! [String: Double]
  let r = (b["X"]!, b["Y"]!, b["Width"]!, b["Height"]!)
  if r.2 * r.3 > (best.map { $0.2 * $0.3 } ?? 0) { best = r }
}
if let b = best { print("onscreen \(Int(b.0)) \(Int(b.1)) \(Int(b.2)) \(Int(b.3))") } else { print("offscreen") }
