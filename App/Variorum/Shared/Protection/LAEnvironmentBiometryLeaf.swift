//
//  LAEnvironmentBiometryLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `BiometryLeaf` (`Executor/Leaves.swift`): this device's biometry from
//  `LAEnvironment.currentUser.state.biometry` (macOS 15+ / iOS 18+ — the Apple facts §5,
//  `notes/plans/vx-266/second-opinion-apple-facts.md`): HARDWARE = a biometry mechanism exists; ENROLLED =
//  `isEnrolled`; the TRANSIENT reasons, which never change anything (§3.10): `builtInSensorInaccessible`
//  (clamshell — "open the lid"), `isLockedOut`, and — from `canEvaluatePolicy`'s error, the only place they
//  surface — a Magic Keyboard with Touch ID that is not paired (`biometryNotPaired`) or not connected
//  (`biometryDisconnected`). A read only: nothing here evaluates a policy that prompts.
//

import Foundation
import LocalAuthentication
import VariorumCore

nonisolated final class LAEnvironmentBiometryLeaf: BiometryLeaf, @unchecked Sendable {
    func biometry() -> BiometryFacts {
        guard let mechanism = LAEnvironment.currentUser.state.biometry, mechanism.biometryType != .none else {
            return .none
        }
        var transient: TransientUnavailability?
        #if os(macOS)
        if mechanism.builtInSensorInaccessible { transient = .lidClosed }
        #endif
        if transient == nil, mechanism.isLockedOut { transient = .lockout }
        if transient == nil {
            var error: NSError?
            let context = LAContext()
            if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
               let code = error.map({ LAError.Code(rawValue: $0.code) }) ?? nil {
                switch code {
                case .biometryNotPaired: transient = .keyboardNotPaired
                case .biometryDisconnected: transient = .keyboardDisconnected
                case .biometryLockout: transient = .lockout
                default: break
                }
            }
        }
        return BiometryFacts(hardware: true, enrolled: mechanism.isEnrolled, transient: transient)
    }
}
