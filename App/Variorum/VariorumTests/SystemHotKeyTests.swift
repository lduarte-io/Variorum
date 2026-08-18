//
//  SystemHotKeyTests.swift
//  VariorumTests
//
//  Phase 13e, E14 (W26) — the TRUE system-wide quick-note hot key.
//
//  These are FEATURE pins (the batch-2/3 convention): E14 builds a door that
//  did not exist, so no red-on-old is owed for the door itself. What they
//  hold is the road that could go wrong silently — a chord registered that is
//  not the chord declared, a declaration nobody registers, a press that
//  reaches no summon — none of which a person would notice until she pressed
//  the keys and nothing happened.
//
//  **The batch's own verification act is NOT here, deliberately.** Whether a
//  SANDBOXED Variorum can hold a system hot key at all was settled the only
//  honest way: the Debug app (bundle id `io.lduarte.Variorum.debug`,
//  `com.apple.security.app-sandbox = true`, verified by `codesign -d
//  --entitlements`) was built, launched and driven with ANOTHER APP
//  FRONTMOST. The evidence is in the batch record: `InstallEventHandler
//  status=0` · `RegisterEventHotKey quickNote ⌃⌥⌘N keyCode=45
//  modifiers=6400 status=0` · two fires from two different frontmost apps,
//  each opening the pad, with no permission prompt at any point.
//

import Carbon.HIToolbox
import Testing

@testable import Variorum

// MARK: - The chord (a pure rule)

@MainActor
@Suite("The system hot key's chord (13e E14)")
struct SystemHotKeyChordTests {
    /// The one that matters: the words the helper shows, the label the
    /// registry declares and the keys Carbon is asked for are ONE source read
    /// three times. A drift here is a key she reads about and presses to no
    /// effect.
    @Test func theDeclaredLabelIsExactlyTheChordTheSystemIsAskedFor() throws {
        let label = try #require(
            CapabilityRegistry.capability(.quickNote).systemShortcutLabel)
        #expect(label == "\u{2303}\u{2325}\u{2318}N", "her Round-5 pick: ⌃⌥⌘N")
        let chord = try #require(GlobalHotKeyChord.chord(forLabel: label))
        #expect(chord.keyCode == UInt32(kVK_ANSI_N))
        #expect(chord.modifiers == UInt32(controlKey | optionKey | cmdKey))
        // The number the sandboxed verification act logged, stated here so
        // the record and the code can be read against each other.
        #expect(chord.modifiers == 6400)
    }

    @Test func everyModifierGlyphCarriesItsOwnCarbonBit() throws {
        let cases: [(String, Int)] = [
            ("\u{2303}N", controlKey), ("\u{2325}N", optionKey),
            ("\u{21E7}N", shiftKey), ("\u{2318}N", cmdKey),
        ]
        for (label, bit) in cases {
            let chord = try #require(GlobalHotKeyChord.chord(forLabel: label), "\(label)")
            #expect(chord.modifiers == UInt32(bit), "\(label)")
            #expect(chord.keyCode == UInt32(kVK_ANSI_N), "\(label)")
        }
    }

    /// A declaration mistake must be a FAILING TEST, never a hot key that
    /// quietly never fires.
    @Test func aLabelThatIsNotModifiersThenOneLetterIsRefused() {
        #expect(GlobalHotKeyChord.chord(forLabel: "N") == nil, "no modifier at all")
        #expect(GlobalHotKeyChord.chord(forLabel: "\u{2318}") == nil, "no key")
        #expect(GlobalHotKeyChord.chord(forLabel: "\u{2318}NN") == nil, "two keys")
        #expect(GlobalHotKeyChord.chord(forLabel: "\u{2318}1") == nil, "not a letter")
        #expect(GlobalHotKeyChord.chord(forLabel: "") == nil)
    }

    @Test func theLetterTableCoversTheAlphabetAndNothingElse() {
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            #expect(GlobalHotKeyChord.keyCode(for: letter) != nil, "\(letter)")
            #expect(GlobalHotKeyChord.keyCode(for: Character(letter.lowercased()))
                    == GlobalHotKeyChord.keyCode(for: letter), "case-insensitive")
        }
        #expect(GlobalHotKeyChord.keyCode(for: "7") == nil)
        #expect(GlobalHotKeyChord.keyCode(for: "\u{2318}") == nil)
    }
}

// MARK: - The declaration (P-1)

@MainActor
@Suite("The system hot key's declaration (13e E14)")
struct SystemHotKeyDeclarationTests {
    /// **The walk** — declared ⇔ registered, the `.menuBarExtra` table's own
    /// assertion one door further out. A `.systemHotKey` door nobody asks the
    /// system for is a promise the app does not keep; a chord asked for
    /// without a declaration is a key with no home in the catalog and no row
    /// in the helper.
    @Test func theSystemHotKeysRegisterExactlyTheDeclaredGlobalDoors() {
        #expect(Set(GlobalHotKeyCenter.registered)
                == CapabilityRegistry.doored(.systemHotKey))
    }

    @Test func theQuickNoteActCarriesTheSystemDoorBesideItsThreeOthers() {
        let capability = CapabilityRegistry.capability(.quickNote)
        #expect(capability.doors == [.menuBar, .menuBarExtra, .palette, .systemHotKey],
                "one act, four doors — the system chord is not a second capability")
        #expect(capability.shortcutLabel == "\u{2318}\u{21e7}N",
                "the IN-APP chord is untouched: ⌘⇧N still pops the pad from inside")
    }

    /// Every declared system chord is READABLE (so it can be registered) and
    /// FINDABLE (13g L1's discoverability guard, extended to the second kind
    /// of key — a chord that works while Variorum is not even in front is
    /// exactly the one she most needs written down).
    @Test func everyDeclaredSystemChordIsReadableAndNamedInTheHelper() {
        let shown = HelperView.shortcutKeysShown
        for capability in CapabilityRegistry.all {
            guard let label = capability.systemShortcutLabel else { continue }
            #expect(GlobalHotKeyChord.chord(forLabel: label) != nil,
                    "\(capability.id) declares \(label) and Carbon must be able to take it")
            #expect(shown.contains(label),
                    "\(capability.id) declares \(label) — the helper (⌘/) must show it")
            #expect(capability.doors.contains(.systemHotKey),
                    "\(capability.id) declares a system chord, so it wears the system door")
        }
    }

    /// A system chord SHADOWS: once Carbon holds it, the app's own menu never
    /// sees those keys. So it must not duplicate an in-app chord, and two
    /// system chords must not duplicate each other.
    @Test func noSystemChordShadowsAnInAppOneOrAnother() {
        var systemLabels: Set<String> = []
        let inApp = Set(CapabilityRegistry.all.compactMap(\.shortcutLabel))
        for capability in CapabilityRegistry.all {
            guard let label = capability.systemShortcutLabel else { continue }
            #expect(!inApp.contains(label),
                    "\(capability.id)'s system chord \(label) would shadow an in-app key")
            #expect(!systemLabels.contains(label), "two system chords on \(label)")
            systemLabels.insert(label)
        }
        #expect(systemLabels == ["\u{2303}\u{2325}\u{2318}N"])
    }
}

// MARK: - The road: install → route → fire → summon

/// A recording stand-in for the four Carbon calls. Pins drive the WHOLE road
/// through it, so a suite never asks the system for her chord — which the
/// running app itself holds, and a test that fights the app for a hot key is
/// the environment-gated tripwire class this phase spent a night
/// dispositioning.
@MainActor
final class RecordingHotKeySystem {
    var handlerInstalls = 0
    var registered: [GlobalHotKeyChord.Chord] = []
    var registeredIDs: [UInt32] = []
    var unregistered = 0
    var handlersRemoved = 0
    var status: OSStatus = noErr

    private let fakeRef = OpaquePointer(bitPattern: 0x1234)!

    var system: GlobalHotKeySystem {
        GlobalHotKeySystem(
            installHandler: { _ in
                self.handlerInstalls += 1
                return (self.fakeRef, noErr)
            },
            register: { chord, id in
                self.registered.append(chord)
                self.registeredIDs.append(id.id)
                return (self.status == noErr ? self.fakeRef : nil, self.status)
            },
            unregister: { _ in
                self.unregistered += 1
                return noErr
            },
            removeHandler: { _ in
                self.handlersRemoved += 1
                return noErr
            })
    }
}

@MainActor
@Suite("The system hot key's road (13e E14)")
struct SystemHotKeyRoadTests {
    @Test func installingAsksForEveryDeclaredChordAndRoutesThePress() {
        let fake = RecordingHotKeySystem()
        let center = GlobalHotKeyCenter(system: fake.system)
        var summoned: [CapabilityID] = []

        let made = center.install { summoned.append($0) }

        #expect(fake.handlerInstalls == 1)
        #expect(fake.registered.count == 1, "one declared system door today")
        #expect(fake.registered.first?.keyCode == UInt32(kVK_ANSI_N))
        #expect(fake.registered.first?.modifiers == UInt32(controlKey | optionKey | cmdKey))
        #expect(made.map(\.id) == [.quickNote])
        #expect(made.first?.isLive == true)
        #expect(center.registrations == made)

        // The press, driven at the same named call the C callback makes.
        let pressed = try? #require(fake.registeredIDs.first)
        center.fire(pressed ?? 0)
        #expect(summoned == [.quickNote])
        #expect(center.fires == 1)
    }

    /// Two windows means two `onAppear`s. The second must not ask the system
    /// for a chord it already holds (which Carbon answers with
    /// `eventHotKeyExistsErr`) — it only replaces the action.
    @Test func aSecondInstallReplacesTheActionAndAsksForNothingNew() {
        let fake = RecordingHotKeySystem()
        let center = GlobalHotKeyCenter(system: fake.system)
        var first = 0
        var second = 0
        center.install { _ in first += 1 }
        center.install { _ in second += 1 }

        #expect(fake.handlerInstalls == 1, "one handler, however many windows")
        #expect(fake.registered.count == 1, "one registration, however many windows")

        center.fire(1)
        #expect(first == 0, "the freshest window's action is the live one")
        #expect(second == 1)
    }

    @Test func aPressForAChordWeNeverRoutedIsIgnored() {
        let fake = RecordingHotKeySystem()
        let center = GlobalHotKeyCenter(system: fake.system)
        var summoned = 0
        center.install { _ in summoned += 1 }

        center.fire(97)
        #expect(summoned == 0)
        #expect(center.fires == 0, "an unrouted id is not a fire")
    }

    @Test func uninstallHandsEveryChordBackAndStopsAnsweringPresses() {
        let fake = RecordingHotKeySystem()
        let center = GlobalHotKeyCenter(system: fake.system)
        var summoned = 0
        center.install { _ in summoned += 1 }

        center.uninstall()
        #expect(fake.unregistered == 1)
        #expect(fake.handlersRemoved == 1)
        #expect(center.registrations.isEmpty)

        center.fire(1)
        #expect(summoned == 0, "a released chord's stale press reaches nothing")
    }

    /// A refusal is RECORDED rather than pretended away: a chord the system
    /// will not give us leaves a registration whose status says so, and the
    /// log line the verification act reads carries the same number.
    @Test func aRefusedRegistrationIsRecordedWithItsStatus() {
        let fake = RecordingHotKeySystem()
        fake.status = OSStatus(eventHotKeyExistsErr)
        let center = GlobalHotKeyCenter(system: fake.system)
        center.install { _ in }

        #expect(center.registrations.first?.status == OSStatus(eventHotKeyExistsErr))
        #expect(center.registrations.first?.isLive == false)
    }

    /// **The one pin that touches the real system**, with a RESERVED chord —
    /// never the app's, so it can never fight a running Variorum for ⌃⌥⌘N.
    /// It holds the plumbing the sandboxed verification act proved in the
    /// shipping context: Carbon takes a handler and a chord and gives them
    /// back.
    @Test func theCarbonRoadItselfTakesAChordAndReleasesIt() {
        let reserved = GlobalHotKeyChord.Chord(
            keyCode: UInt32(kVK_ANSI_Q),
            modifiers: UInt32(controlKey | optionKey | shiftKey | cmdKey))
        let id = EventHotKeyID(signature: GlobalHotKeyCenter.signature, id: 9_001)
        let (ref, status) = GlobalHotKeySystem.carbon.register(reserved, id)
        #expect(status == noErr, "RegisterEventHotKey answered \(status)")
        if let ref {
            #expect(GlobalHotKeySystem.carbon.unregister(ref) == noErr)
        } else {
            Issue.record("a noErr registration must carry a ref")
        }
    }

    /// The summon every door shares — one window id, so all four doors open
    /// the same singleton pad rather than four ideas of one.
    @Test func theSummonOpensExactlyTheOnePadWindow() {
        var opened: [String] = []
        QuickNoteSummon.summon { opened.append($0) }
        #expect(opened == [EditorCommands.quickNoteWindowGroupID])
    }
}
