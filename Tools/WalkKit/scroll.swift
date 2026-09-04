import Foundation
import CoreGraphics
let x = Double(CommandLine.arguments[1])!, y = Double(CommandLine.arguments[2])!
let lines = Int32(CommandLine.arguments[3])!
let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)!
move.post(tap: .cghidEventTap); usleep(200_000)
for _ in 0..<10 {
    let ev = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: -lines, wheel2: 0, wheel3: 0)!
    ev.location = CGPoint(x: x, y: y); ev.post(tap: .cghidEventTap); usleep(120_000)
}
print("scrolled")
