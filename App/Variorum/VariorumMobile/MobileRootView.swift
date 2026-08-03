//
//  MobileRootView.swift
//  VariorumMobile
//
//  Root chrome: the entry list with the capture doors (Today, a chosen
//  date) and the one-row sync status. Functional and unstyled (Phase 13
//  owns beauty). Views render state and send actions only.
//

import SwiftUI
import VariorumCore

struct MobileRootView: View {
    let session: AppSession
    let services: AppServices?
    /// The app's background-flush registry (review round 2).
    let captureRouter: CaptureRouter
    @State private var model: EntryListViewModel
    @State private var path = NavigationPath()
    #if DEBUG
    // Stage 0 TK2 spike door (THROWAWAY — deleted at stage close).
    @State private var spikePresented = SpikeLaunch.autoRunRequested || SpikeLaunch.uiTestBenchRequested
    #endif

    init(session: AppSession, services: AppServices?, captureRouter: CaptureRouter) {
        self.session = session
        self.services = services
        self.captureRouter = captureRouter
        _model = State(initialValue: EntryListViewModel(session: session))
    }

    var body: some View {
        NavigationStack(path: $path) {
            EntryListView(model: model) { postID in
                path.append(postID)
            }
            .navigationTitle(model.scope == .journal ? "Journal" : "All notes")
            .navigationDestination(for: String.self) { postID in
                EntryEditorView(session: session, postID: postID, router: captureRouter)
            }
            .safeAreaInset(edge: .bottom) {
                if let services {
                    SyncStatusRow(services: services)
                }
            }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("TK2 Spike") { spikePresented = true }
                }
            }
            #endif
        }
        .task { await model.startJournal() }
        .task { await model.startAll() }
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        #endif
    }
}
