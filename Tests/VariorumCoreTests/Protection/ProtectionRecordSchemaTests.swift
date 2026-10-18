//
//  ProtectionRecordSchemaTests.swift
//  VariorumCoreTests — VX-306 U1a piece 2: the protection record's table
//  (`v1_31_protection_record`, LOCAL-ONLY) and its one-row codec.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-306 U1a — the protection record's table")
struct ProtectionRecordSchemaTests {
    static func record(_ libraryID: String = UUID().uuidString.lowercased()) -> ProtectionRecord {
        ProtectionRecord.minting(
            libraryID: libraryID, mode: .standard, account: nil,
            currentFingerprint: "0123456789abcdef", at: Date(timeIntervalSinceReferenceDate: 790_000_000))
    }

    @Test func theMigrationMakesTheTableAndItIsLocalOnly() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            #expect(try db.tableExists(ProtectionRecordSchema.table))
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(protection_record)").map { $0["name"] as String }
            #expect(columns == ["library_id", "record", "updated_at"])
            // No outbox trigger names it (local-only: never a payload).
            let triggers = try String.fetchAll(
                db, sql: "SELECT sql FROM sqlite_master WHERE type = 'trigger' AND sql LIKE '%protection_record%'")
            #expect(triggers.isEmpty)
        }
        #expect(SyncSchema.localOnlyTables.contains(ProtectionRecordSchema.table))
        #expect(SyncSchema.table(named: ProtectionRecordSchema.table) == nil)
    }

    @Test func aRecordRoundTripsByteExactly() throws {
        let db = try AppDatabase.inMemory()
        let record = Self.record()
        try db.write { try ProtectionRecordSchema.write(record, at: Date(), $0) }
        let read = try db.read { try ProtectionRecordSchema.read($0) }
        #expect(read == record)
    }

    @Test func aWriteReplacesEveryRowSoTheFileHoldsOneRecord() throws {
        let db = try AppDatabase.inMemory()
        let outgoing = Self.record()
        let incoming = Self.record()
        try db.write { try ProtectionRecordSchema.write(outgoing, at: Date(), $0) }
        try db.write { try ProtectionRecordSchema.write(incoming, at: Date(), $0) }
        let count = try db.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM protection_record") }
        #expect(count == 1)
        #expect(try db.read { try ProtectionRecordSchema.read($0) } == incoming)
    }

    @Test func twoRowsRefuseAndNoTableReadsAsNoRecord() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            for record in [Self.record(), Self.record()] {
                let text = String(data: try ProtectionCoding.canonical(record), encoding: .utf8)!
                try db.execute(
                    sql: "INSERT INTO protection_record (library_id, record, updated_at) VALUES (?, ?, ?)",
                    arguments: [record.libraryID, text, "2026-10-18T00:00:00.000Z"])
            }
        }
        #expect(throws: ProtectionRecordSchema.RecordError.moreThanOneRecord(2)) {
            try db.read { try ProtectionRecordSchema.read($0) }
        }
        let bare = try DatabaseQueue()
        #expect(try bare.read { try ProtectionRecordSchema.read($0) } == nil)
    }

    @Test func thePlaintextExportLeavesItBehindAndTheRecreationMakesItEmpty() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("vx306-record-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let key = StoreKey.mint()
        let store = try AppDatabase.onDisk(url: dir.appendingPathComponent("variorum.sqlite"), key: key)
        try store.write { try ProtectionRecordSchema.write(Self.record(), at: Date(), $0) }
        let export = dir.appendingPathComponent("plain.sqlite")
        try StorePlaintextExport.export(from: store, to: export)
        let exported = try DatabaseQueue(path: export.path)
        #expect(try exported.read { try $0.tableExists(ProtectionRecordSchema.table) } == false)
        try exported.close()
        let created = try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: export)
        #expect(created.contains(ProtectionRecordSchema.table))
        let recreated = try DatabaseQueue(path: export.path)
        #expect(try recreated.read { try ProtectionRecordSchema.read($0) } == nil)
        try recreated.close()
    }
}
