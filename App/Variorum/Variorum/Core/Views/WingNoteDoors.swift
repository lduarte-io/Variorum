//
//  WingNoteDoors.swift
//  Variorum (MAC ONLY) — Core/Views (the Library's and the Pool's note rows,
//  the note ▾ menu's bars and ⌘K's destination selector render them)
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — THE NOTE'S CROSS-WING
//  DOORS' FACES, split out of `WingsModel.swift` when the wings' brain moved
//  to shared code (`Shared/WingsModel.swift`). Moved here byte for byte: the
//  row doors (`WingNoteDoors` — Move to Wing ▸ · Copy to Wing ▸, menus whose
//  verbs are the Mac's capability registry's), the move's confirm
//  (`wingMoveConfirm` — the alert over `WingsModel.MoveAsk`), and the note ▾
//  menu bar's half (`noteMenuWingDoors` — the bar that loads the open note's
//  context and hosts the confirm). Each is a Mac face, so each stays the
//  Mac's; what they read and call — the acts, the destinations, the wing-act
//  signal and the open note's context (`NoteMenuWingContext`) — is the shared
//  brain's.
//

import Foundation
import SwiftUI
import VariorumCore

// MARK: - The note-row doors (Move to Wing ▸ · Copy to Wing ▸) and the move's confirm

/// The two cross-wing doors on a note's row — ONE builder the Library's and
/// the Pool's row menus render (`SidebarView.contextMenuCapabilities`
/// declares them for the note-row grammar). Drawn only while another wing
/// exists (P-2). The row's note lives in the CURRENT wing (both surfaces list
/// the current wing's notes), so its destinations are every other wing.
struct WingNoteDoors: View {
    let wings: WingsModel
    let postID: String
    let title: String
    /// The wing the note LIVES in (13i-d U6 (k)): nil = the current wing —
    /// the Library's and the Pool's rows list only the current wing's notes;
    /// the note ▾ menu passes the open note's own wing, because an open note
    /// can be another wing's (the Open strip keeps it — F-U5-6).
    var fromWing: String? = nil
    /// The move's confirm, when the note leaves books (the caller presents it).
    let onAsk: (WingsModel.MoveAsk) -> Void
    /// After an act (the one-shot listings re-ask; held ones need nothing).
    var onDone: () -> Void = {}

    var body: some View {
        let others = wings.destinations(from: fromWing ?? wings.currentID)
        if !others.isEmpty {
            Menu(CapabilityRegistry.capability(.moveNoteToWing).verb) {
                ForEach(others) { row in
                    Button(row.name) {
                        Task {
                            if let ask = await wings.moveAsk(
                                postID: postID, title: title, to: row.id) {
                                onAsk(ask)
                            } else {
                                onDone()
                            }
                        }
                    }
                }
            }
            Menu(CapabilityRegistry.capability(.copyNoteToWing).verb) {
                ForEach(others) { row in
                    Button(row.name) {
                        Task {
                            await wings.copy(postID: postID, title: title, to: row.id)
                            onDone()
                        }
                    }
                }
            }
        }
    }
}

extension View {
    /// The move's confirm — LISTS the books the note leaves (a book never
    /// spans wings), the one question a cross-wing move asks.
    func wingMoveConfirm(
        _ pending: Binding<WingsModel.MoveAsk?>, wings: WingsModel?,
        onDone: @escaping () -> Void = {}
    ) -> some View {
        alert(
            pending.wrappedValue.map { WingCopy.moveTitle($0.title, to: $0.wingName) } ?? "",
            isPresented: Binding(
                get: { pending.wrappedValue != nil },
                set: { if !$0 { pending.wrappedValue = nil } }),
            presenting: pending.wrappedValue
        ) { ask in
            Button("Move") {
                Task {
                    await wings?.move(postID: ask.postID, title: ask.title, to: ask.wingID)
                    onDone()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { ask in
            Text(WingCopy.moveMessage(leaves: ask.leaves))
        }
    }
}

// MARK: - The note ▾ menu's bar (13i-d U6 (k)) — the context it loads is the
// shared brain's (`NoteMenuWingContext`, `Shared/WingsModel.swift`)

extension View {
    /// The bar's half of the note ▾ wing doors: loads the open note's context
    /// (per note) and hosts the move's confirm — an alert cannot hang off a
    /// menu item, so the bar presents it (the Library row's own shape).
    /// The structured `.task` write is cancellation-guarded (fix B); the
    /// UNSTRUCTURED reloads are subject-guarded instead (`reloadAdopts` —
    /// the sanity pass's NIT: cancellation never reaches them), so either
    /// way a stale load never stomps the next note's context.
    func noteMenuWingDoors(
        session: AppSession, postID: String, wings: WingsModel?,
        context: Binding<NoteMenuWingContext?>, ask: Binding<WingsModel.MoveAsk?>
    ) -> some View {
        self
            // VX-377: keyed on the note AND the window's wing-act signal.
            .task(id: NoteMenuWingContext.loadKey(postID: postID, wings: wings)) {
                let loaded = await NoteMenuWingContext.load(session, postID: postID)
                guard !Task.isCancelled else { return }
                context.wrappedValue = loaded
            }
            .wingMoveConfirm(ask, wings: wings) {
                // An UNSTRUCTURED task: cancellation never reaches it, so
                // the subject check is the guard (`reloadAdopts` — the
                // sanity pass's NIT), applied AFTER the await, where the
                // stale landing happens.
                Task {
                    let loaded = await NoteMenuWingContext.load(session, postID: postID)
                    guard NoteMenuWingContext.reloadAdopts(
                        over: context.wrappedValue, postID: postID) else { return }
                    context.wrappedValue = loaded
                }
            }
    }
}
