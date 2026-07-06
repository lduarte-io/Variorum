//
//  StoreFailureView.swift
//  Variorum
//
//  The recovery surface for a failed store open (KnownIssues
//  "AppDatabase.liveValue failure UX"). Functional and unstyled (Phase 13
//  owns beauty): what failed, where the file lives, and three ways out.
//

import AppKit
import SwiftUI
import VariorumCore

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
