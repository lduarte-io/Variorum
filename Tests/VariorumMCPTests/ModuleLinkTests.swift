import MCP
import Testing
@testable import VariorumMCP

@Suite("VariorumMCP links the pinned SDK (13n-b P2)")
struct ModuleLinkTests {
    @Test func theSDKsProtocolVersionIsReachable() {
        #expect(!Version.latest.isEmpty)
        #expect(VariorumMCP.serverName == "variorum")
    }
}
