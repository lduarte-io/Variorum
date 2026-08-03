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
    // Stage 0 TK2 spike door (KEPT as the executable §5 form — the Stage 0
    // gate record's recorded deviation).
    @State private var spikePresented = SpikeLaunch.autoRunRequested || SpikeLaunch.uiTestBenchRequested
    // Mobile S1 batch 1: the DEBUG door to the new continuous Write
    // surface (today's entry), beside the spike's — the app shape is S3's;
    // this exists so the Stage 1 feel round can open the editor.
    @State private var writeS1PostID: WriteS1Door?
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Write S1") {
                        Task {
                            if let id = await model.openToday() {
                                writeS1PostID = WriteS1Door(postID: id)
                            }
                        }
                    }
                }
            }
            #endif
        }
        .task { await model.startJournal() }
        .task { await model.startAll() }
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        .sheet(item: $writeS1PostID) { door in
            NavigationStack {
                MobileWriteScreen(session: session, postID: door.postID)
                    .navigationTitle("Write (S1)")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Done") { writeS1PostID = nil }
                        }
                    }
            }
        }
        #endif
    }
}

#if DEBUG
private struct WriteS1Door: Identifiable {
    let postID: String
    var id: String { postID }
}
#endif
