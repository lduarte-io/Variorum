//
//  DeviceName.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13x batch 2c (decision 34 — the author's ruling on 2b's question 4):
//  the vault's seventh column, `updated_by_device`, carries the NAME of the
//  device that last wrote the vault, and every notice on another device
//  renders *[device] on [day]* from it. A NAME, never an id — her words:
//  the real name is what lets a user spot an act they did not do. This is
//  the one place the app asks the OS for it; `AppServices` hands it to the
//  vault client, which stamps every write.
//

import Foundation
#if os(iOS)
import UIKit
#endif

nonisolated enum DeviceName {
    /// The device's own user-facing name: `Host.current().localizedName` on
    /// the Mac ("Lillian's MacBook Pro"), `UIDevice.current.name` on the
    /// phone. Never empty — an OS that answers nothing gets the platform
    /// noun (`ProtectionCopy.deviceName`, the ONE word source the parity
    /// C5 sweep allows), so a notice still reads as a sentence.
    static var current: String {
        #if os(iOS)
        let name = MainActor.assumeIsolated { UIDevice.current.name }
        #else
        let name = Host.current().localizedName ?? ""
        #endif
        return name.isEmpty ? "this \(ProtectionCopy.deviceName)" : name
    }
}
