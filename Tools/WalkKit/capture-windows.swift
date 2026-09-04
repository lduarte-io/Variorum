import Foundation
import CoreGraphics
let pid = Int32(CommandLine.arguments[1])!
let out = CommandLine.arguments[2]
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
var n = 0
for w in list where (w["kCGWindowOwnerPID"] as? Int32) == pid && (w["kCGWindowLayer"] as? Int) == 0 {
    let wid = w["kCGWindowNumber"] as! Int
    print("window \(wid) name=\(w["kCGWindowName"] ?? "-") bounds=\(w["kCGWindowBounds"] ?? "-")")
    let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    p.arguments = ["-x", "-o", "-l", String(wid), "\(out)/w\(n).png"]; try! p.run(); p.waitUntilExit(); n += 1
}
print("captured \(n)")
