//
//  MobilePhoneOwnLookFenceTests.swift
//  VariorumMobileTests
//
//  VM-247 (the VM-260 run, batch 3) — **THE PHONE'S LOOK IS THE PHONE'S.** Her
//  words: "I don't like that the theme syncs between mac and phone either it's
//  annoying." · "the voice should also be per device." The traced road (the run
//  record, batch 3): the phone wore the LIBRARY's voice and palette — the shell
//  router held the library's `ThemeStore` and every chrome token, the editor face
//  and every open editor took what that store LANDED (VM-51, R-47-2) — and
//  Settings ▸ Look ▸ Voice wrote the library's synced `theme_voice` row through
//  the Mac Settings' own operation. So a voice chosen on either device moved the
//  other, and a phone choice was a synced row with an outbox row behind it.
//
//  THE PINS (both RED ON OLD — the pre-fix tree is this file's own commit, built
//  into its own DerivedData; only symbols both trees declare):
//  · the phone's voice door writes NO `setting` row and NO outbox row, and still
//    moves the phone — its chrome, its editor face and an OPEN editor's storage;
//  · a look written to the library (the Mac's Settings, or a sync apply — the same
//    rows) moves the phone NOTHING, while the library's own store still lands it.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-247 — this phone's look is its own: never the library's", .serialized)
struct MobilePhoneOwnLookFenceTests {
    /// The library's settings, as rows.
    private func settingRows(_ session: AppSession) async throws -> [String] {
        try await session.database.read { db in
            try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                .map { "\($0["key"] as String)=\($0["value"] as String)" }
        }
    }

    /// The outbox's rows for the `setting` table — what a sync round would push.
    private func settingOutbox(_ session: AppSession) async throws -> [String] {
        try await session.database.read { db in
            try String.fetchAll(
                db, sql: "SELECT row_id FROM sync_outbox WHERE table_name = 'setting' ORDER BY row_id")
        }
    }

    /// A note with one block, its editor loaded, and a router bound to the world's
    /// library with its store running — the shell's own composition — the editor
    /// registered with it.
    private func world(
        _ session: AppSession
    ) async throws -> (MobileShellRouter, ThemeStore, NSTextStorage, Task<Void, Never>, MobileEditorViewModel) {
        let post = try await session.runner.run { ops in
            try ops.createPost(title: "looked", profile: .blog)
        }
        _ = try await session.runner.run { ops in
            try ops.newBlock(in: post.id, text: "Looked text.", at: .end)
        }
        let (model, storage) = makeEditor(session, postID: post.id)
        await model.loadOnce()
        let router = MobileShellRouter()
        router.bindTheme(session: session)
        await router.editors.register(model, tab: .shelf)
        let theme = try #require(router.theme)
        let held = Task { await theme.start() }
        return (router, theme, storage, held, model)
    }

    /// **RED ON OLD** (the door wrote the library's `theme_voice` and its outbox
    /// row — R-47-2's road). Settings ▸ Look ▸ Voice is THIS phone's: the voice
    /// moves here — the chrome's tokens, the editor face, an open editor's
    /// storage — and the library's `setting` table and its outbox are what they
    /// were.
    @Test func thePhonesVoiceDoorWritesNoSettingRowAndNoOutboxRow() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let (router, _, storage, held, model) = try await world(session)
            defer { held.cancel() }
            _ = model
            try await untilLanded { router.voice == .study && MobileEditorStyle.voice == .study }
            let rowsBefore = try await settingRows(session)
            let outboxBefore = try await settingOutbox(session)

            router.setVoice(.terminal)
            try await untilLanded { router.voice == .terminal && MobileEditorStyle.voice == .terminal }
            let font = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(font == MobileEditorStyle.terminalFace.body,
                    "the open editor wears the voice chosen on this phone")
            #expect(router.tokens(dark: false).voice == .terminal, "the chrome wears it too")

            #expect(try await settingRows(session) == rowsBefore,
                    "a Look choice on the phone wrote the library's settings")
            #expect(try await settingOutbox(session) == outboxBefore,
                    "a Look choice on the phone queued a synced row")
        }
    }

    /// **RED ON OLD** (the phone wore whatever the library's store landed). The
    /// Mac's Settings writes these rows — and a sync apply lands the same rows —
    /// and the library's own store still lands them (the witness and the router's
    /// store both read Terminal under lavender); the phone wears what it wore:
    /// Study under the sea-glass in its chrome, its editor face and an open
    /// editor's storage.
    @Test func aLookWrittenToTheLibraryMovesThePhoneNothing() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let (router, theme, storage, held, model) = try await world(session)
            defer { held.cancel() }
            _ = model
            try await untilLanded { router.voice == .study && MobileEditorStyle.settings.palette == .seaglass }

            // A witness over the same library — the Mac's own store, bound the Mac's way.
            let witness = ThemeStore(session: session)
            let watching = Task { await witness.start() }
            defer { watching.cancel() }

            // The Mac's own writes (`ThemeStore.setVoice` / `.setThemePalette` run
            // exactly these operations; a sync apply lands the same rows).
            try await session.runner.run { ops in
                try ops.setThemeVoice(.terminal)
                try ops.setThemePalette(.lavender)
            }
            try await untilLanded { witness.settings.voice == .terminal && witness.settings.palette == .lavender }
            // The router's own store took the write too — and its landing seam ran in
            // the same turn (`ThemeStore.start` sets `settings`, then calls `onLanded`).
            try await untilLanded { theme.settings.voice == .terminal && theme.settings.palette == .lavender }

            #expect(router.voice == .study, "the library's voice moved the phone")
            #expect(router.settings.palette == .seaglass, "the library's palette moved the phone")
            for dark in [false, true] {
                #expect(router.tokens(dark: dark) == VoiceTokens.resolve(
                    voice: .study, palette: .seaglass, tint: .none, dark: dark),
                    "the chrome is the phone's own look (dark: \(dark))")
            }
            #expect(MobileEditorStyle.voice == .study && MobileEditorStyle.settings.palette == .seaglass,
                    "the editor face is the phone's own look")
            let font = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(font == MobileEditorStyle.studyFace.body, "the open editor did not re-voice")
        }
    }
}
