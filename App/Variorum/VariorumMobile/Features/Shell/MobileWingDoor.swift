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
//  phone's Bookcase), and the 44 pt hit area on a line drawn at 11.5 pt.
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

/// **A root's path line, the wing's name a door** (VM-225; the line is batch
/// 1's — P-55-2). With a door to wire and a name to say, the line stays ONE
/// text — the same letters (`MobileWingTitle.doorParts`, pinned), the same
/// wrapping — with the wing's name in the accent, the ink of the other doors
/// on these lines (P-55-17, PROVISIONAL), and the whole title is the door's
/// target. Without either it is exactly the line batch 1 drew, so a harness
/// that wires no door renders as before.
///
/// **The target is at least 44 pt tall, and it is real** (the brief's one
/// sanctioned change to the line's layout). The line is about 34 pt tall at
/// 11.5 pt (its 14 pt top padding, the text, its 6 pt bottom padding — the
/// roots' own, `MobileWingDoorMetrics`). A target hung invisibly beyond it
/// would reach either up into the status bar's inset — the system answers
/// touches there (tap to scroll to top), so it is no target the app can count
/// on — or down into the search field, the books or the first row, which are
/// drawn after the line and would win the touch. So the door's target spans
/// the line's own paddings and the line grows by what is still missing: 10 pt
/// at today's size (34 → 44), the name 5 pt lower, nothing else moved but by
/// that. Measured on the real roots (`MobileWingDoorGeometryTests`).
struct MobileWingPath: View {
    let tokens: VoiceTokens
    let wing: String?
    let page: String
    /// What the line says after the page (the Shelf's "  ·  6 books"),
    /// already voiced.
    var trailing: String = ""
    let onDoor: (() -> Void)?

    var body: some View {
        if let wing, let onDoor {
            let metrics = MobileWingDoorMetrics.self
            Button(action: onDoor) {
                Text(Self.title(
                    MobileWingTitle.doorParts(tokens, wing: wing, page: page, trailing: trailing),
                    tokens: tokens))
                    .font(tokens.small)
                    // The target spans the line's own top and bottom
                    // paddings, then whatever 44 pt still needs…
                    .padding(.top, metrics.lineTopPadding)
                    .padding(.bottom, metrics.lineBottomPadding)
                    .frame(minHeight: metrics.minimumSide)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // …while the line keeps laying its paddings out itself: the
            // target overlaps them, so the line grows only by the remainder.
            .padding(.top, -metrics.lineTopPadding)
            .padding(.bottom, -metrics.lineBottomPadding)
            // The wing's NAME, never its voiced casing (the tab doors'
            // precedent).
            .accessibilityLabel(wing)
            // …and the rest of the line as it is drawn — the page, and the
            // Shelf's count — so VoiceOver reads "Home, Library" as batch 1's
            // plain line read the whole path. No new words (VM-55 ladder
            // round 1, finding 7).
            .accessibilityValue(page + trailing)
        } else {
            Text(tokens.path(MobileWingTitle.components(wing: wing, page: page)) + trailing)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
        }
    }

    /// The line's letters, the name in the accent and the rest in the line's
    /// muted ink.
    static func title(
        _ parts: (lead: String, door: String, rest: String), tokens: VoiceTokens
    ) -> AttributedString {
        var lead = AttributedString(parts.lead)
        lead.foregroundColor = tokens.muted
        var door = AttributedString(parts.door)
        door.foregroundColor = tokens.accent
        var rest = AttributedString(parts.rest)
        rest.foregroundColor = tokens.muted
        return lead + door + rest
    }
}

/// **The door's numbers.** 44 pt is the phone's touch minimum (the sizing
/// sheet's, her accepted base); the two paddings are the roots' path lines'
/// own (`MobileStarredView`, `MobileShelfView`, `MobileLibraryView` —
/// `.padding(.top, 14)`, `.padding(.bottom, 6)`), which the door's target
/// overlaps rather than adds to. If a root's paddings change, the geometry
/// pins (which measure the real roots) say so.
enum MobileWingDoorMetrics {
    static let minimumSide: CGFloat = 44
    static let lineTopPadding: CGFloat = 14
    static let lineBottomPadding: CGFloat = 6
}

// MARK: - The list

/// **The plain list** — the wings in the switcher's order, Home first, the
/// current one marked; each row a real button. The phone's sheet idiom (the
/// title row with Done, the rows below, `MobileMembershipSheet`'s shape) in
/// today's tokens. Its header is the Mac's own (`WingWords.switcherHeader` —
/// the Mac's ▾ list says it). Nothing else is on it: no sizes, no ⋯, no
/// management, no Snippets line — wave 2's.
struct MobileWingListSheet: View {
    let door: MobileWingDoor
    let tokens: VoiceTokens

    var body: some View {
        let switcher = door.switcher
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(tokens.chromeLabel(WingWords.switcherHeader))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button(tokens.chromeLabel("Done")) { door.close() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Done")
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(switcher.rows) { row in
                        wingRow(row, current: row.id == switcher.currentID)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await door.listOpened() }
    }

    private func wingRow(_ row: WingSwitcherBrain.Row, current: Bool) -> some View {
        Button {
            let door = door
            Task { await door.pick(row.id) }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // The mark's column is kept on every row, so the names align.
                Text("\u{2713}")
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .opacity(current ? 1 : 0)
                Text(tokens.chromeLabel(row.name))
                    .font(tokens.body)
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
