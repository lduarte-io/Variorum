import Foundation

// VX-305 U3 — WIP: the acts not yet written (each replaced by its own file in
// the pieces the plan's LIVE STATUS names). Every one refuses.

struct PendingProgram: ActProgram {
    let act: ProtectionAct
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { [] }
    func run(_ step: String, _ ctx: ActContext) async throws { throw ExecutorRefusal.nothingToDo }
}

func MigrationProgram() -> PendingProgram { PendingProgram(act: .migration) }
func ConfirmModeProgram() -> PendingProgram { PendingProgram(act: .confirmMode) }
func MoveOffSharedKeyProgram() -> PendingProgram { PendingProgram(act: .moveOffSharedKey) }
func RetireSharedKeyProgram() -> PendingProgram { PendingProgram(act: .retireSharedKey) }
func RelinkAppleProgram() -> PendingProgram { PendingProgram(act: .relinkApple) }
func CreateLibraryProgram() -> PendingProgram { PendingProgram(act: .createLibrary) }
func KeyDoorProgram(act: ProtectionAct) -> PendingProgram { PendingProgram(act: act) }
func DeviceSettingsProgram() -> PendingProgram { PendingProgram(act: .deviceSettings) }
func TouchIDRearmProgram() -> PendingProgram { PendingProgram(act: .touchIDRearm) }

extension ProtectionExecutor {
    /// WIP: the moves (§3.5 point 2) — written with the old shared key's acts.
    func moveOffSharedKey(_ ctx: ActContext) async throws {}
}
