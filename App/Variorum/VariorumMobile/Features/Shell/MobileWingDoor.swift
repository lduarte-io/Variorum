//
//  MobileWingDoor.swift
//  VariorumMobile
//
//  VM-225 (the VM-55 run, "Wings underneath", batch 4) — THE PLAIN INTERIM
//  WING DOOR. Her word (2026-11-19): "yeah - go ahead and add the plain interim
//  door to this run." — in answer to: "Tap the wing's name on a root, pick from
//  a list of your wings, land on that wing's Bookcase. That is the tap half of
//  what you ruled for the wing title; the swipe, dots, wing management and
//  following a note stay in wave 2." (Her SW-1: the name is the title on every
//  root, tapping it opens the list.) Wave 2's wing face (VM-80, umbrella VM-72)
//  replaces this door whole.
//
//  A FACE over the shared brains, never a second rule (MobileSoul §3):
//  · `WingsModel` (VM-63 moved it to `Shared/`) — the wings read (held by the
//    shell for the roots' titles; read again when the list opens), the
//    switcher's rows (Home first), the deliberate road `goTo(_:saying:)` (switch
//    when another, then LAND — the current wing included, VX-833), and the
//    revalidation that returns the phone Home when its wing dies;
//  · `WingSwitcherBrain` — the switcher's order, the current row, and what a
//    pick means (`.commit(id)` — the current row too).
//  The phone owns only: where the list shows (a plain sheet of real buttons —
//  a SwiftUI `Menu`'s rows are undrivable in process, `MobileSurfaceDriver`'s
//  header), where a landing lands (the shell selects the Shelf page — the
//  phone's Bookcase), and the door's 44 pt hit area on the roots' path line
//  (since the VM-47 re-land, the phone layer's one 44 pt line — VM-50).
//
//  What a switch says: NOTHING (her ruling — a line only for removals and
//  refusals; the Mac's ▾ list is silent too, `goTo(_, saying: false)`). The one
//  word the door can speak is a refusal: a wing that died while the list stood
//  open, picked anyway — the shared table's own sentence for `wingNotFound`,
//  through the phone's refusal road ("a door that did nothing speaks a
//  refusal"). No sentence the brain speaks that names a Mac door (P-55-13's
//  four: the move acts' and the selector's) is reachable from here — the door
//  composes the rows and the switch only.
//

import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileWingDoor {
    /// The shared wings brain the shell holds (the same instance its held
    /// read keeps current — the roots' titles read it too).
    @ObservationIgnored let wings: WingsModel
    /// **The capture box's own leaving, run before a switch** (P-55-18,
    /// PROVISIONAL): a draft already lives in the wing it was minted in
    /// (VM-58 — the box mints as she types), so a switch files it THERE first,
    /// exactly as every page change files it (A5-8 — `selectPage`). Wired by
    /// the shell to `MobileQuickNoteModel.fileOnLeaving`; a harness leaves it
    /// empty.
    @ObservationIgnored let fileCaptureFirst: @MainActor () async -> Void

    /// The list is up.
    var isOpen = false
    /// **The deliberate landings the shell owes** — one per pick, the current
    /// wing included. The shell answers each by showing the Shelf page (the
    /// phone's Bookcase), through its one page road. A counter, never a
    /// closure holding the shell (the Mac's `landInBookcase` is the window's
    /// to wire — here the window is a SwiftUI value, so the model says "land"
    /// and the shell, observing, decides what it means).
    private(set) var landings = 0

    init(
        wings: WingsModel,
        fileCaptureFirst: @escaping @MainActor () async -> Void = {}
    ) {
        self.wings = wings
        self.fileCaptureFirst = fileCaptureFirst
        wings.landInBookcase = { [weak self] in self?.landings &+= 1 }
    }

    /// **The phone's wings brain** — the shared `WingsModel` speaking the
    /// phone's refusal road (batch 3's seam: the Mac hands its own table half,
    /// the phone the shared table's phone sentences, VM-62's plain fallback
    /// behind them).
    static func phoneWings(_ session: AppSession) -> WingsModel {
        WingsModel(session: session, refusalWords: { OpsRefusalCopy.sentence(for: $0, roads: .phone) })
    }

    /// The name was tapped.
    func open() { isOpen = true }

    func close() { isOpen = false }

    /// **The list's own read, as it opens** — the `wing` table alone (a
    /// handful of rows, P1), through the database's reader, off the main
    /// thread (P2). The shell's held read already keeps the rows current; this
    /// read makes the list the store's answer at the moment it opens, even if
    /// the held read has ended.
    func listOpened() async {
        await wings.load()
    }

    /// The switcher the list draws: the wings in the switcher's order (Home
    /// first) and the one it marks.
    var switcher: WingSwitcherBrain {
        WingSwitcherBrain(rows: wings.switcherRows, currentID: wings.currentID)
    }

    /// **A row was picked.** The switcher's answer is a commit (the current
    /// row too — "pick a wing" means one thing on every road, VX-833). The
    /// wings are read again first: a row may name a wing that died while the
    /// list stood open (here, or by sync) — then nothing switches and nothing
    /// lands, the list stays up without that row, and the door says the
    /// table's own words. Otherwise the list closes, a capture draft files in
    /// its own wing when the wing is about to change, and the deliberate road
    /// switches and lands — said by nothing.
    func pick(_ id: String) async {
        guard case .commit(let target) = switcher.pick(id) else { return }
        await wings.load()
        guard wings.rows.contains(where: { $0.id == target }) else {
            wings.session.status.refuse(
                wings.refusalWords(OperationError.wingNotFound(id: target)))
            return
        }
        isOpen = false
        if target != wings.currentID {
            await fileCaptureFirst()
        }
        wings.goTo(target, saying: false)
    }
}

// MARK: - The door, in a root's path line

/// **A root's top line, the wing's name a door** (VM-225; since VM-255 — her
/// R-260-1 — the wing's name ALONE: "it says on the bottom what area you're
/// in"). With a door to wire and a name to say, the name is ONE text — the
/// letters `VoiceTokens.path` draws for it (`MobileWingTitle.doorParts`,
/// pinned) — in the accent, the ink of the other doors on these lines (P-55-17,
/// PROVISIONAL), and the whole title is the door's target. Nothing under it:
/// the Bookcase's quiet count line (R-260-6) left at batch 4a (R-260-11 — no
/// count until the phone has shelves, each shelf then carrying its own). Every
/// root draws it through the one top line (`MobileRootTopLine`, VM-259).
/// Without a door it is the same words as plain text.
///
/// **The target is at least 44 pt tall, and it is real.** A target hung
/// invisibly beyond its line would reach either up into the status bar's inset
/// — the system answers touches there (tap to scroll to top), so it is no
/// target the app can count on — or down into the search field, the books or
/// the first row, which are drawn after the line and would win the touch. So
/// the target is the line's own box: since the VM-47 run the roots' path line
/// IS a 44 pt line (VM-50 — its doors are the phone's 44 pt controls, their
/// hit areas touching), so the door takes the hit-area helper's 44 inside it
/// and the line does not grow (at the VM-55 re-land the earlier hand-back of
/// the roots' 14/6 pt paddings went with the paddings). The text is the
/// phone's `meta` role in the corrected muted ink, ONE line: where the words
/// cannot all fit beside the doors (Terminal at 402 pt — PROVISIONAL P-47-27)
/// the path truncates at its tail, P-47-9's rule. Measured on the real roots
/// (`MobileWingDoorGeometryTests`, `MobilePathLineGeometryTests`).
struct MobileWingPath: View {
    let tokens: VoiceTokens
    let wing: String?
    let onDoor: (() -> Void)?

    var body: some View {
        if let wing, let onDoor {
            Button(action: onDoor) {
                line(Text(Self.title(MobileWingTitle.doorParts(tokens, wing: wing), tokens: tokens)))
                    // The line's own 44 (the hit-area helper), the words on
                    // the line's leading edge.
                    .phoneHitArea(alignment: .leading)
            }
            .buttonStyle(.plain)
            // The wing's NAME, never its voiced casing (the tab doors'
            // precedent). The door draws nothing else, so it carries no value
            // (VM-55 ladder round 1, finding 7: the value was the rest of what it
            // drew — the Bookcase's count, gone at batch 4a, R-260-11).
            .accessibilityLabel(wing)
        } else {
            // An unread name says nothing — never the voice's bare prefix ("~/").
            let words = MobileWingTitle.components(wing: wing)
            line(Text(words.isEmpty ? "" : tokens.path(words))
                .foregroundStyle(tokens.phone.muted))
        }
    }

    /// The name on its one line.
    private func line(_ name: Text) -> some View {
        name
            .phoneType(.meta, tokens)
            .lineLimit(1)
    }

    /// The name's letters: the voice's prefix in the line's muted ink (the
    /// phone's corrected muted — VM-48), the name in the accent.
    static func title(_ parts: (lead: String, door: String), tokens: VoiceTokens) -> AttributedString {
        var lead = AttributedString(parts.lead)
        lead.foregroundColor = tokens.phone.muted
        var door = AttributedString(parts.door)
        door.foregroundColor = tokens.accent
        return lead + door
    }
}

/// **The door's numbers.** 44 pt is the phone's touch minimum (the sizing
/// sheet's, her accepted base — `PhoneMetrics.touchMinimum`): the door's
/// target, and each row of the list. (The two path-line paddings this enum
/// once named, the roots' 14 above and 6 below, left with the line's rebuild
/// as one 44 pt line — the VM-47 run's VM-50, met at the VM-55 re-land; the
/// geometry pins measure the real roots.)
enum MobileWingDoorMetrics {
    static let minimumSide: CGFloat = PhoneMetrics.touchMinimum
}

// MARK: - The list

/// **The plain list** — the wings in the switcher's order, Home first, the
/// current one marked; each row a real button. The phone's sheet idiom (the
/// shared sheet header with Done, the rows below, `MobileMembershipSheet`'s
/// shape) on the phone layer. Its header is the Mac's own (`WingWords.switcherHeader` —
/// the Mac's ▾ list says it). Nothing else is on it: no sizes, no ⋯, no
/// management, no Snippets line — wave 2's.
struct MobileWingListSheet: View {
    let door: MobileWingDoor
    let tokens: VoiceTokens

    var body: some View {
        let switcher = door.switcher
        VStack(alignment: .leading, spacing: PhoneMetrics.Space.s12) {
            // The phone's one sheet header (VM-50): the title at the gutter,
            // Done the closing act with its 64 × 44 hit area.
            PhoneSheetHeader(tokens.chromeLabel(WingWords.switcherHeader), tokens: tokens) {
                door.close()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(switcher.rows) { row in
                        wingRow(row, current: row.id == switcher.currentID)
                    }
                }
            }
        }
        .padding(PhoneMetrics.gutter)
        .background(tokens.room.ignoresSafeArea())
        .task { await door.listOpened() }
    }

    private func wingRow(_ row: WingSwitcherBrain.Row, current: Bool) -> some View {
        Button {
            let door = door
            Task { await door.pick(row.id) }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: PhoneMetrics.Space.s8) {
                // The mark's column is kept on every row, so the names align.
                // (The ✓ in a picker is `meta`; a row's word is a menu row's
                // label, `control` in her ink — sheet §E; PROVISIONAL P-47-8.)
                Text("\u{2713}")
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.accent)
                    .opacity(current ? 1 : 0)
                Text(tokens.chromeLabel(row.name))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(minHeight: MobileWingDoorMetrics.minimumSide)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(row.name)
        .accessibilityAddTraits(current ? .isSelected : [])
    }
}
