//
//  MobileMessageLine.swift
//  VariorumMobile
//
//  **VM-61 — THE PHONE'S ONE MESSAGE LINE** (umbrella VM-55, batch 2a; work-list
//  row W-012). The face of the ONE seam both platforms speak through
//  (`AppSession.status`): it draws `status.current`, which on the phone holds
//  only what her VM-44 ruling lets show — a refusal, an offer, and a receipt
//  whose act took something off the page, with its Undo. It fades on the
//  seam's own clock (the one auto-dismiss policy, `StatusCenter.dismissAfter`)
//  and never pushes the page's content: it floats.
//
//  **HOSTED ONCE, BY THE SHELL, ABOVE EVERYTHING THE SHELL PRESENTS.** Half the
//  phone's message slots lived inside SwiftUI sheets (the note's tags, books,
//  more info, blocks, lenses, ⋯; the book's details; the new-book sheet; the
//  tag manager), and a SwiftUI overlay on the shell draws UNDER a presented
//  sheet — a refusal raised in a sheet would have been spoken where she could
//  not see it, the very class `MobileDeletionTests`' sheet pin was written
//  against. So the shell installs ONE passthrough window over its own scene
//  (`MobileMessageLineHost`): a higher window level draws above the main
//  window's sheets and alerts; the keyboard stays above it (iOS keeps the
//  keyboard over every app window), so the line rides above the keyboard
//  from the keyboard-frame notifications rather than from a non-key window's
//  keyboard safe area; the window never becomes key (the focused text keeps
//  the keyboard); and only the line's own door takes a touch — every other
//  point falls through to the app, tested against a frame this file
//  controls, never against SwiftUI's internal views (the iOS 18/26 hit-test
//  reports on hosting-controller-root windows).
//
//  **The receipt line's anatomy** (the VM-47 run's phone layer, put on at the
//  VM-55 re-land — the sizing sheet §E, "Receipt line"; PROVISIONAL with its
//  numbers, P-47-1): ONE line, 44 tall; the words SF 15 (`controlInline`,
//  chrome — they follow the text size to xxxLarge and hold) — a refusal in the
//  alarm ink every phone error slot wore, a removal in the corrected muted, an
//  offer in ink; its act 15 semibold in the accent across a 44 pt hit area
//  (`PhoneInlineActStyle`); at the gutter, on the room with the tab bar's
//  hairline, because a line that floats over content needs a ground to be read
//  on — in the library's look (voice, palette and tint: the shell hands its
//  settings road, `look`). Its words, its classes and its timing are VM-61's.
//

import SwiftUI
import UIKit
import VariorumCore

// MARK: - The model (what the face reads besides the seam)

@MainActor
@Observable
final class MobileMessageLineModel {
    /// The ONE seam (`AppSession.status`).
    @ObservationIgnored let status: StatusCenter
    /// The library's voice, read live (the shell's own resolver input).
    @ObservationIgnored let voice: @MainActor () -> ThemeVoice
    /// **The library's look, read live** — voice, palette and tint through the
    /// shell's settings road (the VM-47 run's VM-51: every phone face wears the
    /// library's palette, never the voice's bare colours). nil — a harness —
    /// wears the voice's own (`voice`), as before.
    @ObservationIgnored let look: (@MainActor (_ dark: Bool) -> VoiceTokens)?

    /// How far above the safe area's foot the line sits when the keyboard is
    /// down: the tab bar's height on a root (the line never covers the bar's
    /// doors), zero inside a pushed screen. The shell writes it.
    var chromeInset: CGFloat = 0
    /// How much of the window's foot the keyboard covers, from the keyboard
    /// frame notifications (zero while it is down).
    var keyboardOverlap: CGFloat = 0
    /// The window's own bottom safe-area inset (the home indicator's), fed by
    /// the overlay's controller from UIKit. The face ignores the safe area so
    /// its door's frame stays in window coordinates — and a `GeometryReader`
    /// that ignores it reads this inset as ZERO, which put the line one
    /// home-indicator inset too low, over the tab bar's doors (2a follow-up 2,
    /// VM-55 batch 2b). So the inset comes from here, never from the reader.
    var safeBottom: CGFloat = 0

    /// The line's door, in the overlay's coordinate space — the ONLY region
    /// that takes a touch. Not observed: hit-testing reads it, nothing draws it.
    @ObservationIgnored var doorFrame: CGRect?

    init(
        status: StatusCenter, voice: @escaping @MainActor () -> ThemeVoice,
        look: (@MainActor (_ dark: Bool) -> VoiceTokens)? = nil
    ) {
        self.status = status
        self.voice = voice
        self.look = look
    }

    /// **How far above the WINDOW's foot the line's foot sits** — pure,
    /// pinned. Above the keyboard when it is up (its overlap is measured from
    /// the window's foot); otherwise above the safe area's foot, plus the tab
    /// bar on a root. Never inside the home-indicator inset.
    static func footOffset(keyboardOverlap: CGFloat, safeBottom: CGFloat, chromeInset: CGFloat) -> CGFloat {
        max(keyboardOverlap, safeBottom + chromeInset, safeBottom)
    }

    /// **Does this point take a touch?** Only the shown line's own door does
    /// (P-2: a door that is drawn acts; everything else falls through). Pure
    /// over its inputs, pinned.
    static func takesTouch(at point: CGPoint, doorFrame: CGRect?, showing: StatusCenter.Item?) -> Bool {
        guard let showing, showing.action != nil, let doorFrame else { return false }
        return doorFrame.contains(point)
    }

    /// The keyboard's overlap of a window's foot, from a notification's end
    /// frame (screen coordinates — Apple's documented conversion). Zero when
    /// the frame misses the window (a hidden or undocked keyboard).
    static func keyboardOverlap(endFrameInWindow frame: CGRect, windowBounds: CGRect) -> CGFloat {
        let overlap = windowBounds.intersection(frame)
        guard !overlap.isNull, overlap.height > 0 else { return 0 }
        return max(0, windowBounds.maxY - overlap.minY)
    }
}

// MARK: - The face

struct MobileMessageLineView: View {
    let model: MobileMessageLineModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let dark = scheme == .dark
        let tokens = model.look?(dark) ?? VoiceTokens.resolve(voice: model.voice(), dark: dark)
        GeometryReader { _ in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                if let item = model.status.current {
                    line(item, tokens: tokens)
                        .transition(.opacity)
                }
            }
            .padding(.bottom, MobileMessageLineModel.footOffset(
                keyboardOverlap: model.keyboardOverlap,
                safeBottom: model.safeBottom,
                chromeInset: model.chromeInset))
        }
        // The face fills the WINDOW, so the door's frame below is in the
        // window's own coordinates (the hosting view sits at its origin) and
        // the foot is measured from the window's foot. The keyboard is tracked
        // from its own notifications (the overlay is never the key window), so
        // no safe-area region — the keyboard's included — lifts it twice.
        .ignoresSafeArea()
        .animation(.easeOut(duration: 0.18), value: model.status.current?.id)
        .onChange(of: model.status.current?.id) { _, _ in
            // The line lives in its own window, so an assistive reader is
            // told rather than left to find it (MobileSoul §5.6).
            if let words = model.status.current?.text, !words.isEmpty {
                UIAccessibility.post(notification: .announcement, argument: words)
            }
        }
    }

    private func line(_ item: StatusCenter.Item, tokens: VoiceTokens) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: PhoneMetrics.Space.s12) {
            if !item.text.isEmpty {
                Text(words(item, tokens: tokens))
                    .phoneType(.controlInline, tokens)
                    .foregroundStyle(ink(item, tokens: tokens))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    // The words' own air: one line of them is the line's 44,
                    // and several keep clear of its edges.
                    .padding(.vertical, PhoneMetrics.Space.s12)
                    .accessibilityLabel(item.text)
            }
            if let action = item.action {
                Button {
                    // The line goes as its door acts (the Mac toast's rule).
                    if model.status.current?.id == item.id { model.status.clear() }
                    action.perform()
                } label: {
                    Text(tokens.chromeLabel(action.label))
                }
                .buttonStyle(PhoneInlineActStyle(tokens: tokens, weight: .semibold))
                .accessibilityLabel(action.label)
                .onGeometryChange(for: CGRect.self) { geometry in
                    // The hosting view's root space IS the overlay window's
                    // (it fills the window from the origin).
                    geometry.frame(in: .global)
                } action: { frame in
                    model.doorFrame = frame
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: PhoneMetrics.touchMinimum, alignment: .leading)
        .padding(.horizontal, PhoneMetrics.gutter)
        .background(tokens.room)
        .overlay(alignment: .top) {
            Rectangle().fill(tokens.line).frame(height: 1)
        }
        .accessibilityElement(children: .contain)
    }

    /// A removal wears the phone receipts' chrome casing; a refusal and an
    /// offer read as the sentences they are (every phone error slot's own).
    private func words(_ item: StatusCenter.Item, tokens: VoiceTokens) -> String {
        item.kind == .receipt ? tokens.chromeLabel(item.text) : item.text
    }

    private func ink(_ item: StatusCenter.Item, tokens: VoiceTokens) -> Color {
        switch item.kind {
        case .refusal: return tokens.alarm
        case .offer: return tokens.ink
        case .receipt: return tokens.phone.muted
        }
    }
}

// MARK: - The host: one passthrough window over the shell's scene

/// The overlay window. It never becomes key (the focused text keeps the
/// keyboard), and it takes no touch of its own.
final class MobileMessageLineWindow: UIWindow {
    override var canBecomeKey: Bool { false }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return (hit === self || hit === rootViewController?.view) ? nil : hit
    }
}

/// The overlay's root: a plain controller whose view passes every touch
/// through except the line's door, with the line's SwiftUI face as a child
/// filling it, and the keyboard tracked from its notifications.
final class MobileMessageLineController: UIViewController {
    let model: MobileMessageLineModel

    init(model: MobileMessageLineModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func loadView() {
        view = PassthroughView(model: model)
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: MobileMessageLineView(model: model))
        host.view.backgroundColor = .clear
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)

        // Selector observation: removed by the system when this controller
        // goes, so no token outlives the overlay.
        let center = NotificationCenter.default
        center.addObserver(
            self, selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(
            self, selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // The window's real bottom inset, from UIKit (see `safeBottom`): on the
    // first layout and whenever the safe area moves. Guarded, so writing the
    // observed model never loops a layout.
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        adoptSafeBottom()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adoptSafeBottom()
    }

    private func adoptSafeBottom() {
        let inset = view.safeAreaInsets.bottom
        if model.safeBottom != inset { model.safeBottom = inset }
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        adoptKeyboard(end: end, hiding: note.name == UIResponder.keyboardWillHideNotification)
    }

    /// The keyboard's end frame is in SCREEN coordinates (documented); the
    /// overlay fills its screen, so the conversion is the screen's own.
    private func adoptKeyboard(end: CGRect?, hiding: Bool) {
        guard !hiding, let end, let window = view.window else {
            model.keyboardOverlap = 0
            return
        }
        let inWindow = window.screen.coordinateSpace.convert(end, to: window)
        model.keyboardOverlap = MobileMessageLineModel.keyboardOverlap(
            endFrameInWindow: inWindow, windowBounds: window.bounds)
    }

    // The phone app is portrait-only; an overlay root that answered wider
    // would be asked to rotate with nothing under it.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    /// Takes a touch only on the line's door (`takesTouch`), never on its
    /// own ground — the rest of the screen stays hers.
    private final class PassthroughView: UIView {
        let model: MobileMessageLineModel

        init(model: MobileMessageLineModel) {
            self.model = model
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard MobileMessageLineModel.takesTouch(
                at: point, doorFrame: model.doorFrame, showing: model.status.current)
            else { return nil }
            let hit = super.hitTest(point, with: event)
            return hit === self ? nil : hit
        }
    }
}

/// **The shell's installer** — placed once, in the shell's background. When it
/// joins a window it raises the overlay over that window's scene; when it
/// leaves (the shell goes — a lock, a re-key's reopen), the overlay goes with
/// it, so a line never outlives the library it spoke for. The shell writes
/// `chromeInset` through it.
struct MobileMessageLineHost: UIViewRepresentable {
    let model: MobileMessageLineModel
    var chromeInset: CGFloat

    func makeUIView(context: Context) -> Probe {
        Probe(model: model)
    }

    func updateUIView(_ probe: Probe, context: Context) {
        if model.chromeInset != chromeInset { model.chromeInset = chromeInset }
    }

    static func dismantleUIView(_ probe: Probe, coordinator: ()) {
        probe.takeDown()
    }

    /// A zero-size, untouchable view whose only job is to know the window.
    final class Probe: UIView {
        let model: MobileMessageLineModel
        private(set) var overlay: MobileMessageLineWindow?

        init(model: MobileMessageLineModel) {
            self.model = model
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            isAccessibilityElement = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let scene = window?.windowScene {
                raise(over: scene)
            } else {
                takeDown()
            }
        }

        /// The scene whose activation the overlay follows (set while raised).
        private(set) weak var observedScene: UIWindowScene?

        private func raise(over scene: UIWindowScene) {
            guard overlay == nil else { return }
            let overlay = MobileMessageLineWindow(windowScene: scene)
            overlay.windowLevel = .normal + 1
            overlay.backgroundColor = .clear
            overlay.isOpaque = false
            overlay.rootViewController = MobileMessageLineController(model: model)
            // Visible, never key: `isHidden = false`, not makeKeyAndVisible —
            // and never over a scene that is not active (below).
            overlay.isHidden = scene.activationState != .foregroundActive
            self.overlay = overlay
            observe(scene)
        }

        // MARK: The scene's edges (VM-61 — the app-switcher snapshot)

        /// **The line never rides into the app-switcher snapshot.** The
        /// snapshot cover (`SnapshotPrivacy`) is a redaction applied through
        /// the SHELL's environment, and an environment cannot reach this
        /// window, so the overlay follows the scene itself: hidden the moment
        /// the scene resigns active (before iOS snapshots it — a notification,
        /// posted synchronously, rather than a SwiftUI phase that lands a pass
        /// later), every standing line withdrawn once it goes to the
        /// background (a 6 s line never outlives her leaving the app), shown
        /// again when the scene is active. A transient interruption (Control
        /// Center, a system alert) hides a line without losing it.
        private func observe(_ scene: UIWindowScene) {
            let center = NotificationCenter.default
            center.addObserver(
                self, selector: #selector(sceneWillResignActive),
                name: UIScene.willDeactivateNotification, object: scene)
            center.addObserver(
                self, selector: #selector(sceneDidEnterBackground),
                name: UIScene.didEnterBackgroundNotification, object: scene)
            center.addObserver(
                self, selector: #selector(sceneDidBecomeActive),
                name: UIScene.didActivateNotification, object: scene)
            observedScene = scene
        }

        @objc func sceneWillResignActive() {
            overlay?.isHidden = true
        }

        @objc func sceneDidEnterBackground() {
            overlay?.isHidden = true
            model.status.clear()
        }

        @objc func sceneDidBecomeActive() {
            overlay?.isHidden = false
        }

        /// The shell is gone (its view left the window, or SwiftUI dismantled
        /// it — a lock, a re-key's reopen, any state but `.ready`): the
        /// overlay goes with it, before whatever replaces the shell draws.
        func takeDown() {
            NotificationCenter.default.removeObserver(self)
            observedScene = nil
            overlay?.isHidden = true
            overlay?.rootViewController = nil
            overlay = nil
        }
    }
}
