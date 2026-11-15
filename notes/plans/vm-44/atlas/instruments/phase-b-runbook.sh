#!/bin/zsh
# VM-44 capture — Phase B runbook (THROWAWAY instrument; never committed). Read, then run step by step
# ONLY under a held stage claim on the Pro. Nothing here signs in, presses Resume/Sync, or touches the Mac dev store.
echo "runbook: source it and run the steps by hand" ; return 0 2>/dev/null || exit 0

UDID=836ECF73-721C-434E-A2E5-0717E44721FD          # "MobileCatchup Capture", iPhone 17 Pro, iOS 27.0 — never D71C1F55
DD="$HOME/Library/Developer/Xcode/DerivedData/mobilecatchup-capture"
PROD="$DD/Build/Products"
UI_RUN="$PROD/TK2SpikeUITests_TK2SpikeUITests_iphonesimulator27.1-arm64.xctestrun"
UNIT_RUN="$PROD/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64.xctestrun"
ATLAS="$HOME/dev/variorum-mobile-catchup/atlas"
mkdir -p "$ATLAS/screens" "$ATLAS/recordings" "$ATLAS/instruments/xcresults"

# 0 — stage
#   ~/dev/variorum/Tools/stage claim --who vm44-capture --reason "VM-44 phone atlas: sim boot, seed, walk, capture" --minutes 90

# 1 — boot + machinery (by UDID, never `booted`)
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b
xcrun simctl spawn $UDID defaults write com.apple.Accessibility ApplicationAccessibilityEnabled -bool true
xcrun simctl spawn $UDID defaults read com.apple.Accessibility ApplicationAccessibilityEnabled   # expect 1
xcrun simctl ui $UDID appearance light
xcrun simctl status_bar $UDID override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

run_ui() {   # $1 = -only-testing target, $2 = result name; env ATLAS_VOICE / ATLAS_PREFIX / ATLAS_DIR pass through TEST_RUNNER_
  TEST_RUNNER_ATLAS_DIR="${ATLAS_DIR:-$ATLAS/screens}" TEST_RUNNER_ATLAS_PREFIX="${ATLAS_PREFIX:-}" \
  TEST_RUNNER_ATLAS_VOICE="${ATLAS_VOICE:-study}" \
  xcodebuild test-without-building -xctestrun "$UI_RUN" -destination "id=$UDID" \
    -only-testing:"$1" -resultBundlePath "$ATLAS/instruments/xcresults/$2.xcresult" \
    > "$ATLAS/instruments/xcresults/$2.log" 2>&1
  echo "EXIT $? ($2)"; grep -E "Test Case .*(passed|failed)|Executed" "$ATLAS/instruments/xcresults/$2.log" | tail -15
}

# 2 — FIRST RUN on the fresh install (words card → empty states → the first write → furniture)
#     (test-without-building installs the app from $PROD; a fresh device has no library yet)
run_ui VariorumMobileUITests/VM44CaptureFirstRun first-run
#     If 00-first-launch shows "Running tests — no library is open." or a creation failure, the AUT is in test
#     context: fall back to `xcrun simctl launch $UDID io.lduarte.VariorumMobile` + `xcrun simctl io $UDID screenshot`,
#     tap through by hand, and report it. REDACT the words card capture (blur the 12 words) before anyone sees it.

# 3 — SEED (hosted unit test; the app must NOT be running; the library must exist and the first write must have landed)
xcrun simctl terminate $UDID io.lduarte.VariorumMobile 2>/dev/null
xcodebuild test-without-building -xctestrun "$UNIT_RUN" -destination "id=$UDID" \
  -only-testing:VariorumMobileTests/VM44CaptureSeedTests -resultBundlePath "$ATLAS/instruments/xcresults/seed.xcresult" \
  > "$ATLAS/instruments/xcresults/seed.log" 2>&1; echo "EXIT $?"
cat "$ATLAS/instruments/seed-summary.txt"     # or: grep -A20 "VM44-SEED summary" seed.log
#     Expected: 8 wings (+ virtual Home = 9), ≥4 shelves, 23 books live (incl. the Journal + the Prince), 1 gathering,
#     1 archived book, 1 book in trash, ≥118 notes live (+ the Prince's), 2 archived notes, 3 notes in trash,
#     3 arrivals waiting, fanned blocks ≥ 10, longest note ≥ 40,000 words.
#     A prepareDependencies issue reported by XCTest does not by itself mean the seed failed — read the summary.

# 4 — PRIMARY PASS: Study voice, light (the phone has no palette road: Classic colours, not sea-glass — a finding)
ATLAS_VOICE=study run_ui VariorumMobileUITests/VM44CaptureWalk walk-primary
cat "$ATLAS/screens/walk-log.txt" | grep -E "MISSING|WRITE-FAILED"   # each MISSING = a step to redo by hand or fix in the driver

# 5 — SECONDARY PASSES (key screens only)
xcrun simctl ui $UDID appearance dark
ATLAS_VOICE=study ATLAS_PREFIX=dark- run_ui VariorumMobileUITests/VM44CaptureVariants/test01_coreSet variants-dark
xcrun simctl ui $UDID appearance light
ATLAS_VOICE=terminal ATLAS_PREFIX=terminal- run_ui VariorumMobileUITests/VM44CaptureVariants/test01_coreSet variants-terminal
#   optional: text size — xcrun simctl ui $UDID content_size extra-extra-extra-large ; ATLAS_PREFIX=xl- … ; then `large`

# 6 — RECORDINGS (simctl records the device framebuffer; MARK lines in walk-log.txt give trim points)
rec() {   # $1 test method, $2 clip name
  xcrun simctl io $UDID recordVideo --codec=h264 --force "$ATLAS/recordings/$2.mp4" &
  local pid=$!; sleep 2
  ATLAS_VOICE=study run_ui "VariorumMobileUITests/VM44CaptureRecordings/$1" "$2"
  kill -INT $pid; wait $pid 2>/dev/null
}
rec test01_tapIntoQuickEntry rec-01-tap-into-quick-entry
rec test02_quickEntryToNote  rec-02-quick-entry-to-note
rec test03_openLongNote      rec-03-open-long-note
rec test04_scrollLibrary     rec-04-scroll-library
#   trim example: ffmpeg -ss <t0> -i in.mp4 -t 8 -c copy out-trim.mp4

# 7 — close
xcrun simctl status_bar $UDID clear
xcrun simctl shutdown $UDID
#   ~/dev/variorum/Tools/stage release --who vm44-capture
#   Iterating the driver: copy instruments/VM44CaptureWalk.swift into the worktree's VariorumMobileUITests/, then
#     (cd ~/dev/variorum-vm44-capture/App/Variorum && xcodebuild -project Variorum.xcodeproj -scheme TK2SpikeUITests \
#       -configuration Debug -destination "id=$UDID" -derivedDataPath "$DD" build-for-testing)
#   and remove the copy after. A TK2SpikeUITests build re-copies VariorumMobile.app WITHOUT the hosted unit-test
#   PlugIn — rebuild the VariorumMobile scheme (seeder copied in) afterwards if the seed must run again.
#   End of effort: git -C ~/dev/variorum worktree remove ~/dev/variorum-vm44-capture ; xcrun simctl delete $UDID (at the
#   orchestrator's word).
