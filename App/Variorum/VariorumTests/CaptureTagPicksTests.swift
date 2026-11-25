//
//  CaptureTagPicksTests.swift
//  VariorumTests
//
//  VX-1078 (the VX-1036 run, batch 4) — the tags picked on a capture door
//  before the note exists (`Shared/CaptureTagPicks.swift`), pure: how a pick is
//  read (the typed-path rule), how picks join the capture's own `{#…}` tokens
//  at the filing (the tokens untouched and first), and THE MICROSYNTAX
//  UNCHANGED: with nothing picked, the capture the filing applies is the parsed
//  capture, field for field, for every shape the microsyntax suites pin. The
//  doors' end-to-end half is `CaptureTagDoorsTests` (hosted).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-1078 — a capture's picked tags, and the microsyntax unchanged")
struct CaptureTagPicksTests {
    // MARK: - A pick

    @Test func aPickIsReadByTheTypedPathRule() {
        var picks = CaptureTagPicks()
        let first = picks.add("/garden//rhubarb/")
        #expect(first)
        #expect(picks.paths == ["garden/rhubarb"], "slash noise collapses, as a typed path")
        let twice = picks.add("garden/rhubarb")
        #expect(!twice, "the same path twice is one pick")
        let blank = picks.add("   ")
        #expect(!blank, "a blank names nothing")
        let slashes = picks.add("///")
        #expect(!slashes, "nor does a path of slashes")
        let travel = picks.add("travel")
        #expect(travel)
        #expect(picks.paths == ["garden/rhubarb", "travel"], "in the order she picked them")
    }

    @Test func aPillsCrossTakesItsPickOff() {
        var picks = CaptureTagPicks(paths: ["travel", "/errands/", "travel"])
        #expect(picks.paths == ["travel", "errands"], "a restored set reads as a picked one")
        picks.remove("errands/")
        #expect(picks.paths == ["travel"])
        picks.clear()
        #expect(picks.isEmpty)
    }

    // MARK: - At the filing

    /// The tokens first, exactly as parsed and in their order; then each pick
    /// no token already named (by the typed-path rule), each once.
    @Test func theTokensComeFirstAndAPickATokenNamedIsNotAppliedTwice() {
        #expect(CaptureTagPicks.filing(tokens: [], picks: ["travel", "errands"]) == ["travel", "errands"])
        #expect(CaptureTagPicks.filing(tokens: ["dream", "health/workout"], picks: []) == ["dream", "health/workout"])
        #expect(CaptureTagPicks.filing(
            tokens: ["dream", "garden/"], picks: ["sleep", "garden", "dream", "sleep"])
            == ["dream", "garden/", "sleep"],
            "the tokens untouched (even `garden/` as typed); `garden` and `dream` were named; `sleep` once")
    }

    /// `wearing` adds the picks to the tags and changes nothing else.
    @Test func wearingAddsThePicksAndChangesNothingElse() {
        let capture = CaptureMicrosyntax.parse("{t:\"Ocean dream\"} Had a weird dream {#dream}")
        let worn = capture.wearing(CaptureTagPicks(paths: ["sleep", "dream"]))
        #expect(worn.text == capture.text)
        #expect(worn.title == capture.title)
        #expect(worn.tagPaths == ["dream", "sleep"])
    }

    // MARK: - THE MICROSYNTAX UNCHANGED

    /// **With nothing picked, the filing applies the parsed capture, field for
    /// field** — for every shape the microsyntax suites pin (titles, several
    /// tags, nested paths, malformed braces passing through, a token alone on
    /// its line, curly quotes, a bare #hashtag never touched, CRLF). The parse
    /// itself is `CaptureMicrosyntax.swift`, untouched by this batch; its own
    /// suites (`CaptureMicrosyntaxTests`, `CaptureMicrosyntaxDoorTests`,
    /// `CaptureMicrosyntaxLineEndingTests`) run unmodified.
    @Test func withNothingPickedTheFilingIsTheParsedCaptureByteForByte() {
        let captures = [
            "plain words, no braces at all",
            "{t:\"Ocean dream\"} Had a weird dream about the ocean {#dream}",
            "leg day {#health/workout}",
            "{#a} {#b} several {#c/d}",
            "{#} {t:\"\"} {#a{#b malformed stays",
            "{t:\"Title\"}\nthe body on its own line\n{#tag}",
            "{t:\u{201C}Curly\u{201D}} quotes {#x}",
            "a bare #hashtag is never touched",
            "line one {#crlf}\r\nline two",
            "",
        ]
        for raw in captures {
            let parsed = CaptureMicrosyntax.parse(raw)
            #expect(parsed.wearing(CaptureTagPicks()) == parsed, "\(raw.debugDescription)")
        }
    }

    /// And with picks, the tokens' own part of the capture is still exactly
    /// the parse's: the text, the title and the tokens' paths as a prefix.
    @Test func withPicksTheTokensPartIsStillTheParse() {
        let raw = "{#dream} Had a dream {t:\"Night\"} {#sleep/deep}"
        let parsed = CaptureMicrosyntax.parse(raw)
        let worn = parsed.wearing(CaptureTagPicks(paths: ["travel"]))
        #expect(worn.text == parsed.text)
        #expect(worn.title == parsed.title)
        #expect(Array(worn.tagPaths.prefix(parsed.tagPaths.count)) == parsed.tagPaths)
        #expect(worn.tagPaths.count == parsed.tagPaths.count + 1)
    }
}
