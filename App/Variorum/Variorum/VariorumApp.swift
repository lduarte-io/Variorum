//
//  VariorumApp.swift
//  Variorum
//
//  Phase 7: root composition. The store is opened through the recoverable
//  path (AppBootstrap) BEFORE any view exists; a failed open renders
//  StoreFailureView instead of ever reaching the package's headless
//  fatalError. SwiftUI does all chrome; the editor core is AppKit.
//

import SwiftUI
import VariorumCore

@main
struct VariorumApp: App {
    @State private var bootstrap = AppBootstrap()

    var body: some Scene {
        WindowGroup {
            switch bootstrap.state {
            case .ready(let session):
                RootView(session: session)
            case .failed(let error):
                StoreFailureView(error: error) { bootstrap.retry() }
            }
        }
    }
}
