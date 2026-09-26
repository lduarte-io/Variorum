// vis-probe <id> [flag …] — ask the harness-launched dev app for its geometry.
// Posts `…visualWalk.request` (object "<id> <flags>") and prints the first
// `…visualWalk.answer` whose line carries `id=<id>`. Exit 0 on an answer,
// 2 on timeout (VIS_PROBE_TIMEOUT seconds, default 3). The app side is
// `App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift` (DEBUG, env-gated).
import Foundation

let args = Array(CommandLine.arguments.dropFirst())
guard let id = args.first else {
    FileHandle.standardError.write("usage: vis-probe <id> [flag …]\n".data(using: .utf8)!)
    exit(64)
}
let timeout = Double(ProcessInfo.processInfo.environment["VIS_PROBE_TIMEOUT"] ?? "") ?? 3
let center = DistributedNotificationCenter.default()
let request = Notification.Name("io.lduarte.Variorum.debug.visualWalk.request")
let answer = Notification.Name("io.lduarte.Variorum.debug.visualWalk.answer")
var received: String?
let token = center.addObserver(forName: answer, object: nil, queue: .main) { note in
    if let line = note.object as? String, line.hasPrefix("vis id=\(id) ") { received = line }
}
center.postNotificationName(request, object: args.joined(separator: " "),
                            userInfo: nil, deliverImmediately: true)
let deadline = Date().addingTimeInterval(timeout)
while received == nil, Date() < deadline {
    RunLoop.main.run(mode: .default, before: Date().addingTimeInterval(0.02))
}
center.removeObserver(token)
guard let received else { print("vis id=\(id) timeout=1"); exit(2) }
print(received)
