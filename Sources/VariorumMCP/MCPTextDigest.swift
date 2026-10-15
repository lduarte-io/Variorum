import CryptoKit
import Foundation

/// **THE WIRE'S ONE DIGEST** (VX-254, VX-336 U7 — the run record
/// `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`, U7 UNIT RECORD
/// D-254-1, F-254-1 (a) ruled). A take's `sha256` is the SHA-256 of the
/// take's text as its UTF-8 bytes, in lowercase hex (64 characters):
/// nothing normalized (NFC "é" and NFD "é" digest differently), nothing
/// trimmed, no newline conversion and NO domain prefix — so a client proves
/// a write landed byte for byte with any stock tool (`shasum -a 256`,
/// `hashlib.sha256(s.encode()).hexdigest()`) against its own source, without
/// reading the text back. The empty take digests to `e3b0c442…b855`.
///
/// Deliberately unlike the store's own hashes (`MCPCommentWords.digest`,
/// `MCPSetupKeyRule.hash`), which are domain-separated local records: a plain
/// wire digest can never equal, or reveal, either.
///
/// The one home: every write answer that digests a take (the minted records'
/// encoder `MCPMintedBlocks`, the flat answers) and `read_note`'s `ids_only`
/// (VX-256) call this, and only this. Cost ∝ the text hashed.
enum MCPTextDigest {
    static func sha256(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
