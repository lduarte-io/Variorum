//
//  SupportDraft.swift
//  Variorum (MAC ONLY)
//
//  Phase 13r U3-B — THE SUPPORT DOOR'S MAIL DRAFT (R-13r-3/9: "Help ▸ Send
//  Feedback… opens a mail draft to support@stargazing.tech … Nothing is ever
//  sent silently"; R-13r-5: a crash report's "send = the support door's mail
//  draft with the report attached").
//
//  ONE builder, two drafts: the feedback draft (pre-filled with the app and
//  OS versions — and with nothing else) and the crash-report draft (the same
//  draft, the report attached). Everything the draft carries is on screen in
//  the mail app before she sends it; Variorum never sends mail itself.
//
//  The pure half lives here (the words, the versions, the `mailto:` form),
//  so every claim about what a draft contains is pinnable without a mail app
//  (`SupportDraftTests`). The side effect — handing a draft to a mail app —
//  is `SupportMail.swift`.
//

import Foundation

nonisolated struct SupportDraft: Equatable, Sendable {
    /// R-13r-9's address. The mailbox is LIVE (the plan's SITE-SIDE REPORT).
    static let address = "support@stargazing.tech"

    let recipient: String
    let subject: String
    /// Plain text with `\n` line breaks.
    let body: String
    /// The crash report's own file, attached as it is — the very bytes the
    /// Diagnostics surface showed. Nil for feedback.
    let attachment: URL?

    // MARK: The versions (the only thing a draft is pre-filled with)

    nonisolated struct Versions: Equatable, Sendable {
        /// The marketing version (0.9.0).
        let app: String
        /// The stamped build number (R-13r-6's commit count).
        let build: String
        /// "macOS 27.0 (26A428)".
        let os: String

        var lines: [String] { ["Variorum \(app) (\(build))", os] }

        /// The running app and this Mac.
        static func thisMac(
            bundle: Bundle = .main, process: ProcessInfo = .processInfo
        ) -> Versions {
            Versions(
                app: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                    ?? "?",
                build: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?",
                os: osLine(
                    version: process.operatingSystemVersion,
                    versionString: process.operatingSystemVersionString))
        }

        /// "macOS 27.0 (26A428)" from the OS's own numbers and its version
        /// string ("Version 27.0 (Build 26A428)"); the build is left off
        /// rather than guessed when the string does not carry one.
        static func osLine(version: OperatingSystemVersion, versionString: String) -> String {
            var number = "\(version.majorVersion).\(version.minorVersion)"
            if version.patchVersion > 0 { number += ".\(version.patchVersion)" }
            guard let start = versionString.range(of: "(Build "),
                  let end = versionString[start.upperBound...].firstIndex(of: ")")
            else { return "macOS \(number)" }
            let build = versionString[start.upperBound..<end]
            return build.isEmpty ? "macOS \(number)" : "macOS \(number) (\(build))"
        }
    }

    // MARK: The two drafts

    /// Help ▸ Send Feedback…: room to write at the top, then the versions.
    static func feedback(_ versions: Versions) -> SupportDraft {
        SupportDraft(
            recipient: address, subject: SupportCopy.feedbackSubject,
            body: Self.body(footer: versions.lines), attachment: nil)
    }

    /// A crash report's Send: the feedback draft's shape, the report attached.
    static func crashReport(fileName: String, at url: URL, _ versions: Versions) -> SupportDraft {
        SupportDraft(
            recipient: address, subject: SupportCopy.crashSubject,
            body: Self.body(footer: [SupportCopy.attachedLine(fileName)] + versions.lines),
            attachment: url)
    }

    /// The fallback twin when no mail app can take an attachment (a
    /// `mailto:` cannot carry one — Apple's QA1018): the same draft without
    /// it, naming the file she attaches by hand (Variorum shows it to her in
    /// Finder). PROVISIONAL — QUESTIONS #181.
    func attachingByHand() -> SupportDraft {
        guard let attachment else { return self }
        let name = attachment.lastPathComponent
        return SupportDraft(
            recipient: recipient, subject: subject,
            body: body.replacingOccurrences(
                of: SupportCopy.attachedLine(name), with: SupportCopy.attachByHandLine(name)),
            attachment: nil)
    }

    /// Three empty lines to write in, a rule, then the footer.
    private static func body(footer: [String]) -> String {
        "\n\n\n" + SupportCopy.footerRule + "\n" + footer.joined(separator: "\n") + "\n"
    }

    // MARK: The mailto: form (RFC 6068)

    /// `mailto:<address>?subject=…&body=…` — every character outside RFC
    /// 3986's unreserved set percent-encoded, line breaks as CRLF (RFC 6068
    /// §5). It carries no attachment; that is what `SupportMail` is for.
    var mailtoURL: URL? {
        let subjectPart = Self.encode(subject)
        let bodyPart = Self.encode(
            body.replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\n", with: "\r\n"))
        return URL(string: "mailto:\(recipient)?subject=\(subjectPart)&body=\(bodyPart)")
    }

    private static let unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    private static func encode(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: unreserved) ?? ""
    }
}

/// The support door's words. Functional and honest; 13s re-voices.
nonisolated enum SupportCopy {
    /// Help ▸ Send Feedback… (R-13r-3's own words).
    static let feedbackMenuTitle = "Send Feedback\u{2026}"
    static let feedbackSubject = "Variorum feedback"
    static let crashSubject = "Variorum crash report"
    static let footerRule = "\u{2014}\u{2014}\u{2014}"

    static func attachedLine(_ fileName: String) -> String {
        "Attached: \(fileName) \u{2014} the crash report exactly as Variorum showed it to you."
    }

    static func attachByHandLine(_ fileName: String) -> String {
        "Please attach \(fileName) \u{2014} Variorum has shown it to you in Finder. "
            + "It is the crash report exactly as Variorum showed it to you."
    }

    /// The refusal when no mail app could open a draft at all.
    static let nothingCouldOpen =
        "Variorum couldn\u{2019}t open an email draft. You can write to "
        + "\(SupportDraft.address) from any mail app \u{2014} nothing was sent."

    // MARK: The pre-draft choice (19f — her QUESTIONS #181 (i) ruling)

    /// The two roads, in her own words at the ruling.
    static let openInMail = "Open in Mail"
    static let showFileAndCopyAddress = "Show the file and copy the address"
    static let copyAddress = "Copy the address"

    static let feedbackChoiceTitle = "Send feedback"
    static let feedbackChoiceDetail =
        "Open in Mail starts a draft to \(SupportDraft.address) in your mail app. Or Variorum "
        + "copies the address, so you can write from any mail app. Nothing is sent until you "
        + "send it."

    static let reportChoiceTitle = "Send this crash report"
    static let reportChoiceDetail =
        "Open in Mail starts a draft to \(SupportDraft.address) with the report attached. Or "
        + "Variorum shows the report\u{2019}s file in Finder and copies the address, so you can "
        + "send it from any mail app. Nothing is sent until you send it."

    /// What the second road says it did (a receipt — nothing was sent).
    static let copiedAddress =
        "Copied \(SupportDraft.address) \u{2014} paste it into any mail app."

    static func copiedAddressShowingFile(_ fileName: String) -> String {
        "Copied \(SupportDraft.address) and showed \(fileName) in Finder \u{2014} attach it "
            + "to an email from any mail app."
    }
}
