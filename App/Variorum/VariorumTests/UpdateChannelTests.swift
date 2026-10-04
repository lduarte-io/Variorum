//
//  UpdateChannelTests.swift
//  VariorumTests
//
//  Phase 13r U2 — the update channel's two standing guards:
//
//  1. R-13r-7's FENCE: a DEBUG build never instantiates the updater. This
//     suite runs in the Debug test host, so it sees the Debug side. A build
//     that dropped the fence would go red here. (No mutation run was made:
//     a mutant that makes Debug live would START Sparkle in a Debug build
//     against the public feed — exactly what the fence forbids. The U2
//     RECORD says so.) The Release side is the release pipeline's own
//     export check plus the walk's.
//  2. THE BUNDLE'S UPDATE KEYS: the baked feed URL is the ruled, LOCKED
//     one; the public key is the one she minted; the installer launcher is
//     on; and the three keys whose ABSENCE is a decision stay absent:
//     automatic checks (so Sparkle asks), system profiling (so nothing
//     extra is sent) and the downloader service (the app holds
//     network.client). The partial Info.plist is shared by both
//     configurations, so the Debug host's bundle reads the same keys the
//     Release export ships.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The update channel (13r U2 — R-13r-7's fence + the bundle's Sparkle keys)")
@MainActor
struct UpdateChannelTests {
    /// The FENCE, read at both of its levels: the build constant and the
    /// channel the app delegate is handed.
    @Test func aDebugBuildNeverInstantiatesTheUpdater() {
        #expect(UpdateChannel.liveInThisBuild == false,
                "R-13r-7: a DEBUG build must never carry a live updater")
        let channel = UpdateChannel.forThisBuild()
        #expect(channel.isLive == false)
    }

    /// The inert channel's door contract: nothing to render (P-2), nothing
    /// enabled, and both acts are harmless no-ops rather than traps.
    @Test func theInertChannelOffersNoDoorAndItsActsDoNothing() {
        let channel = UpdateChannel(live: false)
        #expect(channel.isLive == false)
        #expect(channel.canCheckForUpdates == false)
        channel.start()
        channel.checkForUpdates()
        #expect(channel.canCheckForUpdates == false)
    }

    @Test func theDoorWearsThePlatformsOwnWords() {
        #expect(UpdateChannel.checkForUpdatesTitle == "Check for Updates…")
    }

    @Test func theBakedFeedIsTheLockedStargazingURL() {
        let feed = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String
        #expect(feed == "https://stargazing.tech/variorum/appcast.xml")
    }

    /// The PUBLIC half of the key minted at HER HANDS step 3 (2026-10-04):
    /// exactly that string, and a well-formed Ed25519 public key (32 bytes).
    @Test func thePublicKeyIsTheOneSheMinted() throws {
        let key = try #require(Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String)
        #expect(key == "tn/IQUaJMGk8Q+T8iE3ph2t+xpdzlUDGxg7+k/5xMhA=")
        #expect(Data(base64Encoded: key)?.count == 32)
    }

    @Test func theSandboxedInstallerRoadIsOnAndTheDownloaderIsNot() {
        let launcher = Bundle.main.object(forInfoDictionaryKey: "SUEnableInstallerLauncherService")
        #expect((launcher as? NSNumber)?.boolValue == true,
                "a real Boolean YES, got \(String(describing: launcher))")
        #expect(Bundle.main.object(forInfoDictionaryKey: "SUEnableDownloaderService") == nil)
    }

    /// The absences that ARE decisions: Sparkle must ask before any
    /// automatic check, and no anonymous system profile may ever be offered.
    @Test func consentIsAskedAndNoSystemProfileIsEverSent() {
        #expect(Bundle.main.object(forInfoDictionaryKey: "SUEnableAutomaticChecks") == nil,
                "set, it would skip Sparkle's consent prompt")
        #expect(Bundle.main.object(forInfoDictionaryKey: "SUEnableSystemProfiling") == nil)
        #expect(Bundle.main.object(forInfoDictionaryKey: "SUPromptUserOnFirstLaunch") == nil)
    }
}
