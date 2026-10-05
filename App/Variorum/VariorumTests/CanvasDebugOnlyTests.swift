//
//  CanvasDebugOnlyTests.swift
//  VariorumTests
//
//  17y B2 — item (p): CANVAS GOES DEBUG-ONLY (her word at the 2026-10-04
//  evening sitting: "let's just do that now, in this run of things",
//  debug-only ratified; her explicit ok on ⌘7 no longer being Canvas).
//
//  THE ONE PLACE: `PostMode.allCases` IS the order every renderer reads (the
//  note mode row, ⌘1–⌘n in EditorCommands, the sidebar rail, the masthead
//  menu — "one order, three renderers"), so the gate lives there and nowhere
//  else: `PostMode.buildKeepsCanvas` (the compile condition, read by nothing
//  but the seam) and the pure `PostMode.order(keepingCanvas:)` that
//  `allCases` returns. Every OTHER Canvas door reads the same seam: the
//  stored-mode decode (a note left in Canvas reopens in the default), the
//  hand-written ⌘-span words (the registry's Switch Mode verb + label, the
//  helper's row, the masthead menu's help), the helper's "canvas"
//  dictionary entry, and the Snippets area's Scraps | Canvas picker.
//
//  The test target builds DEBUG only (CLAUDE.md: never a second
//  configuration), so the RELEASE flavour is pinned through the pure seam —
//  never by adding a Release test configuration (the brief's rule).
//  Red-on-old, stated: the pre-fix tree had no flavour — Canvas in every
//  build. The seam was first added answering exactly that (Canvas kept
//  whatever the flag), and every Release-flavour assertion below ran RED
//  against it (the B2 RECORD's piece 7).
//

import Testing
@testable import Variorum

@MainActor
@Suite("17y (p) — Canvas is DEBUG-only, gated in the one mode-order derivation")
struct CanvasDebugOnlyTests {
    @Test func releaseLosesCanvasAndTheKeysShorten() {
        #expect(PostMode.order(keepingCanvas: false)
                == [.write, .takes, .read, .lenses, .compare, .blocks],
                "RELEASE: six modes — ⌘7 is no longer Canvas (her explicit ok)")
        #expect(PostMode.order(keepingCanvas: true)
                == [.write, .takes, .read, .lenses, .compare, .blocks, .canvas],
                "DEBUG keeps her tinkering surface, last as ever")
        #expect(PostMode.keyLabel(keepingCanvas: false) == "\u{2318}1\u{2013}6")
        #expect(PostMode.keyLabel(keepingCanvas: true) == "\u{2318}1\u{2013}7")
        #expect(PostMode.keySpan(keepingCanvas: false) == "\u{2318}1\u{2013}\u{2318}6")
        #expect(!PostMode.modeList(keepingCanvas: false).contains("Canvas"))
        #expect(PostMode.modeList(keepingCanvas: true).hasSuffix("Blocks \u{00B7} Canvas"))
    }

    /// The compile condition, and the ONE derivation reading it.
    @Test func allCasesIsTheBuildsOrder() {
        #if DEBUG
        #expect(PostMode.buildKeepsCanvas, "a Debug build keeps Canvas")
        #else
        #expect(!PostMode.buildKeepsCanvas, "a Release build drops Canvas")
        #endif
        #expect(PostMode.allCases == PostMode.order(keepingCanvas: PostMode.buildKeepsCanvas))
    }

    /// **No case can silently vanish from the row (the B2 ladder's NIT-5).**
    /// Overriding `allCases` (the one Release-gated derivation) gave up the
    /// compiler's synthesized list: a future case left out of `declaredOrder`
    /// would simply never render — no mode row, no ⌘ key, no rail entry. So
    /// every case is reached here WITHOUT `allCases`, through the exhaustive
    /// `ring(after:)` below, and each must sit in Debug's full row.
    @Test func everyCaseSitsInTheDebugRow() {
        var reached: [PostMode] = []
        var mode = PostMode.write
        repeat {
            reached.append(mode)
            mode = Self.ring(after: mode)
        } while mode != .write && reached.count <= 64
        #expect(mode == .write, "the ring closes back on Write")
        #expect(Set(reached).count == reached.count, "the ring names each case once")
        let row = PostMode.order(keepingCanvas: true)
        for mode in reached {
            #expect(row.contains(mode),
                    "\(mode.rawValue) is a PostMode case missing from `declaredOrder` — it would never render")
        }
        #expect(row.count == reached.count && Set(row) == Set(reached),
                "Debug's full row is every case, each once")
    }

    /// Every `PostMode` case's successor on ONE ring — EXHAUSTIVE by
    /// construction: adding a case fails to compile here until it has an arm,
    /// and that arm must JOIN the ring (the arm before it names it, it names
    /// the next) so `everyCaseSitsInTheDebugRow` reaches it. Never `default:`.
    private static func ring(after mode: PostMode) -> PostMode {
        switch mode {
        case .write: .takes
        case .takes: .read
        case .read: .lenses
        case .lenses: .compare
        case .compare: .blocks
        case .blocks: .canvas
        case .canvas: .write
        }
    }

    /// A note she left in Canvas (her real store ran Canvas in Release
    /// before this) reopens in the default mode there — never a mode the
    /// build cannot render.
    @Test func aStoredCanvasDecodesToTheDefaultInRelease() {
        #expect(PostMode.fromStored("Canvas", keepingCanvas: false) == nil,
                "Release: no stranded mode — the caller's default (Write) owns it")
        #expect(PostMode.fromStored("Canvas", keepingCanvas: true) == .canvas)
        #expect(PostMode.fromStored("Index", keepingCanvas: false) == .read,
                "the retired-tab successors still decode in both flavours")
        #expect(PostMode.fromStored("Outline", keepingCanvas: false) == .compare)
    }

    /// The Snippets area's second face is a Canvas door too ("Canvas = a
    /// VIEW on a post or the scraps area" — AppSpec §12): gone in Release,
    /// and its now one-option picker with it (P-2).
    @Test func theSnippetsAreaLosesItsCanvasFaceInRelease() {
        #expect(PoolDetailView.Mode.faces(keepingCanvas: false) == [.scraps])
        #expect(PoolDetailView.Mode.faces(keepingCanvas: true) == [.scraps, .canvas])
        #expect(PoolDetailView.Mode.allCases
                == PoolDetailView.Mode.faces(keepingCanvas: PostMode.buildKeepsCanvas))
    }

    /// The hand-written words ride the SAME seam in this build: the
    /// registry's verb and label and the helper's row name the build's span.
    @Test func theWordsNameTheBuildsSpan() {
        let capability = CapabilityRegistry.capability(.switchMode)
        #expect(capability.shortcutLabel == PostMode.keyLabel(keepingCanvas: PostMode.buildKeepsCanvas))
        #expect(capability.verb.contains(PostMode.keySpan(keepingCanvas: PostMode.buildKeepsCanvas)))
        let row = HelperView.groups.flatMap(\.items).first { $0.does.hasPrefix("note modes") }
        #expect(row?.keys == PostMode.keyLabel(keepingCanvas: PostMode.buildKeepsCanvas))
        #expect(row?.does == "note modes: "
                + PostMode.modeList(keepingCanvas: PostMode.buildKeepsCanvas))
        #expect(HelperView.entries.contains { $0.term == "canvas" } == PostMode.buildKeepsCanvas,
                "the dictionary teaches Canvas only where the build has it")
    }
}
