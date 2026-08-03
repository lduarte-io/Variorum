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
/// the LK2 switch door, status rows in the chrome register). Reached via
/// the DEBUG door in batch 1; S3 gives it its real navigation home — and
/// the switch door's real Settings home is S3's too (PROVISIONAL
/// placement, recorded).
struct MobileWriteScreen: View {
    @State private var model: MobileEditorViewModel
    @State private var voice: ThemeVoice
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, postID: String) {
        _model = State(initialValue: MobileEditorViewModel(session: session, postID: postID))
        // The stored phone voice governs from the first materialization —
        // set BEFORE the surface exists (makeUIView runs later).
        let stored = MobileVoicePreference.current()
        MobileEditorStyle.voice = stored
        _voice = State(initialValue: stored)
    }

    /// The SwiftUI chrome's tokens — dark rides the system scheme (R51's
    /// black rooms come from the token layer's own dark values).
    private var tokens: VoiceTokens {
        .resolve(voice: voice, dark: scheme == .dark)
    }

    var body: some View {
        MobileWriteView(model: model)
            .ignoresSafeArea(.keyboard) // the container's keyboardLayoutGuide owns avoidance
            .background(tokens.room.ignoresSafeArea())
            .safeAreaInset(edge: .top) { masthead }
            .task { await model.start() }
            .onDisappear {
                let model = model
                Task { await model.finish() }
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
                voiceSwitch
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

    /// LK2's minimal switch door: the current voice's name in the chrome
    /// register; tapping flips voice, preference, and the open surface.
    private var voiceSwitch: some View {
        Button {
            let next: ThemeVoice = voice == .terminal ? .study : .terminal
            voice = next
            MobileVoicePreference.set(next)
            MobileEditorStyle.voice = next
            model.applyVoiceChange()
        } label: {
            Text(tokens.chromeLabel(voice == .terminal ? "Terminal" : "Study"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Voice")
        .accessibilityHint("Switches between the terminal and study voices")
    }
}
