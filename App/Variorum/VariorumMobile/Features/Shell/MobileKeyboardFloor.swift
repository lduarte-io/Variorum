//
//  MobileKeyboardFloor.swift
//  VariorumMobile
//
//  VM-260 F-1a-W1 (the batch-1a walk's s9) — **THE BAND'S FOOT NEVER STANDS
//  BELOW THE KEYBOARD.** SurfaceContracts' bar line: "While the capture box or
//  the Library search holds the keyboard the bar rides above it."
//
//  THE MECHANISM (traced off the walk's captures; the record is F-1a-W1 in
//  `notes/plans/fixes/vm-260-phone-look.md`): the shell's band — every page
//  and the one bar over its foot — takes the root's SwiftUI keyboard
//  avoidance (nothing above it ignores the `.keyboard` region). On the
//  keyboard that FOLLOWS one whose first responder wore an
//  `inputAccessoryView` (the note editor's 52-pt keyboard bar), that avoidance
//  came out short by exactly the accessory's 52 pt: the band's foot, the
//  Library's rows and the bar stood on the keyboard's keys, under its
//  candidate strip's glass (iOS 26.2; forum reports describe the same shape —
//  FB20386257 — and no Apple document does).
//
//  THE FLOOR: UIKit's keyboard layout guide — Apple's recommended reading of
//  "the space the keyboard occupies" — is read by a probe behind the band
//  (`MobileKeyboardFloorProbe`), and the band is LIFTED by however far its
//  foot stands below the guide's top (`MobileKeyboardFloor.lift`). Wherever
//  SwiftUI's avoidance already reaches the keyboard — every case but the
//  short one — the lift is zero and nothing moves, so this corrects only a
//  shortfall and never lowers the band; and once SwiftUI's avoidance has met a
//  keyboard, a band back at its resting foot is that keyboard LEAVING, so a
//  keyboard's ordinary going never meets a floor the probe has not yet
//  cleared. A keyboard SwiftUI never avoided at all is a shortfall like any
//  other (the merge gate's G-3: the Library's search taking its keyboard back
//  while its page returns in a pop — the band's foot stayed at rest under the
//  keys, and the old at-rest gate gave it nothing). A NOTE is left alone: its
//  text view rides the same guide itself (`MobileWriteSurfaceView`) and its
//  screen ignores the keyboard region.
//
//  P-4: the keyboard's notifications are SIGNALS here — "re-read the guide",
//  "the keyboard is leaving" — never the measurement; the measurement is the
//  guide's own frame, and the decision is the pure rule below.
//

import SwiftUI
import UIKit

nonisolated enum MobileKeyboardFloor {
    /// A shortfall under this is layout rounding between the two readings,
    /// never a short avoidance (the traced one is 52 pt).
    static let tolerance: CGFloat = 2

    /// **The probe's reading**, in WINDOW points: the keyboard's top as UIKit's
    /// keyboard layout guide places it, and where the band's foot RESTS with no
    /// keyboard (the window's own safe-area foot).
    struct Reading: Equatable {
        var top: CGFloat
        var restingFoot: CGFloat
    }

    /// **How far the band rises** so its foot meets the keyboard. Zero with no
    /// keyboard up (no reading); zero with the foot back at rest AFTER SwiftUI's
    /// own avoidance had met this keyboard — a keyboard LEAVING (its avoidance
    /// drops first, the probe's nil a turn later) never meets the old floor;
    /// zero with the foot already at or above the keyboard (the floor never
    /// lowers the band) or within the tolerance; zero while a note shows (its
    /// text view rides the guide itself). Else the shortfall — and that holds
    /// for a band whose avoidance NEVER met the keyboard at all (the merge
    /// gate's G-3: a keyboard the Library's search field takes back while its
    /// page returns in a pop is not avoided by SwiftUI, so the band's foot
    /// stays at rest under it; before G-3 the at-rest gate read that band as a
    /// keyboard leaving and gave it nothing).
    static func lift(
        bandFoot: CGFloat, reading: Reading?, noteShowing: Bool, avoidanceSawKeyboard: Bool
    ) -> CGFloat {
        guard !noteShowing, let reading else { return 0 }
        if avoidanceSawKeyboard && bandFoot >= reading.restingFoot - tolerance { return 0 }
        let shortfall = bandFoot - reading.top
        return shortfall > tolerance ? shortfall : 0
    }

    /// **Whether SwiftUI's own avoidance has met the keyboard the probe reads**
    /// (G-3) — the memory that tells a keyboard leaving (it had: the band's foot
    /// stood above rest while the reading stood) from a keyboard SwiftUI never
    /// avoided (it had not). It holds while the reading stands and is forgotten
    /// with it, so each keyboard session is judged on its own.
    static func sawAvoidance(_ was: Bool, bandFoot: CGFloat, reading: Reading?) -> Bool {
        guard let reading else { return false }
        return was || bandFoot < reading.restingFoot - tolerance
    }

    /// The two facts the memory follows, as one value for the shell's change
    /// observation.
    struct Sighting: Equatable {
        var bandFoot: CGFloat
        var reading: Reading?
    }
}

/// **The probe:** a view filling the window behind the band that reads its own
/// `keyboardLayoutGuide` and reports it (`MobileKeyboardFloor.Reading`) while a
/// keyboard is up, nil once it leaves — always a turn AFTER the event, never
/// inside a SwiftUI update (a field resigning in one posts its hide there).
/// Untouchable and unheard. While it is not `active` (a note shows — the rule
/// leaves a note alone) it keeps watching but hands the shell no new reading,
/// so a note's keyboard never re-renders the shell; a nil (the keyboard gone)
/// is always handed on, so nothing stale outlives a note.
struct MobileKeyboardFloorProbe: UIViewRepresentable {
    var active: Bool
    let report: (MobileKeyboardFloor.Reading?) -> Void

    func makeUIView(context: Context) -> Probe {
        Probe(active: active, report: report)
    }

    func updateUIView(_ probe: Probe, context: Context) {
        let wasActive = probe.active
        probe.report = report
        probe.active = active
        // G-3: a keyboard that settled while a note still showed (its reading
        // withheld) is read again the moment the probe may hand it on — a pop
        // that returns a root with a keyboard already up needs no new keyboard
        // event to be read.
        if active && !wasActive { probe.reread() }
    }

    final class Probe: UIView {
        var report: (MobileKeyboardFloor.Reading?) -> Void
        /// Whether new readings reach the shell (see the type's note).
        var active: Bool
        /// Pinned to the guide, so a keyboard change is a layout change of
        /// this view (its `layoutSubviews` re-reads the guide).
        private let marker = UIView()
        /// Between a show (or a frame change) and a hide.
        private var keyboardUp = false
        /// The last reading handed to the shell (nil: none, or the keyboard gone).
        private var delivered: MobileKeyboardFloor.Reading?

        init(active: Bool, report: @escaping (MobileKeyboardFloor.Reading?) -> Void) {
            self.active = active
            self.report = report
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            isAccessibilityElement = false
            accessibilityElementsHidden = true
            marker.isHidden = true
            marker.isUserInteractionEnabled = false
            marker.translatesAutoresizingMaskIntoConstraints = false
            addSubview(marker)
            NSLayoutConstraint.activate([
                marker.topAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
                marker.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.bottomAnchor),
                marker.leadingAnchor.constraint(equalTo: keyboardLayoutGuide.leadingAnchor),
                marker.trailingAnchor.constraint(equalTo: keyboardLayoutGuide.trailingAnchor),
            ])
            // Selector observation: removed by the system with this view.
            let center = NotificationCenter.default
            for name in [UIResponder.keyboardWillShowNotification, UIResponder.keyboardDidShowNotification,
                         UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardDidChangeFrameNotification] {
                center.addObserver(self, selector: #selector(keyboardMoved(_:)), name: name, object: nil)
            }
            for name in [UIResponder.keyboardWillHideNotification, UIResponder.keyboardDidHideNotification] {
                center.addObserver(self, selector: #selector(keyboardLeaving(_:)), name: name, object: nil)
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

        override func layoutSubviews() {
            super.layoutSubviews()
            // A layout pass may run inside SwiftUI's own update, so the
            // reading is handed on after it — never written into one.
            DispatchQueue.main.async { [weak self] in self?.readTheGuide() }
        }

        /// A show or a frame change: a keyboard is up (unless its end frame
        /// lies off the screen — a frame change can be a hide); re-read the
        /// guide once UIKit has laid it out.
        @objc private func keyboardMoved(_ note: Notification) {
            if let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let screen = window?.screen, end.minY >= screen.bounds.maxY - 0.5 {
                keyboardLeft()
                return
            }
            keyboardUp = true
            setNeedsLayout()
            DispatchQueue.main.async { [weak self] in
                self?.layoutIfNeeded()
                self?.readTheGuide()
            }
        }

        /// The keyboard is leaving. (The band never meets the old floor in
        /// between: its own avoidance drops first and the rule's resting-foot
        /// gate reads that — `MobileKeyboardFloor.lift`.)
        @objc private func keyboardLeaving(_ note: Notification) {
            keyboardLeft()
        }

        private func keyboardLeft() {
            keyboardUp = false
            DispatchQueue.main.async { [weak self] in self?.readTheGuide() }
        }

        /// The guide read again a turn later (the probe became active).
        func reread() {
            DispatchQueue.main.async { [weak self] in
                self?.layoutIfNeeded()
                self?.readTheGuide()
            }
        }

        /// The guide's top and the window's resting foot, in window points,
        /// while a keyboard is up; else nil.
        private func readTheGuide() {
            guard keyboardUp, let window else {
                deliver(nil)
                return
            }
            deliver(MobileKeyboardFloor.Reading(
                top: convert(keyboardLayoutGuide.layoutFrame, to: nil).minY,
                restingFoot: window.bounds.maxY - window.safeAreaInsets.bottom))
        }

        /// Hands the shell a reading that changed: a nil always, a reading
        /// only while active.
        private func deliver(_ reading: MobileKeyboardFloor.Reading?) {
            if reading != nil, !active { return }
            switch (delivered, reading) {
            case (nil, nil): return
            case let (old?, new?) where abs(old.top - new.top) <= 0.25
                && abs(old.restingFoot - new.restingFoot) <= 0.25: return
            default: break
            }
            delivered = reading
            report(reading)
        }
    }
}
