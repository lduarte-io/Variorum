//
//  BookMintDoorsLandSourceTests.swift
//  VariorumTests — VX-1039 (the VX-1036 run, batch 1; the design record's §3a trace, N-1): EVERY MINT DOOR A BOOK
//  DRAWS LANDS ITS NOTE. Her report: "when making a new note within a book, it's made at the bottom of a long list
//  sometimes and then you can't actually see the new note ready to be edited." The mechanism, CONFIRMED by reading
//  (§3a): every mint door calls `BookView.mint(_:reveal:)`, and the navigator foot's three doors — "+ new note",
//  "+ new entry" and a gathering's "+ new note" — passed `reveal: false`, so the note was minted and focused and the
//  page was never asked to go to it. The fix retires the switch: the ONE mint act lands every door's note, so no door
//  can opt out of it again.
//
//  A SOURCE pin, SELF-CONTAINED by design (file reads only, no app import — it runs in a minimal SwiftPM package as
//  well as the Mac target; `#filePath`'s symlinks are resolved): the door's opt-out was a literal argument in a view
//  body, which no hosted test can reach without pressing the navigator's button. It reads CODE lines (line comments
//  dropped — a source pin matches code, never a comment). The act's behaviour — the note arriving on the page, live,
//  with the caret in it — is pinned by the hosted suite `BookMintLandingTests` through ⌥⌘N's road, which is the same
//  act every door now runs.
//
//  RED ON OLD: three call sites passed `reveal: false`, and the act's signature carried the switch.
//

import Foundation
import Testing

@Suite("VX-1039 — every mint door a book draws lands its note (source)")
struct BookMintDoorsLandSourceTests {
    /// `App/Variorum`, from this file (symlinks resolved — a scratch package links the suite in).
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (whole-line comments dropped).
    static func codeLines(_ relative: String) throws -> [String] {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init).filter {
            !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//")
        }
    }

    static let bookView = "Variorum/Features/BookView/BookView.swift"

    /// The lines that call the book's one mint act (`mint(.note …`, `mint(.entry …`, `mint(.gathering …`, or a kind
    /// chosen by the foot rule) — never its declaration.
    static func mintCalls(_ lines: [String]) -> [String] {
        lines.filter { line in
            line.contains("mint(") && !line.contains("func mint(")
                && (line.contains("mint(.") || line.contains("mint(Self.footMint") || line.contains("mint(kind"))
        }
    }

    @Test func noMintDoorOptsOutOfTheLanding() throws {
        let lines = try Self.codeLines(Self.bookView)
        let calls = Self.mintCalls(lines)
        // Non-vacuity: the doors really do run the one act — the navigator foot's (note, entry, gathering), the
        // Outline flow's three, and ⌥⌘N's.
        #expect(calls.count >= 7, "the book's mint doors call the one act: \(calls.count) found")
        let optedOut = calls.filter { $0.contains("reveal: false") }
        #expect(optedOut.isEmpty,
                "a mint door asked the act NOT to land its note (the navigator foot's doors, §3a): \(optedOut.map { $0.trimmingCharacters(in: .whitespaces) })")
    }

    @Test func theMintActCarriesNoLandingSwitch() throws {
        let lines = try Self.codeLines(Self.bookView)
        let declaration = try #require(lines.first { $0.contains("private func mint(") },
                                       "the book's one mint act is declared in BookView")
        #expect(!declaration.contains("reveal"),
                "the act lands every door's note — a door cannot ask it not to: \(declaration.trimmingCharacters(in: .whitespaces))")
    }
}
