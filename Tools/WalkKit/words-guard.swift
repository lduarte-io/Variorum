// words-guard <pid>             — before EVERY capture: read the pid's AX tree for words-shaped content (a static text,
//                                  title or description of exactly twelve lowercase words, or the words look's own
//                                  markers). Prints "ok (<n> elements read)" (exit 0) or "withheld (<class>)" (exit 1) —
//                                  never the text. A tree it cannot read whole is WITHHELD, never "ok" (below).
// words-guard --classify <text> — the same matcher over one string, headless (the walk's --self-test proves its teeth).
// words-guard --self-check      — the same SCAN over synthetic trees, headless (the cap, a cycle, unreadable answers,
//                                  words deep in a tree, a clean tree) — exit 0 when every case holds.
//
// VX-623 D-5: capturing EVERY window of the pid (Settings and its sheets included) would catch the twelve-words look
// if a step stopped while it was on screen, so a capture is withheld whenever this says so. The matcher and the
// markers are VX-502's Castle-walk guard (Tools/WalkKit/castle-walk-lib.zsh `wk_words_guard_build`, live-proven), its
// markers re-read from the CURRENT code: ProtectionWords.wordsLookWrittenDown "I've written them down" (:694),
// .wordsLookWarning "These words won't be shown again." (:696), .wordsLookShow "Show my twelve words" (:679).
//
// FAIL-CLOSED (the ladder's round-1 MAJOR, notes/plans/fixes/vx-623-ladder-round1.md): before it, every non-success AX
// answer folded into "nothing here", so a dead, hung or non-GUI pid printed "ok" having inspected nothing — and walk-cap
// lists windows by CGWindowList, with no AX, so it would shoot. Every AX answer is now one of THREE classes:
//   PRESENT    — .success of the expected type;
//   ABSENT     — .noValue · .attributeUnsupported · .notImplemented · a .success of another type (a slider's number):
//                the element has no such text — an ANSWER, not a failure; the scan goes on;
//   UNREADABLE — every other code (.cannotComplete — a hung app after AX's ≈6 s timeout, a dead or non-GUI pid at once —
//                · .apiDisabled · .failure · .illegalArgument · .invalidUIElement …): the scan could not see what is
//                there — WITHHELD AT ONCE (no chain of timeouts before a verdict).
// The windows read must be a PRESENT list (an EMPTY one is legal — zero windows); anything else withholds. A scan that
// reaches the cap with elements still queued withholds too (this also ends a cyclic tree, fail-closed).
// Exit: 0 ok · 1 withheld · 2 usage (withheld too: the walk treats ANY non-zero as withheld).
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

// --- the three classes and THE SCAN (generic over the node, so --self-check drives the very same code) ---------------
enum Got<T> { case present(T), absent, unreadable(Int32) }
let cap = 30000
// scan → nil when the whole tree was read and nothing words-shaped is in it (with the count read), else the reason.
func scan<N>(windows: Got<[N]>, texts: (N) -> AnySequence<Got<String>>, children: (N) -> Got<[N]>) -> (withheld: String?, read: Int) {
    var queue: [N]
    switch windows {
    case .present(let w): queue = w
    case .absent: return ("the pid's windows could not be read — its answer held no window list", 0)
    case .unreadable(let code): return ("the pid's windows could not be read — AXError \(code)", 0)
    }
    var head = 0
    while head < queue.count {
        if head >= cap { return ("the tree was not fully scanned — more than \(cap) elements", head) }
        let e = queue[head]; head += 1
        for t in texts(e) {
            switch t {
            case .present(let s): if let why = verdict(s) { return (why, head) }
            case .absent: continue
            case .unreadable(let code): return ("the pid stopped answering mid-scan — AXError \(code)", head)
            }
        }
        switch children(e) {
        case .present(let c): queue += c
        case .absent: break
        case .unreadable(let code): return ("the pid stopped answering mid-scan — AXError \(code)", head)
        }
    }
    return (nil, head)
}

// --- the AX side: one reader classifies every answer ------------------------------------------------------------
func ax<T>(_ e: AXUIElement, _ name: String, _ type: T.Type) -> Got<T> {
    var v: AnyObject?
    let r = AXUIElementCopyAttributeValue(e, name as CFString, &v)
    switch r {
    case .success: if let x = v as? T { return .present(x) }; return .absent
    case .noValue, .attributeUnsupported, .notImplemented: return .absent
    default: return .unreadable(r.rawValue)
    }
}
let textAttributes = [kAXValueAttribute, kAXTitleAttribute, kAXDescriptionAttribute]

// --- --self-check: the scan's verdicts over synthetic trees (headless) ------------------------------------------
final class Node {
    var texts: [Got<String>]
    var kids: Got<[Node]>
    init(_ texts: [Got<String>] = [.absent, .absent, .absent], kids: Got<[Node]> = .absent) { self.texts = texts; self.kids = kids }
}
func check(_ windows: Got<[Node]>) -> (withheld: String?, read: Int) {
    scan(windows: windows, texts: { AnySequence($0.texts) }, children: { $0.kids })
}
func chain(depth: Int, leaf: Node) -> Node {  // a straight line of `depth` nodes above `leaf`
    var n = leaf
    for _ in 0..<depth { n = Node([.absent, .present("Settings"), .absent], kids: .present([n])) }
    return n
}
func selfCheck() -> Int32 {
    var fails = 0
    func expect(_ label: String, _ got: (withheld: String?, read: Int), withheld want: String?, read count: Int? = nil) {
        let ok = (want == nil ? got.withheld == nil : (got.withheld?.hasPrefix(want!) ?? false)) && (count == nil || got.read == count!)
        print("SELF-CHECK \(label): \(got.withheld.map { "withheld (\($0))" } ?? "ok (\(got.read) elements read)")  \(ok ? "ok" : "FAIL")")
        if !ok { fails += 1 }
    }
    let words = "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima"
    expect("a tree of cap + 1 elements → withheld (not fully scanned)",
           check(.present([Node(kids: .present((0..<cap).map { _ in Node() }))])), withheld: "the tree was not fully scanned")
    expect("a tree of exactly cap elements → ok (read whole)",
           check(.present([Node(kids: .present((0..<(cap - 1)).map { _ in Node() }))])), withheld: nil, read: cap)
    let loop = Node(); loop.kids = .present([loop])
    expect("a node that is its own child → withheld (the cycle ends, fail-closed)", check(.present([loop])), withheld: "the tree was not fully scanned")
    expect("the windows read unreadable (a hung app's AXError -25204) → withheld", check(.unreadable(-25204)), withheld: "the pid's windows could not be read")
    expect("the windows read absent (no window list) → withheld", check(.absent), withheld: "the pid's windows could not be read")
    expect("an EMPTY window list → ok (zero windows)", check(.present([])), withheld: nil)
    expect("a children read unreadable mid-scan → withheld at once",
           check(.present([chain(depth: 5, leaf: Node(kids: .unreadable(-25204)))])), withheld: "the pid stopped answering mid-scan")
    expect("a string read unreadable mid-scan → withheld at once",
           check(.present([chain(depth: 5, leaf: Node([.absent, .unreadable(-25202), .absent]))])), withheld: "the pid stopped answering mid-scan")
    expect("twelve words 40 elements deep → withheld",
           check(.present([chain(depth: 40, leaf: Node([.present(words), .absent, .absent]))])), withheld: "a twelve-word string on screen")
    expect("the words look's marker deep in a tree → withheld",
           check(.present([chain(depth: 12, leaf: Node([.absent, .present("I've written them down"), .absent]))])), withheld: "the words look is on screen")
    expect("an absent answer is not a stop: words BEYOND an absent node are still found",
           check(.present([Node(kids: .present([Node(kids: .absent), chain(depth: 3, leaf: Node([.absent, .absent, .present(words)]))]))])),
           withheld: "a twelve-word string on screen")
    let clean = Node(kids: .present((0..<99).map { _ in Node([.absent, .present("Sync this library…"), .absent],
                                                                kids: .present((0..<4).map { _ in Node() })) }))
    expect("a clean 496-element tree with absent answers throughout → ok, every element read", check(.present([clean])), withheld: nil, read: 496)
    print(fails == 0 ? "SELF-CHECK: every verdict held" : "SELF-CHECK: \(fails) verdict(s) wrong")
    return fails == 0 ? 0 : 1
}

// --- the modes ---------------------------------------------------------------------------------------------------
let args = CommandLine.arguments
if args.count == 3, args[1] == "--classify" {
    if let why = verdict(args[2]) { print("withheld (\(why))"); exit(1) }
    print("ok"); exit(0)
}
if args.count == 2, args[1] == "--self-check" { exit(selfCheck()) }
guard args.count == 2, let raw = Int32(args[1]) else { print("withheld (usage: words-guard <pid> | --classify <text> | --self-check)"); exit(2) }
let app = AXUIElementCreateApplication(pid_t(raw))
let result = scan(windows: ax(app, kAXWindowsAttribute, [AXUIElement].self),
                  texts: { e in AnySequence(textAttributes.lazy.map { ax(e, $0, String.self) }) },
                  children: { ax($0, kAXChildrenAttribute, [AXUIElement].self) })
if let why = result.withheld { print("withheld (\(why))"); exit(1) }
print("ok (\(result.read) elements read)")
