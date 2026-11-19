//
//  MobileRawErrorPinTests.swift
//  VariorumMobileTests
//
//  **VM-62 — REFUSALS IN PLAIN WORDS, NEVER RAW ERROR TEXT** (umbrella VM-55,
//  batch 2b; a Bug, pin before fix). Two suites, both RED on the tree they were
//  committed on (the run's batch 2a + P-55-11 tree) and green on the fix:
//
//  · `MobileNoRawErrorPinTests` — a SOURCE SCAN of every Swift file under
//    `VariorumMobile/` (every folder, `Features/Protection/` and `Spike/`
//    included). Comments are stripped; code and string contents are kept. A
//    line fails when it holds any of:
//      – `String(describing:` or `String(reflecting:` (the enum dump);
//      – `.localizedDescription`;
//      – an error binding interpolated into a string — `\(error)`, `\(err)`,
//        `\(failure)` (the `"Refused: \(error)"` shape);
//      – a call to one of the shared roads that END in a dump:
//        `DeletionRefusal.fallback(` / `DeletionRefusal.words(` (its last
//        resort is "That couldn't be done — ‹the dump›."),
//        `OpsRefusalCopy.message(` ("Refused: ‹the dump›") and
//        `VersionActs.words(` (it falls to `DeletionRefusal`).
//    Exempt, and only these: a line that is an `os.Logger` call or a wrapped
//    line of one (the unified log is read by no face — the raw detail is
//    SUPPOSED to go there), and two
//    named lines in `MobileStarterJournal.swift` whose outcome is recorded and
//    never surfaced (each exemption must match exactly one line, or it is
//    stale and trips).
//
//    **What it cannot see** (said here so nobody reads more into green):
//      1. Shared code the phone renders that dumps INSIDE itself — a Shared
//         helper other than the four roads above. Known today: the R94 sync
//         row and the Protection screen's `ErrorCauseNote` (the verbatim
//         cause is her R94 ruling, not a dump to fix); the store-open failure
//         screen's `reason`, which `Shared/AppBootstrap.swift` builds from
//         `String(describing:)` (custody-adjacent — VM-103's remainder, named
//         in the batch 2b record).
//      2. An error under another name (`"\(thrown)"`), or one passed through
//         a variable first (`let d = "\(e)"`, with `e` not one of the three
//         names) — the scan matches names, not types.
//      3. Whether a forbidden expression would actually RENDER: it forbids
//         the expressions everywhere in phone code except the log, so a dump
//         that only ever reached a log must be written as a log call.
//      4. A `//` inside a string that the simple state machine mis-tracks
//         (a literal nested in an interpolation) can hide the rest of that
//         line — the `stringLiteralContents` walk's own recorded limit.
//
//  · `MobileRefusalSentencePinTests` — the audit's named refusals (B §0.6 /
//    I3 / I4 / M2, C N1 / N5), each through its REAL door over a real store,
//    asserting the sentence the shared table speaks on the phone's road — on
//    the model's slot AND on the one line — and that no case name leaks:
//    Finish on a gathering, Reopen on a sealed book, rename (a note gone under
//    the masthead), unseal (a note in a sealed book), star (a note gone under
//    the press).
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

// MARK: - The source scan

@Suite("VM-62 — no raw error text reaches a phone string")
struct MobileNoRawErrorPinTests {
    /// Each forbidden expression, by name (the offender list says which).
    private static var forbidden: [(name: String, pattern: Regex<Substring>)] { [
        ("String(describing:)", /String\(\s*describing:/),
        ("String(reflecting:)", /String\(\s*reflecting:/),
        (".localizedDescription", /\.localizedDescription\b/),
        ("an error interpolated into a string", /\\\(\s*(?:error|err|failure)\s*\)/),
        ("DeletionRefusal's dumping roads", /DeletionRefusal\.(?:fallback|words)\(/),
        ("OpsRefusalCopy.message (ends in \"Refused: …\")", /OpsRefusalCopy\.message\(/),
        ("VersionActs.words (falls to DeletionRefusal's dump)", /VersionActs\.words\(/),
    ] }

    /// A line that is an `os.Logger` call — the unified log, read by no face —
    /// or a line of one (an `OSLogMessage` interpolation's `privacy:` argument
    /// exists nowhere else, so a call's wrapped message line is known by it).
    private static var logCall: Regex<Substring> {
        /\b(?:log|logger|Log)\.(?:notice|info|debug|error|fault|warning|trace|critical|log)\(|,\s*privacy:\s*\./
    }

    /// The named exemptions — each a recorded, never-surfaced outcome — and
    /// each must match EXACTLY one line (a stale or doubled entry trips).
    private static let exempt: [(file: String, line: String, why: String)] = [
        ("MobileStarterJournal.swift", "return .refused(String(describing: error))",
         "the starter journal's refused outcome is recorded, never surfaced: "
            + "`MobileFirstWriteFurniture` logs it in its one notice line"),
        ("MobileStarterJournal.swift",
         "throw MintError.shelvingDidNotMint(String(describing: other))",
         "`other` is a shelving OUTCOME, not an error; it rides into the "
            + "never-surfaced `.refused` above"),
    ]

    @Test func noPhoneSourceRendersARawError() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
        let root = appRoot.appendingPathComponent("VariorumMobile", isDirectory: true)
        #expect(FileManager.default.fileExists(atPath: root.path), "the sweep root is missing")
        let walk = try #require(FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil))
        var walked = 0
        var offenders: [String] = []
        var exemptHits = [Int](repeating: 0, count: Self.exempt.count)
        for case let url as URL in walk where url.pathExtension == "swift" {
            walked += 1
            let source = try String(contentsOf: url, encoding: .utf8)
            for (number, line) in Self.strippingComments(source).enumerated() {
                let hits = Self.forbidden.filter { line.contains($0.pattern) }
                guard !hits.isEmpty else { continue }
                if line.contains(Self.logCall) { continue }
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if let index = Self.exempt.firstIndex(where: {
                    $0.file == url.lastPathComponent && trimmed == $0.line
                }) {
                    exemptHits[index] += 1
                    continue
                }
                offenders.append(
                    "\(url.lastPathComponent):\(number + 1) [\(hits.map(\.name).joined(separator: ", "))] \(trimmed)")
            }
        }
        #expect(walked > 60, "the walk must actually reach the phone's sources (walked \(walked))")
        let report = offenders.joined(separator: "\n")
        #expect(offenders.isEmpty,
                "no phone string may carry raw error text — \(offenders.count) found:\n\(report)")
        let misfits = Self.exempt.indices.filter { exemptHits[$0] != 1 }
            .map { "\(Self.exempt[$0].file): \"\(Self.exempt[$0].line)\" matched \(exemptHits[$0])" }
        #expect(misfits.isEmpty, "every exemption covers exactly one line — \(misfits)")
        #expect(Self.exempt.allSatisfy { !$0.why.isEmpty })
    }

    /// The scan's own oracle: comments go, code and string contents stay, the
    /// line count is kept (so an offender's line number is the file's).
    @Test func theStripperDropsCommentsAndKeepsCodeAndStrings() {
        let source = """
            let a = 1 // String(describing: error) in a comment
            /* String(describing: error)
               across lines */ let b = "Refused: \\(error)"
            /// `String(describing:)` in a doc comment
            let c = String(describing: error)
            """
        let lines = Self.strippingComments(source)
        #expect(lines.count == 5)
        #expect(!lines[0].contains(Self.forbidden[0].pattern))
        #expect(lines[2].contains(Self.forbidden[3].pattern), "the interpolation survives")
        #expect(!lines[3].contains(Self.forbidden[0].pattern))
        #expect(lines[4].contains(Self.forbidden[0].pattern))
    }

    /// Source minus comments, split into its lines (newlines inside comments
    /// are kept, so line numbers match the file). String contents are kept
    /// RAW — escapes and interpolations included — because an interpolation
    /// is exactly where a dump hides.
    static func strippingComments(_ source: String) -> [String] {
        var out = ""
        let chars = Array(source)
        var i = 0
        enum State { case code, lineComment, blockComment, string, multiline }
        var state = State.code
        var depth = 0
        func has(_ pattern: String) -> Bool {
            i + pattern.count <= chars.count && String(chars[i..<i + pattern.count]) == pattern
        }
        while i < chars.count {
            switch state {
            case .code:
                if has("\"\"\"") { state = .multiline; out += "\"\"\""; i += 3 }
                else if has("//") { state = .lineComment; i += 2 }
                else if has("/*") { state = .blockComment; depth = 1; i += 2 }
                else if chars[i] == "\"" { state = .string; out.append("\""); i += 1 }
                else { out.append(chars[i]); i += 1 }
            case .lineComment:
                if chars[i] == "\n" { state = .code; out.append("\n") }
                i += 1
            case .blockComment:
                if has("/*") { depth += 1; i += 2 }
                else if has("*/") { depth -= 1; i += 2; if depth == 0 { state = .code } }
                else { if chars[i] == "\n" { out.append("\n") }; i += 1 }
            case .string:
                if chars[i] == "\\", i + 1 < chars.count {
                    out.append(chars[i]); out.append(chars[i + 1]); i += 2
                } else if chars[i] == "\"" { out.append("\""); state = .code; i += 1 }
                else if chars[i] == "\n" { out.append("\n"); state = .code; i += 1 }
                else { out.append(chars[i]); i += 1 }
            case .multiline:
                if has("\"\"\"") { out += "\"\"\""; state = .code; i += 3 }
                else if chars[i] == "\\", i + 1 < chars.count {
                    out.append(chars[i]); out.append(chars[i + 1]); i += 2
                } else { out.append(chars[i]); i += 1 }
            }
        }
        return out.components(separatedBy: "\n")
    }
}

// MARK: - The audit's named refusals, through their real doors

@MainActor
@Suite("VM-62 — the named refusals speak the shared table's sentence")
struct MobileRefusalSentencePinTests {
    /// The table's words on the phone's road for `error` — the oracle every
    /// case below is held to (the Mac's sentence where the road is the same).
    private func phoneWords(_ error: OperationError) throws -> String {
        try #require(OpsRefusalCopy.words(for: error, roads: .phone))
    }

    /// The sentence reached both the model's slot and the one line, as a
    /// refusal, with no case name in it.
    private func expectSpoken(
        _ expected: String, slot: String?, session: AppSession, case name: String
    ) throws {
        #expect(slot == expected, "the slot said \(String(describing: slot))")
        let line = try #require(session.status.current, "the refusal reaches the one line")
        #expect(line.kind == .refusal)
        #expect(line.text == expected, "the line said \(line.text)")
        #expect(!line.text.contains(name), "no case name on the screen")
    }

    /// Audit B I3 / §0.6: Finish is drawn on a gathering and `lockReading`
    /// refuses `wrongReadingKind` — it reached her as "That couldn't be done —
    /// wrongReadingKind(…)."
    @Test func finishOnAGatheringSpeaksTheTablesSentence() async throws {
        try await withEditorWorld { session, _ in
            let gatheringID = try await session.runner.run { ops -> String in
                _ = try ops.createTag(name: "sea")
                return try ops.createReading(
                    name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#).id
            }
            let details = MobileBookDetailsModel(session: session, readingID: gatheringID)
            await details.refresh()
            session.status.clear()
            await details.setFinished(true)
            try expectSpoken(
                try phoneWords(.wrongReadingKind(id: gatheringID, expected: .book)),
                slot: details.lastError, session: session, case: "wrongReadingKind")
        }
    }

    /// Audit B I4 / §0.6: Reopen on a sealed book refuses `readingSealed` —
    /// `DeletionRefusal` had no arm, so it reached her as a raw dump.
    @Test func reopenOnASealedBookSpeaksTheTablesSentence() async throws {
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Member")
                let book = try ops.createReading(name: "Closed", kind: .book)
                _ = try ops.addPostToReading(post.id, to: book.id)
                _ = try ops.sealReading(book.id)
                return book.id
            }
            let details = MobileBookDetailsModel(session: session, readingID: bookID)
            await details.refresh()
            session.status.clear()
            await details.setFinished(false)
            try expectSpoken(
                try phoneWords(.readingSealed(id: bookID)),
                slot: details.lastError, session: session, case: "readingSealed")
        }
    }

    /// Audit C N1: the note's rename printed `String(describing:)` — here the
    /// note is deleted under the masthead (another device, the Trash).
    @Test func renamingANoteThatIsGoneSpeaksTheTablesSentence() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Words."])
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.deleteContainer(postID) }
            session.status.clear()
            await model.renameNote("A new name")
            try expectSpoken(
                try phoneWords(.containerNotFound(id: postID)),
                slot: model.statusMessage, session: session, case: "containerNotFound")
        }
    }

    /// Audit C N5: unsealing a note that sits in a sealed book refuses
    /// `noteInSealedBook` — a raw enum dump on the phone.
    @Test func unsealingANoteInASealedBookSpeaksTheTablesSentence() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Kept."])
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Closed", kind: .book)
                _ = try ops.addPostToReading(postID, to: book.id)
                _ = try ops.sealReading(book.id)
                return book.id
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            session.status.clear()
            await model.unlockNote()
            try expectSpoken(
                try phoneWords(.noteInSealedBook(postID: postID, readingID: bookID)),
                slot: model.statusMessage, session: session, case: "noteInSealedBook")
        }
    }

    /// Audit B M2: a star refusal was `"Refused: \(error)"` — here the note is
    /// deleted under her press.
    @Test func starringANoteThatIsGoneSpeaksTheTablesSentence() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Gone soon")
                try ops.deleteContainer(post.id)
                return post.id
            }
            let stars = MobileStarsModel(session: session)
            session.status.clear()
            await stars.toggle(.post(postID), from: .library)
            try expectSpoken(
                try phoneWords(.containerNotFound(id: postID)),
                slot: stars.lastError, session: session, case: "containerNotFound")
        }
    }
}
