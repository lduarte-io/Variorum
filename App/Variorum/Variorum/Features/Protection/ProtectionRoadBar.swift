//
//  ProtectionRoadBar.swift
//  Variorum
//
//  VX-306 U2 — THE OPEN LIBRARY'S PROTECTION LINES on the new road, the Mac's face, in the window's bottom stack beside
//  today's notice bar (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; §7c (2) (3) (7)):
//    - RULE 27's BANNER after a quiet-road open (no key file anywhere): her U2-7 words (VX-414 — *Variorum opened your
//      library, but found no key file for it anywhere. Make a backup now, so a copy exists.*, in place of §7c (3)'s
//      refusal, which spoke of nothing left to open over a library that had just opened) — with the account sentence
//      only when the library names an account — STANDING, no doors (nothing rebuilds a key file from the key).
//    - (The split pair's standing line is DROPPED — no state reaches it; her ruling on P-VX306-U2-6, VX-414.)
//    - (RULE 3's REMINDER lived here until VX-307 U2b: the amended rule 3 makes the card above the quick entry its one
//      home — "never a second bar" — so `WordsBandCard` renders it now, its words and cadence unchanged. This bar still
//      re-reads the reminder's schedule when the app becomes active, for the card.)
//  The bars render nothing on today's road (no model).
//

import SwiftUI
import VariorumCore

struct ProtectionRoadBar: View {
    let model: RoadStandingModel?

    var body: some View {
        if let model {
            VStack(spacing: 0) {
                if let nothing = model.faces.noKeyFileAnywhere { noKeyFileBanner(nothing) }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                // A week can pass in one session — the reminder's schedule is re-read when she comes back (the card
                // above the quick entry renders it — VX-307 U2b).
                model.reminder.evaluate()
            }
        }
    }

    /// Rule 27 on the open library — standing, no doors.
    private func noKeyFileBanner(_ nothing: NoKeyFileAnywhere) -> some View {
        bar {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(ProtectionWords.noKeyFileAfterAQuietOpen)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                if nothing.accountRoad {
                    Text(ProtectionWords.noKeyFileAnywhereAccountRoad)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func bar<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 10) { content() }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
    }
}
