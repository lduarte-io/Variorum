import Foundation
import Testing

// 13n-c — ORCHESTRATOR FINDING O-4 (her ask, 2026-10-11: "make sure that
// outside of the provider setup, claude / claude code isn't hardwired anywhere
// since people may use different providers"). A SOURCE sweep of every string
// literal the apps and the package can show or send: no provider's name, except
//
//   · THE PROVIDER SETUP — the setup menu's own words (`MCPSetupClient` and the
//     pane's "Connect a client" copy), and the field guide's card that teaches
//     that menu by its labels (the H pattern: plain text, never interpolated) —
//     each fenced in its file by an `O-4 SETUP COPY BEGIN` / `END` comment pair;
//   · THE SEARCH KEYWORDS — a `keywords: [ … ]` list is search vocabulary, not
//     copy (her (e): the pane is found by whatever she or a user calls their
//     AI).
//
// The fences are guarded too: balanced, short, only in the files that hold the
// setup, and each actually holding a provider's name (a stale fence fails).
// Headless — it reads the app's sources from disk, the wire-neutrality net's
// precedent; no app is built or launched.

/// A provider's (or its product's) name, as a whole word, any case. "cursor"
/// is left out on purpose: it is the text cursor everywhere in the app's copy.
private var providerPattern: Regex<(Substring, Substring)> {
    #/(?i)\b(claude|anthropic|codex|openai|chatgpt|gemini|copilot|windsurf)\b/#
}

private let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

/// The trees whose literals can reach a user or a client: the Mac app, the
/// shared brains and faces, the phone, and the package (the wire).
private let sweptRoots = [
    "App/Variorum/Variorum",
    "App/Variorum/Shared",
    "App/Variorum/VariorumMobile",
    "Sources",
]

/// The files allowed to hold an `O-4 SETUP COPY` fence, and how many each holds.
private let fencedFiles: [String: Int] = [
    "App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift": 2,
    "App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift": 1,
]
private let fenceBegin = "O-4 SETUP COPY BEGIN"
private let fenceEnd = "O-4 SETUP COPY END"
/// The longest a fence may run (lines) — so a fence can never swallow a file.
private let fenceLimit = 120

private struct Literal {
    let file: String
    let line: Int
    let text: String
    /// Inside an `O-4 SETUP COPY` fence.
    let fenced: Bool
    /// Inside a `keywords: [ … ]` list.
    let keyword: Bool
}

private struct Fence {
    let file: String
    let begin: Int
    var end: Int?
    var holdsProvider = false
}

/// Every string literal in a Swift file (single-line `"…"` and the lines of a
/// `"""` block), comment lines left out — the wire-neutrality net's parser —
/// each marked fenced / keyword, plus the file's fences.
private func scan(_ relative: String) throws -> (literals: [Literal], fences: [Fence]) {
    let source = try String(contentsOf: repoRoot.appendingPathComponent(relative), encoding: .utf8)
    var literals: [Literal] = []
    var fences: [Fence] = []
    var inBlock = false
    var inKeywords = false
    for (index, raw) in source.components(separatedBy: "\n").enumerated() {
        let number = index + 1
        let line = raw.trimmingCharacters(in: .whitespaces)
        if line.hasPrefix("//") {
            if line.contains(fenceBegin) { fences.append(Fence(file: relative, begin: number)) }
            if line.contains(fenceEnd), let last = fences.indices.last, fences[last].end == nil {
                fences[last].end = number
            }
            continue
        }
        let fenced = fences.last.map { $0.end == nil } ?? false
        if inBlock {
            if line.contains("\"\"\"") { inBlock = false; continue }
            literals.append(Literal(file: relative, line: number, text: raw, fenced: fenced, keyword: false))
            continue
        }
        if line.contains("\"\"\"") {
            inBlock = true
            continue
        }
        if line.contains("keywords: [") { inKeywords = true }
        for match in raw.matches(of: #/"((?:[^"\\]|\\.)*)"/#) {
            literals.append(Literal(
                file: relative, line: number, text: String(match.output.1), fenced: fenced, keyword: inKeywords))
        }
        if inKeywords, line.contains("]") { inKeywords = false }
        if fenced, raw.contains(providerPattern), let last = fences.indices.last {
            fences[last].holdsProvider = true
        }
    }
    return (literals, fences)
}

/// Every Swift file under the swept trees, relative to the repo root.
private func sweptFiles() -> [String] {
    var files: [String] = []
    for root in sweptRoots {
        let url = repoRoot.appendingPathComponent(root)
        let walker = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)
        while let file = walker?.nextObject() as? URL {
            guard file.pathExtension == "swift" else { continue }
            files.append(String(file.path.dropFirst(repoRoot.path.count + 1)))
        }
    }
    return files.sorted()
}

@Suite("13n-c O-4 — no provider is hardwired outside the provider setup")
struct MCPProviderNeutralityTests {
    @Test func noLiteralNamesAProviderOutsideTheSetupAndTheKeywords() throws {
        let files = sweptFiles()
        #expect(files.count > 300, "the sweep found the apps and the package (\(files.count) files)")
        var swept = 0
        for file in files {
            for literal in try scan(file).literals {
                swept += 1
                guard !literal.fenced, !literal.keyword else { continue }
                let names = literal.text.matches(of: providerPattern).map { String($0.output.0) }
                #expect(names.isEmpty, "\(literal.file):\(literal.line) names \(names): \(literal.text)")
            }
        }
        #expect(swept > 10_000, "the sweep read the literals (\(swept))")
    }

    /// The fences: only where the setup lives, as many as it needs, balanced,
    /// short, and each holding a provider's name (a fence with none is stale).
    @Test func theSetupFencesAreFewShortAndLive() throws {
        var found: [String: Int] = [:]
        for file in sweptFiles() {
            for fence in try scan(file).fences {
                found[file, default: 0] += 1
                let end = try #require(fence.end, "\(file):\(fence.begin): a fence that never ends")
                #expect(end - fence.begin <= fenceLimit, "\(file):\(fence.begin): \(end - fence.begin) lines")
                #expect(fence.holdsProvider, "\(file):\(fence.begin): a fence holding no provider is stale")
            }
        }
        #expect(found == fencedFiles, "the fences live only in the setup's files: \(found)")
    }
}
