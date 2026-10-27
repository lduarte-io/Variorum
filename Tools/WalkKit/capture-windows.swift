// walk-cap <pid> <outdir> [<prefix>] [--every-layer]
//   Lists the process's on-screen windows (id · layer · name · bounds in POINTS) and saves each as
//   <outdir>/<prefix>w<n>.png via `screencapture -x -o -l <id>` — WINDOW-scoped, never the full screen.
//   Default: layer-0 windows, no prefix (w0.png, w1.png… — the original two-argument behaviour).
//   --every-layer (VX-623 D-5, the first-run walk): every layer the pid owns — an app-modal alert or a floating panel is
//   not layer 0 — skipping slivers under 48 pt (the fresh launch's 40 pt phantom window, tooltips).
import Foundation
import CoreGraphics
let args = CommandLine.arguments
let pid = Int32(args[1])!
let out = args[2]
let everyLayer = args.contains("--every-layer")
let prefix = args.count > 3 && args[3] != "--every-layer" ? args[3] : ""
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
var n = 0
for w in list where (w["kCGWindowOwnerPID"] as? Int32) == pid {
    let layer = w["kCGWindowLayer"] as? Int ?? -1
    let b = w["kCGWindowBounds"] as? [String: Double] ?? [:]
    if everyLayer {
        guard (b["Width"] ?? 0) >= 48, (b["Height"] ?? 0) >= 48 else { continue }
    } else {
        guard layer == 0 else { continue }
    }
    let wid = w["kCGWindowNumber"] as! Int
    print("window \(wid) layer=\(layer) name=\(w["kCGWindowName"] ?? "-") bounds=\(w["kCGWindowBounds"] ?? "-") → \(prefix)w\(n).png")
    let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    p.arguments = ["-x", "-o", "-l", String(wid), "\(out)/\(prefix)w\(n).png"]; try! p.run(); p.waitUntilExit(); n += 1
}
print("captured \(n)")
