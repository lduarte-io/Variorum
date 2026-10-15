import Foundation
import Testing

@testable import VariorumMCP

// VX-254 (VX-336 U7 — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U7 UNIT RECORD D-254-1, F-254-1 (a) ruled): THE WIRE'S ONE DIGEST. A take's
// `sha256` is the SHA-256 of its stored text's UTF-8 bytes, in lowercase hex —
// nothing normalized, trimmed or prefixed — so a client proves a write with any
// stock tool (`shasum -a 256`, `hashlib.sha256(s.encode()).hexdigest()`). Every
// vector below was computed with `printf '…' | shasum -a 256` on the bytes named.
//
// P-254-1. Red by absence on the tree before it: `MCPTextDigest` did not exist.

@Suite("VX-254 — the wire's one digest: plain SHA-256 of the UTF-8 bytes, lowercase hex")
struct MCPTextDigestTests {
    @Test func theDigestIsPlainSHA256OfTheUTF8BytesInLowercaseHex() {
        // The empty take (a blank take is answered and recognizable).
        #expect(MCPTextDigest.sha256("")
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(MCPTextDigest.sha256("abc")
                == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(MCPTextDigest.sha256("a")
                == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
    }

    @Test func nothingIsNormalized() {
        // NFC "é" (c3 a9) and NFD "é" (65 cc 81) are canonically equal Swift
        // strings — and two different digests, because their bytes differ.
        let nfc = "\u{00E9}"
        let nfd = "e\u{0301}"
        #expect(nfc == nfd, "Swift calls them equal; the digest must not")
        #expect(MCPTextDigest.sha256(nfc) == "4a99557e4033c3539de2eb65472017cad5f9557f7a0625a09f1c3f6e2ba69c4c")
        #expect(MCPTextDigest.sha256(nfd) == "bf12767b0f2a56b2190075bae8169f656e3ce8d6357d4aff184bc6c7ea48f9f6")
    }

    @Test func herTranscriptionSlipIsCaught() {
        // Her bilingual-book run's one slip (ch. 11): the source said
        // "beliscáu", the stored take "beliscou".
        #expect(MCPTextDigest.sha256("beliscou")
                == "1ed8e723b16bc7903dd4df9a35ce7df990a81aa578a7cc369b6d120d7b15130d")
        #expect(MCPTextDigest.sha256("belisc\u{00E1}u")
                == "dce72ca8ad6c9e9cb4220809d1c41365d15626394b2dbbec54d5a02666b4223f")
    }

    @Test func nothingIsTrimmed() {
        // A trailing space and an embedded U+0000 are bytes like any other.
        #expect(MCPTextDigest.sha256("a ") != MCPTextDigest.sha256("a"))
        #expect(MCPTextDigest.sha256("a\u{0000}b")
                == "59b271ae1bbcb1d31d41929817f4b16fb439eb4f31520b5ad1d5ce98920a7138")
    }
}
