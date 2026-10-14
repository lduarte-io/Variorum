//
//  MCPPaneCopy.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — Settings ▸ MCP's words, ONE home. The register is DIRECT AND
//  TECHNICAL inside this pane and its sheets (R-13n-5, her words: "it's only
//  for technical people anyway"; P-13n-1 — the app-wide faces an AI act
//  produces keep the app's own voice). A pending client is a CONNECTION
//  REQUEST (Approve… / Deny), never the Arrivals door idiom. Sentence case
//  everywhere (her standing rule). The approved mockup's words
//  (`notes/plans/13n-sitting-mockups/mcp-door-mockups.html` §1–§3) are used
//  verbatim except where U1 cannot yet make them true — each such line says
//  so beside it.
//

import Foundation
import VariorumCore
import VariorumMCP
import VariorumMCPSocket

nonisolated enum MCPPaneCopy {
    // MARK: - The server

    /// The toggle (mockup §1, verbatim).
    static let enableTitle = "Enable the MCP server"
    /// The toggle's sentence — mockup §1's words, kept TRUE to what the
    /// server serves (P-13nb-U1-12's rule: U1 trimmed it to the read rung,
    /// U2 restored the mockup once the write rungs made it true). U3 walk
    /// finding W-2: "no client can overwrite your text" stopped being true
    /// the moment edit could be granted, so the clause says when it can —
    /// and what guards it (R-13n-7's brackets). PROVISIONAL P-13nb-U3-17,
    /// her words to re-voice at 13s-a. 13n-c U2 (VX-272 — no "AI" in
    /// settings-class wording): "AI work" → "a client's work". 13n-c O-4 (her
    /// ask — no provider hardwired outside the setup): "clients like Claude
    /// Code" → "MCP clients" (PROVISIONAL, her copy pass). VX-184 ladder
    /// round 2 (doc-truth): "with a commit before and after every change" was
    /// false once U4/U5 grew the edit rung — only a take's rewrite
    /// (`edit_take`, `restore_commit`) is bracketed, and its "before" is
    /// skipped when the take's latest commit already holds those words — so
    /// the clause says the commits where they are true (VX-234's to re-voice).
    static let enableBlurb =
        "Runs a local MCP server while Variorum is open, so MCP clients can read "
        + "and write here through Variorum's own operations. Nothing is readable until you grant "
        + "it, every grant is revocable, and a client's work lands as takes beside your own \u{2014} a "
        + "client changes your text only where you grant it edit, and when it rewrites a take, the "
        + "take's words before and after are kept as commits."

    // MARK: - The one-line explainers (VX-281 U1 — R-VX184-6)
    //
    // Her ruling: "every explainer cut to one line with the full text behind
    // an (i) popover". Each SUMMARY below is what the pane shows (one line —
    // `ExplainerLine`, pinned to fit); its FULL text is the constant it
    // summarizes, unchanged, in the (i)'s popover — so every truth pin on
    // the full texts stands. Words AS BUILT; every one is on the run record's
    // FOR VX-234 list (her Settings wording pass). Sentence case, no "AI"
    // (VX-272), no provider (O-4).

    /// The server's line (its whole text: `enableBlurb`).
    static let enableSummary =
        "A local MCP server while Variorum is open \u{2014} nothing is readable until you grant it."
    /// L1's line (its whole text: `clientBoundary`): the binding AND what it
    /// cannot promise, in L1's own words — never promising more (the VX-156
    /// brief §12's condition on L1).
    static let clientBoundarySummary =
        "A setup key tells two clients apart \u{2014} not programs running as you."
    /// The setup key's line (its whole text: `keyLine`), her R-VX184-5 words
    /// kept ("running it again replaces the old setup"). VX-258 (VX-246 U1b):
    /// scoped to the truth — a CLIENT'S OWN setup, run again, replaces the old
    /// one; an "Any MCP client" copy waits for her OK (said in the (i)).
    static let keySummary =
        "Each copy carries a fresh key; running a client's own setup again replaces the old one."
    /// The door's one line (its whole text: `stdioLine`), above the path.
    static let stdioSummary = "A standard MCP server over stdio \u{2014} one program, at this path:"

    /// HOW MUCH's line in the grant sheet (its whole text: `rungDetail`, the
    /// ask sheet's lead too). Read and write new already read as one line; the
    /// suggest and edit sentences are cut. The edit line keeps exactly the
    /// clause VX-184's ladder round 2 brought to the as-built reach — it names
    /// nothing a note grant can't do (W-UX-14's rule) and never "every change".
    static func rungSummary(_ rung: MCPGrantRule.Rung, scope: MCPGrantRule.ScopeKind? = nil) -> String {
        switch rung {
        case .read, .writeNew: rungDetail(rung, scope: scope)
        case .suggest: "it can add new takes and comments beside your text \u{2014} it cannot touch a word you wrote"
        case .edit: "it can also change, archive and delete what you shared, your own words included"
        }
    }

    /// The Connect tab's label (R-VX184-6 — her four: Connect · Clients ·
    /// Shared with AI · Activity; the other three are their sections' own
    /// titles). Its section keeps "Connect a client" (`connectSection`), the
    /// field guide's lesson 2 words.
    static let connectTab = "Connect"

    /// The status line beside the toggle (mockup §2).
    static func status(_ state: MCPDoor.ServerState) -> String {
        switch state {
        case .off: "off"
        case .running: "running \u{00B7} socket in the app container \u{00B7} serves while Variorum is open"
        case .waitingForLibrary: "on \u{00B7} starts when the library is open"
        case .failed(let reason): "couldn't start: \(reason)"
        }
    }

    // MARK: - Waiting (13n-c U4 — arrival X; the brief §5, mockup §4/§5)

    /// The asks waiting for her answer, above Connection requests. Nothing
    /// appears by itself: an ask waits here and at its glyph on the thing it
    /// names, until she answers it.
    static let waitingSection = "Waiting"

    // MARK: - Connection requests

    static let requestsSection = "Connection requests"
    static func requestTitle(_ name: String) -> String { "Connection request \u{2014} \(name)" }
    static func requestDetail(firstSeen: String) -> String {
        "First seen \(firstSeen). No access until approved."
    }

    // MARK: - A setup waiting for her OK (VX-258 — VX-246 U1b; PROVISIONAL words, VX-234)

    /// Waiting's re-bind row: a connection presented, under the name of a
    /// client she approved, a setup key that was not copied for that client.
    static func rebindTitle(_ name: String) -> String { "New setup for \(name)" }
    /// Who connected (the version it declared — what tells a stranger from
    /// the client she knows), when, and what each answer does.
    static func rebindDetail(name: String, version: String?, firstSeen: String) -> String {
        let declared = version.map { " (version \($0))" } ?? ""
        return "Connected as \(name)\(declared) with a setup that wasn't copied for it, \(firstSeen). "
            + "It reaches nothing until you allow it; allowing moves the name, with its grants, to this setup."
    }

    // MARK: - Clients

    static let clientsSection = "Clients"
    /// The walk's third finding: "no clients yet" read wrong beside a
    /// waiting request — a client is LISTED here once decided.
    static let noClients = "None yet \u{2014} a client is listed here once you approve or deny its connection request."
    static let connectedNow = "connected now"
    static func lastSeen(_ when: String) -> String { "last seen \(when)" }
    static let deniedState = "denied"
    static let noAccess = "approved \u{00B7} nothing shared"
    /// U2 walk W-1: rung-agnostic since the write rungs — "reads" was
    /// false of a suggest or write-new grant.
    /// 13n-c UX walk W-UX-10: the count is of GRANTS that reach (a client can
    /// hold several on one place — each a live fact), so the noun says grants;
    /// it read "3 shared places" for one book granted three ways. PROVISIONAL.
    static func reads(_ count: Int) -> String {
        count == 1 ? "1 grant" : "\(count) grants"
    }

    // MARK: - Deny… on a client row (13n-c UX walk W-UX-4) — PROVISIONAL words

    static func denyClientTitle(_ name: String) -> String { "Deny \(name)?" }
    /// What the press does, said before it does it: shut out AND every grant
    /// revoked (one press on the client row took all of it, unasked).
    /// VX-168 (P-VX168-U1-1): Deny also forgets the name's setup key, so
    /// letting it back takes its setup run again — said before the press.
    static func denyClientDetail(grants: Int) -> String {
        let shut = "It can't connect again until you approve it and run its setup again."
        switch grants {
        case 0: return shut
        case 1: return shut + " Its grant is revoked now, and approving it later shares nothing back."
        default: return shut + " Its \(grants) grants are revoked now, and approving it later shares nothing back."
        }
    }
    static let denyClientConfirm = "Deny"

    /// 13n-c U2 (the U1 ladder's R2-3; P-13nb-U2-3): the client row counts
    /// only grants that REACH as shared; an inert one is said as inert.
    static func reads(_ count: Int, inert: Int) -> String {
        guard inert > 0 else { return reads(count) }
        let shared = count == 0 ? "nothing shared" : reads(count)
        return "\(shared) \u{00B7} \(inert) inert"
    }

    /// **L1 — the A-4 boundary, said where clients are listed** (13n-c U2;
    /// the VX-156 brief §12's words, mockup §11 — the line the canon says the
    /// pane carries). Direct and technical (R-13n-5). **VX-168 made it
    /// TRUE-ER, never promising more (the brief's own condition):** the setup
    /// key now ties a name to its setup, and K2's recorded non-defeat — any
    /// program running as her can read the key — is said in the same breath.
    /// PROVISIONAL P-VX168-U1-5, her copy pass. VX-198 (R-VX184-5 — the
    /// newest copied setup wins): true of the new rule, no truer — running a
    /// newer setup moves the name to its key, and a connection with any other
    /// key (the one it replaced, one never issued, another client's) or none
    /// is refused. PROVISIONAL P-VX198-2. VX-258 (VX-246 U1b — her ruling,
    /// "tie keys to their tab … the re-bind waits for my ok"): true of the
    /// rule as built, no truer — the client's OWN setup, run again, moves the
    /// name; a setup copied for any MCP client waits for her OK before it
    /// takes a name she approved (a waiting connection is admitted with no
    /// reach, so it is neither "moved" nor "refused"); any other key, or
    /// none, is refused. Its one-line summary stays true as it was.
    static let clientBoundary =
        "A client names itself when it connects. Each setup copied here carries a key that binds "
        + "that name to it. Running the client's own setup again moves the name to the new key; a setup "
        + "copied for any MCP client waits for your OK before it takes a name you approved; any other "
        + "key, or none, is refused. That tells two tools apart, not programs running as you: any of "
        + "them can read the key in the client's settings."

    /// L1's room (VX-168): its four sentences run past the quiet captions'
    /// three lines at the pane's width.
    static let clientBoundaryLines = 5

    // MARK: - The setup key (VX-168 — K2)

    /// What the pane SHOWS where a copy's key goes: a key is minted only by
    /// the copy act and never displayed (the clipboard is its one road out).
    static let shownKey = "\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}"
    /// The line under the shown setup. PROVISIONAL P-VX168-U1-5. VX-198 (her
    /// R-VX184-5 words, the kickoff's): "Running it again replaces the old
    /// setup" — a re-run is the whole road; no Deny, no re-approval.
    /// VX-258 (VX-246 U1b): "running it again" is now the CLIENT'S OWN
    /// setup (a key copied for its name); an "Any MCP client" copy under a
    /// name she approved waits for her OK — said here, under every client's
    /// code block, so neither tab's line promises the other's road.
    static let keyLine =
        "Each copy carries a fresh setup key, shown here as dots, that ties a client's name to that "
        + "setup. Running a client's own setup again replaces the old one; a setup copied for any MCP "
        + "client waits for your OK before it takes a name you approved."
    /// Copy setup command with no library open: the key it mints is kept in
    /// the library, so there is nowhere to keep one. PROVISIONAL.
    static let setupNeedsLibrary = "Open your library to copy a setup \u{2014} its key is kept there."

    // MARK: - Shared with AI

    /// 13n-c U2 made it "Shared places" (VX-272); HER SITTING (2026-10-11,
    /// second round) REVERSED it in-pane — "I think Shared with AI is fine
    /// inside the MCP pane actually. that's a place where it's fair": VX-272
    /// stands app-wide, with her carve-out that inside the MCP pane itself
    /// "AI" is fair wording. Only this title changed; the client row's "N
    /// shared places" and the pane's other words stand.
    static let sharedSection = "Shared with AI"
    static let nothingShared = "Nothing is shared."

    /// 13n-c U2 (R2-3): a live grant whose target is fenced since reaches
    /// NOTHING — the row says so instead of calling it shared, and why.
    static func inertDetail(_ fence: MCPGrantRule.Fence, kind: MCPGrantRule.ScopeKind) -> String {
        let place = kind == .note ? "note" : "book"
        switch fence {
        case .privateMark: return "inert \u{2014} the \(place) is marked Private, which always asks"
        case .journal:
            return kind == .note
                ? "inert \u{2014} a daily Journal entry always asks"
                : "inert \u{2014} it's your daily Journal now, which always asks"
        }
    }
    static func sharedDetail(client: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration) -> String {
        "\(client) \u{00B7} \(rungWord(rung)) \u{00B7} \(durationWord(duration))"
    }
    static let missingTarget = "(gone)"

    // MARK: - One act's row (13n-c U3 — VX-156 item 2; mockup §2)

    /// 13n-c Stage B R2-2: one note is "1 note" (the members sheet can show a
    /// single member once the rest are revoked).
    static func groupTitle(_ count: Int) -> String { count == 1 ? "1 note" : "\(count) notes" }
    static let groupChip = "notes"
    /// The act's members, named — the titles read (at most three); a member
    /// gone since reads "(gone)". 13n-c Stage B R1 B3: the rest are no longer
    /// a dead phrase — `groupMoreRoad` is a door to the act's whole list.
    static func groupMembers(_ titles: [String?]) -> String {
        titles.map { $0 ?? missingTarget }.joined(separator: " \u{00B7} ")
    }
    /// The road to the members the row does not name (R-13n-10's "all N ›"
    /// idiom, said as the sentence's own tail).
    static func groupMoreRoad(_ rest: Int) -> String { "and \(rest) more \u{203A}" }
    /// The members sheet's title.
    static func membersTitle(_ count: Int) -> String { "\(groupTitle(count)) shared in one act" }
    /// R2-3's rule on an act: its members fenced since reach nothing.
    static func groupInert(_ count: Int) -> String {
        count == 1
            ? "1 inert \u{2014} a note fenced since (Private or your daily Journal), which always asks"
            : "\(count) inert \u{2014} notes fenced since (Private or your daily Journal), which always ask"
    }

    static func kindChip(_ kind: MCPGrantRule.ScopeKind) -> String {
        switch kind {
        case .note: "note"
        case .book: "book"
        case .wing: "wing"
        }
    }

    /// The shared rows' rung (mockup §2 — "read and suggest"); one table
    /// with the note's line (`MCPRungWords`).
    static func rungWord(_ rung: MCPGrantRule.Rung) -> String { MCPRungWords.reach(rung) }

    /// 13n-c U4 — "WHILE CONNECTED" RE-WORDED (her round-2 ask: she finds it
    /// vague; copy OPTIONS at the build — the U4 record lists them): the
    /// duration says WHEN IT ENDS — "until it disconnects" (the grant lives
    /// while that client stays connected and is swept when it goes, R-13nb-20).
    /// PROVISIONAL P-13nc-U4-1, her pick at the copy pass; every face that
    /// says the duration reads it from here (the sheet, the ask's buttons, the
    /// pane's rows, the popovers, the receipts, the confirm).
    static let untilDisconnects = "until it disconnects"

    static func durationWord(_ duration: MCPGrantRule.Duration) -> String {
        switch duration {
        case .once: "once"
        case .connection: untilDisconnects
        case .always: "always"
        }
    }

    // MARK: - The open book (mockup §2, verbatim)

    static let openBookSection = "Open book"
    static let openBookTitle = "Everything is readable, always"
    /// 13n-c U1 (VX-163, J8 — the VX-156 mockup §8's recommended words):
    /// only THE daily Journal and anything Private still ask.
    static let openBookDetail = "your daily Journal and anything Private still ask every time"

    // MARK: - Activity (13n-b U3 — the coarse log's face; R-13n-10's caps)

    static let activitySection = "Activity"
    /// 13n-c Stage B R2-5 (B10's class): the log is coarse and capped (the
    /// newest `mcpActivityCap` rows), so "every call" overclaimed — the true
    /// words are lesson 6's own, "the calls clients made recently"
    /// (PROVISIONAL, her copy pass).
    static let noActivity = "Nothing yet \u{2014} the calls clients made recently are listed here."

    /// One line of the ACTIVITY list (the mockup §2's "claude code added 3
    /// takes to “…”"): who, what, where — the MCP room's register, direct.
    /// 13n-c UX walk W-UX-13: a refused call says WHAT was refused in the act
    /// table's words ("ux-walk was refused reading “a letter”"), never the
    /// tool's raw id (PROVISIONAL words, her copy pass).
    static func activityLine(_ line: MCPActivityFace.Line) -> String {
        let target = line.targetTitle.map { "\u{201C}\($0)\u{201D}" }
        if let setup = rebindPhrase(line) { return setup }
        guard line.allowed else {
            let times = line.count > 1 ? " (\(line.count) times)" : ""
            return "\(line.clientName) was refused "
                + refusedPhrase(line.act, target: target, kind: line.targetKind) + times
        }
        return "\(line.clientName) \(activityPhrase(line.act, count: line.count, target: target, kind: line.targetKind))"
    }

    /// **VX-258 (VX-246 U1b) — a setup waiting for her OK, said in words**
    /// (PROVISIONAL words, VX-234). The wait is logged as not allowed (it
    /// reaches nothing — P-VX258-5), but it is no refusal of the client, so it
    /// reads as the ask it is; her two answers say what she did. nil for any
    /// other act.
    private static func rebindPhrase(_ line: MCPActivityFace.Line) -> String? {
        let times = line.count > 1 ? " (\(line.count) times)" : ""
        switch line.act {
        case MCPSetupKeyRule.awaitingAct:
            return "\(line.clientName) asked to use a setup that wasn't copied for it" + times
        case MCPSetupKeyRule.rebindAllowedAct:
            // The row's target is the key the allowed setup replaced (nil
            // when the name had none bound).
            let replaced = line.targetKind == MCPSetupKeyRule.replacedTargetKind
            return "\(line.clientName) took the new setup you allowed"
                + (replaced ? ", which replaced its earlier one" : "") + times
        case MCPSetupKeyRule.rebindDeclinedAct:
            return "\(line.clientName)\u{2019}s new setup wasn\u{2019}t allowed" + times
        default:
            return nil
        }
    }

    /// UX-fix ladder UXR1-1 — the noun a line falls back on when its
    /// target's title did not resolve: the LOGGED kind's ("making a book in a
    /// wing", never "… in a note").
    private static func fallbackNoun(_ kind: String?) -> String {
        switch kind {
        case "book": "a book"
        case "wing": "a wing"
        default: "a note"
        }
    }

    /// W-UX-13 — what a refused call was trying to do, as a gerund.
    /// UXR1-1: a TWO-SIDED act (`add_note_to_book`, `file_note_in_chapter`,
    /// `move_note_to_wing`) logs the side that refused — the note, or the
    /// book / destination wing — so the line says that side as itself and
    /// leaves the other unnamed, as the log does.
    private static func refusedPhrase(_ act: String, target: String?, kind: String?) -> String {
        let at = target ?? fallbackNoun(kind)
        switch act {
        case "list_books": return "listing books"
        case "list_notes":
            switch kind {
            case "book": return "listing a book\u{2019}s notes"
            case "wing": return "listing a wing\u{2019}s notes"
            default: return "listing notes"
            }
        case "read_note": return "reading \(at)"
        case "export_note": return "exporting \(at)"
        case "search": return "searching"
        case "show_in_app": return "showing you \(at)"
        case "add_take": return "adding a take to \(at)"
        case "add_comment": return "commenting in \(at)"
        case "save_lens": return "saving a lens on \(at)"
        case "create_note": return "making a note in \(at)"
        case "import_document": return "importing a document into \(at)"
        case "apply_tag": return "tagging \(at)"
        case "create_book": return "making a book in \(at)"
        case "add_note_to_book": return kind == "book" ? "adding a note to \(at)" : "adding \(at) to a book"
        case "create_section": return "adding a chapter to \(at)"
        case "save_version": return "saving a version of \(at)"
        case "file_note_in_chapter":
            return kind == "book" ? "filing a note in a chapter of \(at)" : "filing \(at) in a chapter"
        case "set_book_rule": return "setting what \(at) collects"
        case "edit_take": return "editing \(at)"
        case "divide_block": return "dividing a block in \(at)"
        case "merge_blocks": return "merging blocks in \(at)"
        case "move_block": return "moving a block in \(at)"
        case "delete_block": return "deleting a block in \(at)"
        case "set_block_name": return "naming a block in \(at)"
        case "put_back": return "putting back a block in \(at)"
        case "set_entry_date": return "setting the date of \(at)"
        case "move_note_to_wing": return kind == "wing" ? "moving a note to \(at)" : "moving \(at) to another wing"
        // VX-168 U2 — the edit rung's deliberate acts (PROVISIONAL words, her
        // copy pass): VX-169's commit, VX-174's merge button.
        case "save_commit": return "committing a take in \(at)"
        case "choose_take": return "choosing a take in \(at)"
        case "adopt_lens": return "making a lens of \(at) the note"
        // VX-184 U3 — VX-173's batch doors (PROVISIONAL words, her copy pass).
        case "add_takes": return "adding takes to \(at)"
        case "add_comments": return "leaving comments in \(at)"
        // VX-188 — a client deleting a comment (its own, at suggest).
        case "delete_comment": return "deleting a comment in \(at)"
        // VX-190 — un-tagging a note at edit.
        case "remove_tag": return "removing a tag from \(at)"
        // VX-187 — two notes linked as versions (the log names one side).
        case "link_versions": return "linking \(at) and another note as versions"
        // VX-184 U4 — VX-195's edit parity inside a note (PROVISIONAL words,
        // P-U4-WORDS — her copy pass).
        case "edit_comment": return "editing a comment in \(at)"
        case "restore_comment": return "restoring a comment in \(at)"
        case "delete_take": return "deleting a take in \(at)"
        case "archive_take": return "archiving a take in \(at)"
        case "unarchive_take": return "unarchiving a take in \(at)"
        case "set_take_label": return "labeling a take in \(at)"
        case "lock_take": return "locking a take in \(at)"
        case "unlock_take": return "unlocking a take in \(at)"
        case "restore_commit": return "restoring a commit in \(at)"
        case "rename_commit": return "renaming a commit in \(at)"
        case "rename_note": return "renaming \(at)"
        case "delete_lens": return "deleting a lens of \(at)"
        // VX-184 U5 — VX-196's edit parity across the library (PROVISIONAL
        // words, P-U5-WORDS — her copy pass). The book acts log the BOOK; the
        // chapter acts their chapter's book; the two-sided membership acts the
        // side that refused (UXR1-1's rule); the note acts the note.
        case "rename_book": return "renaming \(at)"
        case "finish_book": return "finishing \(at)"
        case "reopen_book": return "reopening \(at)"
        case "archive_book": return "archiving \(at)"
        case "unarchive_book": return "unarchiving \(at)"
        case "delete_book": return "deleting \(at)"
        case "remove_note_from_book":
            return kind == "book" ? "taking a note out of \(at)" : "taking \(at) out of a book"
        case "move_note_in_book":
            return kind == "book" ? "moving a note in \(at)" : "moving \(at) in a book"
        case "rename_chapter": return "renaming a chapter of \(at)"
        case "delete_chapter": return "deleting a chapter of \(at)"
        case "move_chapter": return "moving a chapter of \(at)"
        case "delete_note": return "deleting \(at)"
        case "archive_note": return "archiving \(at)"
        case "unarchive_note": return "unarchiving \(at)"
        // VX-168 — a connection the setup key turned away, said precisely
        // here (the client hears one sentence for all of them).
        case "connect_bare": return "connecting without a setup key"
        case "connect_not_issued": return "connecting with a setup key this library doesn\u{2019}t hold"
        case "connect_another_names_key": return "connecting with another client\u{2019}s setup key"
        case "connect_not_this_names_key": return "connecting with a setup key other than its own"
        // VX-198: the key a newer setup replaced (PROVISIONAL P-VX198-2).
        case "connect_replaced_key": return "connecting with a setup a newer one replaced"
        case "connect_unnamed": return "connecting without a name"
        default: return "using " + spokenAct(act)
        }
    }

    /// A tool no row words yet (a future tool), said without its underscores.
    private static func spokenAct(_ act: String) -> String {
        act.replacingOccurrences(of: "_", with: " ")
    }

    private static func activityPhrase(_ act: String, count n: Int, target: String?, kind: String?) -> String {
        let at = target ?? fallbackNoun(kind)
        let times = n > 1 ? " (\(n) times)" : ""
        switch act {
        case "list_books": return "listed books" + times
        case "list_notes":
            switch kind {
            case "book": return "listed a book\u{2019}s notes" + times
            case "wing": return "listed a wing\u{2019}s notes" + times
            default: return "listed its shared notes" + times
            }
        case "read_note": return "read \(at)" + times
        case "export_note": return "exported \(at)" + times
        case "search": return "searched" + times
        case "add_take": return n == 1 ? "added a take to \(at)" : "added \(n) takes to \(at)"
        case "add_comment": return n == 1 ? "commented in \(at)" : "left \(n) comments in \(at)"
        case "save_lens": return "saved a lens on \(at)" + times
        // U3 ladder round 1, F4: a coalesced CREATION run spans different
        // creations (the log's target is the PLACE, its title the newest
        // creation's), so a count never rides one creation's title — the
        // line speaks the count plainly (J8's copy truth; 13s-a-sweepable).
        // UXR1-1: a creation's title is the CREATION's (the logged kind names
        // its place), so a missing one says the creation plainly.
        case "create_note": return n == 1 ? target.map { "made the note \($0)" } ?? "made a note" : "made \(n) notes"
        case "import_document":
            return n == 1 ? target.map { "imported \($0)" } ?? "imported a document" : "imported \(n) documents"
        case "apply_tag": return "tagged \(at)" + times
        case "create_book": return n == 1 ? target.map { "made the book \($0)" } ?? "made a book" : "made \(n) books"
        case "add_note_to_book": return "added \(at) to a book" + times
        case "create_section": return n == 1 ? "added a chapter to \(at)" : "added \(n) chapters to \(at)"
        case "edit_take": return n == 1 ? "edited \(at)" : "made \(n) edits in \(at)"
        case "divide_block": return "divided a block in \(at)" + times
        case "merge_blocks": return "merged blocks in \(at)" + times
        case "move_block": return "moved a block in \(at)" + times
        case "delete_block": return "deleted a block in \(at)" + times
        case "set_block_name": return "named a block in \(at)" + times
        // 13n-c U6: the wing move (the log's target is the NOTE) and the
        // navigation tool (its target a note, a book or — U6 — a wing).
        case "move_note_to_wing": return n == 1 ? "moved \(at) to another wing" : "moved \(at) between wings" + times
        case "show_in_app": return "showed you \(at)" + times
        // 13n-c UX walk W-UX-13: the five acts this table never worded (they
        // fell to "used save_version").
        case "save_version": return n == 1 ? "saved a version of \(at)" : "saved \(n) versions of \(at)"
        case "file_note_in_chapter": return "filed \(at) in a chapter" + times
        case "set_book_rule": return "set what \(at) collects" + times
        case "put_back": return "put back a block in \(at)" + times
        case "set_entry_date": return "set the date of \(at)" + times
        // VX-168 U2 — the deliberate acts (PROVISIONAL words, her copy pass).
        case "save_commit": return n == 1 ? "committed a take in \(at)" : "made \(n) commits in \(at)"
        case "choose_take": return n == 1 ? "chose a take in \(at)" : "chose \(n) takes in \(at)"
        case "adopt_lens": return "made a lens of \(at) the note" + times
        // VX-184 U3 — VX-173's batch doors: one log row per CALL (the log is
        // coarse — its row carries no item count; the receipt counts them).
        case "add_takes": return "added takes to \(at)" + times
        case "add_comments": return "left comments in \(at)" + times
        case "delete_comment": return n == 1 ? "deleted a comment in \(at)" : "deleted \(n) comments in \(at)"
        case "remove_tag": return "removed a tag from \(at)" + times
        case "link_versions": return "linked \(at) and another note as versions" + times
        // VX-184 U4 — VX-195's edit parity inside a note (PROVISIONAL words,
        // P-U4-WORDS). A block's LAST take deleted is logged on the BLOCK
        // (R-VX184-1 — the block went), so the line says so.
        case "edit_comment": return n == 1 ? "edited a comment in \(at)" : "edited \(n) comments in \(at)"
        case "restore_comment": return n == 1 ? "restored a comment in \(at)" : "restored \(n) comments in \(at)"
        case "delete_take":
            if kind == "block" { return "deleted a block in \(at) (its last take)" + times }
            return n == 1 ? "deleted a take in \(at)" : "deleted \(n) takes in \(at)"
        case "archive_take": return n == 1 ? "archived a take in \(at)" : "archived \(n) takes in \(at)"
        case "unarchive_take": return n == 1 ? "unarchived a take in \(at)" : "unarchived \(n) takes in \(at)"
        case "set_take_label": return n == 1 ? "labeled a take in \(at)" : "labeled \(n) takes in \(at)"
        case "lock_take": return n == 1 ? "locked a take in \(at)" : "locked \(n) takes in \(at)"
        case "unlock_take": return n == 1 ? "unlocked a take in \(at)" : "unlocked \(n) takes in \(at)"
        case "restore_commit": return n == 1 ? "restored a commit in \(at)" : "restored \(n) commits in \(at)"
        case "rename_commit": return n == 1 ? "renamed a commit in \(at)" : "renamed \(n) commits in \(at)"
        case "rename_note": return "renamed a note to \(at)" + times
        case "delete_lens": return n == 1 ? "deleted a lens of \(at)" : "deleted \(n) lenses of \(at)"
        // VX-184 U5 — VX-196's edit parity across the library (PROVISIONAL
        // words, P-U5-WORDS). A renamed book is logged under its NEW name.
        case "rename_book": return "renamed a book to \(at)" + times
        case "finish_book": return "finished \(at)" + times
        case "reopen_book": return "reopened \(at)" + times
        case "archive_book": return "archived \(at)" + times
        case "unarchive_book": return "unarchived \(at)" + times
        case "delete_book": return "deleted \(at)" + times
        case "remove_note_from_book": return "took \(at) out of a book" + times
        case "move_note_in_book": return n == 1 ? "moved a note in \(at)" : "moved \(n) notes in \(at)"
        case "rename_chapter": return n == 1 ? "renamed a chapter of \(at)" : "renamed \(n) chapters of \(at)"
        case "delete_chapter": return n == 1 ? "deleted a chapter of \(at)" : "deleted \(n) chapters of \(at)"
        case "move_chapter": return n == 1 ? "moved a chapter of \(at)" : "moved \(n) chapters of \(at)"
        case "delete_note": return "deleted \(at)" + times
        case "archive_note": return "archived \(at)" + times
        case "unarchive_note": return "unarchived \(at)" + times
        // VX-168: a known name's first setup key, bound as it connected.
        case "connect_bound": return "connected with a new setup, now bound to its name" + times
        // VX-198 (R-VX184-5): the newest copied setup took the name.
        case "connect_rebound": return "connected with a newer setup, which replaced its earlier one" + times
        default: return "used " + spokenAct(act) + times
        }
    }

    // MARK: - Connect a client (R-13nb-5 — "Copy setup command")

    // O-4 SETUP COPY BEGIN — the provider setup (her exclusion, 2026-10-11):
    // the setup menu's own words, the one place outside `MCPSetupClient` a
    // provider is named (`MCPProviderNeutralityTests` reads this fence).
    static let connectSection = "Connect a client"
    /// VX-168: the command now replaces an earlier setup, so it says so (the
    /// re-run her R-VX168-1 relies on). PROVISIONAL words, her copy pass.
    static let connectSentence =
        "Claude Code registers Variorum with one command. Copy it, run it in a terminal, then "
        + "start a new Claude Code session \u{2014} it adds Variorum for every folder (user scope), "
        + "replacing an earlier Variorum setup there."
    /// The name the client registers the server under: the Debug build's is
    /// its own, so a dev setup never replaces the real one in Claude Code's
    /// config (the A4 fence, extended to the client's registration).
    static func serverName(isDebugBuild: Bool) -> String {
        isDebugBuild ? "variorum-dev" : "variorum"
    }

    /// The command (R-13nb-5): user scope (the CLI's default `local` would
    /// register only the folder she ran it in), the shim's absolute path
    /// quoted for a POSIX shell. VX-168 (K2): it carries the copy's fresh
    /// setup KEY as the shim's environment (`-e` after the name — the flag is
    /// variadic; the CLI's own example), and it REPLACES any earlier user-scope
    /// registration first — `claude mcp add` refuses a name that exists
    /// ("already exists in user config", the U1 record's scratch probe), and
    /// her R-VX168-1 promise is that re-running the setup is all it takes.
    static func setupCommand(shimPath: String, isDebugBuild: Bool, key: String = shownKey) -> String {
        let name = serverName(isDebugBuild: isDebugBuild)
        return "claude mcp remove -s user \(name) >/dev/null 2>&1; claude mcp add -s user \(name) "
            + "-e \(MCPPreamble.environmentVariable)=\(key) -- \(shellQuoted(shimPath))"
    }

    static func shellQuoted(_ path: String) -> String {
        var escaped = ""
        for character in path {
            if "\"\\$`".contains(character) { escaped.append("\\") }
            escaped.append(character)
        }
        return "\"\(escaped)\""
    }

    // MARK: - The setup menu (13n-c U5 — VX-274: "Claude Code · Codex · a generic path/JSON shape")

    /// **The one direct line** (VX-274: "the pane says the door is a
    /// standard MCP stdio server at one binary path"), above the menu, with
    /// the path itself under it. Direct and technical (R-13n-5); no "AI"
    /// (VX-272).
    static let stdioLine =
        "Variorum's door is a standard MCP server that speaks over stdio: one program, at this path "
        + "inside the app."

    /// The Codex setup (the U5 record's external fact — `codex mcp add
    /// <name> -- <command>`, which writes the user-global `~/.codex/config.toml`):
    /// the same name rule and the same shell quoting as Claude Code's.
    /// VX-168: `--env KEY=VALUE` before the `--` (the run record's cited
    /// syntax — repeatable, no short form).
    static func codexCommand(shimPath: String, isDebugBuild: Bool, key: String = shownKey) -> String {
        "codex mcp add \(serverName(isDebugBuild: isDebugBuild)) --env \(MCPPreamble.environmentVariable)=\(key) "
            + "-- \(shellQuoted(shimPath))"
    }

    /// **The generic stanza** — the `mcpServers` JSON shape most MCP clients
    /// read (modelcontextprotocol.io's local-server page; Cursor's
    /// `mcp.json`): the absolute path as `command`, no arguments. Written by
    /// hand so it reads as the docs print it (two-space indent, `"key": value`)
    /// and the path is never slash-escaped; `jsonQuoted` makes any path legal
    /// JSON (pinned by parsing it back).
    /// VX-168: the key rides as the stanza's `env` (the sibling of `command`
    /// and `args` in the shape modelcontextprotocol.io and Cursor document).
    static func setupJSON(shimPath: String, isDebugBuild: Bool, key: String = shownKey) -> String {
        let name = jsonQuoted(serverName(isDebugBuild: isDebugBuild))
        return """
            {
              "mcpServers": {
                \(name): {
                  "command": \(jsonQuoted(shimPath)),
                  "args": [],
                  "env": {
                    \(jsonQuoted(MCPPreamble.environmentVariable)): \(jsonQuoted(key))
                  }
                }
              }
            }
            """
    }

    /// A JSON string literal (RFC 8259 §7): the quote, the backslash and the
    /// control characters escaped; everything else as written.
    static func jsonQuoted(_ text: String) -> String {
        var escaped = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\"": escaped += "\\\""
            case "\\": escaped += "\\\\"
            case "\n": escaped += "\\n"
            case "\r": escaped += "\\r"
            case "\t": escaped += "\\t"
            case _ where scalar.value < 0x20:
                escaped += String(format: "\\u%04x", scalar.value)
            default: escaped.unicodeScalars.append(scalar)
            }
        }
        return escaped + "\""
    }

    // O-4 SETUP COPY END

    // MARK: - The "all N" road (R-13n-10)

    static func allRoad(_ count: Int) -> String { "all \(count) \u{203A}" }
    static let doneButton = "Done"

    // MARK: - The grant sheet (mockup §3, the U1 form — A-9)

    static func sheetTitle(_ client: String) -> String { "Grant access \u{2014} \(client)" }
    /// 13n-c U2 — the sheet opened from a place (U3's doors), its client
    /// chosen in WHO.
    static let sheetTitleChoosing = "Grant access"
    /// 13n-c U3: the one title rule — a client named or chosen, and Change…
    /// (VX-270 — the sheet replaces what it was opened on) says so.
    static func sheetTitle(client: String?, changing: Bool) -> String {
        guard changing else { return client.map(sheetTitle) ?? sheetTitleChoosing }
        return client.map { "Change access \u{2014} \($0)" } ?? "Change access"
    }

    /// Change…'s one line under the title (T-U3-8 said where she decides):
    /// the confirm REPLACES what the sheet was opened on.
    static let replacesLine = "Confirming replaces the grant you opened this from."

    // MARK: - Several notes (13n-c U3 — the Library's "Share N notes…"; mockup §2)

    static func theseNotes(_ count: Int) -> String {
        count == 1 ? "This note" : "These \(count) notes"
    }
    /// The pick, named — at most three, then "and N more".
    static func notesList(_ titles: [String]) -> String {
        let named = titles.prefix(3).joined(separator: " \u{00B7} ")
        return titles.count > 3 ? "\(named) and \(titles.count - 3) more" : named
    }
    /// **Why "always" is not offered** when ANY picked note is fenced (mockup
    /// §2, verbatim shape: "Always isn't offered: 1 of these notes is a daily
    /// Journal entry, which is only ever shared one ask at a time.").
    static func alwaysWithheldAmong(_ fences: [MCPGrantRule.Fence]) -> String {
        let count = fences.count
        let journal = fences.allSatisfy { $0 == .journal }
        let privateOnly = fences.allSatisfy { $0 == .privateMark }
        let what: String = switch (count == 1, journal, privateOnly) {
        case (true, true, _): "is a daily Journal entry"
        case (true, _, true): "is marked Private"
        case (false, true, _): "are daily Journal entries"
        case (false, _, true): "are marked Private"
        default: "are Private or daily Journal entries"
        }
        return "Always isn't offered: \(count) of these notes \(what), which "
            + (count == 1 ? "is" : "are") + " only ever shared one ask at a time."
    }
    /// The confirm for several notes: "Grant read on 3 notes while connected"
    /// (mockup §2) — no quotes (the count is not a name), no clause (notes,
    /// not a place that grows).
    static func confirmPartsForNotes(
        verb: String, rung: MCPGrantRule.Rung, count: Int, duration: MCPGrantRule.Duration
    ) -> (lead: String, place: String, tail: String) {
        ("\(verb) \(rungName(rung).lowercased()) on ", count == 1 ? "1 note" : "\(count) notes",
         " \(durationWord(duration))")
    }
    // MARK: - The approval road (13n-c UX walk W-UX-2 — her ruling, sitting
    // round 6: APPROVE ALONE, GRANT SEPARATE). Every word PROVISIONAL, her
    // copy pass.

    /// The approval sheet's title — the request row's Approve… (or a denied
    /// client's).
    static func approvalTitle(_ client: String) -> String { "Approve \(client)" }
    /// Its lead: approving admits with zero reach; a grant is its own act.
    static let approvalLead =
        "Approving lets it connect, and it reaches nothing yet. You can grant it a place below, or "
        + "later with Change\u{2026} on its row."
    /// WHERE's first answer on the approval road — and the one it starts on.
    static let nothingYet = "Nothing yet"
    /// The line under WHERE when nothing is picked — honest about the open
    /// book (lesson 3: it lets every approved client read everything).
    static func approveAloneDetail(openBook: Bool) -> String {
        openBook
            ? "The open book is on, so once approved it can read everything except what always asks."
            : "Approved, it reaches nothing until you grant it something."
    }
    /// The confirm with nothing picked: the approval alone.
    static func approveAlone(_ client: String) -> String { "Approve \(client)" }
    /// The confirm's verb when a grant rides the approval ("Approve and grant
    /// read in “X” once").
    static let approveAndGrantVerb = "Approve and grant"

    static let sheetLead =
        "The client sees what you grant and nothing else. Refusals speak to it exactly as they "
        + "speak to you."
    static let whereSection = "Where"
    static let howMuchSection = "How much"
    static let howLongSection = "How long"
    /// 13n-c U2 — WHO (mockup §1/§2): shown whenever the sheet's opener did
    /// not name a client.
    static let whoSection = "Who"
    static let noApprovedClient =
        "No client is approved yet \u{2014} approve a connection request first."
    static let aNote = "A note"
    static let aBook = "A book"
    static func aBookDetail(_ name: String?) -> String {
        name.map { "\u{201C}\($0)\u{201D} \u{2014} its notes, takes and tags" } ?? "choose a book"
    }
    static let thisWing = "A wing"
    /// 13n-c U1 (VX-163, J8 — mockup §8's words): a journal-style book is
    /// in the wing like any book; only the daily Journal and anything
    /// Private ask.
    static func wingDetail(_ name: String) -> String {
        "everything in \(name) except your daily Journal and anything Private, which always ask"
    }
    /// 13n-c UX walk W-UX-19 — Change… on a grant whose book is fenced since:
    /// the book is not offered (no grant reaches it now). PROVISIONAL.
    static let prefilledBookNotOffered =
        "That book is your daily Journal or marked Private now, so no grant reaches it \u{2014} "
        + "choose another book, or Revoke the grant."
    static let noBooks =
        "No book can be shared yet (your daily Journal and Private books are shared one ask at a time)."

    // MARK: - The pickers (13n-c U2 — VX-156 items 1 + 6; mockup §1)

    static let bookPrompt = "Find a book"
    static let notePrompt = "Find a note"
    static let wingPrompt = "Find a wing"
    static let clientPrompt = "Find a client"
    static let chooseBook = "Choose a book"
    static let chooseNote = "Choose a note"
    static let chooseClient = "Choose a client"
    static let noNotes = "No notes in this wing yet."
    /// The picker's foot line (mockup §1, verbatim): why some books are
    /// never in the list.
    static let fencedBooksNote =
        "Your daily Journal and Private books aren't listed \u{2014} they're shared one ask at a time."
    /// The sections (her kickoff: "sort by shelf … favorites"; round 2:
    /// "recently edited … that's often what I want").
    static let recentlyEdited = "Recently edited"
    static let starred = "Starred"
    static let unshelved = "Unshelved"
    /// The a–z layout's one list (its header — without one it read as
    /// Starred's continuation in the U2 capture).
    static let allBooks = "All books"
    /// A shelf section in a wing other than Home names its wing first.
    static func shelfSection(_ shelf: String, glyph: String?, wing: String?) -> String {
        let name = [glyph, shelf].compactMap { $0 }.joined(separator: " ")
        return wing.map { "\($0) \u{00B7} \(name)" } ?? name
    }
    static func unshelvedSection(wing: String?) -> String {
        wing.map { "\($0) \u{00B7} unshelved" } ?? unshelved
    }
    /// The picker's two layouts (PROVISIONAL P-13nc-U2-3).
    static let byShelf = "by shelf"
    static let alphabetical = "a\u{2013}z"
    /// A note row's fence word (the mockup §1 note leg's "daily Journal entry").
    static func noteFenceWord(_ fence: MCPGrantRule.Fence) -> String {
        switch fence {
        case .journal: "daily Journal entry"
        case .privateMark: "Private"
        }
    }
    /// The note leg's wing row, when the library has more than one wing.
    static let noteWingLabel = "Notes in"
    static func aNoteDetail(_ title: String?) -> String {
        title.map { "\u{201C}\($0)\u{201D} \u{2014} its takes, comments and tags" } ?? "choose a note"
    }
    /// **Why "always" is not offered** (mockup §1's note leg, verbatim shape):
    /// a fenced note is only ever shared one ask at a time.
    /// 13n-c +4b (her ruling, sitting round 5 — "…is in “diary”, which is
    /// marked Private… The book's mark is changed in its Book Settings."): when
    /// the note's Private mark comes through Private BOOKS (`throughBooks` —
    /// the lock popover's own read, display-only; empty when the note wears
    /// its own mark), the why names the book and says where the mark is
    /// changed. The own-mark and daily-Journal sentences are untouched.
    /// PROVISIONAL words, her copy pass.
    static func alwaysWithheld(
        _ title: String, _ fence: MCPGrantRule.Fence, throughBooks: [String] = []
    ) -> String {
        switch fence {
        case .journal:
            return "\u{201C}\(title)\u{201D} is a daily Journal entry \u{2014} it's only ever shared one ask at "
                + "a time, so always isn't offered."
        case .privateMark where !throughBooks.isEmpty:
            let quoted = throughBooks.prefix(2).map { "\u{201C}\($0)\u{201D}" }
            let names = throughBooks.count > 2
                ? quoted.joined(separator: ", ") + " and \(throughBooks.count - 2) more"
                : quoted.joined(separator: " and ")
            let are = throughBooks.count == 1 ? "is" : "are"
            return "\u{201C}\(title)\u{201D} is in \(names), which \(are) marked Private \u{2014} it's only "
                + "ever shared one ask at a time, so always isn't offered. "
                + (throughBooks.count == 1 ? "The book's" : "A book's") + " mark is changed in its Book Settings."
        case .privateMark:
            return "\u{201C}\(title)\u{201D} is marked Private \u{2014} it's only ever shared one ask at a "
                + "time, so always isn't offered."
        }
    }
    /// HOW MUCH — the rungs the server can serve, each with the mockup §3
    /// sentence (U2: read · suggest · write new; U3: edit, now that the
    /// server serves it — a rung it couldn't serve was never offered, P-2).
    static let offeredRungs: [MCPGrantRule.Rung] = [.read, .suggest, .writeNew, .edit]

    static func rungName(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "Read"
        case .suggest: "Suggest"
        case .writeNew: "Write new"
        case .edit: "Edit"
        }
    }

    /// The mockup §3 sentences, verbatim — and, 13n-c UX walk W-UX-14, the
    /// write-new sentence said for the SCOPE a grant names (nil and a wing:
    /// the mockup's words): a book grant can never build a book
    /// (`create_book` is wing-only) and a note grant makes no new notes, so
    /// those claims are left out where they could never be true (the truth
    /// pin reads `MCPToolFacts`). PROVISIONAL words, her copy pass.
    ///
    /// VX-184 ladder round 2 (doc-truth) — EDIT: mockup §3's "it can also
    /// edit takes — with a commit before and after every change" stopped
    /// being true when U4/U5 grew the rung: it also deletes notes, books,
    /// chapters, takes and blocks, archives and finishes books, rewrites her
    /// comments and renames — and only a take's rewrite (`edit_take`,
    /// `restore_commit`) keeps commits around the change (its "before"
    /// skipped when the take's latest commit already holds those words, so
    /// the words are still kept). The clause names no act a NOTE grant
    /// can't do ("what you shared" holds at every scope — W-UX-14's rule).
    /// It is also the ask sheet's lead for an edit ask (`MCPAskCopy.lead`).
    /// As built, VX-234's to re-voice.
    static func rungDetail(_ rung: MCPGrantRule.Rung, scope: MCPGrantRule.ScopeKind? = nil) -> String {
        switch rung {
        case .read: "it can read and search what you shared"
        case .suggest:
            "it can add new takes and comments beside your text, and save a lens of its takes "
                + "\u{2014} it cannot touch a word you wrote"
        case .writeNew:
            switch scope {
            case .note?: "it can also apply tags and save versions of it"
            case .book?: "it can also make new notes and chapters in it and apply tags"
            case .wing?, nil: "it can also make new notes, apply tags and build books"
            }
        case .edit:
            "it can also change, archive and delete what you shared, your own words included \u{2014} "
                + "when it rewrites a take, the take's words before and after are kept as commits, so you "
                + "can always compare and come back"
        }
    }

    static let readRung = "Read"
    static let readRungDetail = rungDetail(.read)
    static let cancel = "Cancel"
    /// Why the bounded duration is missing (the client is not connected now).
    static let whileConnectedNote =
        "\u{201C}Until it disconnects\u{201D} is offered while this client is connected."

    /// "Grant suggest in “the lightning thief” while connected" (mockup §3) —
    /// and, since 13n-c's VX-269, the clause that says membership is LIVE:
    /// her sentence, *"Grant read in “dream journal” always, including to
    /// future entries."*, on EVERY book grant ("notes added later become
    /// visible"); D-3 (PROVISIONAL P-13nc-3) gives a wing grant the parallel
    /// clause and keeps both on every duration (a once or while-connected
    /// grant's reach grows the same way while it lives). A note grant names
    /// one note — no clause. The `scope` is required so no grant door can
    /// forget it. A button label, so no closing period (PROVISIONAL
    /// P-13nc-U1-1 — her sentence carries one).
    static func confirm(
        verb: String, rung: MCPGrantRule.Rung = .read, scope: MCPGrantRule.ScopeKind, place: String,
        distinguisher: String? = nil, duration: MCPGrantRule.Duration
    ) -> String {
        let parts = confirmParts(
            verb: verb, rung: rung, scope: scope, place: place, distinguisher: distinguisher,
            duration: duration)
        return parts.lead + parts.place + parts.tail
    }

    /// The confirm in its three parts, so the sheet can let ONLY the place
    /// compress (13n-c U1, the geometry oracle in the U1 record: a voiced
    /// button is one line and tail-truncates, which in Terminal's mono cut
    /// VX-269's clause off — the very words the ruling exists for). The verb,
    /// rung, duration and clause never truncate; the place, shown whole in
    /// WHERE just above, takes what room is left.
    ///
    /// 13n-c U2: the place wears its DISTINGUISHER after its closing quote
    /// (`PlaceLabels` — "“the adventures of sherlock holmes” (made Oct 9)"),
    /// in the tail, so it never compresses away — it is the very fact that
    /// names the right book; and a NOTE grant reads "on" (the VX-156 mockup
    /// §1's "Grant read on “morning pages — oct 9” once").
    static func confirmParts(
        verb: String, rung: MCPGrantRule.Rung = .read, scope: MCPGrantRule.ScopeKind, place: String,
        distinguisher: String? = nil, duration: MCPGrantRule.Duration
    ) -> (lead: String, place: String, tail: String) {
        let preposition = scope == .note ? "on" : "in"
        let distinct = distinguisher.map { $0.isEmpty ? "" : " (\($0))" } ?? ""
        return ("\(verb) \(rungName(rung).lowercased()) \(preposition) \u{201C}", place,
                "\u{201D}\(distinct) \(durationWord(duration))" + liveReachClause(scope))
    }

    /// The confirm's TWO-LINE form (13n-c U2 — the row's final design, the
    /// geometry oracle in the U2 record): when one line cannot hold the whole
    /// sentence (in Terminal's mono even her own example with a day
    /// distinguisher is 554 pt against 489 pt of room), the label takes two
    /// lines, and a place longer than this many characters is middle-
    /// shortened so the verb, rung, distinguisher, duration and clause always
    /// read whole. The place shows whole in WHERE just above.
    static let confirmPlaceLimit = 40

    static func shortPlace(_ place: String) -> String {
        guard place.count > confirmPlaceLimit else { return place }
        let keep = confirmPlaceLimit - 1
        let head = place.prefix((keep + 1) / 2)
        let tail = place.suffix(keep / 2)
        return "\(head)\u{2026}\(tail)"
    }

    /// VX-269's clause (book) and D-3's twin (wing), with its leading comma.
    static func liveReachClause(_ scope: MCPGrantRule.ScopeKind) -> String {
        switch scope {
        case .book: ", including to future entries"
        case .wing: ", including notes added later"
        case .note: ""
        }
    }

    // MARK: - Refusals in the pane (the operations layer's own errors)

    static func refusal(_ error: Error) -> String {
        switch error as? OperationError {
        case .mcpClientNotApproved?: "Approve the client before granting it access."
        case .mcpGrantScopeFenced?:
            // 13n-c U1 (VX-163, J8 — mockup §8's words).
            "Your daily Journal and Private notes are shared one ask at a time, never by a standing grant."
        case .mcpGrantScopeNotFound?: "That place no longer exists."
        case .mcpClientNotFound?: "That client no longer exists."
        case .mcpGrantNotFound?: "That grant no longer exists."
        // VX-258 (VX-246 U1b): her Allow / Don't allow on a setup no longer
        // waiting — answered elsewhere, its client denied, a library adopted.
        // PROVISIONAL words (VX-234).
        case .mcpRebindRequestNotFound?: "That setup isn't waiting any more."
        default: "Couldn't do that: \(error)"
        }
    }
}

/// **THE SETUP MENU's clients** (13n-c U5 — VX-274, the sitting record round 3:
/// "Claude Code · Codex · a generic path/JSON shape"). ONE table: the menu's
/// order, each client's label, its text (the command or the stanza), the
/// sentence that says how to use it, and the receipt its copy speaks. The ONE
/// declared act (`.mcpCopySetupCommand`, her R-13nb-5 words) copies whichever
/// is chosen — choosing is the pane's view state, never a second act.
nonisolated enum MCPSetupClient: String, CaseIterable, Identifiable, Sendable {
    // O-4 SETUP COPY BEGIN — the setup menu's clients, named (her exclusion).
    case claudeCode, codex, anyClient

    var id: String { rawValue }

    var label: String {
        switch self {
        case .claudeCode: "Claude Code"
        case .codex: "Codex"
        case .anyClient: "Any MCP client"
        }
    }

    /// **VX-258 — the name this tab's client declares in its `initialize`**
    /// (`clientInfo.name`). A copy from this tab mints a key CARRYING it
    /// (`MCPDoor.copySetupCommand` → `mintMCPSetupKey(copiedFor:)`), so the
    /// client's OWN setup, run again, takes its name with zero clicks; "Any
    /// MCP client" names nobody, and its copy takes a name she approved only
    /// by her OK (Waiting). Claude Code's: seen live (VX-184 U1's round,
    /// 2.1.296; re-read at VX-246 U1b's window, leg 0). Codex's: an EXTERNAL
    /// LOOKUP of its source, never seen live (Codex is not installed on the
    /// Pro) — `codex-rs/codex-mcp/src/rmcp_client.rs`,
    /// `Implementation::new("codex-mcp-client", …)` (the VX-246 record, U1's
    /// trace item 6). A client whose real name differs connects as a request
    /// (an unknown name) or waits for her OK (a known one) — never refused.
    var expectedName: String? {
        switch self {
        case .claudeCode: "claude-code"
        case .codex: "codex-mcp-client"
        case .anyClient: nil
        }
    }

    /// What the chosen client's copy puts on the clipboard (and the pane
    /// shows verbatim): Claude Code's command unchanged, Codex's command, or
    /// the generic `mcpServers` stanza. Debug keeps `variorum-dev`
    /// (P-13nb-U1-10) in all three.
    /// VX-168 (K2): `key` is the copy's fresh setup key; the pane SHOWS the
    /// text with `MCPPaneCopy.shownKey` in its place (a key is minted only by
    /// the copy act, and never shown — the clipboard is its one road out).
    func text(shimPath: String, isDebugBuild: Bool, key: String = MCPPaneCopy.shownKey) -> String {
        switch self {
        case .claudeCode: MCPPaneCopy.setupCommand(shimPath: shimPath, isDebugBuild: isDebugBuild, key: key)
        case .codex: MCPPaneCopy.codexCommand(shimPath: shimPath, isDebugBuild: isDebugBuild, key: key)
        case .anyClient: MCPPaneCopy.setupJSON(shimPath: shimPath, isDebugBuild: isDebugBuild, key: key)
        }
    }

    /// How to use it — one sentence each (Claude Code's is 13n-b's, unchanged).
    var sentence: String {
        switch self {
        case .claudeCode: MCPPaneCopy.connectSentence
        case .codex:
            "Codex registers Variorum with one command. Copy it, run it in a terminal, then start a new "
                + "Codex session \u{2014} it adds Variorum for every folder (in ~/.codex/config.toml)."
        // VX-168: a client given only the path would run the shim with no
        // key — refused — so the sentence names the variable it also needs.
        // VX-281 U1: the path now sits BELOW the code block (the setup comes
        // first — R-VX184-6), so "the path above" became "the path below".
        case .anyClient:
            "Most MCP clients read their servers from an \u{201C}mcpServers\u{201D} list in JSON. Paste "
                + "this into your client's MCP settings and restart it \u{2014} or give a client that "
                + "asks for a command the path below, with the environment variable this sets."
        }
    }

    /// VX-281 U1 (R-VX184-6): the sentence above cut to ONE line under the
    /// code block — the whole sentence behind its (i). PROVISIONAL words
    /// (VX-234), the receipts' own next steps.
    var summary: String {
        switch self {
        case .claudeCode: "Run it in a terminal, then start a new Claude Code session."
        case .codex: "Run it in a terminal, then start a new Codex session."
        case .anyClient: "Paste it into your client's MCP settings, then restart the client."
        }
    }

    /// The copy's receipt: the client's one-line next step (`summary`) with
    /// "Copied." in front — VX-281 ladder R1-8: one sentence, one constant
    /// (they were two, word for word; the strings are byte-identical). That
    /// a copy then says the next step on two adjacent lines is hers to word
    /// (FOR VX-234).
    var copiedReceipt: String { "Copied. " + summary }
    // O-4 SETUP COPY END
}

/// **THE JUST-IN-TIME ASK's words** (13n-b U2 — AF-6; mockup §4). The MCP
/// room's register (direct and technical — R-13n-5; P-13n-1's boundary keeps
/// the grant and ask sheets inside it); sentence case.
nonisolated enum MCPAskCopy {
    /// "claude-code asks to read “morning pages — oct 9”". 13n-c U2: a book
    /// (or wing) that shares its name with another offered place wears its
    /// distinguisher (`PlaceLabels`, the one rule — mockup §1b's "claude-code
    /// asks to suggest in “the adventures of sherlock holmes” (made 11 Oct)").
    static func title(_ ask: MCPAsk, distinguisher: String? = nil) -> String {
        let verb: String = switch ask.rung {
        case .read: "read"
        case .suggest: "suggest in"
        case .writeNew: "write new in"
        case .edit: "edit in"
        }
        let distinct = distinguisher.map { $0.isEmpty ? "" : " (\($0))" } ?? ""
        let target = ask.scopeKind == .wing
            ? "the \(ask.title) wing\(distinct)" : "\u{201C}\(ask.title)\u{201D}\(distinct)"
        return "\(ask.clientName) asks to \(verb) \(target)"
    }

    /// **13n-c U4 — the pending-ask glyph's hover where it sits ON the target**
    /// (mockup §4's "claude-code asks to suggest here"): the place is the row
    /// it is on, so the sentence says "here".
    static func here(_ ask: MCPAsk) -> String {
        let verb: String = switch ask.rung {
        case .read: "read"
        case .suggest: "suggest"
        case .writeNew: "write new"
        case .edit: "edit"
        }
        return "\(ask.clientName) asks to \(verb) here"
    }

    /// **VX-269 on the ask road** (13n-c U2 — the U1 ladder's F2: every
    /// book grant says its live reach, and an answer here MINTS one): her
    /// clause under a BOOK ask, D-3's twin under a WING ask, nothing for a
    /// note (one note). Every duration carries it (P-13nc-3) — so one line
    /// above the buttons, never a word per button. PROVISIONAL wording
    /// (P-13nc-U2-4), her copy pass. 13n-c Stage B R1 B9: "Any answer below"
    /// was false for Don't allow (it grants nothing) — the line names the
    /// answers that DO grant ("Allowing"), the minimal truth fix; the voice
    /// stays her copy pass.
    static func reachLine(_ ask: MCPAsk, distinguisher: String? = nil) -> String? {
        switch ask.scopeKind {
        case .note: nil
        case .book:
            // Stage B R1 B2: a book a fence covers NOW takes no grant at all —
            // the lead says why, and nothing here can grant it.
            ask.fence != nil ? nil
                : "Allowing grants it in \(PlaceLabels.quoted(ask.title, distinguisher: distinguisher)), "
                    + "including to future entries."
        case .wing: "Allowing grants it in the \(ask.title) wing, including notes added later."
        }
    }

    /// The sentence under it: the fence's reason (mockup §4's journal line,
    /// re-keyed by 13n-c's VX-163 to THE daily Journal — VX-156 mockup §8's
    /// words; the Private twin), else what the rung would let it do.
    ///
    /// 13n-c Stage B R1 B2: a BOOK ask arrives only on an unfenced book (a
    /// fenced book never raises one), so a book that wears a fence when she
    /// opens the ask was fenced SINCE — read on current facts, it says so
    /// honestly: no grant can reach it, and Don't allow lets the ask go.
    static func lead(_ ask: MCPAsk) -> String {
        switch (ask.scopeKind, ask.fence) {
        case (.book, .journal?):
            "This book is your daily Journal now, which no grant reaches \u{2014} its entries are shared "
                + "one ask at a time. \(dontAllow) lets this ask go."
        case (.book, .privateMark?):
            "This book is marked Private now, which no grant reaches \u{2014} its notes are shared "
                + "one ask at a time. \(dontAllow) lets this ask go."
        case (_, .journal?): "A daily Journal entry. Your daily Journal is only ever shared one ask at a time."
        case (_, .privateMark?): "Marked Private. Private notes are only ever shared one ask at a time."
        // 13n-c UX walk W-UX-14: what THIS scope's grant allows, never more.
        case (_, nil): "If you allow it, " + MCPPaneCopy.rungDetail(ask.rung, scope: ask.scopeKind) + "."
        }
    }

    static func button(_ duration: MCPGrantRule.Duration) -> String {
        switch duration {
        case .once: "Once"
        // 13n-c U4 (P-13nc-U4-1): the duration's one word, capitalized.
        case .connection: MCPPaneCopy.untilDisconnects.capitalizedFirst
        case .always: "Always"
        }
    }

    static let dontAllow = "Don't allow"

    /// **13n-c Stage B R2-1 (a) — the ask whose place is gone:** her press
    /// opened a sheet that closed (the note or book deleted, the book now a
    /// gathering, the wing deleted), so it says why, naming the place — a
    /// refusal. PROVISIONAL (P-13nc-SB-5), her copy pass.
    static func gone(_ ask: MCPAsk) -> String {
        let place = ask.scopeKind == .wing ? "The \(ask.title) wing" : "\u{201C}\(ask.title)\u{201D}"
        return "\(place) is gone, so \(ask.clientName)'s ask was let go."
    }

    /// The receipt once her answer lands.
    /// 13n-c UX walk W-UX-15 (T-11): a NOTE grant reads "on", as the grant
    /// sheet's confirm says it ("Grant read on “…”"); a book or wing "in".
    static func granted(_ ask: MCPAsk, duration: MCPGrantRule.Duration) -> String {
        let preposition = ask.scopeKind == .note ? "on" : "in"
        return "Allowed \(ask.clientName): \(MCPPaneCopy.rungName(ask.rung).lowercased()) \(preposition) "
            + "\u{201C}\(ask.title)\u{201D} \(MCPPaneCopy.durationWord(duration))."
    }
}

/// **AN AI ACT's RECEIPT** (13n-b U2 — the mockup §5 line: "claude added 2
/// takes and saved the lens “english readings” · ⌥⌘Z undoes"). An APP-WIDE
/// face, so the app's voice (P-13n-1), sentence case; the client's own name
/// verbatim. A RUN of acts by one client on one target speaks as one line.
nonisolated enum MCPReceiptCopy {
    static let undoes = "\u{2325}\u{2318}Z undoes"
    /// 13n-b U4 (R-13nb-23 (a)): the receipt's one-press door — her "… —
    /// Open ›". App voice (P-13n-1), 13s-a sweepable.
    static let openDoor = "Open \u{203A}"

    static func line(_ run: [MCPWriteReceipt]) -> String {
        guard let first = run.first else { return "" }
        var order: [Operations.MCPWriteAct] = []
        var byAct: [Operations.MCPWriteAct: [MCPWriteReceipt]] = [:]
        for receipt in run {
            if byAct[receipt.act] == nil { order.append(receipt.act) }
            byAct[receipt.act, default: []].append(receipt)
        }
        let parts = order.map { phrase($0, byAct[$0] ?? []) }
        // VX-168 U2: "⌥⌘Z undoes" is said only over a run holding an act ⌥⌘Z
        // walks back — a client's COMMIT is append-only, exactly as hers (no
        // undo entry), so a run of commits alone says what landed and stops.
        let tail = run.contains { $0.act.isUndoable } ? " \u{00B7} \(undoes)" : ""
        // U2 walk W-2: the mockup's line, no "in “title”" clause, and never
        // so long that the bar's truncation eats the undo — past the budget
        // the run speaks as a count.
        let line = "\(first.clientName) \(joined(parts))\(tail)"
        guard line.count > budget else { return line }
        // 13n-c U6: ONE wing move keeps what it must say — where the note went
        // and the books it left — dropping only the note's title (Open › opens
        // it) before the count fallback below.
        if run.count == 1, first.act == .wingMove {
            let short = "\(first.clientName) \(wingMovePhrase(first, titled: false))\(tail)"
            if short.count <= budget { return short }
        }
        // VX-184 U5 (found by the faces pin at the stage window, red first): ONE
        // owned book's delete keeps WHERE ITS NOTES WENT — her "Delete Book
        // Only" receipt's point — dropping only the book's name (it is in the
        // Trash; Open › has nowhere to go) before the count fallback.
        if run.count == 1, first.act == .bookDelete, let whereNotesWent = first.detail {
            let short = "\(first.clientName) deleted a book \u{2014} \(whereNotesWent)\(tail)"
            if short.count <= budget { return short }
        }
        // 13n-c U6, D-U6-1 (red-on-old): ONE act is "a change", never "1 changes".
        let made = run.count == 1 ? "made a change" : "made \(run.count) changes"
        return "\(first.clientName) \(made)\(tail)"
    }

    /// One wing move, as her door's receipt says it (`WingCopy.moved`): the
    /// note (or "a note"), where it went — Home unquoted — and the books it
    /// left.
    private static func wingMovePhrase(_ receipt: MCPWriteReceipt, titled: Bool) -> String {
        let note = titled ? receipt.detail.map { "\u{201C}\($0)\u{201D}" } ?? "a note" : "a note"
        let left = receipt.leftBooks ?? 0
        return "moved \(note) to \(wingWords(receipt))"
            + (left == 0 ? "" : " \u{2014} it left \(left) book\(left == 1 ? "" : "s")")
    }

    private static func wingWords(_ receipt: MCPWriteReceipt) -> String {
        receipt.targetID == "" ? "Home" : "\u{201C}\(receipt.targetTitle ?? "")\u{201D}"
    }

    /// The longest line the bottom bar's quiet slot shows whole at the
    /// default window width (measured at the U2 walk — W-2).
    static let budget = 72

    private static func phrase(_ act: Operations.MCPWriteAct, _ receipts: [MCPWriteReceipt]) -> String {
        let n = receipts.count
        let quoted = { (text: String?) in text.map { "\u{201C}\($0)\u{201D}" } ?? "" }
        switch act {
        case .take: return n == 1 ? "added a take" : "added \(n) takes"
        case .comment: return n == 1 ? "left a comment" : "left \(n) comments"
        case .lens: return n == 1 ? "saved the lens \(quoted(receipts[0].detail))" : "saved \(n) lenses"
        case .tag: return n == 1 ? "added the tag #\(receipts[0].detail ?? "")" : "added \(n) tags"
        case .note: return n == 1 ? "made the note \(quoted(receipts[0].targetTitle))" : "made \(n) notes"
        case .importNote: return n == 1 ? "imported \(quoted(receipts[0].targetTitle))" : "imported \(n) notes"
        case .importBook:
            let notes = receipts[0].count
            return "imported the book \(quoted(receipts[0].targetTitle)) (\(notes) \(notes == 1 ? "note" : "notes"))"
        case .book: return "made the book \(quoted(receipts[0].targetTitle))"
        case .bookAdd:
            return n == 1
                ? "added \(quoted(receipts[0].targetTitle)) to \(quoted(receipts[0].detail))"
                : "added \(n) notes to books"
        // 13n-b U3 — the chapter (write new) and the edit rung's acts.
        case .chapter:
            return n == 1 ? "made the chapter \(quoted(receipts[0].detail))" : "made \(n) chapters"
        case .edit: return n == 1 ? "edited a take" : "edited \(n) takes"
        case .divide: return n == 1 ? "divided a block" : "divided \(n) blocks"
        case .merge: return n == 1 ? "merged two blocks" : "merged blocks \(n) times"
        case .move: return n == 1 ? "moved a block" : "moved \(n) blocks"
        // VX-184 U4 (R-VX184-1): a block's LAST take deleted IS the block —
        // `delete_block`'s act, its detail saying why.
        case .delete:
            return n == 1 ? receipts[0].detail.map { "deleted a block (\($0))" } ?? "deleted a block"
                : "deleted \(n) blocks"
        case .blockName:
            return n == 1
                ? (receipts[0].detail.map { "named a block \(quoted($0))" } ?? "cleared a block's name")
                : "named \(n) blocks"
        // 13n-b U4 — the carriage's acts (P-13nb-U4-2's words, 13s-a sweepable).
        case .putBack: return n == 1 ? "put back \(receipts[0].detail ?? "a block")" : "put back \(n) things"
        case .version: return n == 1 ? "saved a version" : "saved \(n) versions"
        case .entryDate:
            return n == 1
                ? (receipts[0].detail.map { "dated the note \($0)" } ?? "cleared the note's date")
                : "changed \(n) dates"
        case .filing:
            return n == 1
                ? (receipts[0].detail.map { "filed a note under \(quoted($0))" } ?? "unfiled a note")
                : "filed \(n) notes"
        case .bookRule:
            return n == 1 ? "changed what \(quoted(receipts[0].targetTitle)) collects" : "changed \(n) books' rules"
        // 13n-c U6 — a note moved to another wing (her door's receipt's
        // words, `WingCopy.moved`; the run is keyed on the DESTINATION, so a
        // sweep's moves to one wing read as one line — the brief §10).
        case .wingMove:
            return n == 1 ? wingMovePhrase(receipts[0], titled: true)
                : "moved \(n) notes to \(wingWords(receipts[0]))"
        // VX-168 U2 — the deliberate acts (P-13nb-U2-5's family, PROVISIONAL
        // words, 13s-a sweepable): VX-169's commit, VX-174's merge button —
        // her "✓ Make this the note" said back in her door's words.
        case .commit: return n == 1 ? "committed a take" : "made \(n) commits"
        case .choice: return n == 1 ? "chose a take" : "chose \(n) takes"
        case .lensAdoption:
            return n == 1 ? "made the lens \(quoted(receipts[0].detail)) the note" : "adopted \(n) lenses"
        // VX-184 U3 — VX-173's batch doors: a batch's receipt counts its
        // ITEMS (`count`), and a run of batches sums them (PROVISIONAL words).
        case .takes:
            let total = receipts.reduce(0) { $0 + $1.count }
            return total == 1 ? "added a take" : "added \(total) takes"
        case .comments:
            let total = receipts.reduce(0) { $0 + $1.count }
            return total == 1 ? "left a comment" : "left \(total) comments"
        // VX-188 — the client's own comment, deleted (PROVISIONAL words).
        case .commentDelete: return n == 1 ? "deleted a comment" : "deleted \(n) comments"
        // VX-190 — her un-tag, the client's (PROVISIONAL words).
        case .untag: return n == 1 ? "removed the tag #\(receipts[0].detail ?? "")" : "removed \(n) tags"
        // VX-187 — two notes made versions (PROVISIONAL words).
        case .versionLink:
            return n == 1
                ? "linked \(quoted(receipts[0].targetTitle)) and \(quoted(receipts[0].detail)) as versions"
                : "linked \(n) pairs of notes as versions"
        // VX-184 U4 — VX-195's edit parity inside a note (PROVISIONAL words,
        // P-U4-WORDS — her copy pass).
        case .commentEdit: return n == 1 ? "edited a comment" : "edited \(n) comments"
        case .commentRestore: return n == 1 ? "restored a comment" : "restored \(n) comments"
        case .takeDelete: return n == 1 ? "deleted a take" : "deleted \(n) takes"
        case .takeArchive: return n == 1 ? "archived a take" : "archived \(n) takes"
        case .takeUnarchive: return n == 1 ? "unarchived a take" : "unarchived \(n) takes"
        case .takeLabel:
            return n == 1
                ? (receipts[0].detail.map { "labeled a take \(quoted($0))" } ?? "cleared a take's label")
                : "labeled \(n) takes"
        case .takeLock: return n == 1 ? "locked a take" : "locked \(n) takes"
        case .takeUnlock: return n == 1 ? "unlocked a take" : "unlocked \(n) takes"
        case .commitRestore: return n == 1 ? "restored a commit" : "restored \(n) commits"
        case .commitRename:
            return n == 1
                ? (receipts[0].detail.map { "renamed a commit \(quoted($0))" } ?? "cleared a commit's name")
                : "renamed \(n) commits"
        case .noteTitle:
            return n == 1
                ? (receipts[0].detail.map { "renamed the note \(quoted($0))" } ?? "cleared the note's title")
                : "renamed \(n) notes"
        case .lensDelete:
            return n == 1 ? "deleted the lens \(quoted(receipts[0].detail))" : "deleted \(n) lenses"
        // VX-184 U5 — VX-196's edit parity across the library (PROVISIONAL
        // words, P-U5-WORDS — her copy pass). A book act's target is the BOOK
        // (its name); a membership act's the NOTE, its detail the book; a
        // chapter act's detail the chapter's name.
        case .bookName:
            return n == 1 ? "renamed the book \(quoted(receipts[0].detail))" : "renamed \(n) books"
        case .bookFinish: return n == 1 ? "finished \(quoted(receipts[0].targetTitle))" : "finished \(n) books"
        case .bookReopen: return n == 1 ? "reopened \(quoted(receipts[0].targetTitle))" : "reopened \(n) books"
        case .bookArchive: return n == 1 ? "archived \(quoted(receipts[0].targetTitle))" : "archived \(n) books"
        case .bookUnarchive:
            return n == 1 ? "unarchived \(quoted(receipts[0].targetTitle))" : "unarchived \(n) books"
        case .bookDelete:
            guard n == 1 else { return "deleted \(n) books" }
            // Her "Delete Book Only" on an OWNED book says where the notes went.
            return "deleted the book \(quoted(receipts[0].targetTitle))"
                + (receipts[0].detail.map { " \u{2014} \($0)" } ?? "")
        case .bookRemove:
            return n == 1
                ? "took \(quoted(receipts[0].targetTitle)) out of \(quoted(receipts[0].detail))"
                : "took \(n) notes out of books"
        case .bookRelease:
            return n == 1
                ? "released \(quoted(receipts[0].targetTitle)) from \(quoted(receipts[0].detail))"
                : "released \(n) notes from books"
        case .bookOrder:
            return n == 1 ? "moved a note in \(quoted(receipts[0].targetTitle))"
                : "moved \(n) notes in \(quoted(receipts[0].targetTitle))"
        case .chapterName:
            return n == 1 ? "renamed a chapter \(quoted(receipts[0].detail))" : "renamed \(n) chapters"
        case .chapterDelete:
            return n == 1 ? "deleted the chapter \(quoted(receipts[0].detail))" : "deleted \(n) chapters"
        case .chapterMove:
            return n == 1 ? "moved the chapter \(quoted(receipts[0].detail))" : "moved \(n) chapters"
        case .noteDelete:
            return n == 1 ? "deleted \(quoted(receipts[0].targetTitle)) (it's in the Trash)" : "deleted \(n) notes"
        case .noteArchive: return n == 1 ? "archived \(quoted(receipts[0].targetTitle))" : "archived \(n) notes"
        case .noteUnarchive:
            return n == 1 ? "unarchived \(quoted(receipts[0].targetTitle))" : "unarchived \(n) notes"
        }
    }

    /// 13n-c U6 (VX-158 — mockup §7): an agent's `show_in_app` to a WING, said
    /// as the wing switcher's "Now in …" with who moved her. Home is a
    /// place-name, never quoted (`WingFollow.nowIn`'s rule). A receipt (her
    /// receipt style governs it). 13s-a sweepable.
    static func shownWing(_ wingName: String, isHome: Bool, client: String) -> String {
        let wing = isHome ? "Home" : "\u{201C}\(wingName)\u{201D}"
        return "Now in \(wing) \u{2014} \(client) showed you this wing."
    }

    private static func joined(_ parts: [String]) -> String {
        guard parts.count > 1 else { return parts.first ?? "" }
        return parts.dropLast().joined(separator: ", ") + " and " + (parts.last ?? "")
    }
}


/// **THE ACTIVITY FACE's coalescing** (13n-b U3 — R-13n-10: the list stays
/// legible at length): consecutive log rows by one client, of one act, on one
/// target, with one outcome, read as ONE line with a count — the mockup's
/// "added 3 takes to …". Pure: the rows in, newest first; the lines out.
nonisolated enum MCPActivityFace {
    struct Line: Equatable, Identifiable, Sendable {
        /// The newest row's id (stable while the run grows older).
        let id: Int64
        let clientName: String
        let act: String
        let targetKind: String?
        let targetID: String?
        let targetTitle: String?
        let allowed: Bool
        let count: Int
        /// The newest row's stamp.
        let at: String
    }

    static func lines(_ rows: [MCPActivityRow]) -> [Line] {
        var lines: [Line] = []
        for row in rows {
            if let last = lines.last, last.clientName == row.clientName, last.act == row.act,
               last.targetID == row.targetID, last.targetKind == row.targetKind, last.allowed == row.allowed {
                lines[lines.count - 1] = Line(
                    id: last.id, clientName: last.clientName, act: last.act, targetKind: last.targetKind,
                    targetID: last.targetID, targetTitle: last.targetTitle ?? row.targetTitle,
                    allowed: last.allowed, count: last.count + 1, at: last.at)
            } else {
                lines.append(Line(
                    id: row.id, clientName: row.clientName, act: row.act, targetKind: row.targetKind,
                    targetID: row.targetID, targetTitle: row.targetTitle, allowed: row.allowed,
                    count: 1, at: row.at))
            }
        }
        return lines
    }
}
