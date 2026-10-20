//
//  CopyDoorsSheet.swift
//  Variorum
//
//  VX-306 U3 — THE TWO DOORS, the Mac's faces (rule 17; §7c (8) (9), built exactly as drafted — PROVISIONAL, hers at
//  the bundle). One sheet over `CopyDoorsModel`: a picked thing being read, its honest refusal, the several-stores
//  chooser, a picked copy's doors, and MAKE THIS MY LIBRARY's confirm — the title, the lead, the copy's own secret only
//  when its quiet road doesn't open it, her twelve words, her passphrase when one is set, one button; and LOOK INSIDE
//  (`LookInsideSheet` — P-VX306-U3-15, the read-only facts sheet).
//
//  And the RESTORE LIST's rows on the new road (`RoadRestoreRows`, Settings ▸ Data Safety): this library's copies newest
//  first, then the other libraries on this Mac — each row its day, its kind, *Look inside…* and *Make this my
//  library…*.
//

import SwiftUI
import VariorumCore

struct CopyDoorsSheet: View {
    @Bindable var model: CopyDoorsModel
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch model.phase {
            case .reading:
                Text(LibraryOpenCopy.sheetTitle).font(.title3.weight(.semibold))
                HStack(spacing: 8) {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.filingLine).foregroundStyle(.secondary)
                }
            case .refused(let message, let detail):
                Text(LibraryOpenCopy.sheetTitle).font(.title3.weight(.semibold))
                Text(message).fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack { Spacer(); Button("Close") { onClose() }.keyboardShortcut(.cancelAction) }
            case .choosing(let stores):
                Text(LibraryOpenCopy.sheetTitle).font(.title3.weight(.semibold))
                Text(LibraryOpenCopy.severalStoresLead).fixedSize(horizontal: false, vertical: true)
                ForEach(stores, id: \.self) { store in
                    Button(store.lastPathComponent) { Task { await model.choose(store) } }
                }
                HStack { Spacer(); Button(ProtectionWords.makeMineCancel) { onClose() }.keyboardShortcut(.cancelAction) }
            case .doors(let row):
                Text(LibraryOpenCopy.sheetTitle).font(.title3.weight(.semibold))
                Text(ProtectionWords.pickedCopyLine(row.asOf.map { ProtectionWords.day($0) } ?? ProtectionWords.offerUnknownDay))
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button(ProtectionWords.makeMineCancel) { onClose() }.keyboardShortcut(.cancelAction)
                    Spacer()
                    if model.offersLookInside {
                        Button(ProtectionWords.lookInsideDoor) { Task { await model.openLookInside(row) } }
                    }
                    if model.offersMakeMine {
                        Button(ProtectionWords.makeMineDoor) { Task { await model.openMakeMine(row) } }
                    }
                }
            case .plaintextExport(let store):
                // VX-309 U1b — T-8: a plain-text copy, brought in as a new library through the import road.
                Text(LibraryOpenCopy.sheetTitle).font(.title3.weight(.semibold))
                Text(ProtectionWords.bringInLead(stepsALibraryAside: model.bringInStepsALibraryAside))
                    .fixedSize(horizontal: false, vertical: true)
                if let refusal = model.bringInRefusal {
                    Text(refusal)
                        .font(.callout)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Button(ProtectionWords.makeMineCancel) { onClose() }
                        .keyboardShortcut(.cancelAction)
                        .disabled(model.bringingIn)
                    Spacer()
                    if model.bringingIn {
                        TravellingDotsIndicator(ink: .secondary)
                        Text(ProtectionWords.bringInWorking).font(.caption).foregroundStyle(.secondary)
                    }
                    Button(ProtectionWords.bringInButton) { Task { await model.bringIn(store) } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.bringingIn)
                }
            case .listing(let listing):
                // VX-309 U1b: this Mac's copies with no library open — rule 17's Restore from Backup at the empty slot.
                Text(LibraryOpenCopy.restoreSectionTitle).font(.title3.weight(.semibold))
                Text(listing.isEmpty ? ProtectionWords.noCopiesOnThisMac : ProtectionWords.emptySlotRestoreListLead)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(listing.all) { row in listingRow(row) }
                    }
                }
                .frame(maxHeight: 320)
                HStack { Spacer(); Button(ProtectionWords.makeMineCancel) { onClose() }.keyboardShortcut(.cancelAction) }
            case .makeMine(let confirm):
                MakeMineConfirm(model: confirm)
            case .lookInside(let look):
                LookInsideSheet(model: look)
            case .done:
                // The act is done (the reopen already routed) or she left; the sheet leaves.
                Color.clear.frame(height: 1).onAppear { onClose() }
            }
        }
        .padding(22)
        .frame(width: isLooking ? 560 : 460, alignment: .leading)
    }

    private var isLooking: Bool {
        if case .lookInside = model.phase { return true }
        return false
    }

    /// One copy of the listing: its day and kind, and its doors.
    private func listingRow(_ row: CopyDoorRow) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.asOf.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? ProtectionWords.offerUnknownDay)
                    .font(.callout)
                Text(ProtectionWords.copyKind(row.kind))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if model.offersLookInside {
                Button(ProtectionWords.lookInsideDoor) { Task { await model.openLookInside(row) } }
            }
            if model.offersMakeMine {
                Button(ProtectionWords.makeMineDoor) { Task { await model.openMakeMine(row) } }
            }
        }
    }
}

/// MAKE THIS MY LIBRARY's confirm — §7c (8).
struct MakeMineConfirm: View {
    @Bindable var model: MakeMineModel

    @State private var copySecret = ""
    @State private var words = ""
    @State private var passphrase = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ProtectionWords.makeMineTitle).font(.title3.weight(.semibold))
            Text(model.lead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if model.checking {
                HStack(spacing: 6) {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.makeMineChecking).font(.caption).foregroundStyle(.secondary)
                }
            } else if model.intoTheEmptySlot {
                // VX-309 U1b — T-5: no library is open — the copy's own secret is the one thing asked, and its lock.
                PeekableSecretField(label: ProtectionWords.makeMineCopySecretField, text: $copySecret, onSubmit: submit)
                    .textFieldStyle(.roundedBorder)
            } else {
                if model.needsCopySecret {
                    PeekableSecretField(label: ProtectionWords.makeMineCopySecretField, text: $copySecret)
                        .textFieldStyle(.roundedBorder)
                    Text(ProtectionWords.makeMineCopySecretNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                TextField(ProtectionWords.makeMineWordsField, text: $words, axis: .vertical)
                    .lineLimit(2, reservesSpace: true)
                    .autocorrectionDisabled()
                    .privacySensitive()
                    .textFieldStyle(.roundedBorder)
                if model.passphraseSet {
                    PeekableSecretField(label: ProtectionWords.makeMinePassphraseField, text: $passphrase, onSubmit: submit)
                        .textFieldStyle(.roundedBorder)
                }
            }
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.makeMineCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.makeMineWorking).font(.caption).foregroundStyle(.secondary)
                }
                Button(ProtectionWords.makeMineButton) { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.intoTheEmptySlot
                              ? !model.canSubmitIntoTheEmptySlot(copySecret: copySecret)
                              : !model.canSubmit(words: words, passphrase: passphrase))
            }
        }
    }

    private func submit() {
        let secret = copySecret
        if model.intoTheEmptySlot {
            Task { await model.submitIntoTheEmptySlot(copySecret: secret) }
            return
        }
        let typedWords = words
        let typedPassphrase = passphrase
        Task { await model.submit(copySecret: secret, words: typedWords, passphrase: typedPassphrase) }
    }
}

/// The Restore list's rows on the new road (Settings ▸ Data Safety) — the catalogue's copies, newest first.
struct RoadRestoreRows: View {
    @Bindable var list: CopyDoorsListModel
    /// A row's *Look inside…* (the scene's presenter opens the look — P-VX306-U3-15).
    let lookInside: (CopyDoorRow) -> Void
    /// A row's *Make this my library…* (the scene's presenter opens the confirm).
    let makeMine: (CopyDoorRow) -> Void

    var body: some View {
        if !list.listing.isEmpty {
            Section(LibraryOpenCopy.restoreSectionTitle) {
                Text(ProtectionWords.restoreListLead)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(list.listing.thisLibrary) { row in rowView(row) }
                if !list.listing.otherLibraries.isEmpty {
                    Text(ProtectionWords.otherLibrariesHeading)
                        .font(.callout.weight(.semibold))
                        .padding(.top, 4)
                    ForEach(list.listing.otherLibraries) { row in rowView(row) }
                }
            }
        }
    }

    private func rowView(_ row: CopyDoorRow) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.asOf.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? ProtectionWords.offerUnknownDay)
                    .font(.callout)
                Text(ProtectionWords.copyKind(row.kind))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(ProtectionWords.lookInsideDoor) { lookInside(row) }
            Button(ProtectionWords.makeMineDoor) { makeMine(row) }
        }
    }
}

/// The new road's Restore list as Settings hands it down: the roads, and a row's *Make this my library…* through the
/// scene's own presenter.
struct RoadDoorsHost {
    let roads: CopyDoorsRoads
    let lookInside: (CopyDoorRow) -> Void
    let makeMine: (CopyDoorRow) -> Void
}
