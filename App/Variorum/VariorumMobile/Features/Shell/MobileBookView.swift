//
//  MobileBookView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — a book's note list (scope item 1: chapters
//  honored; the Read flow itself is S4's). Pushed under the system back
//  door (minimal inline nav — the nav chrome's voice is look-track,
//  recorded); rows are read-cheap doors into THE editor.
//
//  Since parity A3 (P35, her ruled flip) this screen IS the book's front:
//  a book tap lands here, and the READ flow is this screen's chrome door
//  (`onRead` — the exact mirror of the retired Read-side "contents"
//  door's placement).
//

import SwiftUI
import VariorumCore

struct MobileBookView: View {
    /// The Read door's word (P35 — voice-cased at render; pinned).
    static let readDoorTitle = "Read"
    /// The details door's word (parity C2, the LK5 expansion — the fork's
    /// ruled placement: the contents screen's trailing chrome, beside
    /// Read; voice-cased at render; pinned).
    static let detailsDoorTitle = "Details"

    // MARK: - Batch 10's two doors (her *"when you're within a book, there
    // should be a new note and new chapter button, which the mac up does
    // have"*)

    /// **The note door reuses the phone's ONE new-note word**
    /// (`MobileNewNoteDoor.doorTitle`, which the shelf and the Library path
    /// lines already say). The Mac's own in-book door reads `+ new note`;
    /// this is that word in the phone's casing, and taking it from the
    /// existing symbol is what stops a third spelling appearing.
    static var newNoteDoorTitle: String { MobileNewNoteDoor.doorTitle }

    /// The chapter door + its alert — the Mac's own words (`BookView`'s
    /// `+ new chapter` / "New Chapter" / "Name" / "Create"), in the phone's
    /// casing. Voice-cased at render; pinned.
    static let newChapterDoorTitle = "+ New Chapter"
    static let newChapterAlertTitle = "New Chapter"
    static let newChapterFieldTitle = "Name"
    static let newChapterConfirmTitle = "Create"

    @State private var model: MobileBookViewModel
    @State private var detailsPresented = false
    /// Batch 10: the New Chapter alert and its field (a real `@State`
    /// binding — §15's trap (a)).
    @State private var newChapterPresented = false
    @State private var chapterNameField = ""
    private let session: AppSession
    let tokens: VoiceTokens
    let onOpen: (String) -> Void
    /// The Read flow door (P35's inversion — Read is the door now).
    let onRead: () -> Void
    /// A NEWLY MINTED note opens for WRITING (batch 10 — the brief's
    /// letter: *"the minted note opens for writing"*, and the phone's own
    /// `+ New Note` grammar on both other roots). nil in harness/preview
    /// use, where the screen is mounted without a stack to push onto.
    let onOpenForWriting: ((String) -> Void)?
    /// The book went (round 2 batch 4 — PR4): pop this screen, because a
    /// contents list of a tombstoned book is exactly what the delete door
    /// must not leave behind. nil in harness/preview use.
    let onDeleted: (() -> Void)?

    init(
        session: AppSession, readingID: String, tokens: VoiceTokens,
        onOpen: @escaping (String) -> Void,
        onRead: @escaping () -> Void,
        onOpenForWriting: ((String) -> Void)? = nil,
        onDeleted: (() -> Void)? = nil
    ) {
        _model = State(initialValue: MobileBookViewModel(session: session, readingID: readingID))
        self.session = session
        self.tokens = tokens
        self.onOpen = onOpen
        self.onRead = onRead
        self.onOpenForWriting = onOpenForWriting
        self.onDeleted = onDeleted
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                ForEach(Array(model.groupedRows.enumerated()), id: \.offset) { _, group in
                    if let section = group.section {
                        Text(tokens.chromeLabel(MobileBookViewModel.sectionLabel(section)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                    }
                    ForEach(group.entries, id: \.postID) { entry in
                        noteRow(entry)
                    }
                }
                if model.entries.isEmpty {
                    Text(tokens.chromeLabel("No notes in this book yet."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(20)
                }
                if model.truncated {
                    // The bounded-window marker (never a silent cut;
                    // P32's neutral reword — one shared sentence).
                    Text(tokens.chromeLabel(
                        MobileBookViewModel.truncationMarker(shown: model.entries.count)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(20)
                }
                bookDoors
                // **A REFUSAL SPEAKS WHERE THE TAP WAS** (the batch-10 cold
                // review, MAJOR 2). The doors trail the contents list, so on
                // a book longer than a screen the header's slot is off the
                // top of the viewport and a refused door read as nothing
                // happening. This is the phone's own root-slot grammar —
                // `MobileStarredView` puts `stars.error(on:)` beside the door
                // that fired it for exactly this reason.
                if let refusal = model.doorRefusal {
                    Text(refusal)
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
            }
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // The details door (parity C2 — the ruled placement: the
                // contents screen is the book's front, and its nav bar is
                // the book's chrome-door row).
                Button(tokens.chromeLabel(Self.detailsDoorTitle)) {
                    detailsPresented = true
                }
                .font(tokens.small)
            }
            ToolbarItem(placement: .topBarTrailing) {
                // The Read door (P35): the calm continuous column, from
                // the contents — the retired contents door's placement,
                // mirrored.
                Button(tokens.chromeLabel(Self.readDoorTitle)) { onRead() }
                    .font(tokens.small)
            }
        }
        .sheet(isPresented: $detailsPresented) {
            MobileBookDetailsSheet(
                session: session, readingID: model.readingID, tokens: tokens,
                onDeleted: { onDeleted?() })
                .presentationDetents([.medium, .large])
        }
        // Batch 10 — the Mac's own alert, word for word (`BookView`'s "New
        // Chapter" / "Name" / "Create" / "Cancel").
        .alert(Self.newChapterAlertTitle, isPresented: $newChapterPresented) {
            TextField(Self.newChapterFieldTitle, text: $chapterNameField)
            Button(tokens.chromeLabel(Self.newChapterConfirmTitle)) {
                let name = chapterNameField
                let model = model
                Task { await model.newChapter(named: name) }
            }
            // The face gate (the rename door's own rule, C2 ladder R1-3):
            // a blank name never fires a silent no-op.
            .disabled(!MobileBookViewModel.canName(chapterNameField))
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        }
        .task { await model.start() }
    }

    /// **THE TWO DOORS INSIDE A BOOK** (batch 10, her ask). They trail the
    /// contents list — the `+ new book` precedent: a list ends with the way
    /// to add to it.
    ///
    /// **Rendered on CURATED books only** (`showsBookDoors`): on a smart
    /// book both are ABSENT rather than present-and-refusing, because
    /// derived membership has no row to mint and chapters are refused by
    /// model rule — P-2's own case, and the phone's `showsDailyDoor`
    /// precedent. On a FINISHED book they stay and REFUSE in the family's
    /// voice — **and the refusal renders immediately beneath them**, which
    /// is what makes that divergence honest (the cold review's MAJOR 2: a
    /// door kept so it can explain must explain where the finger is).
    /// Details' Reopen row is one tap away and a door that vanished on
    /// finishing would explain nothing.
    @ViewBuilder
    private var bookDoors: some View {
        if model.showsBookDoors {
            Button {
                let model = model
                Task {
                    if let postID = await model.newNote() {
                        onOpenForWriting?(postID)
                    }
                }
            } label: {
                doorRow(Self.newNoteDoorTitle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.newNoteDoorTitle)
            Button {
                chapterNameField = ""
                newChapterPresented = true
            } label: {
                doorRow(Self.newChapterDoorTitle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.newChapterDoorTitle)
        }
    }

    private func doorRow(_ title: String) -> some View {
        HStack {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
            Spacer()
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let reading = model.reading {
                // ONE finished-state grammar (S3 ladder, NIT 2): the name
                // brain speaks; this header stops respelling it.
                Text(tokens.chromeLabel(MobileShelfFaces.name(for: reading)))
                    .font(tokens.title)
                    .foregroundStyle(reading.locked ? tokens.accent : tokens.ink)
            }
            if let error = model.lastError {
                Text(error).font(tokens.small).foregroundStyle(tokens.alarm)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private func noteRow(_ entry: Queries.ReadingEntry) -> some View {
        Button {
            onOpen(entry.postID)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(MobileBookViewModel.rowTitle(entry))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                if let day = entry.entryDate {
                    Text(day)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
