//
//  KeychainMemoryLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `MemoryStoreLeaf` (`Executor/Leaves.swift`): WHAT THIS MAC REMEMBERS (rule 21's
//  four things — `Model/DeviceMemory.swift`), one device-only NON-SECRET item per library ID under
//  `ProtectionNames.memoryService` / `memoryAccount`, the value the `Sealed<DeviceMemory>` in
//  `ProtectionCoding` JSON (sealed whole under the library key — an edit is caught at the open, never here).
//    - `rememberedLibraryIDs` enumerates by NAME — attributes only, no payload read;
//    - `readMemory` hands back what the item holds (bytes that are not a sealed memory read as none — a
//      memory that fails its seal remembers nothing anyway);
//    - writes are verified by a read-back; deletes only at the doors that make another library this Mac's
//      (the executor's rule). Every mutation asks the test tripwire first.
//

import Foundation
import Security
import VariorumCore

nonisolated final class KeychainMemoryLeaf: MemoryStoreLeaf, @unchecked Sendable {
    static let service = ProtectionNames.memoryService

    let scope: String

    init(scope: String) { self.scope = scope }

    func account(_ libraryID: String) -> String { ProtectionNames.memoryAccount(scope: scope, libraryID: libraryID) }

    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>? {
        try ProtectionKeychain.readData(service: Self.service, account: account(libraryID), residence: .deviceOnly)
            .flatMap { try? ProtectionCoding.decoder().decode(Sealed<DeviceMemory>.self, from: $0) }
    }

    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "memory.write")
        let data = try ProtectionCoding.canonical(memory)
        try ProtectionKeychain.upsert(
            service: Self.service, account: account(libraryID), residence: .deviceOnly, data: data, label: libraryID,
            accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        guard try ProtectionKeychain.readData(service: Self.service, account: account(libraryID), residence: .deviceOnly) == data else {
            throw ProtectionKeychain.KeychainError.writeDidNotReadBack("memory.write")
        }
    }

    func rememberedLibraryIDs() throws -> Set<String> {
        Set(try ProtectionKeychain.list(service: Self.service, residence: .deviceOnly).compactMap { attributes in
            ProtectionKeychain.account(of: attributes).flatMap { ProtectionNames.parseMemoryAccount($0, scope: scope) }
        })
    }

    func deleteMemory(libraryID: String) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "memory.delete")
        try ProtectionKeychain.delete(service: Self.service, account: account(libraryID), residence: .deviceOnly)
    }
}
