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
}
