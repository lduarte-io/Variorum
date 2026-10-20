import Foundation

// The stage rule (rail 2): the ambient may be on screen only while the stage is free or held by the
// coordinator's own hold — a claim whose reason starts with exactly "HOLD:". Any other claim (a GO'd
// session, the coordinator's "GO pending:" bridge, its "HOLD FOR <walk>" hold for an expired claim)
// means someone else owns the screen, and the ambient goes. `Tools/stage` writes the claim with bash
// `printf %q`, so the values arrive shell-quoted; `unquote` reverses exactly that.

public enum StageVerdict: Equatable, Sendable {
    /// No claim: the stage is free.
    case free
    /// The coordinator's own hold ("HOLD:" prefix).
    case hold(who: String)
    /// A claim by the claimant named with `--allow-claimant` (the evidence window only).
    case allowed(who: String)
    /// Someone else holds the stage: the ambient must not be up.
    case foreign(who: String, reason: String)
    /// The lock directory exists but its claim file doesn't yet (a claim mid-write, or a stale lock).
    case pending

    public var permitsAmbient: Bool {
        switch self {
        case .free, .hold, .allowed: true
        case .foreign, .pending: false
        }
    }
}

public enum StageClaim {
    public static let holdPrefix = "HOLD:"

    public static var defaultLockDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".variorum/stage.d", isDirectory: true)
    }

    /// Reads the lock as `Tools/stage` leaves it.
    public static func read(lockDirectory: URL = defaultLockDirectory, allowedClaimant: String? = nil) -> StageVerdict {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: lockDirectory.path, isDirectory: &isDir), isDir.boolValue else {
            return .free
        }
        let meta = try? String(contentsOf: lockDirectory.appendingPathComponent("claim"), encoding: .utf8)
        return verdict(meta: meta, allowedClaimant: allowedClaimant)
    }

    /// The decision for a lock directory that exists, given its claim file's contents (nil = no file).
    public static func verdict(meta: String?, allowedClaimant: String?) -> StageVerdict {
        guard let meta else { return .pending }
        let fields = parse(meta)
        guard let who = fields["WHO"] else { return .pending }
        let reason = fields["REASON"] ?? ""
        if reason.hasPrefix(holdPrefix) { return .hold(who: who) }
        if let allowedClaimant, !allowedClaimant.isEmpty, who == allowedClaimant { return .allowed(who: who) }
        return .foreign(who: who, reason: reason)
    }

    /// `KEY=value` lines, values unquoted.
    public static func parse(_ meta: String) -> [String: String] {
        var out: [String: String] = [:]
        for line in meta.split(whereSeparator: \.isNewline) {
            guard let eq = line.firstIndex(of: "=") else { continue }
            let key = String(line[..<eq])
            out[key] = unquote(String(line[line.index(after: eq)...]))
        }
        return out
    }

    /// Reverses bash's `printf %q`: `$'…'` (ANSI-C escapes, octal bytes for non-ASCII), `'…'`, and
    /// backslash-escaped bare words.
    public static func unquote(_ s: String) -> String {
        var bytes: [UInt8] = []
        let u = Array(s.utf8)
        var i = 0
        while i < u.count {
            let c = u[i]
            if c == UInt8(ascii: "$"), i + 1 < u.count, u[i + 1] == UInt8(ascii: "'") {
                i += 2
                while i < u.count, u[i] != UInt8(ascii: "'") {
                    if u[i] == UInt8(ascii: "\\"), i + 1 < u.count {
                        let e = u[i + 1]
                        i += 2
                        switch e {
                        case UInt8(ascii: "n"): bytes.append(10)
                        case UInt8(ascii: "t"): bytes.append(9)
                        case UInt8(ascii: "r"): bytes.append(13)
                        case UInt8(ascii: "a"): bytes.append(7)
                        case UInt8(ascii: "b"): bytes.append(8)
                        case UInt8(ascii: "e"), UInt8(ascii: "E"): bytes.append(27)
                        case UInt8(ascii: "f"): bytes.append(12)
                        case UInt8(ascii: "v"): bytes.append(11)
                        case UInt8(ascii: "0")...UInt8(ascii: "7"):
                            var v = Int(e - UInt8(ascii: "0")), n = 1
                            while n < 3, i < u.count, (UInt8(ascii: "0")...UInt8(ascii: "7")).contains(u[i]) {
                                v = v * 8 + Int(u[i] - UInt8(ascii: "0")); i += 1; n += 1
                            }
                            bytes.append(UInt8(truncatingIfNeeded: v))
                        case UInt8(ascii: "x"):
                            var v = 0, n = 0
                            while n < 2, i < u.count, let d = hexDigit(u[i]) { v = v * 16 + d; i += 1; n += 1 }
                            bytes.append(UInt8(truncatingIfNeeded: v))
                        default: bytes.append(e) // \\ \' \" and anything else: the character itself
                        }
                    } else {
                        bytes.append(u[i]); i += 1
                    }
                }
                i += 1 // closing quote
            } else if c == UInt8(ascii: "'") {
                i += 1
                while i < u.count, u[i] != UInt8(ascii: "'") { bytes.append(u[i]); i += 1 }
                i += 1
            } else if c == UInt8(ascii: "\\"), i + 1 < u.count {
                bytes.append(u[i + 1]); i += 2
            } else {
                bytes.append(c); i += 1
            }
        }
        return String(decoding: bytes, as: UTF8.self)
    }

    private static func hexDigit(_ c: UInt8) -> Int? {
        switch c {
        case UInt8(ascii: "0")...UInt8(ascii: "9"): Int(c - UInt8(ascii: "0"))
        case UInt8(ascii: "a")...UInt8(ascii: "f"): Int(c - UInt8(ascii: "a")) + 10
        case UInt8(ascii: "A")...UInt8(ascii: "F"): Int(c - UInt8(ascii: "A")) + 10
        default: nil
        }
    }
}

/// Rail 5: real input quits the ambient. The host reads the HID system's idle time (what the
/// coordinator reads too — nothing is posted, nothing is asserted); input that arrived after the
/// short launch grace means someone is at the machine.
public enum InputRule {
    public static let launchGrace = 0.75

    /// `uptime` = seconds since the ambient came up; `idle` = seconds since the last HID event.
    public static func inputArrived(uptime: Double, idle: Double, grace: Double = launchGrace) -> Bool {
        guard uptime.isFinite, idle.isFinite else { return false }
        return uptime - idle > grace
    }
}
