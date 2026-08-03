//
//  MobileWriteView.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 1: the SwiftUI face of the continuous Write
//  surface — a representable over `MobileWriteSurfaceView` (the
//  keyboard-avoiding container) wiring the UITextViewDelegate gate into
//  the view model. Functional and unstyled (the look track owns beauty).
//
//  The Phase 8 capture views are UNTOUCHED — they keep working until S3
//  replaces them; batch 1 reaches this surface through a DEBUG-gated door
//  beside the spike's (the Stage 0 precedent), so her feel round can open
//  it without the app shape existing yet.
//

import SwiftUI
import VariorumCore

struct MobileWriteView: UIViewRepresentable {
    let model: MobileEditorViewModel

    func makeUIView(context: Context) -> MobileWriteSurfaceView {
        let surface = MobileWriteSurfaceView()
        // The gate delegate is the VM's own since batch 2 (`attach` installs
        // it) — the SwiftUI face carries no police of its own, so every host
        // of the surface polices identically.
        model.attach(textView: surface.textView)
        return surface
    }

    func updateUIView(_ uiView: MobileWriteSurfaceView, context: Context) {}
}

/// The Write screen: the surface under a voiced masthead (batch 3 — the
/// look canon lands: the voice room, the title in the voice's title type,
/// status rows in the chrome register). Since S3 batch 1 this is THE
/// app's editor (the shell pushes it for every note; the S1 DEBUG door
/// retired): the shell router registers the active editor for the
/// app-level background flush, `beginEditing` raises the keyboard on
/// arrival (the Today door's straight-into-typing invitation), and the
/// masthead's voice-switch door RETIRED to Settings (P11's placement —
/// recorded; the shell router is the one voice authority, so an open
/// surface follows a Settings flip via `applyVoiceChange`).
struct MobileWriteScreen: View {
    @State private var model: MobileEditorViewModel
    /// The shell's voice authority; nil in harness/preview use, where the
    /// stored preference read at init governs.
    private let router: MobileShellRouter?
    private let beginEditing: Bool
    /// The OWNING tab stack (S3 ladder BLOCKER): liveness registration
    /// carries the stack's identity, passed by the shell's per-stack
    /// destination builder — never read from the visible-tab state.
    private let tab: MobileTab
    private let fallbackVoice: ThemeVoice
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String,
        router: MobileShellRouter? = nil, beginEditing: Bool = false,
        tab: MobileTab = .shelf
    ) {
        _model = State(initialValue: MobileEditorViewModel(session: session, postID: postID))
        self.router = router
        self.beginEditing = beginEditing
        self.tab = tab
        // The live phone voice governs from the first materialization —
        // set BEFORE the surface exists (makeUIView runs later). With a
        // router the value is already authoritative (idempotent).
        let stored = router?.voice ?? MobileVoicePreference.current()
        MobileEditorStyle.voice = stored
        fallbackVoice = stored
    }

    /// The SwiftUI chrome's tokens — dark rides the system scheme (R51's
    /// black rooms come from the token layer's own dark values). Reading
    /// `router.voice` keeps the masthead live under a Settings flip.
    private var tokens: VoiceTokens {
        .resolve(voice: router?.voice ?? fallbackVoice, dark: scheme == .dark)
    }

    var body: some View {
        MobileWriteView(model: model)
            .ignoresSafeArea(.keyboard) // the container's keyboardLayoutGuide owns avoidance
            .background(tokens.room.ignoresSafeArea())
            .safeAreaInset(edge: .top) { masthead }
            .task {
                // Wiring COMPLETES before the infinite observation loops
                // (S3 ladder, MAJOR 2 — `start()` never returns while the
                // editor lives, so nothing may be sequenced after it):
                // liveness registration first (the authority flushes any
                // same-post sibling's pending text), then the arrival
                // routine (authoritative first load + the Today door's
                // focus raise — a sealed note's gate still refuses and
                // speaks; raising focus never bypasses the police), then
                // the loops, last, forever.
                if let router {
                    await router.editors.register(model, tab: tab)
                }
                await model.arrive(focus: beginEditing)
                await model.start()
            }
            .onDisappear {
                let model = model
                router?.editors.deregister(model)
                Task { await model.teardown() }
            }
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(model.displayTitle ?? "")
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
            }
            if let canary = model.canaryMessage {
                Text(canary).font(tokens.small).foregroundStyle(.red)
            }
            if model.isSealed {
                Text("This note is locked — reading only.")
                    .font(tokens.small).foregroundStyle(tokens.muted)
            }
            if let status = model.statusMessage {
                Text(status).font(tokens.small).foregroundStyle(tokens.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom, 6)
        .background(tokens.room)
    }
}
