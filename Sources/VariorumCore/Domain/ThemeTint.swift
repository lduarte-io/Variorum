import Foundation

/// **THE ONE RULE FOR A CUSTOM PALETTE SEED** (18g, the 2026-09-12
/// use-report round — her R-Q6 *"maybe the ability to choose the hex code
/// of your default theme"* and R-Q13 *"Custom = ONE hex, with an optional
/// second"*).
///
/// A seed is six hexadecimal digits. This type is the only place that says
/// so: the SETTER validates through it (a malformed value refuses — the
/// door fires and says why, P-2), the READ validates through it (a value
/// that reached the row by any other road — a hand-edited store, a peer on
/// an older build, a future key rename — reads as ABSENT rather than as a
/// colour nobody can name), and the app's derivation brain turns the
/// stored text into a number through it. Two copies of a validation rule is
/// the drift class (MobileSoul §3); this is one.
///
/// **What it tolerates and what it refuses.** It trims surrounding
/// whitespace and accepts ONE leading `#`, because that is how a colour is
/// written down everywhere she would copy one from; everything else — five
/// digits, seven, `rgb(…)`, a colour word, an empty string — is not a
/// colour and returns nil. The normalized form is always six UPPERCASE
/// digits with no `#`, so the stored value is canonical and two devices
/// that typed the same colour differently converge to the same bytes under
/// CAS.
///
/// **Why the stored form matters to the envelope.** `setting.value` is
/// classified PLAIN under E2EE with the column-fenced promise "enum
/// semantics, no prose" (AppSpec §7, the 14b ladder's R1-9). Six hex digits
/// are structured, not prose — the promise holds because this rule is what
/// keeps the column from ever holding anything else. The CLEARED form is
/// the empty string (a `setting` row is upsert-only and never tombstoned —
/// the `fan_style` class), which this rule reads as absent.
public enum ThemeTint {
    /// The canonical six-digit form of a seed she typed, or nil if it is
    /// not a colour. Also the CLEAR test: `normalize("")` is nil.
    public static func normalize(_ raw: String?) -> String? {
        guard let raw else { return nil }
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6 else { return nil }
        let digits = text.uppercased()
        guard digits.allSatisfy({ $0.isHexDigit && $0.isASCII }) else { return nil }
        return digits
    }

    /// The same rule, as the 24-bit sRGB number the token layer wants.
    /// Nil for exactly the values `normalize` calls not-a-colour.
    public static func value(_ raw: String?) -> UInt32? {
        guard let digits = normalize(raw) else { return nil }
        return UInt32(digits, radix: 16)
    }

    /// What a cleared seed is stored as — the empty string, because a
    /// `setting` row is upsert-only and never tombstoned. Named so the
    /// setter and any future reader agree about what "no colour" looks
    /// like in the column.
    public static let cleared = ""
}
