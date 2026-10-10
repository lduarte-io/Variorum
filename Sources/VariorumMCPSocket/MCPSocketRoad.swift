import Darwin
import Foundation

/// **THE MCP DOOR's SOCKET ROAD** (13n-b U1 — R-13n-3; the architect's AF-1
/// on the A-10 probe facts, the plan's U1 record). The one rule BOTH ends
/// read: the app (the listener, inside its sandbox) and the `variorum-mcp`
/// shim (the client's stdio end, unsandboxed). Foundation and Darwin only —
/// the shim links this and nothing of Variorum's (A-2: zero store access,
/// zero VariorumCore).
///
/// - **Where:** `<the app's container>/Data/mcp.sock` — the sandboxed app's
///   own home, the ONLY place a sandboxed listener can bind (probe (b): the
///   home-relative exception refuses `bind`). The shim reaches it from its
///   OWN bundle: `../Info.plist` names the app's bundle id, and the container
///   is `~/Library/Containers/<bundle id>/Data` under the REAL home — so the
///   Debug shim reaches the dev app and the Release shim the real one by
///   construction (the A4 fence extended to the door).
/// - **How:** an ABSOLUTE path, length-guarded. AF-1 approved
///   `bindat`/`connectat` against a directory descriptor so `sun_path`'s
///   104-byte limit could never bite; on the macOS 27 SDK neither they nor
///   the per-thread `pthread_fchdir_np` are public API (no header declares
///   them — a shipping app does not call private syscalls), so both ends use
///   the plain path and refuse HONESTLY when it would not fit (`pathTooLong`)
///   rather than truncate it. The budget is 103 bytes:
///   `/Users/<name>/Library/Containers/<bundle id>/Data/mcp.sock` leaves a
///   user name up to 36 characters (Debug) or 42 (Release). The socket is
///   `0600` inside a `0700` container.
/// - **Refusals the shim tells apart (probe (a)):** ENOENT / ECONNREFUSED ⇒
///   the server isn't running ("Variorum must be open"); EPERM / EACCES ⇒
///   macOS blocked the connection — its own honest line.
public enum MCPSocketRoad {
    /// The socket's name inside the container's data directory.
    public static let socketName = "mcp.sock"

    /// The longest socket path `sockaddr_un` holds (104 bytes, NUL included).
    public static let maxPathBytes = 103

    /// The socket's absolute path.
    public static func socketPath(directory: URL, name: String = socketName) -> String {
        directory.appendingPathComponent(name).path
    }

    // MARK: - Where

    /// The sandboxed app's own data directory, from its bundle id and the
    /// REAL home (never `$HOME`, which a sandboxed caller sees remapped).
    public static func containerDataDirectory(bundleIdentifier: String, realHome: String) -> URL {
        URL(fileURLWithPath: realHome, isDirectory: true)
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Containers", isDirectory: true)
            .appendingPathComponent(bundleIdentifier, isDirectory: true)
            .appendingPathComponent("Data", isDirectory: true)
    }

    /// The account's real home directory (the password database's answer).
    public static func realHome() -> String? {
        guard let entry = getpwuid(getuid()), let dir = entry.pointee.pw_dir else { return nil }
        return String(cString: dir)
    }

    /// The bundle id of the app whose `Contents/MacOS/` holds `executable`:
    /// `Contents/Info.plist`'s `CFBundleIdentifier`. nil when the executable
    /// does not sit inside an app bundle.
    public static func bundleIdentifier(ofAppContaining executable: URL) -> String? {
        let contents = executable.resolvingSymlinksInPath()
            .deletingLastPathComponent()      // MacOS
            .deletingLastPathComponent()      // Contents
        let plist = contents.appendingPathComponent("Info.plist")
        guard let data = try? Data(contentsOf: plist),
              let object = try? PropertyListSerialization.propertyList(from: data, format: nil),
              let dictionary = object as? [String: Any],
              let identifier = dictionary["CFBundleIdentifier"] as? String,
              !identifier.isEmpty
        else { return nil }
        return identifier
    }

    // MARK: - Connect (the shim's end)

    public enum ConnectFailure: Error, Equatable, Sendable {
        /// ENOENT / ECONNREFUSED / ENOTDIR: nothing is listening — the app is
        /// not open, or its MCP server is off.
        case notRunning(errno: Int32)
        /// EPERM / EACCES: macOS refused the connection.
        case blocked(errno: Int32)
        /// The path is longer than `sockaddr_un` holds (an unusually long
        /// home path) — refused rather than truncated.
        case pathTooLong(bytes: Int)
        /// Anything else.
        case other(errno: Int32)
    }

    /// The shim's two honest roads, classified from `errno` (pure — pinned).
    public static func classify(errno code: Int32) -> ConnectFailure {
        switch code {
        case ENOENT, ECONNREFUSED, ENOTDIR: .notRunning(errno: code)
        case EPERM, EACCES: .blocked(errno: code)
        default: .other(errno: code)
        }
    }

    /// Connect to the socket `name` inside `directory`. Returns a connected,
    /// blocking stream socket with SIGPIPE suppressed, or the classified
    /// failure.
    public static func connect(directory: URL, name: String = socketName) -> Result<Int32, ConnectFailure> {
        let path = socketPath(directory: directory, name: name)
        guard path.utf8.count <= maxPathBytes else { return .failure(.pathTooLong(bytes: path.utf8.count)) }
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return .failure(.other(errno: errno)) }
        suppressSIGPIPE(fd)
        let result = withSocketAddress(path) { address, length in Darwin.connect(fd, address, length) }
        guard result == 0 else {
            let code = errno
            close(fd)
            return .failure(classify(errno: code))
        }
        return .success(fd)
    }

    // MARK: - Listen (the app's end)

    public struct ListenError: Error, Equatable, Sendable, CustomStringConvertible {
        public enum Kind: Equatable, Sendable {
            /// Another live process already answers on this socket — never
            /// unlinked out from under it.
            case alreadyServed
            /// The path is longer than `sockaddr_un` holds.
            case pathTooLong(bytes: Int)
            case failed(step: String, errno: Int32)
        }
        public let kind: Kind
        public init(kind: Kind) { self.kind = kind }
        public var description: String {
            switch kind {
            case .alreadyServed:
                return "another Variorum is already serving \(MCPSocketRoad.socketName)"
            case .pathTooLong(let bytes):
                return "the socket path is \(bytes) bytes; macOS allows \(MCPSocketRoad.maxPathBytes)"
            case .failed(let step, let code):
                return "\(step) failed: \(String(cString: strerror(code))) (errno \(code))"
            }
        }
    }

    /// Bind and listen on `name` inside `directory` (`0600`). A STALE socket
    /// file (nobody answering) is replaced; a LIVE one refuses
    /// (`alreadyServed`) — a second instance never steals the first's door.
    public static func listen(directory: URL, name: String = socketName, backlog: Int32 = 8) throws -> Int32 {
        let path = socketPath(directory: directory, name: name)
        guard path.utf8.count <= maxPathBytes else {
            throw ListenError(kind: .pathTooLong(bytes: path.utf8.count))
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if case .success(let probe) = connect(directory: directory, name: name) {
            close(probe)
            throw ListenError(kind: .alreadyServed)
        }
        Darwin.unlink(path)
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw ListenError(kind: .failed(step: "socket", errno: errno)) }
        _ = fcntl(fd, F_SETFD, FD_CLOEXEC)
        let bound = withSocketAddress(path) { address, length in bind(fd, address, length) }
        guard bound == 0 else {
            let code = errno
            close(fd)
            throw ListenError(kind: .failed(step: "bind", errno: code))
        }
        guard chmod(path, 0o600) == 0 else {
            let code = errno
            close(fd)
            Darwin.unlink(path)
            throw ListenError(kind: .failed(step: "chmod", errno: code))
        }
        guard Darwin.listen(fd, backlog) == 0 else {
            let code = errno
            close(fd)
            Darwin.unlink(path)
            throw ListenError(kind: .failed(step: "listen", errno: code))
        }
        return fd
    }

    /// Remove the socket file (server stop — the socket dies with the app).
    public static func unlink(directory: URL, name: String = socketName) {
        Darwin.unlink(socketPath(directory: directory, name: name))
    }

    /// A peer that vanishes must never raise SIGPIPE in this process (the app
    /// would die of a closed client): writes fail with EPIPE instead.
    public static func suppressSIGPIPE(_ fd: Int32) {
        var on: Int32 = 1
        _ = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &on, socklen_t(MemoryLayout<Int32>.size))
    }

    private static func withSocketAddress<R>(
        _ path: String, _ body: (UnsafePointer<sockaddr>, socklen_t) -> R
    ) -> R {
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8)
        withUnsafeMutableBytes(of: &address.sun_path) { raw in
            raw.copyBytes(from: bytes)       // guarded ≤ maxPathBytes by every caller
            raw[bytes.count] = 0
        }
        address.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)
        return withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                body($0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
    }
}
