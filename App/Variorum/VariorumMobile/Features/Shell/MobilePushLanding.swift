//
//  MobilePushLanding.swift
//  VariorumMobile
//
//  **A-260-1 — A THING MADE BUT NOT OPENED SAYS WHERE IT LANDED** (the VM-260
//  run's adjudication of batch 1a's P-260-1a; built in batch 1b). The one push
//  door (`MobileShellView.push(_:in:)`) lands nothing on a page she has since
//  left (VM-256, R-260-5): a note or book asked for there — minted after she
//  moved on, the lag's window — is MADE and kept, and never opened (P-3: no
//  editor mounts or takes the pen on a page she cannot see). That arm stands;
//  silence does not: an outcome other than the one she asked for is a
//  DIRECTION (SurfaceContracts, the phone line: "a direction … keeps its
//  line"), so the door says where the thing is — through the existing seam,
//  never a refusal, no Undo (nothing left the page).
//
//  The words name the room the thing lists in — every note lists in the
//  Library, every book on the Bookcase — by the bar's own words for its rooms
//  (`MobileTabBar.word`, derived, never retyped), because the door knows the
//  route it was asked to push and nothing of the mint behind it (a Today entry
//  may have existed already, so the line never says "new"). The other routes
//  (a book's Read, the Trash, Archived, Versions, Protection) are never made by
//  the door that asks for them, so they say nothing. DRAFT words — PROVISIONAL
//  for her wording pass.
//

import Foundation

@MainActor
enum MobilePushLanding {
    /// What the door says when it kept `route` instead of opening it — nil for
    /// a route no door makes.
    static func direction(for route: MobileRoute) -> String? {
        switch route {
        case .note:
            return "That note didn't open because you'd moved on — it's in the "
                + "\(MobileTabBar.word(.library))."
        case .book:
            return "That book didn't open because you'd moved on — it's on the "
                + "\(MobileTabBar.word(.shelf))."
        case .bookRead, .trash, .archive, .versions, .protection:
            return nil
        }
    }
}
