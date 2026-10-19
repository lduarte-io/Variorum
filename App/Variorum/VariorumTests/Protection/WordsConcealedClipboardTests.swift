//
//  WordsConcealedClipboardTests.swift
//  VariorumTests — VX-308 U3 piece 3: VX-448 (her ruling, QUESTIONS #235's HER RULINGS block: "concealed pasteboard type +
//  clear at lock/quit; the 60-second timer and the restore-prior-contents go"). `WordsClipboard` — the one home — gains the
//  new road's rule: the words as one line PLUS the concealed marker type, NO timer, nothing restored; cleared at the lock
//  (the bootstrap's `finish`, a library closed behind the lobby) and at quit (`applicationWillTerminate`), and then ONLY
//  if the board still holds that copy. Every drive uses a PRIVATE named pasteboard — her clipboard is never a test's.
//  The wirings are pinned by source (red on the pre-VX-448 tree: the bootstrap's one road was `WordsClipboard.copy`, the
//  60-second timer, and nothing cleared at the lock or at quit). Today's `copy` is untouched (its own pins stand).
//

#if os(macOS)
import AppKit
import Foundation
import Testing

@testable import Variorum

@MainActor
@Suite("VX-308 U3 — VX-448: the words' Copy concealed, cleared at lock and at quit, no timer", .serialized)
struct WordsConcealedClipboardTests {
    static func privateBoard() -> NSPasteboard {
        NSPasteboard(name: NSPasteboard.Name("io.lduarte.variorum.tests.concealed.\(UUID().uuidString)"))
    }

    static let words = (1...12).map { "word\($0)" }

    /// Code lines of a file under `App/Variorum/` (comments dropped).
    static func code(_ relative: String) throws -> String {
        try RoadAccountWordsTests.repoFile("App/Variorum/" + relative)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    /// The words ride ONE line, and the board carries the concealed marker beside them (a clipboard history keeps
    /// nothing of them).
    @Test func theWordsRideOneLineMarkedConcealed() {
        WordsClipboard.clearHeld()
        let board = Self.privateBoard()
        defer { board.releaseGlobally() }
        WordsClipboard.copyConcealed(Self.words, to: board)
        #expect(board.string(forType: .string) == Self.words.joined(separator: " "))
        #expect(board.types?.contains(WordsClipboard.concealedType) == true, "the concealed type is set")
        #expect(WordsClipboard.concealedType.rawValue == "org.nspasteboard.ConcealedType")
        #expect(WordsClipboard.holdsACopy)
        WordsClipboard.clearHeld()
    }

    /// The timer is GONE (nothing clears on its own) and nothing is RESTORED: the clear empties the board — it never
    /// writes back what was there before the copy.
    @Test func noTimerAndNothingRestored() async throws {
        WordsClipboard.clearHeld()
        let board = Self.privateBoard()
        defer { board.releaseGlobally() }
        board.clearContents()
        board.setString("what she had before", forType: .string)
        WordsClipboard.copyConcealed(Self.words, to: board)
        try await Task.sleep(for: .milliseconds(150))
        #expect(board.string(forType: .string) == Self.words.joined(separator: " "), "no timer cleared them")
        #expect(WordsClipboard.clearHeld())
        #expect(board.string(forType: .string) == nil, "emptied — the earlier contents are not restored")
        #expect(!WordsClipboard.holdsACopy)
    }

    /// The clear at lock and at quit empties ONLY its own copy: her later copy is never erased, and the rule lets go
    /// either way.
    @Test func theClearEmptiesOnlyItsOwnCopy() {
        WordsClipboard.clearHeld()
        let board = Self.privateBoard()
        defer { board.releaseGlobally() }
        WordsClipboard.copyConcealed(Self.words, to: board)
        board.clearContents()
        board.setString("her own later copy", forType: .string)
        #expect(!WordsClipboard.clearHeld(), "nothing of hers cleared")
        #expect(board.string(forType: .string) == "her own later copy")
        #expect(!WordsClipboard.holdsACopy)
        #expect(!WordsClipboard.clearHeld(), "a second clear holds nothing")
    }

    /// THE WIRINGS (red on the pre-VX-448 tree): the bootstrap's ONE `copyWords` — every new-road look's road (the
    /// card, the doors' look, the tour, the banner, U2's join moment) — is the concealed rule, never today's timer; the
    /// lock's clear sits in `finish`'s non-ready arm beside the presenter's `libraryClosed`, the new road only; the quit's
    /// in `applicationWillTerminate`; the rule's body sleeps on nothing.
    @Test func everyNewRoadLookRidesItAndTheLockAndTheQuitClearIt() throws {
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        let road = try #require(bootstrap.range(of: "private static func copyWords(_ words: [String])"))
        let roadBody = bootstrap[road.upperBound...].prefix(260)
        #expect(roadBody.contains("WordsClipboard.copyConcealed(words)"), "the one road is the concealed rule")
        #expect(!roadBody.contains("WordsClipboard.copy(words)"), "never today's 60-second timer")
        let finish = try #require(bootstrap.range(of: "private func finish(_ outcome: OpenOutcome)"))
        let finishHead = bootstrap[finish.upperBound...].prefix(700)
        #expect(finishHead.contains("protectionSheets?.libraryClosed()") && finishHead.contains("if newRoad { Self.clearWordsAtLock() }"),
                "the lock's clear beside VX-239's drop, the new road only")
        #expect(bootstrap.contains("WordsClipboard.clearHeld()"), "clearWordsAtLock clears the held copy")
        let delegate = try Self.code("Variorum/VariorumAppDelegate.swift")
        let quit = try #require(delegate.range(of: "func applicationWillTerminate(_ notification: Notification)"))
        #expect(delegate[quit.upperBound...].prefix(400).contains("WordsClipboard.clearHeld()"), "the quit's clear")
        let rule = try Self.code("Shared/WordsCopyDoor.swift")
        let concealed = try #require(rule.range(of: "static func copyConcealed("))
        let concealedBody = rule[concealed.upperBound...].prefix(500)
        #expect(!concealedBody.contains("Task.sleep") && !concealedBody.contains("clearAfter"), "no timer")
        #expect(concealedBody.contains("concealedType"))
    }
}
#endif
