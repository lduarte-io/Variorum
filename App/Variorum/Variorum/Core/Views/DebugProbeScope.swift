//
//  DebugProbeScope.swift
//  Variorum (Mac)
//
//  13u2 UNIT E — **the DEBUG geometry oracles' one scoping rule**
//  (`KnownIssuesAndTechDebt` row 50).
//
//  THE DEFECT, measured at 18d batch 3: the oracles are process-global
//  statics while Swift Testing runs SUITES IN PARALLEL, so a surface mounted
//  by one suite writes into the oracle another suite is reading — a book
//  mounted by `BookIndexEditingTests` landed four chapter rows in a
//  two-chapter book's pin. `.serialized` orders tests WITHIN a suite and does
//  nothing about this. The failure mode is the worst kind: **a green pin that
//  proved nothing.**
//
//  THE RULE, batch 3's and the 18d ladder's: key every oracle by its
//  subject's id, and give each suite subjects no other suite can mint.
//
//  WHAT THIS FILE ADDS, and why it is stronger than the rule as written: the
//  second half of that rule ("a live uuid generator per suite") is a property
//  of the TEST, and eight of the suites that read these oracles mint
//  `.incrementing` uuids — so every one of their posts, blocks and tags is
//  `00000000-…-0000` in every test world at once, and subject-id keying alone
//  would not separate them. Flipping those suites to live uuids would move
//  every seeded expectation they carry.
//
//  So the SCOPE is named by something the pin already holds and that two
//  worlds cannot share whatever the uuid dependency says: **the `AppSession`
//  the surface belongs to**, by object identity. A suite constructs its own
//  session; a concurrent suite's session is a different object; the oracle
//  rows cannot meet. Subject-id keying rides UNDER it wherever an oracle
//  holds many subjects at once (tag cards, stamps, workbench rows), so a pin
//  that mounts two of a thing in one session still names which one it means.
//
//  It travels by ENVIRONMENT rather than by parameter, and that is the whole
//  reason the sweep is cheap: `TakeCardFrame` is a generic value view with no
//  session and dozens of construction sites, and threading a scope argument
//  to each would be a real refactor of shipped view code to serve a DEBUG
//  oracle. A surface sets the scope once at its own root; every probe under
//  it reads it.
//
//  **A surface that forgets is LOUD, not silent** — its reports land under
//  `unscoped`, which no pin reads, so the pin goes red rather than quietly
//  reading a stranger's rectangle. That is the direction this defect class
//  should fail in.
//

import SwiftUI

#if DEBUG
struct DebugProbeScopeKey: EnvironmentKey {
    /// A report with no surface scope. No pin reads this, deliberately.
    static let defaultValue = "unscoped"
}

extension EnvironmentValues {
    var debugProbeScope: String {
        get { self[DebugProbeScopeKey.self] }
        set { self[DebugProbeScopeKey.self] = newValue }
    }
}

extension AppSession {
    /// This session's probe scope — stable for the session's life, and
    /// different for every other live session in the process. A pin names it
    /// to read the oracles its OWN mounts wrote.
    nonisolated var debugProbeScope: String {
        "session-\(UInt(bitPattern: ObjectIdentifier(self).hashValue))"
    }
}
#endif

extension View {
    /// Mark this subtree as belonging to `session`'s probe scope. Applied at
    /// the root of every surface a pin can mount on its own; a no-op outside
    /// DEBUG, so nothing ships.
    @ViewBuilder
    func debugProbeScope(_ session: AppSession) -> some View {
        #if DEBUG
        self.environment(\.debugProbeScope, session.debugProbeScope)
        #else
        self
        #endif
    }

    /// The same, for a pin that mounts a COMPONENT rather than a surface —
    /// a card frame with no session behind it. It names its own world (a
    /// live uuid) so two suites doing the same thing cannot meet.
    @ViewBuilder
    func debugProbeScope(_ scope: String) -> some View {
        #if DEBUG
        self.environment(\.debugProbeScope, scope)
        #else
        self
        #endif
    }
}
