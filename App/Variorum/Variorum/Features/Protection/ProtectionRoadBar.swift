//
//  ProtectionRoadBar.swift
//  Variorum
//
//  VX-306 U2 — THE OPEN LIBRARY'S PROTECTION LINES on the new road, the Mac's face, in the window's bottom stack beside
//  today's notice bar (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; §7c (2) (3) (7)):
//    - RULE 27's BANNER after a quiet-road open (no key file anywhere): §7c (3)'s words — with the account sentence
//      only when the library names an account — STANDING, no doors (nothing rebuilds a key file from the key).
//    - The SPLIT PAIR's standing line (§7c (2)'s last sentence).
//    - RULE 3's REMINDER — a calm ask: §7c (7)'s line, *Set a passphrase…* · *Not now* (and *Don't show again* on a
//      scheduled showing after three dismissals); its door opens the set-passphrase sheet this bar presents.
//  The bars render nothing on today's road (no model).
//

import SwiftUI
import VariorumCore

struct ProtectionRoadBar: View {
    let model: RoadStandingModel?

    @State private var sheet: SetPassphraseModel?

    var body: some View {
        if let model {
            VStack(spacing: 0) {
                if let nothing = model.faces.noKeyFileAnywhere { noKeyFileBanner(nothing) }
                if model.faces.splitPair { splitPairLine }
                if let showing = model.reminder.showing { reminderBar(showing, model: model) }
            }
            .sheet(item: $sheet) { sheet in
                SetPassphraseSheet(model: sheet)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                // A week can pass in one session — the reminder's schedule is re-read when she comes back.
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
                Text(ProtectionWords.noKeyFileAnywhere)
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

    private var splitPairLine: some View {
        bar {
            Text(ProtectionWords.offerSplitPair)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    /// Rule 3's calm ask.
    private func reminderBar(_ showing: PassphraseReminderRules.Showing, model: RoadStandingModel) -> some View {
        bar {
            Text(ProtectionWords.reminderLine)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button(ProtectionWords.reminderSetDoor) {
                sheet = model.makeSetPassphraseSheet { sheet = nil }
            }
            Button(ProtectionWords.reminderNotNow) {
                Task { await model.reminder.notNow() }
            }
            if showing.offersDontShowAgain {
                Button(ProtectionWords.reminderDontShowAgain) {
                    Task { await model.reminder.dontShowAgain() }
                }
            }
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
