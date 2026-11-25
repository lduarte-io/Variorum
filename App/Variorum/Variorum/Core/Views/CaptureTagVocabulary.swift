//
//  CaptureTagVocabulary.swift
//  Variorum (MAC ONLY) — Core/Views: what a capture's tag field suggests
//
//  **VX-1078 (the VX-1036 run, batch 4).** The capture doors' tag field
//  (`CaptureTagItems`) suggests the LANDING wing's live tags, most-used first
//  (VX-576 — the suggest brain's `uses:`): the wing the band's note is minted in
//  (the wing she stands in), or the wing the pad is aimed at (P-915-B3-1's
//  landing word, a dead wing reading as Home's). P-9: its own small model, so
//  neither capture model grows a read.
//
//  ONE read per opening of the field, never held (the masthead cluster's
//  VX-576 posture): the vocabulary is ∝ the wing's tags and the counts ∝ the
//  wing's tags × the saturation cap of live applications each
//  (`Queries.tagUseCountSaturation`; the VX-1036 ladder's R1-2/R2-1) — paid
//  only when she opens the field, nothing at rest.
//

import Observation
import VariorumCore

@MainActor
@Observable
final class CaptureTagVocabulary {
    /// The landing wing's live tags (the field's suggestions).
    private(set) var tags: [Tag] = []
    /// How many live notes wear each of them, by id (most-used first).
    private(set) var uses: [String: Int] = [:]

    /// Read the wing's vocabulary and its counts — once, when the field opens.
    func load(session: AppSession, wingID: String) async {
        let read = try? await session.database.read { db in
            (try Queries.allTags(db, wingID: wingID), try Queries.tagUseCounts(db, wingID: wingID))
        }
        guard let read else { return }
        tags = read.0
        uses = read.1
    }
}
