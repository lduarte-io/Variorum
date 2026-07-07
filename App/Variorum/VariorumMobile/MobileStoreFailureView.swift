//
//  MobileStoreFailureView.swift
//  VariorumMobile
//
//  The recovery surface for a failed store open — the iOS twin of the Mac's
//  StoreFailureView (no Finder/quit affordances here). Functional and
//  unstyled (Phase 13 owns beauty).
//

import SwiftUI
import VariorumCore

struct MobileStoreFailureView: View {
    let error: AppDatabase.StoreOpenError
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Variorum database could not be opened.")
                .font(.headline)
            if !error.storePath.isEmpty {
                Text("Store: \(error.storePath)")
                    .font(.caption)
                    .textSelection(.enabled)
            }
            Text(error.reason)
                .font(.callout)
                .textSelection(.enabled)
            Button("Retry") { retry() }
        }
        .padding(24)
    }
}
