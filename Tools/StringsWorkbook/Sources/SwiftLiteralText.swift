// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation

/// Renders the BODY of a Swift string literal (the text between its quotes,
/// exactly as the copy-pass inventory writes it — escapes kept) into the text
/// the screen shows, with one deliberate exception: `\(…)` interpolations stay
/// VERBATIM, because the workbook's "current" take must show her where the
/// runtime value goes, and the applying implementer needs the expression.
///
/// Escapes rendered: `\u{…}`, `\n`, `\t`, `\r`, `\0`, `\"`, `\'`, `\\`. Any
/// other backslash sequence REFUSES (`unknownEscape`) rather than guessing —
/// the inventory is a fixed snapshot, so an unknown escape is a parse defect
/// worth stopping for.
public enum SwiftLiteralText {
    public enum RenderError: Error, Equatable, CustomStringConvertible {
        case unknownEscape(String)
        case badUnicodeEscape(String)
        case unterminatedInterpolation(String)

        public var description: String {
            switch self {
            case .unknownEscape(let s): return "unknown Swift escape in literal: \(s)"
            case .badUnicodeEscape(let s): return "malformed \\u{…} escape in literal: \(s)"
            case .unterminatedInterpolation(let s): return "unterminated \\(…) interpolation in literal: \(s)"
            }
        }
    }

    public static func render(_ body: String) throws -> String {
        let chars = Array(body)
        var out = ""
        var i = 0
        while i < chars.count {
            let c = chars[i]
            guard c == "\\" else {
                out.append(c)
                i += 1
                continue
            }
            guard i + 1 < chars.count else { throw RenderError.unknownEscape(body) }
            let next = chars[i + 1]
            switch next {
            case "(":
                let end = try interpolationEnd(chars, openParen: i + 1, body: body)
                out.append(contentsOf: String(chars[i...end]))
                i = end + 1
            case "u":
                guard i + 2 < chars.count, chars[i + 2] == "{",
                      let close = chars[(i + 3)...].firstIndex(of: "}")
                else { throw RenderError.badUnicodeEscape(body) }
                let hex = String(chars[(i + 3)..<close])
                guard (1...8).contains(hex.count),
                      let value = UInt32(hex, radix: 16),
                      let scalar = Unicode.Scalar(value)
                else { throw RenderError.badUnicodeEscape(body) }
                out.unicodeScalars.append(scalar)
                i = close + 1
            case "n": out.append("\n"); i += 2
            case "t": out.append("\t"); i += 2
            case "r": out.append("\r"); i += 2
            case "0": out.append("\0"); i += 2
            case "\"": out.append("\""); i += 2
            case "'": out.append("'"); i += 2
            case "\\": out.append("\\"); i += 2
            default:
                throw RenderError.unknownEscape("\\\(next) in \(body)")
            }
        }
        return out
    }

    /// The index of the `)` that closes the interpolation whose `(` sits at
    /// `openParen`. Nested parentheses count; string literals INSIDE the
    /// interpolation (`\(x ?? "a (note)")`) are skipped whole, escapes and all.
    static func interpolationEnd(_ chars: [Character], openParen: Int, body: String) throws -> Int {
        var depth = 0
        var i = openParen
        var inString = false
        while i < chars.count {
            let c = chars[i]
            if inString {
                if c == "\\" { i += 2; continue }
                if c == "\"" { inString = false }
                i += 1
                continue
            }
            switch c {
            case "\"": inString = true
            case "(": depth += 1
            case ")":
                depth -= 1
                if depth == 0 { return i }
            default: break
            }
            i += 1
        }
        throw RenderError.unterminatedInterpolation(body)
    }
}
