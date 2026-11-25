//
//  MobileVoiceTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 1, batch 3 — the look canon's pins (LK2's phone-local
//  voice preference retired at VM-51), the shared VoiceTokens layer's UIKit derivation
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

    // (LK2's phone-local preference pin — `voicePreferenceRoundTripsAndDefaultsTerminal`
    // — retired with the preference at VM-51: the phone wears the LIBRARY's voice
    // and palette. Its successors are `MobileLibraryLookTests`.)

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
    /// ink, palette, and the paragraph gap + line air all follow the
    /// live voice. **VM-48 moved these pins to the sizing sheet's note
    /// body** — Study Iowan 17 on a 27 pt line with a 14 pt paragraph gap,
    /// Terminal SF Mono 15 on 25 with 12 (two under) — measured at the
    /// default text size, where `UIFontMetrics` is the identity. (They
    /// held the A3 spacing floor before: gap 1.0 × and line 0.4 × the
    /// point size, at 14 / 16.) **MOVED with VM-254** (the VM-260 run, batch
    /// 3, her R-260-2): the note's body one notch under — Study Iowan 16 on
    /// 25, Terminal SF Mono 14 on 23 — the paragraph gaps kept (14 / 12).
    @Test func surfaceWriteValuesFollowTheLiveVoice() {
        // VM-51: the baseline is the whole look (voice AND palette — the face
        // wears the library's palette now), so a landing another suite adopted
        // cannot colour this pin's palette compare.
        MobileEditorStyle.adopt(Queries.ThemeSettings())
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        let terminalFont = MobileEditorStyle.baseFont
        let terminalStyle = MobileEditorStyle.baseParagraphStyle
        #expect(terminalFont.pointSize == 14)
        #expect(terminalStyle.paragraphSpacing == 12)
        #expect(abs(terminalFont.lineHeight + terminalStyle.lineSpacing - 23) <= 0.5,
                "terminal pitch \(terminalFont.lineHeight + terminalStyle.lineSpacing)")

        MobileEditorStyle.voice = .study
        #expect(MobileEditorStyle.baseFont.familyName == "Iowan Old Style")
        #expect(MobileEditorStyle.baseFont.pointSize == 16)
        #expect(MobileEditorStyle.markdownPalette
                == MobileEditorStyle.studyFace.palette)
        #expect(MobileEditorStyle.baseParagraphStyle.paragraphSpacing == 14)
        let studyPitch = MobileEditorStyle.baseFont.lineHeight
            + MobileEditorStyle.baseParagraphStyle.lineSpacing
        #expect(abs(studyPitch - 25) <= 0.5, "study pitch \(studyPitch)")
        #expect(MobileEditorStyle.baseFont != terminalFont)
    }
}
