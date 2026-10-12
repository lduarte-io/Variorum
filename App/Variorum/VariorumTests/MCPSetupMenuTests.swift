//
//  MCPSetupMenuTests.swift
//  VariorumTests (Mac)
//
//  13n-c U5 — R-AIR-13, THE SETUP MENU (the sitting record round 3: "the
//  setup command grows a per-client menu: Claude Code · Codex · a generic
//  path/JSON shape (the door is a standard MCP stdio server at one binary
//  path; the pane says so)"). The three setups' words, each one's text as a
//  client reads it (Claude Code's byte-unchanged from 13n-b; Codex's from the
//  U5 record's cited syntax; the generic stanza PARSED back as JSON over
//  awkward paths), the door copying the chosen one with its own receipt, the
//  one stdio line, R-AIR-8 (no "AI" in the pane's words) and the search.
//

import AppKit
import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("13n-c U5 — the setup menu (R-AIR-13)")
struct MCPSetupMenuTests {
    private static let releasePath = "/Applications/Variorum.app/Contents/MacOS/variorum-mcp"

    /// Paths a JSON or shell writer must survive: spaces, quotes, a
    /// backslash, a dollar, a backtick, non-ASCII, and a control character.
    private static let awkwardPaths = [
        releasePath,
        "/Users/a b/\"x\"/$y/`z`\\w/variorum-mcp",
        "/Users/Zoë/Library/Developer/DerivedData/Variorum-éè/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp",
        "/tmp/tab\there/new\nline/variorum-mcp",
    ]

    // MARK: - The menu

    @Test func theMenuIsThreeClientsInHerOrder() {
        #expect(MCPSetupClient.allCases == [.claudeCode, .codex, .anyClient])
        #expect(MCPSetupClient.allCases.map(\.label) == ["Claude Code", "Codex", "Any MCP client"])
    }

    /// Claude Code's setup is 13n-b's command, byte for byte (R-13nb-5 —
    /// the menu adds clients; it changes nothing she already uses).
    @Test func claudeCodesSetupIsTheShippedCommandUnchanged() {
        for debug in [false, true] {
            #expect(MCPSetupClient.claudeCode.text(shimPath: Self.releasePath, isDebugBuild: debug)
                == MCPPaneCopy.setupCommand(shimPath: Self.releasePath, isDebugBuild: debug))
        }
        #expect(MCPSetupClient.claudeCode.sentence == MCPPaneCopy.connectSentence)
        #expect(MCPSetupClient.claudeCode.copiedReceipt == MCPPaneCopy.copiedReceipt)
    }

    /// Codex's setup (the U5 record's external fact: `codex mcp add <name>
    /// -- <command>`, user-global): the same name rule and shell quoting.
    @Test func codexsSetupIsItsAddCommandWithTheSameNameRuleAndQuoting() {
        #expect(MCPSetupClient.codex.text(shimPath: Self.releasePath, isDebugBuild: false)
            == "codex mcp add variorum -- \"/Applications/Variorum.app/Contents/MacOS/variorum-mcp\"")
        #expect(MCPSetupClient.codex.text(shimPath: "/x", isDebugBuild: true)
            .hasPrefix("codex mcp add variorum-dev -- "),
                "a dev setup never replaces the real registration (P-13nb-U1-10)")
        let awkward = MCPSetupClient.codex.text(shimPath: "/Users/a b/\"x\"/$y/`z`\\w", isDebugBuild: false)
        #expect(awkward.hasSuffix("-- \"/Users/a b/\\\"x\\\"/\\$y/\\`z\\`\\\\w\""),
                "the same POSIX double-quote escaping as Claude Code's")
        #expect(MCPSetupClient.codex.sentence.contains("~/.codex/config.toml"),
                "it says where Codex keeps it, for every folder")
    }

    /// The generic stanza PARSES, names the server by the build's name, and
    /// hands back the exact path as its command with no arguments — over
    /// every awkward path (a JSON writer that gets one wrong is a client that
    /// never starts).
    @Test func theGenericStanzaParsesBackToTheExactPathUnderTheBuildsName() throws {
        for debug in [false, true] {
            for path in Self.awkwardPaths {
                let text = MCPSetupClient.anyClient.text(shimPath: path, isDebugBuild: debug)
                let object = try JSONSerialization.jsonObject(with: Data(text.utf8))
                let root = try #require(object as? [String: Any])
                #expect(Array(root.keys) == ["mcpServers"])
                let servers = try #require(root["mcpServers"] as? [String: Any])
                let name = debug ? "variorum-dev" : "variorum"
                #expect(Array(servers.keys) == [name])
                let entry = try #require(servers[name] as? [String: Any])
                #expect(entry["command"] as? String == path, "the exact path back: \(path)")
                #expect((entry["args"] as? [Any])?.isEmpty == true)
            }
        }
        // It reads as the docs print it: the slash never escaped.
        let plain = MCPSetupClient.anyClient.text(shimPath: Self.releasePath, isDebugBuild: false)
        #expect(plain.contains("\"command\": \"\(Self.releasePath)\""))
        #expect(plain.hasPrefix("{\n  \"mcpServers\": {\n    \"variorum\": {\n"))
    }

    @Test func theJSONQuoterEscapesExactlyWhatJSONRequires() {
        #expect(MCPPaneCopy.jsonQuoted("a\"b\\c") == "\"a\\\"b\\\\c\"")
        #expect(MCPPaneCopy.jsonQuoted("/a/b") == "\"/a/b\"", "a slash stays a slash")
        #expect(MCPPaneCopy.jsonQuoted("\u{01}") == "\"\\u0001\"")
        #expect(MCPPaneCopy.jsonQuoted("é") == "\"é\"")
    }

    // MARK: - The door

    /// Each choice copies ITS text with ITS receipt, under the button; the
    /// default stays Claude Code's (13n-b's callers untouched).
    @Test func theDoorCopiesTheChosenSetupWithItsOwnReceipt() throws {
        let door = MCPDoor(serverAllowed: false)
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-mcp-setup-test-\(UUID().uuidString)"))
        defer { pasteboard.releaseGlobally() }
        for client in MCPSetupClient.allCases {
            door.copySetupCommand(for: client, to: pasteboard)
            #expect(pasteboard.string(forType: .string) == door.setupText(for: client))
            #expect(door.setupText(for: client)
                == client.text(shimPath: MCPDoor.shimPath, isDebugBuild: true), "the test host is Debug")
            #expect(door.note == MCPDoor.Note(text: client.copiedReceipt, place: .connect))
        }
        door.copySetupCommand(to: pasteboard)
        #expect(pasteboard.string(forType: .string) == door.setupCommand, "the default is Claude Code's")
        #expect(Set(MCPSetupClient.allCases.map(\.copiedReceipt)).count == 3, "three receipts, three next steps")
    }

    /// A receipt names ONE client's next step: choosing another client clears
    /// it — but never a refusal at the pane's head.
    @Test func choosingAnotherClientClearsOnlyTheCopyReceipt() {
        let door = MCPDoor(serverAllowed: false)
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-mcp-setup-clear-\(UUID().uuidString)"))
        defer { pasteboard.releaseGlobally() }
        door.copySetupCommand(for: .claudeCode, to: pasteboard)
        door.clearConnectNote()
        #expect(door.note == nil)
        door.note = MCPDoor.Note(text: "a refusal", place: .top)
        door.clearConnectNote()
        #expect(door.note?.place == .top, "a refusal at the head stays")
    }

    // MARK: - The words

    /// R-AIR-13's line: the door is a standard MCP server over stdio, one
    /// program at one path — said once, above the menu.
    @Test func theOneLineSaysStdioOneProgramOnePath() {
        #expect(MCPPaneCopy.stdioLine.contains("standard MCP server"))
        #expect(MCPPaneCopy.stdioLine.contains("stdio"))
        #expect(MCPPaneCopy.stdioLine.contains("one program"))
        #expect(MCPDoor.shimPath.hasSuffix("/Contents/MacOS/variorum-mcp"))
    }

    /// R-AIR-8: the pane's words say MCP and client, never "AI"; sentence
    /// case (her standing rule — no word capitalized for emphasis).
    @Test func theSetupWordsCarryNoAIAndNoShoutedWord() {
        var words = [MCPPaneCopy.stdioLine, MCPPaneCopy.connectSection]
        for client in MCPSetupClient.allCases {
            words += [client.label, client.sentence, client.copiedReceipt]
        }
        for text in words {
            #expect(text.range(of: #"\bAI\b"#, options: .regularExpression) == nil, "no “AI”: \(text)")
            #expect(text.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil,
                    "no shouted word: \(text)")
        }
    }

    /// The Settings search finds the pane by the menu's own words.
    @Test func theSearchFindsThePaneByTheMenusWords() {
        for word in ["codex", "json", "setup", "stdio"] {
            #expect(SettingsSearch.findings(matching: word, in: SettingsSearch.settingsEntries)
                .contains { $0.pane == .mcp }, "“\(word)” finds the MCP pane")
        }
    }

    /// Stage B R1 B7: the pane's searchable description (the line under its
    /// title, and what Settings' search reads) never says Claude Code alone,
    /// which stopped being true at U5. A JUSTIFIED EDIT (the ritual) at the
    /// close-out pass — 13n-c O-4, her ask ("outside of the provider setup,
    /// claude / claude code isn't hardwired anywhere"): B7's PROVISIONAL words
    /// named the menu's choices ("Claude Code, Codex or any MCP client"); the
    /// description now says it sets up ANY MCP client and names no provider —
    /// and neither does the server row's blurb.
    /// **13n-c UX walk W-UX-18 (T-16) — a geometry oracle:** the pane's
    /// description fits the Settings header's two lines in Terminal's mono
    /// (the widest voice), at the detail column's measured room — 720 (the
    /// window) − 196 (the sidebar) − 1 (the hairline) − 2 × 18 (the header's
    /// padding). It ran to "…how to set up any…" before (146 characters).
    @Test func thePanesDescriptionFitsTheHeadersTwoLinesInTerminal() {
        let room: CGFloat = 720 - 196 - 1 - 2 * 18
        let mono = NSFont.monospacedSystemFont(ofSize: 11.5, weight: .regular)
        let text = NSAttributedString(string: SettingsPane.mcp.blurb, attributes: [.font: mono])
        let rect = text.boundingRect(
            with: NSSize(width: room, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading])
        let lineHeight = NSLayoutManager().defaultLineHeight(for: mono)
        #expect((rect.height / lineHeight).rounded() <= 2,
                "\(rect.height / lineHeight) lines at \(room) pt: \(SettingsPane.mcp.blurb)")
        #expect(SettingsPane.mcp.blurb.contains("how to set up any MCP client"))
    }

    @Test func thePanesDescriptionSetsUpAnyClientAndNamesNoProvider() {
        let blurb = SettingsPane.mcp.blurb
        #expect(blurb.contains("how to set up any MCP client"))
        let serverRow = SettingsCatalog.rows.first { $0.id == "mcpServer" }?.blurb ?? ""
        #expect(serverRow.contains("A local server for any MCP client"))
        for text in [blurb, serverRow, MCPPaneCopy.enableBlurb] {
            for client in MCPSetupClient.allCases where client != .anyClient {
                #expect(!text.localizedCaseInsensitiveContains(client.label), "\(client.label) in: \(text)")
            }
            #expect(!text.contains("AI"), "R-AIR-8: settings-class wording")
        }
        #expect(!blurb.contains("the command that sets up Claude Code"))
    }

    /// 13n-c O-4 (her (e)): the copy names no provider, but the SEARCH finds the
    /// pane by whatever she or a user calls their AI — the keywords are search
    /// vocabulary, never copy.
    @Test func theSearchFindsThePaneWhateverItsClientIsCalled() {
        for word in ["claude", "codex", "anthropic", "openai", "chatgpt", "cursor", "gemini", "copilot"] {
            #expect(SettingsSearch.findings(matching: word, in: SettingsSearch.settingsEntries)
                .contains { $0.pane == .mcp }, "“\(word)” finds the MCP pane")
        }
    }
}
