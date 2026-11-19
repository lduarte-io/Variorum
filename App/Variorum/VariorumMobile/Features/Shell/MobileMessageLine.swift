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
//  **Today's tokens, no restyle** (umbrella VM-47 owns sizes): the words in
//  `tokens.small` — a refusal in the alarm ink every phone error slot wore, a
//  removal in the muted ink every phone receipt wore, its Undo in the accent —
//  on the room with the tab bar's hairline, because a line that floats over
//  content needs a ground to be read on.
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

    /// How far above the safe area's foot the line sits when the keyboard is
    /// down: the tab bar's height on a root (the line never covers the bar's
    /// doors), zero inside a pushed screen. The shell writes it.
    var chromeInset: CGFloat = 0
    /// How much of the window's foot the keyboard covers, from the keyboard
    /// frame notifications (zero while it is down).
    var keyboardOverlap: CGFloat = 0

    /// The line's door, in the overlay's coordinate space — the ONLY region
    /// that takes a touch. Not observed: hit-testing reads it, nothing draws it.
    @ObservationIgnored var doorFrame: CGRect?

    init(status: StatusCenter, voice: @escaping @MainActor () -> ThemeVoice) {
        self.status = status
        self.voice = voice
    }

    /// **Where the line's foot sits above the safe area's foot** — pure,
    /// pinned. Above the keyboard when it is up (its overlap is measured from
    /// the window's foot, so the safe-area inset it already covers comes off);
    /// above the tab bar on a root; never below the safe area.
    static func lift(keyboardOverlap: CGFloat, safeBottom: CGFloat, chromeInset: CGFloat) -> CGFloat {
        max(keyboardOverlap - safeBottom, chromeInset, 0)
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

/// The coordinate space the line's door reports in — the overlay window's
/// own (the hosting view fills it from the origin).
private let messageLineSpace = "MobileMessageLine"

struct MobileMessageLineView: View {
    let model: MobileMessageLineModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let tokens = VoiceTokens.resolve(voice: model.voice(), dark: scheme == .dark)
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                if let item = model.status.current {
                    line(item, tokens: tokens)
                        .transition(.opacity)
                }
            }
            .padding(.bottom, MobileMessageLineModel.lift(
                keyboardOverlap: model.keyboardOverlap,
                safeBottom: proxy.safeAreaInsets.bottom,
                chromeInset: model.chromeInset))
        }
        // The keyboard is tracked from its own notifications (the overlay is
        // never the key window), so SwiftUI's avoidance must not add a second
        // lift on top.
        .ignoresSafeArea(.keyboard)
        .coordinateSpace(.named(messageLineSpace))
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
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            if !item.text.isEmpty {
                Text(words(item, tokens: tokens))
                    .font(tokens.small)
                    .foregroundStyle(ink(item, tokens: tokens))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
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
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .buttonStyle(.plain)
                .accessibilityLabel(action.label)
                .onGeometryChange(for: CGRect.self) { geometry in
                    geometry.frame(in: .named(messageLineSpace))
                } action: { frame in
                    model.doorFrame = frame
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
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
        case .receipt: return tokens.muted
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

        private func raise(over scene: UIWindowScene) {
            guard overlay == nil else { return }
            let overlay = MobileMessageLineWindow(windowScene: scene)
            overlay.windowLevel = .normal + 1
            overlay.backgroundColor = .clear
            overlay.isOpaque = false
            overlay.rootViewController = MobileMessageLineController(model: model)
            // Visible, never key: `isHidden = false`, not makeKeyAndVisible.
            overlay.isHidden = false
            self.overlay = overlay
        }

        func takeDown() {
            overlay?.isHidden = true
            overlay?.rootViewController = nil
            overlay = nil
        }
    }
}
