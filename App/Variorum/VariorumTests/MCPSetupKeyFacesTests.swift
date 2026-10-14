//
//  MCPSetupKeyFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-198 — R-VX184-5, THE NEWEST COPIED SETUP WINS, on the pane's faces (the
//  run record `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1): the setup
//  line says a re-run replaces the old setup (her words), every connection act
//  in her Activity list speaks in words — the rebind and the replaced key's
//  refusal included — and the Deny confirm, reviewed against the new rule,
//  stays true as it was.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-198 — the setup key's faces")
struct MCPSetupKeyFacesTests {
    private func line(_ act: String, allowed: Bool, count: Int = 1) -> String {
        MCPPaneCopy.activityLine(MCPActivityFace.Line(
            id: 1, clientName: "claude-code", act: act, targetKind: MCPSetupKeyRule.replacedTargetKind,
            targetID: "0f0f", targetTitle: nil, allowed: allowed, count: count, at: "2026-10-12T00:00:00.000Z"))
    }

    /// Her words (the kickoff's R-VX184-5 line), under every client's setup.
    @Test func theSetupLineSaysARerunReplacesTheOldSetup() {
        // VX-258 (A JUSTIFIED EDIT, the ritual — VX-246 U1b): her R-VX184-5
        // words as she ruled them at VX-258 — a CLIENT'S OWN setup, run again,
        // replaces the old one; an "Any MCP client" copy waits for her OK.
        #expect(MCPPaneCopy.keyLine.contains("Running a client's own setup again replaces the old one"))
        #expect(MCPPaneCopy.keyLine.hasSuffix(
            "a setup copied for any MCP client waits for your OK before it takes a name you approved."))
        #expect(!MCPPaneCopy.keyLine.contains("Deny"), "no Deny on the everyday road")
    }

    /// Every connection act speaks in words — never an act id, never a key's
    /// hash (the rebind row carries the replaced key's hash as its target; no
    /// face shows it).
    @Test func everyConnectionActSpeaksInWords() {
        for refusal in MCPSetupKeyRule.Refusal.allCases {
            let said = line(MCPSetupKeyRule.activityAct(refusal), allowed: false)
            #expect(said.hasPrefix("claude-code was refused connecting") && !said.contains("_") && !said.contains("0f0f"),
                    "\(refusal): \(said)")
        }
        #expect(line(MCPSetupKeyRule.boundAct, allowed: true)
                == "claude-code connected with a new setup, now bound to its name")
        #expect(line(MCPSetupKeyRule.reboundAct, allowed: true)
                == "claude-code connected with a newer setup, which replaced its earlier one")
        #expect(line(MCPSetupKeyRule.reboundAct, allowed: true, count: 2)
                == "claude-code connected with a newer setup, which replaced its earlier one (2 times)")
        #expect(line(MCPSetupKeyRule.activityAct(.replaced), allowed: false)
                == "claude-code was refused connecting with a setup a newer one replaced")
    }

    /// Reviewed against R-VX184-5 ("Deny unchanged"): Deny still releases the
    /// name's key, so its confirm's road back — approve, then run the setup
    /// again — stays exactly true; it never named Deny as the way to rotate.
    @Test func theDenyConfirmStaysTrue() {
        #expect(MCPPaneCopy.denyClientDetail(grants: 0)
                == "It can't connect again until you approve it and run its setup again.")
    }
}
