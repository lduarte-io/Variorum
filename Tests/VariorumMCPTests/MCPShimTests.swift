import Darwin
import Foundation
import Testing

@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U1 P7 — THE SHIM's behaviour (A-2, AF-1 as amended — P-13nb-U1-7):
// the bundle-derived socket road, the two honest refusals told apart and
// spoken as a JSON-RPC error to the client's first request, the length guard
// instead of a truncated path, and the byte pump carrying a real `initialize`
// through to the server verbatim.

@Suite("13n-b U1 — the variorum-mcp shim", .serialized)
struct MCPShimTests {
    @Test func theSocketRoadIsTheAppsOwnContainerUnderTheRealHome() {
        let directory = MCPSocketRoad.containerDataDirectory(
            bundleIdentifier: "io.lduarte.Variorum.debug", realHome: "/Users/someone")
        #expect(directory.path == "/Users/someone/Library/Containers/io.lduarte.Variorum.debug/Data")
        #expect(MCPSocketRoad.socketPath(directory: directory)
                == "/Users/someone/Library/Containers/io.lduarte.Variorum.debug/Data/mcp.sock")
    }

    @Test func theShimFindsItsAppByItsOwnBundle() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("vshim-\(UUID().uuidString.prefix(8))/Variorum.app/Contents", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root.deletingLastPathComponent().deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: root.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
        let plist = try PropertyListSerialization.data(
            fromPropertyList: ["CFBundleIdentifier": "io.lduarte.Variorum.debug"], format: .xml, options: 0)
        try plist.write(to: root.appendingPathComponent("Info.plist"))
        let shim = root.appendingPathComponent("MacOS/variorum-mcp")
        #expect(MCPSocketRoad.bundleIdentifier(ofAppContaining: shim) == "io.lduarte.Variorum.debug")
        #expect(MCPSocketRoad.bundleIdentifier(
            ofAppContaining: URL(fileURLWithPath: "/usr/local/bin/variorum-mcp")) == nil)
    }

    @Test func theTwoRefusalsAreToldApart() {
        #expect(MCPSocketRoad.classify(errno: ENOENT) == .notRunning(errno: ENOENT))
        #expect(MCPSocketRoad.classify(errno: ECONNREFUSED) == .notRunning(errno: ECONNREFUSED))
        #expect(MCPSocketRoad.classify(errno: EPERM) == .blocked(errno: EPERM))
        #expect(MCPSocketRoad.classify(errno: EACCES) == .blocked(errno: EACCES))
        #expect(MCPSocketRoad.classify(errno: EIO) == .other(errno: EIO))
        #expect(MCPShim.refusalMessage(.notRunning(errno: ENOENT)).hasPrefix("Variorum must be open"))
        #expect(MCPShim.refusalMessage(.blocked(errno: EPERM)).hasPrefix("macOS refused the connection"))
        #expect(MCPShim.refusalMessage(.pathTooLong(bytes: 140)).contains("140 bytes"))
    }

    @Test func aPathTooLongForTheSocketIsRefusedNeverTruncated() throws {
        let deep = URL(fileURLWithPath: "/tmp/" + String(repeating: "d", count: 120), isDirectory: true)
        if case .failure(let failure) = MCPSocketRoad.connect(directory: deep) {
            #expect(failure == .pathTooLong(bytes: MCPSocketRoad.socketPath(directory: deep).utf8.count))
        } else {
            Issue.record("a too-long path must refuse")
        }
        #expect(throws: MCPSocketRoad.ListenError(kind: .pathTooLong(
            bytes: MCPSocketRoad.socketPath(directory: deep).utf8.count))) {
            try MCPSocketRoad.listen(directory: deep)
        }
    }

    @Test func theRefusalAnswersTheFirstRequestByItsID() throws {
        let request = Data(#"{"jsonrpc":"2.0","id":7,"method":"initialize","params":{}}"#.utf8)
        let answer = MCPShim.refusalResponse(toFirstLine: request, message: "Variorum must be open.")
        #expect(answer.last == UInt8(ascii: "\n"), "a framed line")
        let object = try #require(try JSONSerialization.jsonObject(with: answer.dropLast()) as? [String: Any])
        #expect(object["jsonrpc"] as? String == "2.0")
        #expect(object["id"] as? Int == 7)
        let error = try #require(object["error"] as? [String: Any])
        #expect(error["code"] as? Int == MCPShim.refusalCode)
        #expect(error["message"] as? String == "Variorum must be open.")
        let stringID = MCPShim.refusalResponse(toFirstLine: Data(#"{"id":"a1","method":"x"}"#.utf8), message: "m")
        #expect(try (JSONSerialization.jsonObject(with: stringID.dropLast()) as? [String: Any])?["id"] as? String == "a1")
        let garbage = MCPShim.refusalResponse(toFirstLine: Data("not json".utf8), message: "m")
        #expect(try (JSONSerialization.jsonObject(with: garbage.dropLast()) as? [String: Any])?["id"] is NSNull)
    }

    @Test func aShimOutsideAnAppRefusesHonestlyOnTheWire() throws {
        var input: [Int32] = [-1, -1], output: [Int32] = [-1, -1]
        #expect(pipe(&input) == 0 && pipe(&output) == 0)
        defer { for fd in input + output { close(fd) } }
        _ = MCPShim.writeAll(input[1], Data((#"{"jsonrpc":"2.0","id":1,"method":"initialize"}"# + "\n").utf8))
        let outcome = MCPShim.run(
            executable: URL(fileURLWithPath: "/usr/local/bin/variorum-mcp"), home: "/Users/x",
            input: input[0], output: output[1])
        #expect(outcome == .notInsideApp)
        let line = MCPShim.readFirstLine(output[0], limit: 4096)
        let object = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        #expect(object["id"] as? Int == 1)
        #expect((object["error"] as? [String: Any])?["message"] as? String
                == MCPShim.notInsideAppMessage(URL(fileURLWithPath: "/usr/local/bin/variorum-mcp")))
    }

    // MARK: - VX-168: the preamble (K2 — the shim stays MCP-blind)

    @Test func theKeyIsReadFromTheEnvironmentAsTheShimWillSpeakIt() {
        let variable = MCPPreamble.environmentVariable
        #expect(variable == "VARIORUM_MCP_KEY")
        #expect(MCPPreamble.key(inEnvironment: [variable: "vmk1_abcDEF-_9"]) == "vmk1_abcDEF-_9")
        #expect(MCPPreamble.key(inEnvironment: [variable: "  vmk1_abc\n"]) == "vmk1_abc", "trimmed")
        #expect(MCPPreamble.key(inEnvironment: [:]) == nil, "absent: bare")
        #expect(MCPPreamble.key(inEnvironment: [variable: "   "]) == nil, "empty: bare")
        #expect(MCPPreamble.key(inEnvironment: [variable: "vmk1 abc"]) == nil, "a space could split the line")
        #expect(MCPPreamble.key(inEnvironment: [variable: "vmk1_é"]) == nil, "printable ASCII only")
        #expect(MCPPreamble.key(inEnvironment: [variable: "a\u{0}b"]) == nil)
        #expect(MCPPreamble.key(inEnvironment: [variable: String(repeating: "k", count: 257)]) == nil, "bounded")
        #expect(MCPPreamble.key(inEnvironment: [variable: String(repeating: "k", count: 256)]) != nil)
    }

    @Test func thePreambleIsOneLineNoReaderTakesForAFrame() {
        let line = MCPPreamble.line(key: "vmk1_abc")
        #expect(line == Data("variorum-mcp-key vmk1_abc\n".utf8))
        #expect(MCPPreamble.classify(line.dropLast()) == .preamble(key: "vmk1_abc"))
        #expect(MCPPreamble.classify(Data("variorum-mcp-key".utf8)) == .preamble(key: ""), "a tag with no key")
        #expect(MCPPreamble.classify(Data(#"{"jsonrpc":"2.0","id":0,"method":"initialize"}"#.utf8)) == .frame)
        #expect(MCPPreamble.classify(Data("variorum-mcp-keys vmk1_abc".utf8)) == .frame, "the whole word only")
        #expect(MCPPreamble.classify(Data()) == .frame)
        #expect((try? JSONSerialization.jsonObject(with: line.dropLast())) == nil, "never JSON")
    }

    /// The connected shim: a key in its environment → the preamble FIRST,
    /// then the client's bytes verbatim; no key → nothing of its own (the
    /// client's `initialize` is the first line the app reads).
    @Test func aKeyedShimSpeaksThePreambleFirstAndABareOneNothing() throws {
        for keyed in [true, false] {
            var pair: [Int32] = [-1, -1]
            #expect(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
            var input: [Int32] = [-1, -1], output: [Int32] = [-1, -1]
            #expect(pipe(&input) == 0 && pipe(&output) == 0)
            let environment = keyed ? [MCPPreamble.environmentVariable: "vmk1_drill"] : [:]
            let (shimSocket, shimInput, shimOutput) = (pair[0], input[0], output[1])
            let shim = Thread {
                MCPShim.serve(socket: shimSocket, environment: environment, input: shimInput, output: shimOutput)
                close(shimSocket)
            }
            shim.start()
            let initialize = #"{"jsonrpc":"2.0","id":0,"method":"initialize","params":{}}"#
            _ = MCPShim.writeAll(input[1], Data((initialize + "\n").utf8))
            let first = MCPShim.readFirstLine(pair[1], limit: 4096)
            if keyed {
                #expect(first == Data("variorum-mcp-key vmk1_drill".utf8), "the preamble first")
                #expect(MCPShim.readFirstLine(pair[1], limit: 4096) == Data(initialize.utf8), "then verbatim")
            } else {
                #expect(first == Data(initialize.utf8), "a bare shim says nothing of its own")
            }
            close(input[1])
            shutdown(pair[1], SHUT_RDWR)
            close(pair[1])
            close(input[0])
            close(output[0])
            close(output[1])
        }
    }

    @Test func theTransportCapsAnUnterminatedLine() {
        var fds: [Int32] = [-1, -1]
        #expect(pipe(&fds) == 0)
        defer { close(fds[0]) }
        _ = MCPShim.writeAll(fds[1], Data("{\"a\":1}\n{\"b\":2}\n".utf8) + Data(repeating: UInt8(ascii: "x"), count: 300))
        close(fds[1])
        var lines: [String] = []
        MCPSocketTransport.readLines(fd: fds[0], cap: 100) { lines.append(String(decoding: $0, as: UTF8.self)) }
        #expect(lines == ["{\"a\":1}", "{\"b\":2}"], "complete lines pass; the oversize tail ends the read")
    }

    /// The pump carries a client's `initialize` to a REAL server and its
    /// answer back, byte for byte. VX-168 (A JUSTIFIED EDIT, the ritual): the
    /// shim runs CONNECTED as it ships — its setup key in its environment, so
    /// the preamble goes first — and the session behind it serves verbatim.
    @Test func thePumpCarriesARealSessionVerbatim() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        guard case .success(let socket) = MCPSocketRoad.connect(directory: h.directory) else {
            Issue.record("could not connect")
            return
        }
        var input: [Int32] = [-1, -1], output: [Int32] = [-1, -1]
        #expect(pipe(&input) == 0 && pipe(&output) == 0)
        let environment = [MCPPreamble.environmentVariable: try h.setupKey(for: "pump-test")]
        let (shimInput, shimOutput) = (input[0], output[1])
        let pump = Thread {
            MCPShim.serve(socket: socket, environment: environment, input: shimInput, output: shimOutput)
            close(socket)
            close(shimOutput)
        }
        pump.start()
        let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"pump-test","version":"1"}}}"#
        _ = MCPShim.writeAll(input[1], Data(initialize.utf8) + Data("\n".utf8))
        let line = MCPShim.readFirstLine(output[0], limit: 1 << 20)
        let object = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        #expect(object["id"] as? Int == 1)
        let result = try #require(object["result"] as? [String: Any])
        #expect((result["serverInfo"] as? [String: Any])?["name"] as? String == "variorum")
        #expect(try h.client("pump-test").state == .pending, "the shim's client is the self-declared name")
        close(input[1])  // the client hangs up: the pump half-closes, the server ends the session
        #expect(try await h.eventually { h.host.connectedClientNames.isEmpty })
        close(input[0])
        close(output[0])
    }
}
