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

/// The first frame, while the store opens off the main thread (13l L-c).
///
/// **Deliberately silent.** The work behind it measured 54 ms at its worst
/// and "almost imperceptible" on her device, so a spinner would announce a
/// wait she does not have; and the calm ground is what the app opens onto
/// anyway. What this view exists for is the honest STRUCTURE: there is now
/// a moment with no session, and it renders as itself rather than as an
/// empty shell that looks broken.
struct MobileStoreOpeningView: View {
    var body: some View {
        Color(.systemBackground).ignoresSafeArea()
    }
}

struct MobileStoreFailureView: View {
    let error: AppDatabase.StoreOpenError
    let retry: () -> Void

    var body: some View {
        ScrollView {
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
}
