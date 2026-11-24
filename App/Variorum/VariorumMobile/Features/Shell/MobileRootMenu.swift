//
//  MobileRootMenu.swift
//  VariorumMobile
//
//  VM-53 (the VM-47 run, batch 5) — **the ⋯ menu on a root, and Settings'
//  door from anywhere.** The ticket: "only the Shelf has a door to it (Library,
//  Starred and Write have none). It becomes … reachable from every root and from
//  a note." The home mockup's frame 34 ("The ⋯ menu, on every root"): ONE menu,
//  the same on all three roots, carrying Settings; later umbrellas add their
//  doors to the same menu (New book, Shelves, Wings, Select, Archived, Trash,
//  Tags — W-021, W-069, W-050 …). This ticket is the menu's shape and its first
//  door; the Bookcase's gear (P-47-9) retires into it.
//
//  THE DOOR is the shell's (it owns the Settings sheet), handed down through the
//  environment — the `ProtectionPaneDoor` precedent — so each root draws the menu
//  in ONE line and a note's ⋯ sheet reaches the same door without a closure
//  threaded through the Write screen. nil (no shell above: a harness) ⇒ no item,
//  and a menu with no item is not drawn (P-2).
//
//  **A system `Menu`, PROVISIONAL (P-47-22).** The mockup draws a pull-down
//  anchored at the ⋯, which is the system's own `Menu`. The phone's harness
//  cannot reach a presented `Menu`'s rows in process (`MobileSurfaceDriver`'s
//  header, measured), so the pins hold the ⋯ door on each root (mounted, 44 × 44,
//  on the path line), the menu's items as data (`items(settings:)`, each act
//  driven), and the walk drives the real menu out of process. The alternative —
//  the note's ⋯ grammar, a sheet of menu rows (drivable in process, one more
//  sheet in front of Settings) — is one view away.
//

import SwiftUI

/// The shell's road to the Settings sheet, handed to every screen under it.
struct MobileSettingsDoor {
    let open: @MainActor () -> Void
}

private struct MobileSettingsDoorKey: EnvironmentKey {
    static let defaultValue: MobileSettingsDoor? = nil
}

extension EnvironmentValues {
    /// VM-53: the shell's Settings door (nil outside a shell — then no door
    /// renders: the roots' ⋯ menu and the note's Settings row stand down).
    var mobileSettingsDoor: MobileSettingsDoor? {
        get { self[MobileSettingsDoorKey.self] }
        set { self[MobileSettingsDoorKey.self] = newValue }
    }
}

/// **The ⋯ on a root's path line** — a 22 pt glyph in the accent (the gear's
/// tone, whose place it takes) in a 44 × 44 hit area, opening the system menu.
struct MobileRootMenu: View {
    let tokens: VoiceTokens
    @Environment(\.mobileSettingsDoor) private var settingsDoor

    /// The door's spoken name (iOS's own word for a ⋯ button).
    static let spokenLabel = "More"
    static let symbol = "ellipsis"
    /// The Settings item's word — the door's word on screen today.
    static let settingsTitle = "Settings"

    /// One item of the menu: its word and its act.
    struct Item: Identifiable {
        let title: String
        let act: @MainActor () -> Void
        var id: String { title }
    }

    /// **The menu's items, as data** — what the menu draws, in order. Today one:
    /// Settings, where the shell gave the door. Later umbrellas append theirs.
    /// An item's word is its identity in the menu (`Item.id`), so each item's
    /// word must be distinct.
    static func items(settings: MobileSettingsDoor?) -> [Item] {
        var items: [Item] = []
        if let settings {
            items.append(Item(title: settingsTitle, act: settings.open))
        }
        return items
    }

    var body: some View {
        let items = Self.items(settings: settingsDoor)
        if !items.isEmpty {
            Menu {
                ForEach(items) { item in
                    Button(tokens.chromeLabel(item.title)) { item.act() }
                        .accessibilityLabel(item.title)
                }
            } label: {
                Image(systemName: Self.symbol)
                    .modifier(PhoneGlyphModifier(size: PhoneControlMetrics.iconGlyph))
                    .foregroundStyle(tokens.accent)
                    .phoneHitArea()
            }
            .accessibilityLabel(Self.spokenLabel)
        }
    }
}
