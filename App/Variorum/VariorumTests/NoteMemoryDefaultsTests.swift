//
//  NoteMemoryDefaultsTests.swift
//  VariorumTests
//
//  **VX-926 U4 — the per-note memories' ONE defaults domain** (VX-97 · VX-666 · VX-695;
//  `notes/plans/fixes/vx-926-test-flakes.md`, "## U4 record"). The test host IS the dev app,
//  and every per-note view memory used to persist into its REAL domain
//  (`io.lduarte.Variorum.debug`) under fixture ids that repeat — 2,731 keys by 2026-10-28,
//  and VX-695's band test red machine-wide on them. `NoteMemoryDefaults` is the one seam:
//  the app's own domain in the app, a suite of the host's own, emptied at the ask, under a
//  test runner. What these hold:
//
//  - the RULE, on scratch domains only (`resolve` takes the app's domain and the hosted
//    suite's name as parameters precisely so no pin here touches a real one): the app's arm
//    hands back the app's domain untouched; the host's arm hands back a suite of its own,
//    emptied, and a write through it never reaches the app's;
//  - THIS process (a test runner's host) keeps them off the app's domain;
//  - every per-note memory's DEFAULT road reads and writes the seam, never
//    `UserDefaults.standard` (asserted by the real domain's ABSENCE of a random key — a read).
//
//  RED ON OLD by the named revert R-U4-H (the host's arm returns `appDomain()` — exactly the
//  pre-fix behaviour, every memory on `.standard`): the rule's pin reds on scratch domains;
//  the process pin reds on identity alone; the default-road pin reds and its `defer` removes
//  the random keys it wrote from BOTH domains, so even the revert leaves nothing behind.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VX-926 U4 — the per-note memories' one defaults domain (VX-97 · VX-666 · VX-695)", .serialized)
struct NoteMemoryDefaultsTests {
    /// Fixed scratch names (one plist each, emptied in and out — a per-run UUID name would add
    /// a file per run to the container's Preferences, the accumulation the record names).
    private static let scratchAppName = "io.lduarte.Variorum.vx926-u4-pins.app-domain"
    private static let scratchHostedName = "io.lduarte.Variorum.vx926-u4-pins.hosted"

    private func emptied(_ name: String) throws -> UserDefaults {
        let suite = try #require(UserDefaults(suiteName: name))
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func forget(_ names: String...) {
        for name in names { UserDefaults(suiteName: name)?.removePersistentDomain(forName: name) }
    }

    // MARK: - The rule (scratch domains only)

    /// **The app's arm is the app's domain, untouched** — the dev app's behaviour
    /// byte-unchanged: the very object it was handed, nothing emptied, the hosted suite never
    /// consulted.
    @Test func theAppKeepsItsMemoriesInItsOwnDomainUntouched() throws {
        let app = try emptied(Self.scratchAppName)
        let hosted = try emptied(Self.scratchHostedName)
        defer { forget(Self.scratchAppName, Self.scratchHostedName) }
        app.set("takes", forKey: "postMode.p1")
        hosted.set("kept", forKey: "postMode.p2")

        let store = NoteMemoryDefaults.resolve(
            .app, appDomain: app, hostedSuiteName: Self.scratchHostedName)

        #expect(store === app, "the app's arm hands back the app's own domain object")
        #expect(store.string(forKey: "postMode.p1") == "takes", "nothing in it was emptied")
        #expect(hosted.string(forKey: "postMode.p2") == "kept", "the hosted suite was never touched")
        #expect(NoteMemoryDefaults.resolve(.app) === UserDefaults.standard,
                "in the app the default IS UserDefaults.standard — the domain every memory always wrote")
    }

    /// **A test runner's host keeps them in a suite of its own, EMPTIED at the ask** — a run
    /// begins with no memory, never reads an earlier run's, and a write through it never
    /// reaches the app's domain. RED under R-U4-H (the arm returns the app's domain): the store
    /// IS the stand-in, and the write lands in it.
    @Test func aTestHostKeepsThemInASuiteOfItsOwnEmptiedAtTheAsk() throws {
        let app = try emptied(Self.scratchAppName)
        let hosted = try emptied(Self.scratchHostedName)
        defer { forget(Self.scratchAppName, Self.scratchHostedName) }
        hosted.set("an earlier run's", forKey: "currentBlock.p0")

        let store = NoteMemoryDefaults.resolve(
            .hostingTests, appDomain: app, hostedSuiteName: Self.scratchHostedName)
        store.set("takes", forKey: "postMode.p1")

        #expect(store !== app, "the host's arm is never the app's domain")
        #expect(app.object(forKey: "postMode.p1") == nil,
                "a write through the host's store never reaches the app's domain")
        let reread = try #require(UserDefaults(suiteName: Self.scratchHostedName))
        #expect(reread.object(forKey: "currentBlock.p0") == nil,
                "emptied at the ask: a run never reads another run's memory")
    }

    // MARK: - This process

    /// **This process is a test runner's host, and its per-note memories live off the app's
    /// domain.** RED under R-U4-H on identity alone (no write needed).
    @Test func thisHostKeepsItsPerNoteMemoriesOffTheAppsDomain() throws {
        #expect(AppBootstrap.Launch.thisProcess == .hostingTests,
                "premise: this process is a test runner's host (VX-604's decision)")
        #expect(NoteMemoryDefaults.store !== UserDefaults.standard,
                "the test host's per-note memories are never the dev app's domain")
        let key = "postMode.vx926-u4-\(UUID().uuidString)"
        defer {
            NoteMemoryDefaults.store.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)   // only a revert could have put it there
        }
        NoteMemoryDefaults.store.set("takes", forKey: key)
        let hosted = try #require(UserDefaults(suiteName: NoteMemoryDefaults.hostedTestsSuiteName))
        #expect(hosted.string(forKey: key) == "takes", "the store IS the hosted suite")
        #expect(UserDefaults.standard.object(forKey: key) == nil, "…and the dev app's domain never saw it")
    }

    // MARK: - Every per-note memory's DEFAULT road

    /// **Each home reads and writes the seam when no defaults are handed in** — the road every
    /// production caller takes. The real domain is checked by a READ of a random key's absence.
    /// (The Canvas's view memory — not injectable at all — and `PostDetailView`'s two bare
    /// writes are held by the source pin `NoteMemorySeamSourcePinTests` in the core target and
    /// by the migrated mounted suites: CanvasBankTests' planted bank memory, TourTests' mode
    /// memory read back after the flow.)
    @Test func everyPerNoteMemoryTakesTheSeamByDefault() throws {
        let id = "vx926-u4-\(UUID().uuidString)"
        let keys = [
            CurrentBlockMemory.key(id),
            SurfaceSizeMemory.key(.outline, id), SurfaceSizeMemory.key(.flow, id),
            "postMode.\(id)", ReadModeView.faceKey(id),
            TakesViewMemory.defaultsKeyPrefix + id, TakesBoardLayout.slotHeightsKeyPrefix + id,
            "bookIndex.grouping.\(id)",
        ]
        let store = NoteMemoryDefaults.store
        defer {
            for key in keys {
                store.removeObject(forKey: key)
                UserDefaults.standard.removeObject(forKey: key)   // only a revert could have put it there
            }
        }
        func onTheSeamOnly(_ key: String, _ what: String) {
            #expect(store.object(forKey: key) != nil, "\(what): written to the seam")
            #expect(UserDefaults.standard.object(forKey: key) == nil, "\(what): never the dev app's domain")
        }

        // The current block (VX-666's family).
        var blocks = CurrentBlockMemory()
        blocks.remember(FocusedBlock(postID: id, blockID: "b1", variantID: "v1", utf16Offset: 3))
        onTheSeamOnly(CurrentBlockMemory.key(id), "currentBlock")
        #expect(CurrentBlockMemory().current(for: id)?.utf16Offset == 3, "a fresh memory reads it back")
        blocks.forget(postID: id)
        #expect(store.object(forKey: CurrentBlockMemory.key(id)) == nil, "…and forgets it there")

        // The surface sizes (VX-97's store) — both key spaces, and the eviction door.
        for namespace in SurfaceSizeMemory.Namespace.allCases {
            let memory = SurfaceSizeMemory(namespace, fingerprint: { "t" })
            memory.remember(id, CGSize(width: 600, height: 900))
            memory.persist(id)
            onTheSeamOnly(SurfaceSizeMemory.key(namespace, id), "surfaceSize.\(namespace.rawValue)")
            #expect(SurfaceSizeMemory(namespace, fingerprint: { "t" }).size(id)
                    == CGSize(width: 600, height: 900), "a fresh memory reads it back")
        }
        SurfaceSizeMemory.forgetPersisted(id)
        #expect(store.object(forKey: SurfaceSizeMemory.key(.outline, id)) == nil
                && store.object(forKey: SurfaceSizeMemory.key(.flow, id)) == nil,
                "the eviction door forgets both on the seam")

        // The mode (VX-666's) — the read road, and the one RootView hands the read tier.
        store.set(PostMode.takes.rawValue, forKey: "postMode.\(id)")
        #expect(PostDetailView.rememberedMode(postID: id) == .takes, "the mode memory reads the seam")
        #expect(ReadTakesView.holdsTakes(postID: id, defaults: NoteMemoryDefaults.store),
                "…and so does the pane's takes-first question, as RootView asks it")
        #expect(UserDefaults.standard.object(forKey: "postMode.\(id)") == nil)

        // Read's face.
        ReadModeView.remember(.read, postID: id)
        onTheSeamOnly(ReadModeView.faceKey(id), "readFace")
        #expect(ReadModeView.rememberedFace(postID: id) == .read)

        // The Takes board's view memory and slot heights.
        TakesViewMemory(columns: [TakesColumn(kind: .main)], alignmentLocked: false).save(postID: id)
        onTheSeamOnly(TakesViewMemory.defaultsKeyPrefix + id, "takesViewMemory")
        #expect(TakesViewMemory.load(postID: id)?.alignmentLocked == false)
        store.set(["b1": 120.0], forKey: TakesBoardLayout.slotHeightsKeyPrefix + id)
        #expect(TakesBoardLayout(postID: id).slotHeight("b1") == 120, "the slot heights read the seam")

        // The book Index's grouping (per book — the same class).
        BookIndexGroupingPrefs(defaults: store).setChoice(.chapters, for: id)
        #expect(BookIndexGroupingModel(readingID: id).choice == .chapters,
                "the grouping memory reads the seam")
        #expect(UserDefaults.standard.object(forKey: "bookIndex.grouping.\(id)") == nil)
    }
}
