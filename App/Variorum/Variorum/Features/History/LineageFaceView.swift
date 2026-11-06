//
//  LineageFaceView.swift
//  Variorum (Mac)
//
//  **VX-801 (VX-827 U3b) — THE LINEAGE FACE**, behind its doors ("lineage ›"
//  on the Commits face, Lineage in both block ▾ menus, and the origin door —
//  "See original from…" and ⌘K's twin — which opens it on the original). THE
//  DESIGN MEMO's geometry: the family as ONE vertical list, older above, this
//  block marked, no horizontal scroll anywhere; under it the selected
//  member's header (what happened · where it lives · counts · its acts); under
//  that the SAME pane+rail composition the Commits face draws
//  (`CommitsFaceBody`), over the selected block — her *"when you select an
//  ancestor block, you can still click on its various takes & commits
//  easily"*.
//
//  P3: every text is a `Text`; the face replaces the mode's surface (or rides
//  the hosts' sheet) exactly as the Commits face does — no editor beside it.
//

import SwiftUI
import VariorumCore

struct LineageFaceView: View {
    /// The acts this face renders inline (P-1's `.surface` doors): the
    /// member header's four, the pane+rail composition's own (a relative's
    /// moments bring back across lineage; this block's are the Commits face's),
    /// and "‹ history" back to the Commits face is the host's swap, not an act.
    static let surfaceCapabilities: [CapabilityID] = [
        .putBackLineageBlock, .bringBackLineageAsTake, .compareLineageWithNow, .goToLineageWing,
    ] + CommitsFaceBody.surfaceCapabilities

    /// The family list's most height before it scrolls on its own (B's rail
    /// rows, about seven).
    static let familyMaxHeight: CGFloat = 220
    static let rowHeight: CGFloat = 30

    let session: AppSession
    let onBack: () -> Void
    /// "‹ history" — the host swaps back to the Commits face.
    let onHistory: () -> Void
    @State private var model: LineageFaceModel
    @State private var crumbTitle: String?
    @State private var crumbBlock: String?
    @FocusState private var keysHeld: Bool
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, request: BlockHistoryRequest, select: String?,
        onBack: @escaping () -> Void, onHistory: @escaping () -> Void,
        model: LineageFaceModel? = nil
    ) {
        self.session = session
        self.onBack = onBack
        self.onHistory = onHistory
        _model = State(initialValue: model
            ?? LineageFaceModel(session: session, request: request, select: select))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            crumbRow
            // The newest word wins: the face's own acts clear the pane's line
            // before they speak, so a pane act's line is never masked by an
            // older header receipt.
            if let status = model.node?.status ?? model.status {
                CommitsFaceStatusLine(status: status, tokens: tokens)
            }
            familyList
            if model.hasNoLineage {
                Text(tokens.chromeLabel(LineageFaceCopy.noLineage))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let member = model.selected, member.direction != .origin {
                memberHeader(member)
            }
            if let node = model.node {
                CommitsFaceBody(model: node, session: session, tokens: tokens) { keysHeld = true }
                    .id(node.blockID)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.room)
        // The fast swapper's keys step the selected block's moments, as on the
        // Commits face (PROVISIONAL P-U3a-4).
        .focusable()
        .focusEffectDisabled()
        .focused($keysHeld)
        .onKeyPress(.upArrow) {
            guard let node = model.node, node.compareBoxes == nil else { return .ignored }
            node.step(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            guard let node = model.node, node.compareBoxes == nil else { return .ignored }
            node.step(by: 1)
            return .handled
        }
        .onAppear { keysHeld = true }
        .task { await model.start() }
        .task { await readCrumb() }
        #if DEBUG
        .onAppear { LineageFaceOracle.publish(model, owner: oracleOwner) }
        .onDisappear { LineageFaceOracle.release(owner: oracleOwner) }
        #endif
    }

    #if DEBUG
    @State private var oracleOwner = UUID()
    #endif

    private func readCrumb() async {
        let read = try? await CommitsFaceCrumb.read(
            session: session, postID: model.request.postID, blockID: model.request.blockID)
        crumbTitle = read?.title ?? nil
        crumbBlock = read?.block
    }

    // MARK: - The crumb row

    private var crumbRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Button(tokens.chromeLabel(CommitsFaceCopy.back), action: onBack)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(CommitsFaceCopy.backHelp)
            Text(tokens.chromeLabel(
                ([crumbTitle, crumbBlock].compactMap { $0 } + [LineageFaceCopy.crumb])
                    .joined(separator: " \u{203A} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 0)
            Button(tokens.chromeLabel(CommitsFaceCopy.backToHistory), action: onHistory)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(BlockHistoryPath.name)
        }
    }

    // MARK: - The family

    private var familyList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.chromeLabel(LineageFaceCopy.family))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .padding(.horizontal, 6)
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(model.members.enumerated()), id: \.element.id) { index, member in
                        familyRow(member)
                            // A new generation starts a new band (B's gaps).
                            .padding(.top, index > 0
                                && model.members[index - 1].generation != member.generation ? 7 : 0)
                    }
                }
                .padding(.bottom, 2)
            }
            .frame(maxHeight: min(
                Self.familyMaxHeight,
                CGFloat(max(model.members.count, 1)) * (Self.rowHeight + 2) + 24))
        }
        .padding(8)
        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tokens.line, lineWidth: 1))
    }

    private func familyRow(_ member: LineageFamily.Member) -> some View {
        let selected = member.blockID == model.selectedBlockID
        let isThis = member.direction == .origin
        return HStack(spacing: 8) {
            familyDot(member, selected: selected)
                .frame(width: 20)
            Text(tokens.chromeLabel(model.verb(member)))
                .font(tokens.small)
                .foregroundStyle(isThis ? tokens.chosen : tokens.muted)
                .lineLimit(1)
                .frame(width: 78, alignment: .leading)
            if let text = member.text, !isThis {
                Text(CommitRowFace.restingPreview(text))
                    .font(tokens.small)
                    .foregroundStyle(member.isMuted ? tokens.faint : tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 6)
            Text(tokens.chromeLabel(model.place(member)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
                .layoutPriority(1)
            if let counts = member.counts, !member.isMuted {
                Text(tokens.chromeLabel(LineageFaceCopy.counts(counts)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
            }
            ForEach(member.acts, id: \.self) { act in
                if case .goToWing(let wingID) = act {
                    Button(tokens.chromeLabel(WingCopy.goTo(model.wingName(wingID)))) {
                        model.goToWing(wingID)
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .lineLimit(1)
                    .fixedSize()
                }
            }
        }
        .frame(minHeight: Self.rowHeight)
        .padding(.trailing, 8)
        .background(selected ? tokens.wash : Color.clear, in: RoundedRectangle(cornerRadius: 7))
        .opacity(member.isMuted ? 0.6 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            model.select(member.blockID)
            keysHeld = true
        }
        .help(member.isMuted
            ? LineageFaceCopy.trashHelp
            : (member.selectable ? LineageFaceCopy.selectHelp : model.place(member)))
    }

    private func familyDot(_ member: LineageFamily.Member, selected: Bool) -> some View {
        Group {
            if member.direction == .origin {
                Circle()
                    .strokeBorder(selected ? tokens.ink : tokens.chosen, lineWidth: 2)
                    .background(Circle().fill(tokens.surface))
                    .frame(width: 10, height: 10)
            } else if selected {
                Circle().fill(tokens.ink).frame(width: 10, height: 10)
                    .overlay(Circle().stroke(tokens.ring, lineWidth: 1.5).padding(-3))
            } else if member.isMuted || !member.selectable {
                Circle()
                    .strokeBorder(tokens.faint, lineWidth: 1.5)
                    .background(Circle().fill(tokens.surface))
                    .frame(width: 8, height: 8)
            } else {
                Circle().fill(tokens.faint).frame(width: 9, height: 9)
            }
        }
    }

    // MARK: - The selected member's header

    private func memberHeader(_ member: LineageFamily.Member) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(tokens.chromeLabel(model.verb(member)))
                .font(tokens.navigation.weight(.medium))
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(tokens.chromeLabel(
                ([model.place(member)] + (member.counts.map { [LineageFaceCopy.counts($0)] } ?? []))
                    .joined(separator: " \u{B7} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 8)
            ForEach(member.acts, id: \.self) { act in
                switch act {
                case .putBack:
                    Button(tokens.chromeLabel(BlockPastCopy.putBackVerb)) {
                        Task { await model.putBack() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(LineageFaceCopy.putBackHelp)
                case .bringBackAsTake:
                    Button(tokens.chromeLabel(BlockHistoryPath.bringBackAsTakeVerb)) {
                        Task { await model.bringBack() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(LineageFaceCopy.bringBackHelp)
                case .compareWithNow:
                    Button(tokens.chromeLabel(LineageFaceCopy.compareWithNow)) {
                        model.compareWithNow()
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(LineageFaceCopy.compareWithNowHelp)
                case .goToWing:
                    EmptyView()  // another wing's member is never selected
                }
            }
        }
        .padding(.horizontal, 6)
    }
}

/// **THE BLOCK'S HISTORY & LINEAGE SURFACE — its one host** (VX-827 U3b).
/// Every host that shows the surface (the note's full pane, the bars' and the
/// take panel's sheets) composes THIS, and the request says which face it
/// opens on; "lineage ›" and "‹ history" swap the two faces in place.
struct BlockHistorySurface: View {
    let session: AppSession
    let request: BlockHistoryRequest
    let onBack: () -> Void
    @State private var opening: HistoryOpening

    init(session: AppSession, request: BlockHistoryRequest, onBack: @escaping () -> Void) {
        self.session = session
        self.request = request
        self.onBack = onBack
        _opening = State(initialValue: request.opening)
    }

    var body: some View {
        switch opening {
        case .commits:
            CommitsFaceView(
                session: session, request: request, onBack: onBack,
                onLineage: { opening = .lineage(select: nil) })
        case .lineage(let select):
            LineageFaceView(
                session: session, request: request, select: select, onBack: onBack,
                onHistory: { opening = .commits })
        }
    }
}

#if DEBUG
/// **The Lineage face's pin door** (the VX-668 shape, `CommitsFaceOracle`'s
/// twin): the mounted face publishes its model, keyed by its note,
/// owner-stamped. Read by pins only; decides nothing.
@MainActor
enum LineageFaceOracle {
    private static var models = OwnedRegistrations<String, LineageFaceModel>()

    static func model(forPost postID: String) -> LineageFaceModel? { models[postID] }

    static func publish(_ model: LineageFaceModel, owner: UUID) {
        models.publish(model, for: model.request.postID, owner: owner)
    }

    static func release(owner: UUID) { models.release(owner: owner) }
}
#endif
