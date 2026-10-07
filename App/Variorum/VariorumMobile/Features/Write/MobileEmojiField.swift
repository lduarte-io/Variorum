//
//  MobileEmojiField.swift
//  VariorumMobile
//
//  Round 2, batch 7 (PR19) — THE PHONE'S EMOJI PICKER, which is not a picker
//  at all: it is the emoji KEYBOARD, raised on a one-glyph field.
//
//  ── WHY THIS SHAPE ──────────────────────────────────────────────────────
//
//  The Mac's 13e E1 answer was `orderFrontCharacterPalette` — its words:
//  *"the system's own … the one place every Mac user already knows how to
//  find an emoji."* iOS has no character palette; the place every iPhone
//  user already knows is the 🙂 key on their own keyboard. So the phone's
//  road is to OPEN THAT, on a field whose whole content is the glyph.
//
//  `UITextInputMode.activeInputModes` and `primaryLanguage` are the public
//  API for it, and the mechanism is honest about its own preconditions: the
//  emoji keyboard is on by default but a user can remove it, and it is
//  absent in some locales. **When it is absent this falls back to
//  `super.textInputMode` — the ordinary keyboard — which is EXACTLY the
//  prompt that shipped.** So the fallback is structural rather than
//  promised: there is no arm that can fail, only one that upgrades.
//
//  ── THE RULE IS A PURE FUNCTION, ON PURPOSE ─────────────────────────────
//
//  `UITextInputMode` cannot be constructed in a test — so the *selection
//  rule* is lifted out of the override into `emojiMode(in:primaryLanguage:)`,
//  generic over anything that can name a language. That is the half worth
//  pinning (it is where a typo would silently disable the whole feature),
//  and it is pinned against fakes. The override is then two lines that
//  cannot be wrong in an interesting way, and its own behaviour is a device
//  fact recorded rather than claimed.
//

import UIKit

/// The one-glyph entry that raises the emoji keyboard.
///
/// `textInputContextIdentifier` is deliberately `""`: it stops UIKit
/// remembering this field's keyboard choice and applying it to unrelated
/// fields (and vice versa) — without it, a field that once raised emoji can
/// keep raising it elsewhere in the app.
final class MobileEmojiTextField: UITextField {
    override var textInputContextIdentifier: String? { "" }

    override var textInputMode: UITextInputMode? {
        MobileEmojiKeyboard.emojiMode(
            in: UITextInputMode.activeInputModes, primaryLanguage: \.primaryLanguage)
            ?? super.textInputMode
    }
}

/// The emoji row's host: title, message, the one-glyph field, Cancel/Set.
///
/// It exists because the emoji keyboard needs a field we own (see above) and
/// `UIAlertController` never yields one. Everything else about it is the
/// alert's contract, kept byte-for-byte so the row's SEMANTICS do not move
/// with its chrome: **cancel calls back `nil` (nothing happens); Set calls
/// back the text, and EMPTY is a real answer meaning "no glyph"** — the Mac
/// `CalloutMenu.promptEmoji`'s rule, which `MobileCallout.apply(.emoji(""))`
/// then honours by trimming to none.
///
/// The completion fires EXACTLY ONCE on every road out, the swipe-to-dismiss
/// one included (`presentationControllerDidDismiss`) — a prompt that could
/// leave its caller waiting forever is the shape a menu row must not have.
@MainActor
final class MobileEmojiPromptController: UIViewController, UIAdaptivePresentationControllerDelegate {
    private let messageText: String
    private var completion: ((String?) -> Void)?
    let field = MobileEmojiTextField()
    /// The content's scroll (MINOR 4) — the reason the Cancel/Set row stays
    /// reachable at accessibility text sizes.
    let scroll = UIScrollView()

    init(title: String, message: String, completion: @escaping @MainActor (String?) -> Void) {
        self.messageText = message
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            // **THE SHEET CAN GROW, AND ITS CONTENT SCROLLS** (the batch-7
            // fix wave, cold review MINOR 4). A single hard 220 pt detent
            // over a stack with no bottom constraint and no scroll meant
            // that at accessibility text sizes — `.headline` and
            // `.footnote` both scale, and the message wraps to more lines —
            // the Cancel/Set row was pushed off the surface, leaving
            // swipe-to-dismiss (a CANCEL) as the only road out: the emoji
            // could never be SET at large text sizes. MobileSoul §5.6 names
            // Dynamic Type as a phone-native expectation.
            //
            // Two changes, both cheap: the resting height is CLAMPED to
            // what the sheet may actually take, and `.medium()` joins it so
            // the sheet can grow; `viewDidLoad` puts the stack in a scroll
            // view so the buttons are reachable at any size regardless.
            sheet.detents = [
                .custom(identifier: .init("callout.emoji")) { context in
                    min(220, context.maximumDetentValue)
                },
                .medium(),
            ]
            sheet.prefersGrabberVisible = true
        }
        presentationController?.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "callout.emoji.sheet"

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true

        let messageLabel = UILabel()
        messageLabel.text = messageText
        messageLabel.font = .preferredFont(forTextStyle: .footnote)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.font = .systemFont(ofSize: 28)
        field.textAlignment = .center
        field.accessibilityIdentifier = "callout.emoji.field"
        field.accessibilityLabel = "Callout emoji"

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.accessibilityIdentifier = "callout.emoji.cancel"
        cancel.addAction(UIAction { [weak self] _ in self?.finish(nil) }, for: .touchUpInside)

        let set = UIButton(type: .system)
        set.setTitle("Set", for: .normal)
        set.accessibilityIdentifier = "callout.emoji.set"
        set.addAction(
            UIAction { [weak self] _ in self?.finish(self?.field.text ?? "") },
            for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [cancel, UIView(), set])
        buttons.axis = .horizontal
        buttons.distribution = .fill

        let stack = UIStackView(arrangedSubviews: [
            titleLabel, messageLabel, field, buttons,
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        // The content SCROLLS (MINOR 4): with the stack pinned straight to
        // the view — leading/trailing/top only, no bottom, no scroll —
        // anything taller than the detent simply fell off the sheet. The
        // stack now owns the scroll's content guide top AND bottom, which
        // is what gives the scroll a content height to work with, and its
        // width follows the frame guide so nothing lays out horizontally.
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.accessibilityIdentifier = "callout.emoji.scroll"
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.leadingAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(
                equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The whole point: the emoji keyboard rises with the sheet.
        field.becomeFirstResponder()
    }

    /// Answers once and dismisses. `completion` is cleared first, so a
    /// dismissal callback arriving after a button press cannot answer twice.
    private func finish(_ answer: String?) {
        guard let completion else { return }
        self.completion = nil
        dismiss(animated: true) { completion(answer) }
    }

    /// Swipe-to-dismiss is a CANCEL — the road the alert's own dismissal
    /// takes, kept so the semantics travel with the chrome.
    nonisolated func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        MainActor.assumeIsolated {
            guard let completion else { return }
            self.completion = nil
            completion(nil)
        }
    }
}

nonisolated enum MobileEmojiKeyboard {
    /// The language tag iOS gives its emoji keyboard.
    static let emojiLanguage = "emoji"

    /// **The rule**: the first active input mode whose primary language is
    /// the emoji keyboard's, or nil when the user does not have one enabled
    /// (the fallback arm — the ordinary keyboard, i.e. the shipped prompt).
    ///
    /// Generic over the naming so a pin can drive it with fakes;
    /// `UITextInputMode` has no public initializer, and a rule that can only
    /// be exercised on a device is a rule that ships unpinned.
    static func emojiMode<Mode>(
        in modes: [Mode], primaryLanguage: (Mode) -> String?
    ) -> Mode? {
        modes.first { primaryLanguage($0) == emojiLanguage }
    }
}
