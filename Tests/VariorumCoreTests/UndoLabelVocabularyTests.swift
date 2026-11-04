import Foundation
import Testing
@testable import VariorumCore

/// **VX-634 — the structural undo receipt speaks the app's words.** Her walk
/// (the VX-601 batch A walk, O-1): ⌥⌘Z after Delete Take spoke "Undid: Delete
/// Variant" — the model word where the app says "take". The receipt is
/// `StructuralUndoCopy.undone(label)` over the label the operation registered,
/// so the word is fixed where it is minted: `deleteVariant`'s entry is
/// "Delete Take".
///
/// Two pins: the behaviour (the label her ⌥⌘Z and ⇧⌥⌘Z read back), and a
/// FENCE over every literal undo label in the shipped code (the label-fence
/// precedent, `DeadVocabularyTests`' form): no model word on a registered
/// label, with a NAMED allow-list whose every entry carries its reason. The
/// sweep this fix ran is the record's table
/// (`notes/plans/fixes/vx-770-takes-compare-window.md`, BATCH 5 › E).
@Suite("VX-634 — undo labels speak the app's words")
struct UndoLabelVocabularyTests {
    /// Delete Take, then ⌥⌘Z, then ⇧⌥⌘Z: both directions name a TAKE.
    @Test func deletingATakeUndoesAndRedoesAsDeleteTake() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "kept take")
            let spare = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(spare.id)
            #expect(try stack.undo(with: ops) == "Delete Take")
            #expect(try stack.redo(with: ops) == "Delete Take")
        }
    }

    // MARK: - The fence

    /// `…/Tests/VariorumCoreTests/<this file>` → the repo root.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo
    }

    /// The model words the app never speaks on an undo label: a take is never
    /// a "variant", a note never a "post" or a "container", a book never a
    /// "reading", a chapter never a "section", a commit never a "savepoint".
    static let modelWords = ["variant", "variants", "container", "post", "posts",
                             "reading", "readings", "section", "sections",
                             "savepoint", "savepoints"]

    /// Labels that may still carry a model word, each with the decision that
    /// keeps it. Nothing else may.
    ///
    /// 1. **"Archive Variant"** — `archiveVariant`'s entry, the sibling VX-634's
    ///    sweep found (the app's door is "Archive this take"). Deliberately NOT
    ///    fixed by the batch (the brief: fix only the Delete-Variant member,
    ///    report the rest); it rides the closeout as a ticket candidate. Remove
    ///    this line when it says "Archive Take".
    static let allowed: [String: String] = [
        "Archive Variant": "VX-634 sweep — the closeout ticket candidate (not this batch's)",
    ]

    /// Every literal undo label: the core Operations' `label: "…"` arguments
    /// (each one an undo registration there) and every `withCompound(label: "…")`
    /// across the app, the shared code and the core.
    static func literalUndoLabels() throws -> [(label: String, site: String)] {
        let roots = ["Sources/VariorumCore", "App/Variorum/Variorum", "App/Variorum/Shared"]
        var found: [(String, String)] = []
        for rootName in roots {
            let root = repoRoot.appendingPathComponent(rootName)
            guard let walker = FileManager.default.enumerator(
                at: root, includingPropertiesForKeys: nil) else { continue }
            for case let file as URL in walker where file.pathExtension == "swift" {
                let relative = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
                let inOperations = relative.hasPrefix("Sources/VariorumCore/Operations/")
                let source = try String(contentsOf: file, encoding: .utf8)
                for (index, line) in source.split(
                    separator: "\n", omittingEmptySubsequences: false).enumerated() {
                    let text = String(line)
                    let trimmed = text.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("//") || trimmed.hasPrefix("*") { continue }
                    let marker = inOperations ? "label: \"" : "withCompound(label: \""
                    var search = text.startIndex..<text.endIndex
                    while let start = text.range(of: marker, range: search) {
                        guard let end = text[start.upperBound...].firstIndex(of: "\"") else { break }
                        found.append((String(text[start.upperBound..<end]),
                                      "\(relative):\(index + 1)"))
                        search = text.index(after: end)..<text.endIndex
                    }
                }
            }
        }
        return found
    }

    @Test func noUndoLabelSpeaksAModelWord() throws {
        let labels = try Self.literalUndoLabels()
        #expect(labels.count > 25, "the scan must actually reach the registrations (\(labels.count))")
        #expect(labels.contains { $0.label == "Delete Block" }, "non-vacuity: a known label is found")
        var offenders: [String] = []
        for (label, site) in labels where Self.allowed[label] == nil {
            for word in Self.modelWords where Self.containsWord(word, in: label) {
                offenders.append("\(site) — \"\(label)\" says \"\(word)\"")
            }
        }
        #expect(offenders.isEmpty, """
            An undo label speaks a model word (the receipt reads "Undid: <label>"; the app says \
            take / note / book / chapter / commit). Use the app's word, or add the label to this \
            pin's allow-list WITH the decision that allows it.
            \(offenders.joined(separator: "\n"))
            """)
        // The allow-list is live: every entry still exists (a fixed sibling
        // must leave the list, so the fence closes over it).
        for allowedLabel in Self.allowed.keys {
            #expect(labels.contains { $0.label == allowedLabel },
                    "allow-list entry \"\(allowedLabel)\" no longer exists — remove it")
        }
    }

    /// The matcher fires on the banned forms and spares code-name lookalikes.
    @Test func theMatcherFiresOnWholeWordsOnly() {
        #expect(Self.containsWord("variant", in: "Delete Variant"))
        #expect(Self.containsWord("post", in: "Move Post"))
        #expect(!Self.containsWord("post", in: "Compose"))
        #expect(!Self.containsWord("reading", in: "Readings"))  // its own word
        #expect(!Self.containsWord("section", in: "Intersection"))
    }

    /// `word` appears in `text` as a whole word, case-insensitively.
    static func containsWord(_ word: String, in text: String) -> Bool {
        var search = text.startIndex..<text.endIndex
        while let range = text.range(of: word, options: .caseInsensitive, range: search) {
            let before = range.lowerBound > text.startIndex
                ? text[text.index(before: range.lowerBound)] : " "
            let after = range.upperBound < text.endIndex ? text[range.upperBound] : " "
            let boundary: (Character) -> Bool = { !($0.isLetter || $0.isNumber || $0 == "_") }
            if boundary(before) && boundary(after) { return true }
            search = range.upperBound..<text.endIndex
        }
        return false
    }
}
