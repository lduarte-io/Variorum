//
//  ProtectionRoadBar.swift
//  Variorum
//
//  VX-306 U2 — THE OPEN LIBRARY'S PROTECTION LINES on the new road, the Mac's face, in the window's bottom stack beside
//  today's notice bar (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; §7c (2) (3) (7)):
//    - RULE 27's BANNER after a quiet-road open (no key file anywhere). VX-308 U3 — VX-447 (her ruling, QUESTIONS #235):
//      THE BANNER BECOMES THE DOOR where the place beside the library is EMPTY — her U2-7 first sentence (*Variorum opened
//      your library, but found no key file for it anywhere.*), then the door line (the whole line is the door — rule 2's
//      "click here"): record the words (the look, inline in the bar — `WordsLookPanel`, one look at a time through the
//      band) → the core writes a FRESH key file the words lock → the backup follows (rule 5's pair) with one receipt; the
//      banner retires once that look closes over the remade file. A STRAY beside (another key's file) keeps her U2-7
//      words with no door (a mint would write over it — rule 21). The account sentence follows when the library names an
//      account, in its open-library variant (F-U2c-5 folded — her ruling).
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

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        if let model {
            VStack(spacing: 0) {
                if model.showsNoKeyFileBanner, let nothing = model.faces.noKeyFileAnywhere {
                    noKeyFileBanner(nothing, model)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                // A week can pass in one session — the reminder's schedule is re-read when she comes back (the card
                // above the quick entry renders it — VX-307 U2b).
                model.reminder.evaluate()
            }
        }
    }

    /// Rule 27 on the open library — the door where the place beside is empty (VX-447), her U2-7 words otherwise.
    private func noKeyFileBanner(_ nothing: NoKeyFileAnywhere, _ model: RoadStandingModel) -> some View {
        bar {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                if model.faces.noKeyFileDoor {
                    Text(ProtectionWords.noKeyFileOpenedLead)
                        .font(.callout)
                        .fixedSize(horizontal: false, vertical: true)
                    if let look = model.noKeyFileLook, look.phase != .closed {
                        WordsLookPanel(look: look, tokens: tokens)
                    } else if model.offersNoKeyFileDoor {
                        // Her "click here" idiom (rule 2's card): the whole line is the door.
                        Button {
                            Task { await model.openNoKeyFileLook() }
                        } label: {
                            Text(ProtectionWords.noKeyFileDoor)
                                .font(.callout)
                                .foregroundStyle(tokens.accent)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if let message = model.noKeyFileLook?.message {
                            Text(message)
                                .font(.caption)
                                .alarmVoice()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    Text(ProtectionWords.noKeyFileAfterAQuietOpen)
                        .font(.callout)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if nothing.accountRoad {
                    Text(ProtectionWords.noKeyFileAccountRoadOpen)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func bar<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(alignment: .top, spacing: 10) { content() }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
    }
}
