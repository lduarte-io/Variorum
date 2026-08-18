//
//  GlobalHotKey.swift
//  Variorum (Mac)
//
//  Phase 13e, E14 (ledger row W26) — THE TRUE SYSTEM-WIDE HOT KEY, her
//  kickoff-sitting ruling (Round 5): *build it in 13e; chord ⌃⌥⌘N, fixed for
//  now* (a recorder UI is a later at-her-word add).
//
//  ── WHAT IT ADDS, AND WHAT IT DELIBERATELY DOES NOT ─────────────────────
//  The quick note already had three doors (13f W5): the menu-bar extra, ⌘⇧N
//  and File ▸ Quick Note. The first reaches her from any app; the other two
//  only while Variorum is frontmost. This is a FOURTH DOOR on the SAME act —
//  one keystroke that summons the pad with any app in front — so it is
//  declared as another `Capability.Door` on `.quickNote` rather than as a
//  second capability (P-1: every act declared exactly once), and it summons
//  through the ONE summon line every other door uses (`QuickNoteSummon`).
//  There is no second mint path: what the pad becomes is still
//  `QuickNoteMint.file`'s business, untouched.
//
//  ── WHY CARBON, AND WHY NO PERMISSION PROMPT ────────────────────────────
//  The three mechanisms were measured at 13f (W5's proposal table):
//  `NSEvent.addGlobalMonitorForEvents` needs Accessibility (TCC) and
//  `CGEventTap` needs Input Monitoring — both permission-shaped, both refused.
//  `RegisterEventHotKey` is present and NOT deprecated in the macOS 26 SDK
//  (`AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER`, no `DEPRECATED` macro) and
//  needs neither. The no-prompt claim was UNCONFIRMED against any primary
//  Apple source, so it was settled the only honest way — on her machine, at
//  the 13e kickoff sitting (Round 4): `InstallEventHandler: 0` ·
//  `RegisterEventHotKey: 0` · THREE fires with another app frontmost, and NO
//  permission prompt at registration or at fire. Her words: *"i heard the
//  glass chime!"* FB15168205's reported sandbox regression class is
//  ⌥-only/⌥⇧ chords; ⌃⌥⌘N sits outside it.
//
//  ── THE SHAPE, AND WHY EACH SEAM EXISTS ─────────────────────────────────
//  · `GlobalHotKeyChord` PARSES the registry's declared label into the pair
//    Carbon registers, so the words she reads in the helper and the keys the
//    system grabs are ONE source and cannot drift.
//  · `GlobalHotKeySystem` is the four Carbon calls behind an injected value
//    — because a pin that asks the system for HER chord would fight the
//    running app for it, which is exactly the environment-gated tripwire
//    class this phase spent a night dispositioning. Pins drive the whole
//    road (parse → register → route → fire → summon) through `.inert`, and
//    ONE small pin proves `.carbon` itself with a reserved chord.
//  · `fire(_:)` is a NAMED call, not a closure buried in a C callback (the
//    `QuickNotePad` lesson, W20: a promise inside a hook no test can drive
//    is a promise no test can keep).
//

import AppKit
import Carbon.HIToolbox
import os

// MARK: - The chord (a pure rule)

/// The DECLARED label, translated into what Carbon registers.
///
/// One direction on purpose: the registry's `systemShortcutLabel` is the
/// source, and the keys are derived from it — so the helper row, the
/// registry entry and the system registration are the same three characters
/// read three times, never three tables kept in step by hand.
nonisolated enum GlobalHotKeyChord {
    struct Chord: Equatable, Sendable {
        /// A Carbon virtual key code (`kVK_ANSI_*`).
        let keyCode: UInt32
        /// Carbon's own modifier mask (`cmdKey`, `optionKey`, …) — NOT
        /// `NSEvent.ModifierFlags`, and not SwiftUI's `EventModifiers`.
        let modifiers: UInt32
    }

    /// The modifier glyphs, in the order macOS writes them.
    static let modifierGlyphs: [(glyph: Character, carbon: Int)] = [
        ("\u{2303}", controlKey),  // ⌃
        ("\u{2325}", optionKey),   // ⌥
        ("\u{21E7}", shiftKey),    // ⇧
        ("\u{2318}", cmdKey),      // ⌘
    ]

    /// `"⌃⌥⌘N"` → the pair `RegisterEventHotKey` takes. nil when the label
    /// carries no modifier, names a key this table has no code for, or is not
    /// exactly "modifiers then one key" — all three are declaration mistakes,
    /// and the registry walk turns them into a failing test rather than a
    /// hot key that quietly never fires.
    static func chord(forLabel label: String) -> Chord? {
        var modifiers = 0
        var remaining = Substring(label)
        while let first = remaining.first,
              let match = modifierGlyphs.first(where: { $0.glyph == first }) {
            modifiers |= match.carbon
            remaining = remaining.dropFirst()
        }
        guard modifiers != 0, remaining.count == 1,
              let keyCode = keyCode(for: remaining[remaining.startIndex])
        else { return nil }
        return Chord(keyCode: UInt32(keyCode), modifiers: UInt32(modifiers))
    }

    /// The US-layout virtual key codes, by the SDK's own names rather than by
    /// magic numbers. Letters only: every chord a global summon could
    /// sensibly wear is a letter, and a key this table does not know is
    /// caught by the walk instead of failing silently at launch.
    static func keyCode(for character: Character) -> Int? {
        switch character.uppercased() {
        case "A": kVK_ANSI_A
        case "B": kVK_ANSI_B
        case "C": kVK_ANSI_C
        case "D": kVK_ANSI_D
        case "E": kVK_ANSI_E
        case "F": kVK_ANSI_F
        case "G": kVK_ANSI_G
        case "H": kVK_ANSI_H
        case "I": kVK_ANSI_I
        case "J": kVK_ANSI_J
        case "K": kVK_ANSI_K
        case "L": kVK_ANSI_L
        case "M": kVK_ANSI_M
        case "N": kVK_ANSI_N
        case "O": kVK_ANSI_O
        case "P": kVK_ANSI_P
        case "Q": kVK_ANSI_Q
        case "R": kVK_ANSI_R
        case "S": kVK_ANSI_S
        case "T": kVK_ANSI_T
        case "U": kVK_ANSI_U
        case "V": kVK_ANSI_V
        case "W": kVK_ANSI_W
        case "X": kVK_ANSI_X
        case "Y": kVK_ANSI_Y
        case "Z": kVK_ANSI_Z
        default: nil
        }
    }
}

// MARK: - The system, injected

/// The four Carbon calls, behind a value — the app's own
/// injected-dependency idiom applied to the one seam that reaches outside
/// the process.
@MainActor
struct GlobalHotKeySystem {
    var installHandler: (UnsafeMutableRawPointer) -> (EventHandlerRef?, OSStatus)
    var register: (GlobalHotKeyChord.Chord, EventHotKeyID) -> (EventHotKeyRef?, OSStatus)
    var unregister: (EventHotKeyRef) -> OSStatus
    var removeHandler: (EventHandlerRef) -> OSStatus

    /// The real one.
    static let carbon = GlobalHotKeySystem(
        installHandler: { userData in
            var spec = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed))
            var ref: EventHandlerRef?
            // A NON-CAPTURING literal, so Swift can hand it over as a C
            // function pointer. Everything it needs rides `userData`.
            let status = InstallEventHandler(
                GetApplicationEventTarget(),
                { _, event, userData -> OSStatus in
                    guard let event, let userData else { return OSStatus(eventNotHandledErr) }
                    var hotKeyID = EventHotKeyID()
                    let read = GetEventParameter(
                        event, EventParamName(kEventParamDirectObject),
                        EventParamType(typeEventHotKeyID), nil,
                        MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
                    guard read == noErr else { return read }
                    // The pointer crosses as its ADDRESS, deliberately: a raw
                    // pointer is not `Sendable`, and Swift 6 is right to
                    // refuse to send one into an isolated closure — a number
                    // is the honest way to carry it, and the box is
                    // reconstituted on the actor that owns it.
                    let address = UInt(bitPattern: userData)
                    let pressed = hotKeyID.id
                    // Carbon delivers hot keys on the app's own event loop,
                    // which IS the main thread — so this is an assertion of
                    // a fact, not a hop.
                    MainActor.assumeIsolated {
                        guard let raw = UnsafeMutableRawPointer(bitPattern: address)
                        else { return }
                        Unmanaged<GlobalHotKeyBox>.fromOpaque(raw)
                            .takeUnretainedValue().center?.fire(pressed)
                    }
                    return noErr
                },
                1, &spec, userData, &ref)
            return (ref, status)
        },
        register: { chord, id in
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(
                chord.keyCode, chord.modifiers, id, GetApplicationEventTarget(), 0, &ref)
            return (ref, status)
        },
        unregister: { UnregisterEventHotKey($0) },
        removeHandler: { RemoveEventHandler($0) })

    /// The pins' one — it takes the same road and asks the system for
    /// nothing, so a suite never fights the running app for a hot key.
    static let inert = GlobalHotKeySystem(
        installHandler: { _ in (nil, noErr) },
        register: { _, _ in (nil, noErr) },
        unregister: { _ in noErr },
        removeHandler: { _ in noErr })
}

/// What the C callback is handed. It holds the centre WEAKLY, so a centre
/// that dies before its handler is removed makes the callback a no-op rather
/// than a dangling read; the box itself is retained by the userData pointer
/// and released in `uninstall()`.
@MainActor
final class GlobalHotKeyBox {
    weak var center: GlobalHotKeyCenter?
}

// MARK: - The centre

/// The app's system hot keys: one per declared `.systemHotKey` door.
@MainActor
final class GlobalHotKeyCenter {
    /// **The declared ⇔ registered table** (P-1's walk, the `.menuBarExtra`
    /// precedent from 13f W5): the acts this app asks the SYSTEM for. A door
    /// added to the registry without a line here — or a line here without the
    /// door — fails `theSystemHotKeysRegisterExactlyTheDeclaredGlobalDoors`.
    nonisolated static let registered: [CapabilityID] = [.quickNote]

    /// The four-character signature Carbon files our hot keys under.
    /// ("VRHK" — Variorum hot key.)
    nonisolated static let signature = OSType(0x5652_484B)

    struct Registration: Equatable, Sendable {
        let id: CapabilityID
        let chord: GlobalHotKeyChord.Chord
        /// Carbon's own answer. `noErr` is the only success; the sandboxed
        /// verification act reads this through the log line below.
        let status: OSStatus
        var isLive: Bool { status == noErr }
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "global-hotkey")

    private(set) var registrations: [Registration] = []
    /// How many times the system has handed us a press. Read by pins; also
    /// the number the log line reports, so the verification act can tell a
    /// real fire from a coincidence.
    private(set) var fires = 0

    private let system: GlobalHotKeySystem
    private var routes: [UInt32: CapabilityID] = [:]
    private var refs: [UInt32: EventHotKeyRef] = [:]
    private var handler: EventHandlerRef?
    private var box: GlobalHotKeyBox?
    private var summon: ((CapabilityID) -> Void)?

    init(system: GlobalHotKeySystem = .carbon) { self.system = system }

    /// Ask the system for every declared chord, and say what to do with a
    /// press.
    ///
    /// **Idempotent**, because the caller is a window's `onAppear` and there
    /// can be several windows: a second call only replaces the action (every
    /// window's action opens the same singleton pad, so replacing it is a
    /// no-op in behaviour and keeps the freshest environment).
    @discardableResult
    func install(summon: @escaping (CapabilityID) -> Void) -> [Registration] {
        self.summon = summon
        guard registrations.isEmpty else { return registrations }

        let box = GlobalHotKeyBox()
        box.center = self
        self.box = box
        let (handler, handlerStatus) = system.installHandler(
            Unmanaged.passRetained(box).toOpaque())
        self.handler = handler
        Self.log.notice("InstallEventHandler status=\(handlerStatus, privacy: .public)")

        var made: [Registration] = []
        for (index, id) in Self.registered.enumerated() {
            let label = CapabilityRegistry.capability(id).systemShortcutLabel
            guard let label, let chord = GlobalHotKeyChord.chord(forLabel: label) else {
                Self.log.error(
                    "\(id.rawValue, privacy: .public) declares no readable system chord")
                continue
            }
            let raw = UInt32(index + 1)
            routes[raw] = id
            let (ref, status) = system.register(
                chord, EventHotKeyID(signature: Self.signature, id: raw))
            if let ref, status == noErr { refs[raw] = ref }
            made.append(Registration(id: id, chord: chord, status: status))
            Self.log.notice(
                """
                RegisterEventHotKey \(id.rawValue, privacy: .public) \
                \(label, privacy: .public) keyCode=\(chord.keyCode, privacy: .public) \
                modifiers=\(chord.modifiers, privacy: .public) \
                status=\(status, privacy: .public)
                """)
        }
        registrations = made
        return made
    }

    /// **What a press DOES** — named, so a pin drives the same call the C
    /// callback makes (the `QuickNotePad` lesson). A press for a hot key we
    /// never routed is ignored: another app's registration cannot reach us,
    /// but a stale id after `uninstall()` could.
    func fire(_ raw: UInt32) {
        guard let id = routes[raw] else { return }
        fires += 1
        Self.log.notice(
            "hot key fired: \(id.rawValue, privacy: .public) (fire #\(self.fires, privacy: .public))")
        summon?(id)
    }

    /// Hand every chord back to the system. The app never calls this — the
    /// centre lives as long as the app does — but the pin that exercises the
    /// REAL Carbon road does, and so would a future recorder UI re-picking a
    /// chord.
    func uninstall() {
        for ref in refs.values { _ = system.unregister(ref) }
        refs.removeAll()
        routes.removeAll()
        registrations.removeAll()
        if let handler { _ = system.removeHandler(handler) }
        handler = nil
        if let box { Unmanaged.passUnretained(box).release() }
        box = nil
        summon = nil
    }
}

// MARK: - The one summon line

/// **What every quick-note door does**, in one place.
///
/// The pad is a singleton `Window` scene, so "summon" is one call — and the
/// reason it is a named function rather than four copies of that call is
/// `NSApp.activate()`: two of the four doors (this hot key and the menu-bar
/// extra) are pressed while ANOTHER APP is frontmost, and without activating,
/// the floating pad opens behind whatever she was looking at. The other two
/// doors are pressed while Variorum is already frontmost, where activating is
/// a no-op — so one line serves all four rather than two knowing a rule the
/// other two don't.
@MainActor
enum QuickNoteSummon {
    static func summon(opening open: (String) -> Void) {
        NSApp.activate()
        open(EditorCommands.quickNoteWindowGroupID)
    }
}
