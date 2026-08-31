//
//  MobileLibraryView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the Library tab (M7): everything, newest
//  first; search over the standing catalog scope; the bookless filter
//  (the Pool's phone home); the "+ new note" minting door. Voiced chrome
//  in the mockup's register; reading is cheap (P3 — no live editor
//  here).
//

import SwiftUI
import VariorumCore

struct MobileLibraryView<TabBar: View>: View {
    @Bindable var model: MobileLibraryViewModel
    /// The scraps area's model (parity C3 — the third filter's listing;
    /// constructed by the shell beside this view's own model).
    @Bindable var scraps: MobileScrapsModel
    /// The starred set (parity C3): the note rows' star door — the ONE
    /// model the shell threads to every surface with the door.
    @Bindable var stars: MobileStarsModel
    /// **The books listing's model — the SHELF's own, threaded here** (the
    /// filter batch, her #92(a): *"filtering to 'books' lists her books
    /// themselves as openable rows"*).
    ///
    /// It is the SAME instance the Shelf holds, deliberately: `bookshelf` +
    /// `shelfPins` + the daily designation ride one held observation there
    /// and both tab stacks stay alive by design (`MobileLivenessAuthority` —
    /// *"nothing about visibility ever fires `onDisappear`"*), so a second
    /// model would be a second observation over rows the app is already
    /// watching. Reusing it is also what keeps the row FACES from forking:
    /// `rowName`/`rowMeta` are `MobileShelfFaces`, never a second rule.
    ///
    /// *(The 6c "nothing shared" ruling is about the two RECOVERY rooms'
    /// message slots — an act in one speaking in the other. Nothing here acts:
    /// the Library's book rows open a book and nothing else, so this model's
    /// error and receipt slots are never written from this surface.)*
    ///
    /// **Consequence, stated so nobody re-derives it:** the held observation
    /// belongs to the SHELF root's `.task`, not to this view — one loop for
    /// one model, whichever surface is wearing it. In the app that root is
    /// always mounted, so the rows are there before she can reach this filter;
    /// a harness that mounts THIS view alone must drive the model the way the
    /// app does (`start()` + `refreshTags()`), and the geometry/behaviour pins
    /// do exactly that. A second `start()` here would run a second loop
    /// writing identical values and double `observationTicks`, which
    /// `MobileShelfPerfTests` reads.
    let books: MobileShelfViewModel
    let tokens: VoiceTokens
    @ViewBuilder let tabBar: () -> TabBar
    let onOpen: (MobileRoute) -> Void
    /// **The Two-rooms doors** (batch 6c — her QUESTIONS #84 ruling). Batch
    /// 4's single `onOpenRecovery` opened a screen holding both states; it
    /// is now two destinations, and the Library is where both doors live:
    /// the path line's 🗑 and the listing's narrowed trailing row. Both nil
    /// in harness/preview use.
    var onOpenTrash: (() -> Void)?
    var onOpenArchive: (() -> Void)?

    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            searchField
            filterRow
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let hits = model.hits {
                        hitRows(hits)
                    } else if model.filter == .scraps {
                        // The scraps area (parity C3): standalone blocks
                        // with their tags, and the mint door.
                        MobileScrapsSection(model: scraps, tokens: tokens)
                    } else if model.filter == .books {
                        // #92(a): her books themselves, as openable rows.
                        bookRows
                    } else {
                        listingRows
                        // The Archived room's door belongs under a NOTE
                        // listing — it opens archived NOTES (§0's model
                        // fact: a book cannot be archived at all), so it
                        // does not trail the books or scraps listings.
                        archiveRow
                    }
                }
                .padding(.horizontal, 8)
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let receipt = model.receipt {
                // A landed act's own words, in the muted slot — never the
                // red one (the Mac recovery model's split).
                Text(tokens.chromeLabel(receipt))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let starsError = stars.error(on: .library) {
                // A star refusal fired HERE (D2 — one home per refusal,
                // clearing after a beat; "spoken where the door fired"
                // is now structurally true, not hoped).
                Text(tokens.chromeLabel(starsError))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        // The listing observation restarts when the sort flips (parity
        // C3 — a way of looking; nothing is written).
        .task(id: model.sort) { await model.startAll() }
        .task { await model.startBookless() }
        // The scraps observation's lifecycle lives HERE (FIX-C3c): the
        // section's body is flat lazy-row content now, so its task
        // moved to stable chrome — it runs while the Scraps filter
        // shows and cancels when the filter leaves, exactly the old
        // section-task lifecycle.
        .task(id: model.filter) {
            if model.filter == .scraps { await scraps.start() }
        }
        .task(id: query) { await model.search(query) }
        // PR1's confirm — a real `@Bindable` projection (§15's trap (a))
        // AND `presenting:`, which is the half batch 4 was missing: without
        // it the note to delete was read back AFTER SwiftUI's dismissal had
        // cleared it, so this door confirmed and deleted NOTHING (batch
        // 4.5b's BLOCKER; the rule is at
        // `MobileLibraryViewModel.deleteNotePresented`).
        .alert(
            MobileEditorViewModel.deleteNoteConfirmTitle,
            isPresented: $model.deleteNotePresented,
            presenting: model.pendingDeleteNote
        ) { item in
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task { await model.confirmDeleteNote(item) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: { _ in
            Text(MobileEditorViewModel.deleteNoteConfirmDetail)
        }
    }

    /// **THE ARCHIVE ROOM'S DOOR — the trailing row, NARROWED** (batch 6c;
    /// batch 4's `recoveryRow`). It is the listing's own last row, the
    /// `+ new book` precedent: a list of notes ends with the way to the
    /// notes that left it — and a row is a real Button, a door a pin can
    /// drive (§15's trap (b)), which a `Menu` item is not.
    ///
    /// **What changed is what it CLAIMS.** It said `RecoveryCopy.surfaceName`
    /// — *"Archived & Deleted"* — and opened a screen holding both. Under
    /// Two rooms it says **Archived** and opens only the archive: *"it no
    /// longer claims deletion"*, which is the whole reason that awkward
    /// two-noun name existed. Deletion's door is the path line's 🗑.
    @ViewBuilder
    private var archiveRow: some View {
        if let onOpenArchive, model.filter.isNoteListing {
            Button(action: onOpenArchive) {
                HStack {
                    Text(tokens.chromeLabel(MobileRecoveryDoors.archiveLabel))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    Spacer()
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(MobileRecoveryDoors.archiveLabel)
        }
    }

    /// **The path line gains a THIRD door — the Trash's 🗑** (batch 6c;
    /// option 2's own letter, and the analogue of her Mac B1 ruling, where
    /// the Library masthead's trash icon replaced a ⋯ menu). This is the
    /// cost she knowingly accepted: P38's crowding lesson kept this strip
    /// two doors wide, and the Two-rooms option spends the third here rather
    /// than in the filter row, which is already at its width budget.
    private var pathLine: some View {
        // `spacing: 16` — the Shelf path line's own value, adopted now that
        // this strip carries two trailing doors instead of one.
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(tokens.path(["Library"]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            if let onOpenTrash {
                MobileTrashDoor(tokens: tokens, act: onOpenTrash)
            }
            Button {
                Task {
                    if let postID = await model.newNote() {
                        onOpen(.note(postID, focus: true))
                    }
                }
            } label: {
                // The ONE door word (P33: the shelf's twin reads it too).
                Text(tokens.chromeLabel(MobileNewNoteDoor.doorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New Note")
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var searchField: some View {
        TextField(tokens.chromeLabel("Search notes, books…"), text: $query)
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(tokens.line, lineWidth: 1)))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
    }

    /// **all · books · notes · bookless · scraps** — her #85's kind doors
    /// joining the provenance ones, through the ONE filter brain
    /// (`MobileFilterRow`, which the Archive room renders too: *"Archived …
    /// needs the same filters that the regular library has"*).
    ///
    /// The sort rides the trailing slot as a GLYPH (#92(b) — *"the width
    /// budget gives at the SORT"*), and its **availability rule is
    /// unchanged**: `.all` only. Bookless keeps the core query's own order,
    /// scraps are pointer-ordered, books order as the SHELF orders (pins
    /// first, then journals, then names — `MobileShelfFaces.ordered`), and
    /// `.notes` shows the `.all` listing, so a sort door on any of them could
    /// not mean what it says. *(PROVISIONAL, logged: `.notes` renders the same
    /// rows as `.all` and therefore loses the sort by that rule — one line if
    /// she wants it back.)*
    private var filterRow: some View {
        MobileFilterRow(
            doors: MobileListingFilter.libraryDoors,
            selection: model.filter,
            tokens: tokens,
            select: { model.filter = $0 },
            trailing: {
                if model.filter == .all {
                    sortMenu
                }
            })
    }

    /// The four standing stamps (entry date · created · last touched · last
    /// meaningful edit), newest first — **the menu is byte-unchanged; only its
    /// door shrank** (#92(b)). The full verb and the current stamp moved into
    /// the accessibility label, so what an assistive reader hears is strictly
    /// more than the old text door said.
    private var sortMenu: some View {
        Menu {
            ForEach(MobileLibraryViewModel.sortOptions, id: \.self) { option in
                Button {
                    model.setSort(option)
                } label: {
                    if option == model.sort {
                        Label(MobileLibraryViewModel.sortWord(option),
                              systemImage: "checkmark")
                    } else {
                        Text(MobileLibraryViewModel.sortWord(option))
                    }
                }
            }
        } label: {
            Image(systemName: MobileSortDoor.symbol)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        }
        .accessibilityLabel(
            MobileSortDoor.label(
                sortWord: MobileLibraryViewModel.sortWord(model.sort)))
    }

    /// **BOOKS AS ROWS** — her #92(a): *"filtering to 'books' lists her books
    /// themselves as openable rows"*, and the Library becomes the surface that
    /// really does hold everything.
    ///
    /// **The faces are the SHELF's, through the existing brain** — never a
    /// second row-rendering rule: `rowName` is `MobileShelfFaces.name` (the
    /// stored name plus the finished " ✓" state) and `rowMeta` is
    /// `MobileShelfFaces.meta` (LK5's order — count · tags · daily). The order
    /// is `MobileShelfFaces.ordered`, so a book sits where the Shelf puts it.
    /// A row opens the book's CONTENTS, which is exactly what the Shelf's row
    /// does (P35's ruled inversion).
    ///
    /// **What a row deliberately does NOT carry:** the Shelf row's long-press
    /// acts (pin · star · delete). This is a LISTING, not a second shelf — and
    /// duplicating three acts is duplicating three confirms and two message
    /// slots. Recorded as a call in the batch record.
    @ViewBuilder
    private var bookRows: some View {
        let windowed = model.windowedBooks(books.orderedBooks)
        if windowed.rows.isEmpty {
            Text(tokens.chromeLabel(MobileListingFilter.noBooksLine))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 24)
                .accessibilityLabel(MobileListingFilter.noBooksLine)
        }
        ForEach(windowed.rows, id: \.reading.id) { book in
            Button {
                onOpen(.book(book.reading.id))
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(tokens.chromeLabel(books.rowName(for: book)))
                        .font(tokens.body)
                        .foregroundStyle(
                            book.reading.locked ? tokens.accent : tokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    Text(tokens.chromeLabel(books.rowMeta(for: book)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // Plain, and it carries the META as well as the name — an
            // explicit label REPLACES the one SwiftUI would compose from the
            // row's children, so a name-only label would have dropped the
            // count and tags out of the accessibility tree while the Shelf's
            // own rows still spoke them (measured; the rule is
            // `MobileShelfFaces.spokenRow`).
            .accessibilityLabel(MobileShelfFaces.spokenRow(
                name: books.rowName(for: book), meta: books.rowMeta(for: book)))
        }
        if windowed.truncated {
            // The filterless rooms' one sentence, from its one home. (The
            // Library's kind filter cannot narrow a books listing further —
            // "books" IS the narrowing — so the Trash's "narrow the filter"
            // half would be a road that does not exist here.)
            Text(tokens.chromeLabel(
                MobileRoomListing.truncationMarker(shown: windowed.rows.count)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .accessibilityLabel(
                    MobileRoomListing.truncationMarker(shown: windowed.rows.count))
        }
    }

    private var listingRows: some View {
        ForEach(model.visible, id: \.postID) { item in
            Button {
                onOpen(.note(item.postID, focus: false))
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(MobileLibraryViewModel.rowTitle(item))
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    if let day = item.entryDate {
                        Text(day)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // Star (parity C3, her ruling 10): the note row's long-press
            // — the Mac's own row-menu placement, the phone's grammar.
            .contextMenu {
                let target = StarTarget.post(item.postID)
                Button(tokens.chromeLabel(
                    MobileStarsModel.doorTitle(starred: stars.isStarred(target)))) {
                    let stars = stars
                    Task { await stars.toggle(target, from: .library) }
                }
                // Delete the note (round 2 batch 4 — PR1): the row's
                // long-press, beside Star, the phone's established
                // row-menu grammar. Move to Trash; the model confirms.
                Button(
                    tokens.chromeLabel(MobileEditorViewModel.deleteNoteTitle),
                    role: .destructive
                ) {
                    model.requestDeleteNote(item)
                }
            }
        }
    }

    @ViewBuilder
    private func hitRows(_ hits: [Queries.CatalogHit]) -> some View {
        if hits.isEmpty {
            Text(tokens.chromeLabel("Nothing found."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 24)
        }
        ForEach(Array(hits.enumerated()), id: \.offset) { _, hit in
            if let route = MobileLibraryViewModel.destination(for: hit) {
                Button {
                    onOpen(route)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(hit.title)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        Spacer(minLength: 12)
                        Text(tokens.chromeLabel(hitDetail(hit)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func hitDetail(_ hit: Queries.CatalogHit) -> String {
        switch hit.kind {
        case .book: return hit.detail ?? "book"
        case .post: return hit.detail ?? "note"
        case .block: return hit.detail.map { "block · \($0)" } ?? "block"
        }
    }
}
