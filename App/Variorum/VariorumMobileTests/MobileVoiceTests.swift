//
//  MobileVoiceTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 1, batch 3 — the look canon's pins: LK2's phone-local
//  voice preference, the shared VoiceTokens layer's UIKit derivation
//  (fonts on iOS, R51's fully black dark rooms, the per-voice markdown
//  palette), and the object-stability the attribute-equality tests ride.
//

import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile voice — LK2 + the token derivation (S1 batch 3)")
struct MobileVoiceTests {
    /// The batch brief's named verification, MEASURED PRECISELY: Iowan Old
    /// Style ships on iOS 26.2 as a **hidden system font** — absent from
    /// `UIFont.familyNames` (measured: the advertised list has no Iowan),
    /// but the PostScript-name lookup `IowanOldStyle-Roman` resolves it
    /// and the resolved font reports the real family. R49's
    /// nothing-bundled rule holds on the phone; the serif-design fallback
    /// stays the never-reached net on this OS (re-verify per point
    /// release, the LK1 discipline — if a future iOS pulls the hidden
    /// font, THIS pin is the tripwire and the fallback catches the app).
    @Test func iowanOldStyleResolvesByNameOnIOSAndTheStudyFaceUsesIt() {
        #expect(UIFont(name: "IowanOldStyle-Roman", size: 16) != nil)
        #expect(MobileEditorStyle.studyFace.body.familyName == "Iowan Old Style")
    }

    /// The terminal face is the mono voice (the token layer's own rule),
    /// via the system monospaced design — the brief's second font note.
    @Test func terminalBodyIsTheSystemMonospacedDesign() {
        let traits = MobileEditorStyle.terminalFace.body.fontDescriptor.symbolicTraits
        #expect(traits.contains(.traitMonoSpace))
    }

    /// LK2: the preference round-trips in its own store and DEFAULTS to
    /// the terminal voice (the leading voice, R1); an ephemeral suite so
    /// the test never touches the real store.
    @Test func voicePreferenceRoundTripsAndDefaultsTerminal() throws {
        let suite = "MobileVoiceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(MobileVoicePreference.current(defaults) == .terminal)
        MobileVoicePreference.set(.study, defaults)
        #expect(MobileVoicePreference.current(defaults) == .study)
        MobileVoicePreference.set(.terminal, defaults)
        #expect(MobileVoicePreference.current(defaults) == .terminal)
    }

    /// R51 pinned at the UIKit derivation: BOTH voices' dark rooms resolve
    /// to fully black — and the light rooms don't, so the pin proves the
    /// colors are really dynamic (not a stuck resolution).
    @Test func darkRoomsAreFullyBlackInBothVoices() {
        for face in [MobileEditorStyle.terminalFace, MobileEditorStyle.studyFace] {
            let dark = face.room.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .dark))
            var red: CGFloat = -1, green: CGFloat = -1, blue: CGFloat = -1, alpha: CGFloat = -1
            #expect(dark.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
            #expect(red == 0 && green == 0 && blue == 0 && alpha == 1)

            let light = face.room.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .light))
            var lr: CGFloat = -1, lg: CGFloat = -1, lb: CGFloat = -1, la: CGFloat = -1
            #expect(light.getRed(&lr, green: &lg, blue: &lb, alpha: &la))
            #expect(lr > 0 || lg > 0 || lb > 0, "the light room must not be black")
        }
    }

    /// The attribute-equality bar the render tests ride: repeated palette
    /// reads hand back the SAME color objects (the faces are cached), and
    /// the two voices' palettes genuinely differ.
    @Test func palettesAreObjectStableAndPerVoice() {
        #expect(MobileEditorStyle.markdownPalette.marker
                == MobileEditorStyle.markdownPalette.marker)
        #expect(MobileEditorStyle.markdownPalette.codeTint
                == MobileEditorStyle.markdownPalette.codeTint)
        let light = UITraitCollection(userInterfaceStyle: .light)
        let terminalMarker = MobileEditorStyle.terminalFace.palette.marker.resolvedColor(with: light)
        let studyMarker = MobileEditorStyle.studyFace.palette.marker.resolvedColor(with: light)
        #expect(terminalMarker != studyMarker, "the two voices' dimmed-marker inks differ")
        let terminalChip = MobileEditorStyle.terminalFace.palette.codeTint.resolvedColor(with: light)
        let studyChip = MobileEditorStyle.studyFace.palette.codeTint.resolvedColor(with: light)
        #expect(terminalChip != studyChip, "the 13k K10 chip tint is per-voice")
    }

    /// The switched style flows into every surface-write value: fonts,
    /// ink, palette, and the paragraph gap (the Mac's 0.5 × pointSize
    /// rule) all follow the live voice.
    @Test func surfaceWriteValuesFollowTheLiveVoice() {
        MobileEditorStyle.voice = .terminal
        defer { MobileEditorStyle.voice = .terminal }
        let terminalFont = MobileEditorStyle.baseFont
        let terminalGap = MobileEditorStyle.baseParagraphStyle.paragraphSpacing
        #expect(terminalGap == (terminalFont.pointSize * 0.5).rounded())

        MobileEditorStyle.voice = .study
        #expect(MobileEditorStyle.baseFont.familyName == "Iowan Old Style")
        #expect(MobileEditorStyle.markdownPalette
                == MobileEditorStyle.studyFace.palette)
        #expect(MobileEditorStyle.baseParagraphStyle.paragraphSpacing
                == (MobileEditorStyle.baseFont.pointSize * 0.5).rounded())
        #expect(MobileEditorStyle.baseFont != terminalFont)
    }
}
