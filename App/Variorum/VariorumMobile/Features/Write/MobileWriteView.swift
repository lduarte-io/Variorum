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

/// The Write screen: the surface + the one status voice. Reached via the
/// DEBUG door in batch 1; S3 gives it its real navigation home.
struct MobileWriteScreen: View {
    @State private var model: MobileEditorViewModel

    init(session: AppSession, postID: String) {
        _model = State(initialValue: MobileEditorViewModel(session: session, postID: postID))
    }

    var body: some View {
        MobileWriteView(model: model)
            .ignoresSafeArea(.keyboard) // the container's keyboardLayoutGuide owns avoidance
            .safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let canary = model.canaryMessage {
                        Text(canary).font(.caption).foregroundStyle(.red)
                    }
                    if model.isSealed {
                        Text("This note is locked — reading only.")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    if let status = model.statusMessage {
                        Text(status).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .task { await model.start() }
            .onDisappear {
                let model = model
                Task { await model.finish() }
            }
    }
}
