import Foundation

/// **WHAT A SAVEPOINT'S NAME IS, AS ONE RULE** (13u3 UNIT D — item 14, her
/// ruling R-13u3-1; the master plan's words: *"an optional name at the
/// manual-commit door, enter-to-skip keeps ⌘S instant"*).
///
/// `commit_point.message` has carried a name since v1 and no face ever
/// offered one. Now three doors write it — the commit door's field, the
/// rename door in Block History, and `commit(message:)`'s own parameter —
/// and a name typed at one of them must mean exactly what it means at the
/// others. So the normalisation is a pure function both the operations layer
/// and the faces consult, rather than a `trimmingCharacters` call repeated at
/// each door (`setTakeLabel`'s inline version is the counterexample this
/// avoids: the same rule, spelled once per site).
///
/// The rule, whole: **ends trimmed; nothing left means no name.** A field she
/// opens and leaves empty, a field she clears, and an explicit nil are the
/// same act — the savepoint has no name — which is what lets ⌘S ⏎ stay two
/// keys and what makes the rename door's clear road free.
///
/// Newlines are trimmed at the ends with the spaces (a name is a line, and a
/// pasted line often carries one) but NEVER touched inside: the store keeps
/// what she typed, and a face that cannot show a two-line name is the face's
/// problem to solve with `lineLimit`, not the store's to solve by editing her
/// text.
public enum SavepointName {
    /// The stored form of a typed name: trimmed, and nil where nothing but
    /// whitespace is left. VX-357: any U+0000 is removed first
    /// (`StoredText.stripped` — the store cannot hold one), so a name of
    /// nothing but null characters is no name.
    public static func normalized(_ raw: String?) -> String? {
        guard let trimmed = StoredText.stripped(raw)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty
        else { return nil }
        return trimmed
    }
}
