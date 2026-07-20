//
//  ModesTutorialView.swift
//  Variorum
//
//  Phase 11, Step A10 — the modes tutorial (the author's instruction,
//  spike round 6, 2026-07-13): an in-app walkthrough of the THREE MODES —
//  POLISH IN PLACE / THREAD ONE PIECE / FORK THE PIECE — styled like the
//  spike's mockup pages (captioned sections, LIVE examples per mode) over
//  a SEEDED demo post. Seeding never touches the user's real posts — a
//  dedicated, clearly-labeled, deletable demo post; every example drives
//  REAL operations on the demo only. Functional at 11a; the pretty pass is
//  Phase 13's. The governing vocabulary, hers: "a lens is the same
//  structure with different choices; a version is a different structure;
//  promote is the bridge."
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class ModesTutorialModel {
    @ObservationIgnored let session: AppSession
    @ObservationIgnored private let defaults: UserDefaults

    /// The demo's stable marker (a LOCAL bookmark, not schema): the demo
    /// post's id lives in defaults; seeding validates it still exists live
    /// and re-seeds only when it doesn't — idempotent by construction.
    nonisolated static let demoDefaultsKey = "modesTutorialDemoPostID"
    nonisolated static let forkedCopiesKey = "modesTutorialForkedCopyIDs"
    nonisolated static let demoTitle = "Variorum modes tutorial (demo — safe to delete)"

    init(session: AppSession, defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
    }

    private(set) var demoPostID: String?
    private(set) var projection = Queries.TakesProjection()
    private(set) var statusMessage: String?
    @ObservationIgnored private var observation: Task<Void, Never>?

    nonisolated struct DemoShape: Equatable, Sendable {
        var polishBlockID: String
        var threadBlockID: String
        var forkBlockID: String
    }
    private(set) var shape: DemoShape?

    // MARK: - Seeding (idempotent, isolated)

    /// Finds the existing live demo or seeds a fresh one. NEVER touches any
    /// other row (pinned): the only writes are the demo's own mints.
    func ensureDemo() async {
        if let existing = defaults.string(forKey: Self.demoDefaultsKey) {
            let alive = try? await session.database.read { db in
                try Queries.containerIsLive(db, id: existing, includingArchived: false)
            }
            if alive == true {
                demoPostID = existing
                await loadShape(postID: existing)
                startObservation(postID: existing)
                return
            }
        }
        do {
            let postID: String = try await session.runner.run { ops in
                let post = try ops.createPost(title: Self.demoTitle, profile: .generic)
                _ = try ops.newBlock(
                    in: post.id,
                    text: "Polish in place: just write. Every keystroke autosaves; "
                        + "⌘S keeps a savepoint. No machinery appears until you ask for it.",
                    at: .end)
                let thread = try ops.newBlock(
                    in: post.id,
                    text: "Thread one piece: this paragraph has a second take — "
                        + "open its fan (⑂) and try both.",
                    at: .end)
                let take = try ops.branchVariant(thread.block.id, from: thread.variant.id)
                try ops.autosave(
                    take.id,
                    text: "Thread one piece, the bolder cut: same paragraph, different "
                        + "choice — a LENS remembers a whole set of choices like this.",
                    charDelta: 40)
                let lens = try ops.createLens(post: post.id, name: "tutorial thread")
                _ = try ops.setLensChoice(lens: lens.id, block: thread.block.id, variant: take.id)
                _ = try ops.newBlock(
                    in: post.id,
                    text: "Fork the piece: when the STRUCTURE should differ — not just "
                        + "the choices — duplicate this post as a version. A lens is the "
                        + "same structure with different choices; a version is a "
                        + "different structure; promote is the bridge.",
                    at: .end)
                return post.id
            }
            defaults.set(postID, forKey: Self.demoDefaultsKey)
            demoPostID = postID
            await loadShape(postID: postID)
            startObservation(postID: postID)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    private func loadShape(postID: String) async {
        let slots = (try? await session.database.read { db in
            try Queries.renderPost(db, containerID: postID)
        }) ?? []
        guard slots.count >= 3 else { return }
        shape = DemoShape(
            polishBlockID: slots[0].blockID,
            threadBlockID: slots[1].blockID,
            forkBlockID: slots[2].blockID)
    }

    private func startObservation(postID: String) {
        observation?.cancel()
        observation = Task { [session] in
            do {
                for try await value in session.database.observeTakes(postID) {
                    self.projection = value
                }
            } catch is CancellationError {
            } catch {
                self.statusMessage = String(describing: error)
            }
        }
    }

    func teardown() {
        observation?.cancel()
    }

    // MARK: - The live examples (REAL ops, demo post only)

    func choose(blockID: String, variantID: String) async {
        await run { ops in try ops.chooseVariant(blockID, variantID: variantID) }
    }

    func divergeHere(blockID: String, fromVariantID: String) async {
        await run { ops in _ = try ops.branchVariant(blockID, from: fromVariantID) }
    }

    func adoptTutorialLens() async {
        guard let lens = projection.lenses.first else { return }
        await run { ops in try ops.adoptLens(lens.id) }
    }

    /// The fork example: a REAL `duplicateAsVersion` of the demo — the copy
    /// is tracked so Reset can clean it up too.
    func forkDemo() async {
        guard let demoPostID else { return }
        do {
            let copy = try await session.runner.run { ops in
                try ops.duplicateAsVersion(demoPostID)
            }
            var copies = defaults.stringArray(forKey: Self.forkedCopiesKey) ?? []
            copies.append(copy.post.id)
            defaults.set(copies, forKey: Self.forkedCopiesKey)
            statusMessage = "Forked — the version copy sits in your library beside the demo."
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// Reset: delete the demo (its blocks/takes/lenses cascade — no
    /// orphans) plus any tracked forked copies, then re-seed fresh.
    func resetDemo() async {
        let doomed = [defaults.string(forKey: Self.demoDefaultsKey)].compactMap { $0 }
            + (defaults.stringArray(forKey: Self.forkedCopiesKey) ?? [])
        let alive: [String] = (try? await session.database.read { db in
            try doomed.filter { try Queries.containerIsLive(db, id: $0) }
        }) ?? []
        do {
            try await session.runner.run { ops in
                for id in alive {
                    try ops.deleteContainer(id)
                }
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
        defaults.removeObject(forKey: Self.demoDefaultsKey)
        defaults.removeObject(forKey: Self.forkedCopiesKey)
        demoPostID = nil
        shape = nil
        await ensureDemo()
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        statusMessage = nil
        do {
            try await session.runner.run(body)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }
}

struct ModesTutorialView: View {
    let session: AppSession
    /// Open the demo post in the ordinary detail (the tutorial teaches the
    /// REAL surfaces).
    var openPost: ((String) -> Void)?
    @State private var model: ModesTutorialModel

    init(session: AppSession, openPost: ((String) -> Void)? = nil, model: ModesTutorialModel? = nil) {
        self.session = session
        self.openPost = openPost
        _model = State(initialValue: model ?? ModesTutorialModel(session: session))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if let status = model.statusMessage {
                    Text(status).font(.caption).foregroundStyle(.secondary)
                }
                polishSection
                threadSection
                forkSection
            }
            .padding(20)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .task { await model.ensureDemo() }
        .onDisappear { model.teardown() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Three ways to work").font(.title2.weight(.semibold))
            Text("Everything below runs on a demo post — play freely; nothing "
                + "touches your writing. Reset any time.")
                .foregroundStyle(.secondary)
            HStack {
                if let id = model.demoPostID {
                    Button("Open the demo post") { openPost?(id) }
                }
                Button("Reset demo") { Task { await model.resetDemo() } }
            }
            .controlSize(.small)
        }
    }

    private var polishSection: some View {
        section(
            number: "1",
            title: "Polish in place",
            caption: "Most writing needs no machinery: type, autosave keeps up, "
                + "⌘S keeps a savepoint you can always return to. If your text "
                + "looks like basic text, it behaves like basic text.")
        {
            if let shape = model.shape,
               let slot = slot(shape.polishBlockID) {
                PaneSurfaceView(
                    text: slot.text ?? "", isLive: false,
                    role: "tutorial",
                    onFocusRequest: {
                        if let id = model.demoPostID { openPost?(id) }
                    })
            }
        }
    }

    private var threadSection: some View {
        section(
            number: "2",
            title: "Thread one piece",
            caption: "A paragraph you're unsure about can hold several TAKES at "
                + "once — the fan. ✓ chooses which one the post shows; a LENS "
                + "saves a whole set of choices (the same structure, different "
                + "choices) without touching the post.")
        {
            if let shape = model.shape, let slot = slot(shape.threadBlockID) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.projection.fans[shape.threadBlockID] ?? [], id: \.id) { take in
                        HStack(alignment: .top, spacing: 6) {
                            Button("✓") {
                                Task {
                                    await model.choose(
                                        blockID: shape.threadBlockID, variantID: take.id)
                                }
                            }
                            .controlSize(.mini)
                            .disabled(take.id == slot.variantID)
                            .help("Choose this take — the post shows it")
                            Text(take.workingText)
                                .font(.callout)
                                .foregroundStyle(take.id == slot.variantID ? .primary : .secondary)
                        }
                    }
                    HStack {
                        Button("Diverge here (mint another take)") {
                            if let from = slot.variantID {
                                Task {
                                    await model.divergeHere(
                                        blockID: shape.threadBlockID, fromVariantID: from)
                                }
                            }
                        }
                        if !model.projection.lenses.isEmpty {
                            Button("Adopt the “tutorial thread” lens (✓ everything)") {
                                Task { await model.adoptTutorialLens() }
                            }
                        }
                    }
                    .controlSize(.small)
                }
            }
        }
    }

    private var forkSection: some View {
        section(
            number: "3",
            title: "Fork the piece",
            caption: "When the STRUCTURE should differ — a rearranged argument, a "
                + "different opening — duplicate the post as a VERSION: a "
                + "different post, linked to this one, compared side by side in "
                + "the Compare mode. Promote turns a lens into a version — the "
                + "bridge between the two.")
        {
            if let shape = model.shape, let slot = slot(shape.forkBlockID) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(slot.text ?? "").font(.callout)
                    Button("Duplicate the demo as a version") {
                        Task { await model.forkDemo() }
                    }
                    .controlSize(.small)
                }
            }
        }
    }

    private func slot(_ blockID: String) -> Queries.RenderedBlock? {
        model.projection.slots.first { $0.blockID == blockID }
    }

    @ViewBuilder
    private func section(
        number: String, title: String, caption: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.headline)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(.quaternary))
                Text(title).font(.headline)
            }
            Text(caption).foregroundStyle(.secondary)
            content()
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.06)))
        }
    }
}
