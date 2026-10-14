import CryptoKit
import Foundation

/// **THE WORDS A CLIENT WROTE** (P-VX260-1, option (b) — VX-246 U1b; the run
/// record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, THE ORCHESTRATOR
/// ON U1's HAND-BACK). Her rule (VX-260): "Once she has edited an AI's comment,
/// deleting it needs EDIT" — wherever she edits it. The local-only authorship
/// record (`mcp_comment_author`) keeps a digest of the words the client wrote;
/// a comment is the client's OWN only while its words still hash to that
/// digest. Any change to the words — her edit on any device (arriving by sync,
/// which runs no door here), another client's — and it is not; a change BACK to
/// the very words it wrote makes it the client's again (an unchanged digest
/// means unchanged words). Acts that change no word — an undo or redo, her
/// delete and Put back, a sync arrival of the same text — leave it as it was.
///
/// Pure: the digest of a string, nothing else. Never leaves the store (the
/// record is local-only, exported empty).
public enum MCPCommentWords {
    /// Hex SHA-256 over a domain-separated encoding of the words exactly as
    /// stored (`block_comment.text`) — byte-exact, no trimming or folding.
    public static func digest(_ text: String) -> String {
        let digest = SHA256.hash(data: Data(("variorum.mcp-comment-words.v1:" + text).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Is a comment its writer's own? The record must name the asker, carry a
    /// digest (NULL — a record from before `v1_29` — is UNPROVEN: never), and
    /// that digest must be the digest of the comment's words now.
    public static func isOwn(
        recordedClient: String?, recordedDigest: String?, currentText: String?, asker: String
    ) -> Bool {
        guard let recordedClient, recordedClient == asker,
              let recordedDigest, let currentText else { return false }
        return recordedDigest == digest(currentText)
    }
}
