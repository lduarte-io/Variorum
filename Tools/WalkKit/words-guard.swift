// words-guard <pid>             — before EVERY capture: read the pid's AX tree for words-shaped content (a static text,
//                                  title or description of exactly twelve lowercase words, or the words look's own
//                                  markers). Prints "ok" (exit 0) or "withheld (<class>)" (exit 1) — never the text.
// words-guard --classify <text> — the same matcher over one string, headless (the walk's --self-test proves its teeth).
//
// VX-623 D-5: capturing EVERY window of the pid (Settings and its sheets included) would catch the twelve-words look
// if a step stopped while it was on screen, so a capture is withheld whenever this says so. The matcher and the
// markers are VX-502's Castle-walk guard (Tools/WalkKit/castle-walk-lib.zsh `wk_words_guard_build`, live-proven), its
// markers re-read from the CURRENT code: ProtectionWords.wordsLookWrittenDown "I've written them down" (:694),
// .wordsLookWarning "These words won't be shown again." (:696), .wordsLookShow "Show my twelve words" (:679).
import ApplicationServices
import Foundation

let twelve = try! NSRegularExpression(pattern: "^\\s*[a-z]+(\\s+[a-z]+){11}\\s*$")
let markers = ["i've written them down", "these words won't be shown again.", "show my twelve words"]
func verdict(_ s: String) -> String? {
    let l = s.lowercased()
    if twelve.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil { return "a twelve-word string on screen" }
    if markers.contains(where: { l.contains($0) }) { return "the words look is on screen" }
    return nil
}

let args = CommandLine.arguments
if args.count == 3, args[1] == "--classify" {
    if let why = verdict(args[2]) { print("withheld (\(why))"); exit(1) }
    print("ok"); exit(0)
}
guard args.count == 2, let raw = Int32(args[1]) else { print("withheld (usage: words-guard <pid> | --classify <text>)"); exit(2) }
let pid = pid_t(raw)
func attr(_ e: AXUIElement, _ n: String) -> AnyObject? { var v: AnyObject?; return AXUIElementCopyAttributeValue(e, n as CFString, &v) == .success ? v : nil }
var queue: [AXUIElement] = (attr(AXUIElementCreateApplication(pid), kAXWindowsAttribute) as? [AXUIElement]) ?? []
var seen = 0
while !queue.isEmpty, seen < 30000 {
    let e = queue.removeFirst(); seen += 1
    for n in [kAXValueAttribute, kAXTitleAttribute, kAXDescriptionAttribute] {
        guard let s = attr(e, n) as? String else { continue }
        if let why = verdict(s) { print("withheld (\(why))"); exit(1) }
    }
    queue += (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}
print("ok")
