import Foundation

/// **A FOLDER OF VARIORUM DOCUMENTS, READ AS A BOOK** (13n-a — R-13n-8: *"a
/// FOLDER imports as a book — subfolders = chapters, filename order = book
/// order, folder names = names"*).
///
/// Pure over what the app read off the disk (the face walks the folder under
/// its security scope and hands every file's folder-relative path and text
/// here), so the folder rule is pinned headlessly:
///
/// - **What counts:** files whose extension is one the import door accepts
///   (`importableExtensions` — `.variorum`, `.md`/`.markdown`, `.txt`/`.text`;
///   PROVISIONAL, the plan's open item); anything hidden (a path component
///   starting with ".") never counts; every other file is passed over.
/// - **Chapters:** each FIRST-LEVEL subfolder is a chapter named by its
///   folder — an empty subfolder still makes its (empty) chapter. A file
///   nested DEEPER rides into its first-level chapter, ordered by its path
///   (PROVISIONAL — chapters never nest, AppSpec §7 `reading_section`).
/// - **Order:** digit-aware a–z, the Bookcase's own rule
///   (`localizedStandardCompare` — Finder's: "2 …" before "10 …"), for the
///   chapters and for the files inside each; the raw string breaks ties.
/// - **Fail-honest:** every file parses before anything is minted; the first
///   refusal (in book order) names its file and line.
public enum VariorumDocumentFolder {
    /// The extensions the import door reads (lower-cased comparison).
    public static let importableExtensions: Set<String> = [
        "variorum", "md", "markdown", "txt", "text",
    ]

    /// One file as the face read it.
    public struct File: Equatable, Sendable {
        /// Relative to the picked folder, "/"-separated ("ch 1/03 x.md").
        public var relativePath: String
        public var contents: String

        public init(relativePath: String, contents: String) {
            self.relativePath = relativePath
            self.contents = contents
        }
    }

    /// Whether a path names a file the door imports: an accepted extension,
    /// and no hidden component anywhere in it.
    public static func isImportable(_ relativePath: String) -> Bool {
        let components = relativePath.split(separator: "/").map(String.init)
        guard let name = components.last, !components.contains(where: { $0.hasPrefix(".") })
        else { return false }
        let ext = (name as NSString).pathExtension.lowercased()
        return importableExtensions.contains(ext)
    }

    /// The title a file gives a note whose header names none: its name
    /// without the extension.
    public static func fallbackTitle(forFileNamed name: String) -> String {
        let last = name.split(separator: "/").last.map(String.init) ?? name
        return precomposed((last as NSString).deletingPathExtension)
    }

    /// **A NAME TAKEN FROM A PATH IS STORED PRECOMPOSED (NFC).** macOS hands
    /// paths back decomposed ("a" + U+0303) where a typed name is precomposed
    /// ("ã"); Swift compares the two equal, SQLite compares bytes — so a book
    /// named by its folder would never match the name she types into a search
    /// or the duplicate-name guard's read. Found by the 13n-a door test (the
    /// receipt matched, the row did not). Only NAMES are normalized: a
    /// document's text is hers, byte for byte.
    static func precomposed(_ name: String) -> String {
        name.precomposedStringWithCanonicalMapping
    }

    /// One file read as a note (a single-file import).
    public static func note(
        named relativePath: String, contents: String
    ) throws(VariorumDocument.Failure) -> VariorumDocument.NamedDocument {
        do throws(VariorumDocument.Failure) {
            return VariorumDocument.NamedDocument(
                fallbackTitle: fallbackTitle(forFileNamed: relativePath),
                document: try VariorumDocument.parse(contents))
        } catch {
            var failure = error
            failure.file = relativePath
            throw failure
        }
    }

    /// The folder read as a book. `subfolders` are the folder-relative paths
    /// of its directories (only first-level ones matter — they are the
    /// chapters, empty or not).
    public static func plan(
        folderName: String, files: [File], subfolders: [String] = []
    ) throws(VariorumDocument.Failure) -> VariorumDocument.Book {
        var unfiled: [File] = []
        var chapterFiles: [String: [File]] = [:]
        for subfolder in subfolders {
            let components = subfolder.split(separator: "/").map(String.init)
            guard let first = components.first.map(precomposed), !first.hasPrefix(".")
            else { continue }
            if chapterFiles[first] == nil { chapterFiles[first] = [] }
        }
        for file in files where isImportable(file.relativePath) {
            let components = file.relativePath.split(separator: "/").map(String.init)
            if components.count == 1 {
                unfiled.append(file)
            } else {
                chapterFiles[precomposed(components[0]), default: []].append(file)
            }
        }
        guard !unfiled.isEmpty || chapterFiles.values.contains(where: { !$0.isEmpty }) else {
            throw VariorumDocument.Failure(.noImportableFiles, file: folderName)
        }

        let chapterNames = chapterFiles.keys.sorted(by: orderedBefore)
        var chapters: [VariorumDocument.Book.Chapter] = []
        for name in chapterNames {
            var notes: [VariorumDocument.NamedDocument] = []
            for file in (chapterFiles[name] ?? []).sorted(by: { pathOrderedBefore($0.relativePath, $1.relativePath) }) {
                notes.append(try note(named: file.relativePath, contents: file.contents))
            }
            chapters.append(.init(name: name, notes: notes))
        }
        var unfiledNotes: [VariorumDocument.NamedDocument] = []
        for file in unfiled.sorted(by: { pathOrderedBefore($0.relativePath, $1.relativePath) }) {
            unfiledNotes.append(try note(named: file.relativePath, contents: file.contents))
        }
        return VariorumDocument.Book(
            name: precomposed(folderName), chapters: chapters, unfiled: unfiledNotes)
    }

    // MARK: - Order (the Bookcase's a–z rule)

    /// Digit-aware, case-insensitive (Finder's rule); raw order breaks ties.
    static func orderedBefore(_ a: String, _ b: String) -> Bool {
        switch a.localizedStandardCompare(b) {
        case .orderedAscending: return true
        case .orderedDescending: return false
        case .orderedSame: return a < b
        }
    }

    /// Paths compare component by component, each by `orderedBefore`.
    static func pathOrderedBefore(_ a: String, _ b: String) -> Bool {
        let left = a.split(separator: "/").map(String.init)
        let right = b.split(separator: "/").map(String.init)
        for (x, y) in zip(left, right) where x != y {
            return orderedBefore(x, y)
        }
        return left.count < right.count
    }
}
