import CryptoKit
import Foundation
import VariorumCore

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

    /// **VX-358 (RUN VX-548 batch 2a — PROVISIONAL MB-5): the one key a
    /// no-op answers when the spellings differ.** `edit_take` and
    /// `restore_commit` treat a text that reads as the take's under canonical
    /// equality as nothing to write (`changed: false` — an invisible
    /// re-normalization never rewrites prose); when the text asked (sent, or
    /// the commit's) is nonetheless SPELLED with other code points (NFC
    /// against NFD — `StoredText.spellingDiffers`), the answer carries this
    /// key, `true`, beside a `sha256` that stays the STORED text's — absent
    /// otherwise, so every other answer is byte-unchanged. Read by the two
    /// answers and by the descriptions' sentence, never retyped.
    static let spellingDiffersKey = "stored_text_normalization_differs"

    /// **THE FAN DIGEST** (A-771-2, the VX-771 run's batch 1 — fork F-2;
    /// PROVISIONAL P-771-8): the archive proof a BRIEF copy answer carries in
    /// place of its per-block records (`duplicate_note` with `brief: true`,
    /// `copy_note_to_wing`). The SHA-256 (this file's `sha256`) of a text with
    /// ONE LINE PER BLOCK in note order — each line that block's take digests
    /// in fan order, separated by single spaces, the SHOWN take's prefixed
    /// `*` — the lines joined by `\n`, no trailing newline (no blocks: the
    /// empty text). A client spells the same text from `read_note` with
    /// `ids_only: true` on the SOURCE (each take's `sha256`, `chosen` marking
    /// the shown one), so equal digests prove the copy is the note: its words,
    /// their order, the block boundaries and which take each block shows.
    /// Labels stay out (they ride verbatim; free text would need escaping).
    /// Built from what the act minted — ∝ the copy's takes, no second read.
    static func fanSHA256(_ blocks: [Operations.MintedBlockTakes]) -> String {
        sha256(fanText(blocks))
    }

    /// The text `fanSHA256` digests, spelled once.
    static func fanText(_ blocks: [Operations.MintedBlockTakes]) -> String {
        blocks.map { block in
            block.takes.map { take in
                (take.id == block.shownTakeID ? "*" : "") + sha256(take.text)
            }.joined(separator: " ")
        }.joined(separator: "\n")
    }

    /// The answer key, read by the answer and the descriptions, never retyped.
    static let fanKey = "fan_sha256"
}
