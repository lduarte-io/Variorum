//
//  main.swift
//  variorum-mcp — THE MCP DOOR's stdio shim (13n-b U1, A-2)
//
//  A protocol-blind byte pump embedded at Variorum.app/Contents/MacOS/. An MCP
//  client (Claude Code, Claude Desktop, any stdio client) launches it; it
//  finds ITS OWN app's socket from its own bundle — the Debug shim reaches the
//  dev app, the Release shim the real one, by construction — and copies
//  newline-delimited JSON-RPC both ways verbatim. When the socket cannot be
//  reached it answers the client's first request with one honest JSON-RPC
//  error ("Variorum must be open", or macOS blocking the connection) and
//  exits. It holds no store, no key, no grant: the app is the one process that
//  ever touches the library. Signed with the hardened runtime and NO
//  app-sandbox entitlement, so a terminal-launched client can run it.
//
//  The whole behaviour lives in VariorumMCPSocket (`MCPShim`), tested
//  headless in VariorumMCPTests; this file only launches it.
//

import Darwin
import Foundation
import VariorumMCPSocket

// A client that hangs up mid-write must end the shim quietly, never by signal.
signal(SIGPIPE, SIG_IGN)

let executable = URL(fileURLWithPath: Bundle.main.executablePath ?? CommandLine.arguments[0])
let outcome = MCPShim.run(executable: executable, home: MCPSocketRoad.realHome())
switch outcome {
case .pumped:
    exit(0)
case .refused(let failure):
    FileHandle.standardError.write(Data((MCPShim.refusalMessage(failure) + "\n").utf8))
    exit(1)
case .notInsideApp:
    FileHandle.standardError.write(Data((MCPShim.notInsideAppMessage(executable) + "\n").utf8))
    exit(1)
}
