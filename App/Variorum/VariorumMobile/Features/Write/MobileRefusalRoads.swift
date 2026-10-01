//
//  MobileRefusalRoads.swift
//  VariorumMobile
//
//  **The phone's half of the one refusal table** (18m U3). The table lives in
//  `Shared/OpsRefusalTable.swift` and both apps speak it; what a shared home
//  must not hold — a platform's own door words (MobileSoul §4 item 4) —
//  arrives from each platform's own target. These are the phone's: its note
//  seal is the masthead's Lock Note / Unlock Note door, and it has no divide
//  chord and no ceremony, so those slots stay EMPTY and the sentences end at
//  the fact that is true here. Living in this target is what makes it a
//  compile-time fact that the phone can never speak the Mac's roads (and the
//  shared file's string-level ban is `OpsRefusalTableIntegrityTests`).
//

import Foundation
import VariorumCore

nonisolated extension SealedNoteCopy.Words {
    /// The phone's note-seal door (mobile parity A1 #4 — the masthead lock,
    /// "Unlock Note" on the sealed state line): a sealed note is "locked", and
    /// the way out is to "unlock" it — the phone's shipped vocabulary.
    static let phone = SealedNoteCopy.Words(state: "locked", verb: "unlock")
}

nonisolated extension OpsRefusalRoads {
    /// 13i-c U2: a book's seal is "sealed" here too (the ruled noun), but the
    /// phone has no Unseal door for books yet (the mobile catch-up's), so the
    /// sentence names none.
    static let phone = OpsRefusalRoads(
        seal: .phone, divideChord: nil, arrangeTakesRoad: nil,
        bookSeal: .init(state: "sealed", verb: nil))
}
