//
//  OneWingChord.swift
//  Variorum (MAC ONLY) — Core/Views (beside the wing switcher's keys)
//
//  13n-c UX walk W-UX-6 — ⌘L WITH ONE WING SPEAKS. Her ruled note (P-13nc-SB-2,
//  reworded at the sitting: "There is only one wing so far — New Wing… under
//  the wing name at the top of the Bookcase makes another, and then ⌘L
//  switches between them.") was declared on `.switchWing` and rendered
//  NOWHERE: View ▸ Switch Wing… is grey with one wing (her ruling — grey with
//  a note, never hidden), a grey menu item swallows its chord in silence, and
//  a grey menu item shows no help. AppSpec §12: "A door that did nothing
//  speaks a refusal." So the chord takes the standing unavailable idiom (⌥⌘A's
//  and ⌥⌘O's — the registry's `unavailableNote` said on the status line as a
//  refusal): an app-wide local monitor sees ⌘L before the menu does, and ONLY
//  while switching is unavailable it consumes the chord and speaks the note.
//  With two or more wings it passes every ⌘L to the menu untouched.
//
//  VX-632 (her #245 RB-6 ruling; A-648-7 — "the grey chord SPEAKING, the
//  OneWingChord W-UX-6 precedent generalized"): the SAME monitor speaks for
//  ⌘L's two ⌥ variants. ⌥⌘L (Move to Wing…) and ⇧⌥⌘L (Copy to Wing…) are
//  View-menu items grey wherever their act cannot run — and a grey item
//  swallows its chord in silence exactly as ⌘L's did — so while the chord's
//  item is grey (`WingChords.enabled`) the monitor consumes it and speaks
//  `WingChords.refusal` (one wing: ⌘L's own note; else the note act's).
//  Enabled, every chord passes to the menu untouched.
//

import AppKit

enum OneWingChord {
    /// One key event's road: consumed (and the note spoken on the session's
    /// status line) when it is ⌘L and switching is unavailable — or (VX-632)
    /// ⌥⌘L / ⇧⌥⌘L while that chord's menu item is grey; otherwise passed on.
    /// Pure of AppKit's dispatch — the pin feeds it real events.
    @MainActor
    static func speak(_ event: NSEvent, session: AppSession?) -> Bool {
        guard let session else { return false }
        if WingSwitcherKeys.key(for: event) == .tapL {
            guard !session.commandRouter.isEnabled(.switchWing) else { return false }
            session.status.refuse(CapabilityRegistry.capability(.switchWing).unavailableNote)
            return true
        }
        guard event.type == .keyDown,
              let chord = WingChords.chord(
                charactersIgnoringModifiers: event.charactersIgnoringModifiers,
                flags: event.modifierFlags),
              !WingChords.enabled(chord, isEnabled: session.commandRouter.isEnabled)
        else { return false }
        session.status.refuse(WingChords.refusal(chord, wingCount: session.wing.wingCount))
        return true
    }

    /// The app's monitor (installed once at launch). Returns the token.
    @MainActor
    static func install(session: @escaping @MainActor () -> AppSession?) -> Any? {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            speak(event, session: session()) ? nil : event
        }
    }
}
