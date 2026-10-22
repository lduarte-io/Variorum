//
//  StoreFailureView.swift
//  Variorum
//
//  The recovery surface for a failed store open (KnownIssues
//  "AppDatabase.liveValue failure UX"). Functional and unstyled (Phase 13
//  owns beauty): what failed, where the file lives, and three ways out.
//  (VX-329 U1: the 13p sidecar-present unlock road beside it — today's key
//  file's wraps through today's lobby — left with today's road; the
//  protection road's own lobby is every unlock's one door.)
//

import AppKit
import SwiftUI
import VariorumCore

/// The first frame, while the store opens off the main thread (13l L-c).
///
/// **Deliberately silent.** The work behind it measured 54 ms at its worst,
/// and the app opens onto a calm ground regardless; a spinner would announce
/// a wait she does not have. What this view exists for is the honest
/// STRUCTURE — there is now a moment with no session, and it renders as
/// itself rather than as an empty window that looks broken.
struct StoreOpeningView: View {
    var body: some View {
        Color(nsColor: .textBackgroundColor).ignoresSafeArea()
    }
}

struct StoreFailureView: View {
    let error: AppDatabase.StoreOpenError
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Variorum database could not be opened.")
                .font(.headline)
            if !error.storePath.isEmpty {
                Text("Store: \(error.storePath)")
                    .textSelection(.enabled)
            }
            Text(error.reason)
                .textSelection(.enabled)
                .font(.callout)
            HStack {
                Button("Retry") { retry() }
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting(
                        [URL(fileURLWithPath: error.storePath)])
                }
                .disabled(error.storePath.isEmpty)
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(24)
        .frame(minWidth: 480)
    }
}
