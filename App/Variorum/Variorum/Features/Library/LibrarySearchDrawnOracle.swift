//
//  LibrarySearchDrawnOracle.swift
//  Variorum (Mac)
//
//  **VX-895 (the VX-913 run, B1) — what the Library's search faces DREW**:
//  the answer sheet's groups header ("Notes, with their passages" / "Blocks &
//  scraps") and the band's counts line. The bug it exists for is a VIEW that
//  never re-ran — the header read a property no observation could see, so a
//  facet pick whose answer listed the same groups left the header naming the
//  last facet that changed them. A pin that read the MODEL would be green on
//  that bug (the model held the picked facet all along); this records the
//  words the face built, on appear and whenever a re-run CHANGES them, so a
//  body that never re-runs keeps its stale words here exactly as on screen
//  (`CatalogStampOracle`'s pattern, one surface over).
//
//  Owner-keyed (18k UNIT C4 — `DebugOracleOwnership.swift`: a teardown takes
//  only its own words) and SESSION-scoped (13u2 UNIT E — `DebugProbeScope`:
//  the test host is the dev-store app, whose own Library could write the same
//  slots; the catalog marks only the band and the sheet with its session).
//  DEBUG only: the shipping build carries the slot's name and nothing else.
//

import SwiftUI

/// Which search face's words a recorder reports. Always compiled (the
/// modifier's signature names it); the store is DEBUG-only.
enum LibrarySearchDrawnSlot: String, Hashable {
    /// The answer sheet's section word over the groups.
    case groupsHeader
    /// The band's counts line ("— 7 notes · 7 passages").
    case countsLine
}

#if DEBUG
@MainActor
enum LibrarySearchDrawnOracle {
    private static var store = OwnedRegistrations<String, String>()

    /// The words `slot` last drew in `session`'s Library — nil while that
    /// face is not on screen (or never was).
    static func drawn(_ slot: LibrarySearchDrawnSlot, in session: AppSession) -> String? {
        store[key(slot, session.debugProbeScope)]
    }

    static func record(_ words: String, _ slot: LibrarySearchDrawnSlot, scope: String, owner: UUID) {
        store.publish(words, for: key(slot, scope), owner: owner)
    }

    static func withdraw(_ slot: LibrarySearchDrawnSlot, scope: String, owner: UUID) {
        store.withdraw(key(slot, scope), owner: owner)
    }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() { store.forgetAll() }

    private static func key(_ slot: LibrarySearchDrawnSlot, _ scope: String) -> String {
        "\(scope)\u{2016}\(slot.rawValue)"
    }
}

/// A modifier rather than chained closures so the registrant's token is
/// minted once per view identity (`CatalogStampRecorder`'s reason).
private struct LibrarySearchDrawnRecorder: ViewModifier {
    let slot: LibrarySearchDrawnSlot
    let words: String
    @Environment(\.debugProbeScope) private var scope
    @State private var owner = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear { LibrarySearchDrawnOracle.record(words, slot, scope: scope, owner: owner) }
            .onChange(of: words) { _, new in
                LibrarySearchDrawnOracle.record(new, slot, scope: scope, owner: owner)
            }
            .onDisappear { LibrarySearchDrawnOracle.withdraw(slot, scope: scope, owner: owner) }
    }
}
#endif

extension View {
    /// Report the words this search face draws to the DEBUG oracle; a no-op
    /// outside DEBUG.
    @ViewBuilder
    func librarySearchDrawn(_ slot: LibrarySearchDrawnSlot, _ words: String) -> some View {
        #if DEBUG
        self.modifier(LibrarySearchDrawnRecorder(slot: slot, words: words))
        #else
        self
        #endif
    }
}
