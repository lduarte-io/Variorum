//
//  TakesCommands.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R73): the take lifecycle's
//  keyboard family rides ONE notification channel from the menu bar to
//  whichever surface is visible — the Takes/Lenses boards handle with
//  their focused pane; Write handles with its caret block; nothing is ever
//  a dead key (the 9d fire-and-speak posture; an inapplicable surface
//  SAYS what to do instead).
//

import Foundation

extension Notification.Name {
    static let variorumTakesCommand = Notification.Name("variorumTakesCommand")
}

enum TakesCommand: String {
    case toggleFan      // ⌘⇧T — open/close takes at the block you're in
    case closeAll       // ⎋ / menu — back to the plain page
    case branch         // ⌘T — new take (branch from shown)
    case blank          // ⌥⌘T — new blank take (never chooses — R90)
    case blankChoose    // ⇧⌥⌘T — the power variant: blank AND chosen
    case choose         // ⌘⏎ — choose the take you're in
    case stepPrev       // ⌃⌘← — previous take (ring / column pick)
    case stepNext       // ⌃⌘→ — next take
    case archive        // ⌘⇧A — archive the take you're in
    case saveLens       // ⌘⇧L — save current choices as a lens

    static func post(_ command: TakesCommand) {
        NotificationCenter.default.post(
            name: .variorumTakesCommand, object: nil,
            userInfo: ["command": command.rawValue])
    }

    static func from(_ notification: Notification) -> TakesCommand? {
        (notification.userInfo?["command"] as? String).flatMap(TakesCommand.init(rawValue:))
    }
}
