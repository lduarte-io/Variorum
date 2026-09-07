//
//  MobileInfoPlistPinTests.swift
//  VariorumMobileTests
//
//  pre-13x ladder round 1, F2 (MINOR-2 — corner 48): every Face ID use on
//  iOS needs `NSFaceIDUsageDescription` in the BUILT Info.plist — without
//  it iOS terminates the app at the first prompt (a flicker of the gate,
//  then death; found on her phone at the second sitting, the first real
//  Face ID gate this phase reached). The key rides both iOS configurations
//  (`INFOPLIST_KEY_NSFaceIDUsageDescription` in the pbxproj); the hosted
//  suite's `Bundle.main` IS the app, so a template re-add or a drift in
//  either configuration fails here, not on her phone.
//

import Foundation
import Testing
@testable import VariorumMobile

@Suite("pre-13x F2 — the built Info.plist carries the Face ID usage description (corner 48)")
struct MobileInfoPlistPinTests {
    @Test func theBuiltProductCarriesTheFaceIDUsageDescription() {
        let value = Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription") as? String
        #expect(value?.isEmpty == false,
                "NSFaceIDUsageDescription must be present and non-empty in the built Info.plist — iOS kills the app at the first Face ID prompt without it")
        #expect(value == "Unlock your Variorum library", "the pbxproj's own sentence (both configurations)")
    }
}
