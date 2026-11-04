import Darwin
import Foundation

/// **THE APP'S CLOSE LINE** (VX-762 — B2 part two, PROVISIONAL P-771-3; the
/// orchestrator's A-771-3; the record `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`,
/// BATCH 4 RECORD). Before the app hangs a connection up on a stop it can name
/// (her switch, the library locking or closing, the quit), it writes ONE line
/// on the socket saying why — the byte `marker` (0x1E, ASCII RS), the words,
/// a newline — and the shim, which relays every other byte verbatim, keeps that
/// line off the client's stdout and says its words on stderr instead (the
/// downstream twin of VX-168's one preamble line upstream).
///
/// **Why no MCP byte can ever be taken for it — the shim stays MCP-blind by
/// construction.** Every line the app writes on the socket is a JSON text (the
/// SDK's frames, the refusals, the handshake window's answers), and a JSON text
/// cannot hold the raw byte 0x1E ANYWHERE: RFC 8259 §7 requires U+0000–U+001F
/// escaped inside strings, and outside strings only structural characters,
/// literals, numbers and the four whitespace bytes (0x20 0x09 0x0A 0x0D) are
/// legal; and UTF-8 never uses a byte below 0x80 inside a multi-byte sequence.
/// MCP's stdio framing is newline-delimited (A-3: the socket's framing IS
/// stdio's), so a line start is a frame start, and a close line ends at its own
/// newline — it can never swallow a frame. The shim reads no JSON and knows no
/// method: newlines and one byte that is never JSON.
public enum MCPCloseLine {
    /// The one byte that opens a close line (ASCII RS).
    public static let marker: UInt8 = 0x1E

    /// The most bytes of words a close line may carry; a longer one is never
    /// said (the shim falls back to its own sentence — A-771-3 (1)).
    public static let cap = 512

    /// The line as the app writes it: the marker, the words, a newline. nil when
    /// the words could never be said (empty, too long, or holding a control
    /// character — so a close line can never break a terminal or a log line).
    public static func line(_ words: String) -> Data? {
        guard speakable(words) else { return nil }
        var line = Data([marker])
        line.append(contentsOf: Data(words.utf8))
        line.append(UInt8(ascii: "\n"))
        return line
    }

    /// A complete close line's words (the bytes between the marker and the
    /// newline), or nil when they could never be said.
    static func words(_ bytes: Data) -> String? {
        guard bytes.count <= cap, let words = String(data: bytes, encoding: .utf8), speakable(words) else {
            return nil
        }
        return words
    }

    private static func speakable(_ words: String) -> Bool {
        let bytes = words.utf8.count
        return bytes > 0 && bytes <= cap
            && !words.unicodeScalars.contains { $0.properties.generalCategory == .control }
            && !words.allSatisfy(\.isWhitespace)
    }

    // MARK: - The shim's downstream relay

    /// **The downstream's ONE piece of state** (A-771-3 (1): never blocks or
    /// reorders a relayed byte). Fed each read of the socket in order, it hands
    /// back the spans to write to stdout — every byte not in a close line,
    /// verbatim, in order, at once — and keeps a close line's bytes (capped) in
    /// place of writing them. `atLineStart` is the only framing knowledge.
    struct Relay {
        private var atLineStart = true
        private var diverting = false
        private var diverted = Data()
        private var overflowed = false
        /// The words of the latest COMPLETE close line (nil when it could not be
        /// said); a newer close line replaces it.
        private var latest: String?

        /// The ranges of `chunk` to write to stdout, in order.
        mutating func take(_ chunk: UnsafeBufferPointer<UInt8>) -> [Range<Int>] {
            var spans: [Range<Int>] = []
            var index = 0
            var forwardStart = 0
            let count = chunk.count
            while index < count {
                if diverting {
                    guard let newline = Self.newline(in: chunk, from: index) else {
                        keep(chunk, index..<count)
                        index = count
                        break
                    }
                    keep(chunk, index..<newline)
                    latest = overflowed ? nil : MCPCloseLine.words(diverted)
                    diverted = Data()
                    overflowed = false
                    diverting = false
                    atLineStart = true
                    index = newline + 1
                    forwardStart = index
                    continue
                }
                if atLineStart, chunk[index] == MCPCloseLine.marker {
                    if forwardStart < index { spans.append(forwardStart..<index) }
                    diverting = true
                    atLineStart = false
                    index += 1
                    continue
                }
                guard let newline = Self.newline(in: chunk, from: index) else {
                    atLineStart = false
                    index = count
                    break
                }
                atLineStart = true
                index = newline + 1
            }
            if !diverting, forwardStart < count { spans.append(forwardStart..<count) }
            return spans
        }

        /// What the app's end says: the latest complete close line's words — nil
        /// (the shim's own sentence) when none came, when the last one could not
        /// be said, or when the stream ended INSIDE one (torn: A-771-3 (1)).
        var closingWords: String? { diverting ? nil : latest }

        private mutating func keep(_ chunk: UnsafeBufferPointer<UInt8>, _ range: Range<Int>) {
            guard !overflowed, !range.isEmpty else { return }
            guard diverted.count + range.count <= MCPCloseLine.cap else {
                overflowed = true
                diverted = Data()
                return
            }
            diverted.append(contentsOf: UnsafeBufferPointer(rebasing: chunk[range]))
        }

        /// The next newline at or after `start` (`memchr` — linear, as the app's
        /// own line reader is).
        private static func newline(in chunk: UnsafeBufferPointer<UInt8>, from start: Int) -> Int? {
            guard let base = chunk.baseAddress, start < chunk.count,
                  let found = memchr(base + start, Int32(UInt8(ascii: "\n")), chunk.count - start)
            else { return nil }
            return base.distance(to: found.assumingMemoryBound(to: UInt8.self))
        }
    }
}
