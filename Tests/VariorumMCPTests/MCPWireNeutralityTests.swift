import Foundation
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// 13n-c Stage B R1 — B13 + the orchestrator's O-2: EVERYTHING THE SERVER CAN
// SAY assumes no one's pronouns. Variorum ships to anyone; the advice, the tool
// descriptions and every refusal or ask sentence a client reads name "the
// author" (or "they"), never "she"/"her". The app's own faces speak to the
// user as "you" and are not swept here — only what crosses the wire.
//
// Two nets, so a new string cannot slip between them: the VALUES the server
// sends (the advice, every tool as the SDK encodes it, every refusal sentence
// the authority and the show rule compose), and a SOURCE sweep of every string
// literal in the server target plus the op-refusal table the host hands it
// (`MCPHostHooks.refusalWords` speaks `OpsRefusalCopy` to the client).

/// A gendered third-person pronoun, as a whole word, any case.
private func pronouns(in text: String) -> [String] {
    text.matches(of: #/(?i)\b(she|her|hers|herself|he|him|his|himself)\b/#).map { String($0.output.0) }
}

/// Every string inside a JSON value (keys and values).
private func strings(in json: Any) -> [String] {
    switch json {
    case let text as String: return [text]
    case let array as [Any]: return array.flatMap(strings(in:))
    case let object as [String: Any]: return object.keys.map { $0 } + object.values.flatMap(strings(in:))
    default: return []
    }
}

/// The repo root, from this file's own path (Tests/VariorumMCPTests/…).
private let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

/// Every string literal in a Swift file — single-line `"…"` and the lines of a
/// `"""` block — with comment lines left out.
private func stringLiterals(in source: String) -> [(line: Int, text: String)] {
    var found: [(Int, String)] = []
    var inBlock = false
    for (index, raw) in source.components(separatedBy: "\n").enumerated() {
        let line = raw.trimmingCharacters(in: .whitespaces)
        if inBlock {
            if line.contains("\"\"\"") { inBlock = false; continue }
            found.append((index + 1, raw))
            continue
        }
        if line.hasPrefix("//") { continue }
        if line.contains("\"\"\"") {
            // An opening delimiter (a closing one on the same line never
            // occurs in this target's style).
            inBlock = true
            continue
        }
        for match in raw.matches(of: #/"((?:[^"\\]|\\.)*)"/#) {
            found.append((index + 1, String(match.output.1)))
        }
    }
    return found
}

@Suite("13n-c Stage B — the wire assumes no one's pronouns (B13, O-2)")
struct MCPWireNeutralityTests {
    @Test func theAdviceNamesTheAuthorNeverAPronoun() {
        #expect(pronouns(in: MCPSession.instructions).isEmpty,
                "the advice: \(pronouns(in: MCPSession.instructions))")
        #expect(MCPSession.instructions.contains("the author"))
        #expect(MCPSession.instructions.count <= MCPSession.instructionsBound, "still inside its bound")
    }

    /// Every tool exactly as the SDK puts it on the wire — name, title,
    /// description and every input-schema description.
    @Test func everyToolAsSentIsNeutral() throws {
        #expect(!MCPToolCatalog.all.isEmpty)
        for declaration in MCPToolCatalog.all {
            let data = try JSONEncoder().encode(declaration.tool)
            let json = try JSONSerialization.jsonObject(with: data)
            for text in strings(in: json) {
                #expect(pronouns(in: text).isEmpty, "\(declaration.name): \(text)")
            }
        }
    }

    /// Every refusal and ask sentence the server composes: the authority's
    /// words for every reason × target, with and without the asked sentence;
    /// the show rule's; the wire-only op refusals.
    @Test func everyRefusalAndAskSentenceIsNeutral() {
        let reasons: [MCPGrantRule.Reason] = [
            .clientPending, .clientDenied, .notShared, .fenced(.journal), .fenced(.privateMark),
        ] + MCPGrantRule.Rung.allCases.map { .rungTooLow(granted: $0) }
        let targets: [MCPRefusalCopy.Target] = [.note, .book, .wing]
        var sentences: [String] = [MCPRefusalCopy.askedSentence]
        for reason in reasons {
            for target in targets {
                sentences.append(MCPRefusalCopy.words(reason, target))
                sentences.append(MCPRefusalCopy.words(reason, target, asked: true))
            }
        }
        sentences += [
            MCPShowRule.notFrontmostWords, MCPShowRule.otherWindowWords,
            MCPShowRule.unavailableWords, MCPShowRule.partialShowWords,
        ]
        let errors: [OperationError] = [
            .postNotInReading(postID: "n", readingID: "r"), .sectionNotFound(id: "s"),
            .invalidTagName(name: "a b"),
        ]
        sentences += errors.compactMap(MCPWireRefusalCopy.words)
        for sentence in sentences {
            #expect(pronouns(in: sentence).isEmpty, "\(sentence)")
        }
        #expect(MCPRefusalCopy.askedSentence.contains("once they answer"))
    }

    /// The net under the values: every string literal in the server target
    /// (everything the server can send is written there) and in the op-refusal
    /// table the host speaks to the client through.
    @Test func everyStringLiteralTheServerCanSendIsNeutral() throws {
        let serverDirectory = repoRoot.appendingPathComponent("Sources/VariorumMCP")
        let files = try FileManager.default.contentsOfDirectory(atPath: serverDirectory.path)
            .filter { $0.hasSuffix(".swift") }
            .map { serverDirectory.appendingPathComponent($0) }
            + [repoRoot.appendingPathComponent("App/Variorum/Shared/OpsRefusalTable.swift")]
        #expect(files.count > 10, "the sweep found the server's files")
        var literals = 0
        for file in files {
            let source = try String(contentsOf: file, encoding: .utf8)
            for (line, text) in stringLiterals(in: source) {
                literals += 1
                #expect(pronouns(in: text).isEmpty, "\(file.lastPathComponent):\(line): \(text)")
            }
        }
        #expect(literals > 200, "the sweep read the literals (\(literals))")
    }
}
