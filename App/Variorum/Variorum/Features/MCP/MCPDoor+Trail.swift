//
//  MCPDoor+Trail.swift
//  Variorum (MAC ONLY)
//
//  VX-679 (the VX-809 run, batch 5 — her R-679): HER PRESS on a row of the
//  sidebar's "From ‹client› · N" section. The row's TEXT lands exactly where
//  the offer (or the receipt) would have, through the roads that already land
//  them — nothing new opens anything:
//
//  - a WRITE's row → the receipt's Open › (`openShow` — the place re-read
//    first; gone ⇒ said where she pressed, nothing opened, the row let go);
//  - an ASK's row, while that ask still STANDS → her take of it, exactly
//    (`takeShowOffer` — the ask ends, the take is logged);
//  - an ASK's row once it no longer stands → the take's road without the
//    standing ask (`landAsk`).
//
//  The row's SYMBOL is its other door — the request's details, a glance with
//  no road (the section's popover; nothing read, nothing written).
//

import Foundation
import VariorumMCP

extension MCPDoor {
    /// The row's text: go there (`.mcpOpenTrailPlace`). A row the trail no
    /// longer holds (a gone place let go by another press, the library closed)
    /// does nothing — its face is already gone with it.
    func openTrailEntry(_ id: UUID) {
        guard let entry = trail.trail.entry(id) else { return }
        switch entry.act {
        case .write:
            openShow(ShownChange(target: entry.target, clientName: entry.clientName, title: entry.title))
        case .show(let request):
            if let offer = showOffer, offer.request == request {
                takeShowOffer(offer.itemID)
            } else {
                landAsk(request)
            }
        }
    }

    // MARK: - VX-874 — her hand on the section (rulings (1)–(3))

    /// **The row's ✕ and its right-click Dismiss** (`.mcpDismissTrailEntry`):
    /// the row goes and nothing else (rail (b)) — an ask that still STANDS
    /// keeps its bottom-bar line, its Open › and its ✕; ⌥⌘O's last change
    /// stays; nothing is read or written.
    func dismissTrailEntry(_ id: UUID) {
        trail.update { $0.dismiss(id) }
    }

    /// **Clear All** (`.mcpClearTrail` — her "a clear all button, like the
    /// sidebar too"; the Open list's Close All Notes grammar): every row of
    /// the section goes, every client's — the rows only (no standing ask
    /// ends, ⌥⌘O's last change stays).
    func clearTrail() {
        trail.update { $0.clear() }
    }

    /// **VX-904 — her press on a group's header** (her word: "maybe add ability
    /// to collapse a whole client group"): fold or open THAT client's group.
    /// View state in the trail's session memory — no act, no store, nothing
    /// read (the registry's standing note: a header's collapse is not an act).
    func toggleTrailFold(_ clientName: String) {
        trail.update { $0.toggleFold(clientName) }
    }

    /// **A hand drag's landing** (ruling (3) — rail (a), PROVISIONAL P-874-3):
    /// the row moves among its own stratum (`MCPTrail.reordered` — a drop that
    /// would not act moves nothing). Returns whether anything moved.
    @discardableResult
    func moveTrailEntry(_ id: UUID, onto slot: MCPTrail.Slot) -> Bool {
        var moved = false
        trail.update { moved = $0.move(id, onto: slot) }
        return moved
    }
}
