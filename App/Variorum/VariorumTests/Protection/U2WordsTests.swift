//
//  U2WordsTests.swift
//  VariorumTests — VX-309 U2: THE WORDS UNIT's lines, pinned AS DRAFTED (every line here is PROVISIONAL — hers at the bundle —
//  unless it is her own sentence, which is pinned against where she said it). One file so the unit's words live together
//  and her pass can read them in one place. Pure; also runs headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U2 — the words unit's lines, as drafted")
struct U2WordsTests {
    /// A label as a sentence names it (the door's trailing ellipsis dropped).
    static func named(_ door: String) -> String {
        door.hasSuffix("\u{2026}") ? String(door.dropLast()) : door
    }

    /// Her no-shouty-caps rule ("I hate unnecessary caps"): no word in capitals but the platform's own.
    static func shouts(_ line: String) -> [Substring] {
        line.split(whereSeparator: { !$0.isLetter }).filter { word in
            word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
        }
    }

    // MARK: - Piece 3 — Move's not-yet line names the road (her ruling, 2026-10-19)

    /// RED ON OLD: "isn't ready in this build yet" said nothing she could do. The line names the road as the faces stand —
    /// This Mac Only renders only while signed out — in the doors' own names, and what the set-up does (rule 7's hand-up).
    @Test func moveNotYetNamesTheRoad() {
        let line = ProtectionWords.moveNotYet
        #expect(!line.contains("isn't ready"), "a road, not a not-yet")
        #expect(line == "To move this library to that account, sign out, choose Use this \(ProtectionCopy.deviceName) "
            + "only, then sign back in to that account and turn on sync. This library's passphrase and twelve words "
            + "become that account's.")
        #expect(line.contains(Self.named(ProtectionWords.thisMacOnlyDoor)), "This Mac Only by its own name")
        #expect(line.lowercased().contains(Self.named(ProtectionWords.turnOnSyncDoor).lowercased()))
        #expect(line.lowercased().contains(Self.named(ProtectionWords.accountSignOutDoor).lowercased()))
        #expect(Self.shouts(line).isEmpty)
    }
}
