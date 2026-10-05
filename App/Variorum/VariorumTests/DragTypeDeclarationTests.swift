//
//  DragTypeDeclarationTests.swift
//  VariorumTests
//
//  17y B2 — items (a)(b)(e): THE SHARED DRAG MECHANISM.
//
//  Every in-app drag the Bookcase and the Book Panel offer rides a
//  `Transferable` token whose `CodableRepresentation` names a CUSTOM
//  exported type (`UTType(exportedAs:)`). An exported type the bundle does
//  not DECLARE (Info.plist `UTExportedTypeDeclarations`) resolves with no
//  supertypes — it does not conform to `public.data` — and the system
//  faults at launch: *Type "io.lduarte.variorum.bookcase-item" was expected
//  to be declared and exported in the Info.plist of Variorum.app, but it was
//  not found.* The drag session STARTS (the row's image follows the
//  pointer) but no drop destination ever recognises the payload: no target
//  lights, nothing lands (driven on the pre-fix build — the B2 RECORD's
//  reproduction; 13i-d's F-U1-4 / F-U2-4 had recorded it as a synthetic-
//  harness artifact, and her real hand met it on the Bookcase and the Book
//  Panel). The Open strip's reorder token was the "proven road" both were
//  modelled on; it carried the same undeclared type and was never walked.
//
//  Red-on-old, stated: the pre-fix bundle has NO `UTExportedTypeDeclarations`
//  — all three tests fail (the scan finds three undeclared identifiers; the
//  named tokens find no declaration; their runtime types do not conform to
//  `public.data`).
//

import CoreTransferable
import Foundation
import Testing
import UniformTypeIdentifiers
@testable import Variorum

@Suite("17y (a)(b)(e) — every in-app drag type is a DECLARED data type")
struct DragTypeDeclarationTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The bundle's exported declarations, by identifier → its conformances.
    private static func declarations() -> [String: [String]] {
        let raw = Bundle.main.object(forInfoDictionaryKey: "UTExportedTypeDeclarations")
            as? [[String: Any]] ?? []
        var out: [String: [String]] = [:]
        for entry in raw {
            guard let id = entry["UTTypeIdentifier"] as? String else { continue }
            out[id] = entry["UTTypeConformsTo"] as? [String] ?? []
        }
        return out
    }

    /// The three drag tokens the app ships, by the types they actually export
    /// (read from the `Transferable` conformance — never a copied string).
    private static let tokens: [(name: String, types: [UTType])] = [
        ("BookcaseDragToken (the Bookcase — items (a)/(b))",
         BookcaseDragToken.exportedContentTypes()),
        ("BookPanelDragToken (the Book Panel — item (e))",
         BookPanelDragToken.exportedContentTypes()),
        ("OpenNoteDragToken (the Open strip's reorder — the same class)",
         SidebarView.OpenNoteDragToken.exportedContentTypes()),
    ]

    @Test func theAppsDragTokensExportDeclaredDataTypes() {
        let declared = Self.declarations()
        for token in Self.tokens {
            #expect(!token.types.isEmpty, "\(token.name) exports no type")
            for type in token.types {
                let conformances = declared[type.identifier]
                #expect(conformances != nil, """
                    \(token.name) exports \(type.identifier), which the bundle does not \
                    declare — an undeclared exported type is not a data type, so the drag \
                    starts and no drop site ever accepts it (17y (a)(b)(e)).
                    """)
                #expect(conformances?.contains(UTType.data.identifier) == true,
                        "\(type.identifier) must conform to public.data")
            }
        }
    }

    /// What the pasteboard needs at RUNTIME: the type the drag writes is a
    /// data type. On the pre-fix bundle this is false for all three.
    @Test func theRuntimeTypesConformToData() {
        for token in Self.tokens {
            for type in token.types {
                #expect(type.conforms(to: .data),
                        "\(token.name): \(type.identifier) resolves without public.data")
            }
        }
    }

    /// The class, not just today's three: ANY `UTType(exportedAs:)` in the
    /// Mac app's or the shared sources must be declared (a fourth drag token
    /// added later would otherwise ship dead exactly like these did).
    @Test func everyExportedIdentifierInTheSourcesIsDeclared() throws {
        let declared = Self.declarations()
        let pattern = try NSRegularExpression(pattern: #"UTType\(exportedAs:\s*"([^"]+)""#)
        var found: Set<String> = []
        for rootName in ["Variorum", "Shared"] {
            let root = Self.appRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            guard let walker = FileManager.default.enumerator(
                at: root, includingPropertiesForKeys: nil) else { continue }
            for case let file as URL in walker where file.pathExtension == "swift" {
                let source = try String(contentsOf: file, encoding: .utf8)
                let range = NSRange(source.startIndex..., in: source)
                for match in pattern.matches(in: source, range: range) {
                    if let r = Range(match.range(at: 1), in: source) { found.insert(String(source[r])) }
                }
            }
        }
        #expect(found.count >= 3, "the scan must reach the three shipped drag tokens (\(found))")
        let undeclared = found.filter { declared[$0] == nil }.sorted()
        #expect(undeclared.isEmpty, """
            Exported in code but not declared in the bundle (App/Variorum/VariorumInfo.plist \
            → UTExportedTypeDeclarations, conforming to public.data): \(undeclared)
            """)
    }
}
