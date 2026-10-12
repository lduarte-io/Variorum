import Foundation

/// **THE SETUP KEY's PREAMBLE** (VX-168 — the VX-156 brief §12's K2, her
/// kickoff ruling R-VX168-1). The one line BOTH ends read, before any MCP
/// frame: the `variorum-mcp` shim speaks the key its setup gave it (the
/// `VARIORUM_MCP_KEY` environment variable every setup the pane copies
/// carries), then pumps bytes exactly as before. A-2's "protocol-blind" byte
/// pump becomes **MCP-blind**: the shim still parses nothing of MCP — the one
/// thing it knows is to say this line first.
///
/// The line is `variorum-mcp-key <key>` — never JSON, so no reader can take it
/// for a frame (a JSON-RPC line starts `{` or `[`). A BARE shim (no key in its
/// environment) sends no line at all: the connection's first line is then the
/// client's own `initialize`, which the app answers with its one refusal.
/// Foundation only, like the rest of this module.
public enum MCPPreamble {
    /// The environment variable a setup puts the key in.
    public static let environmentVariable = "VARIORUM_MCP_KEY"
    /// The line's leading word.
    public static let tag = "variorum-mcp-key"
    /// The longest key the shim will speak (a minted key is 48 characters;
    /// anything this long is not one, and a line is never unbounded).
    public static let maxKeyLength = 256

    /// The key the shim's environment carries, as the shim will speak it:
    /// trimmed; nil when absent, empty, too long, or holding anything but
    /// printable ASCII without spaces (such a value is no key the app minted,
    /// and could break the line — the shim then runs bare and the app's
    /// refusal says what to do).
    public static func key(inEnvironment environment: [String: String]) -> String? {
        guard let raw = environment[environmentVariable] else { return nil }
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key.utf8.count <= maxKeyLength,
              key.utf8.allSatisfy({ $0 > 0x20 && $0 < 0x7F })
        else { return nil }
        return key
    }

    /// The one line, framed: `variorum-mcp-key <key>\n`.
    public static func line(key: String) -> Data {
        Data("\(tag) \(key)\n".utf8)
    }

    /// A connection's first line, as the app reads it.
    public enum FirstLine: Equatable, Sendable {
        /// The preamble, carrying the key presented (possibly empty).
        case preamble(key: String)
        /// No preamble: the line is the first MCP frame (a bare shim).
        case frame
    }

    /// Classify a connection's first line (its newline already removed).
    public static func classify(_ line: Data) -> FirstLine {
        let tagBytes = Array(tag.utf8)
        let bytes = Array(line)
        guard bytes.count >= tagBytes.count, Array(bytes.prefix(tagBytes.count)) == tagBytes else { return .frame }
        let rest = bytes.dropFirst(tagBytes.count)
        guard rest.isEmpty || rest.first == UInt8(ascii: " ") else { return .frame }
        let key = String(decoding: rest, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return .preamble(key: key)
    }
}
