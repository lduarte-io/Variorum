//
//  MobileRenderedPixels.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, part A's fixes) — **WHAT A SURFACE DRAWS, READ
//  AS PIXELS.** Three of the walk's findings are facts no frame or property
//  can hold: a ground that stops at the safe area (W-A1), a word drawn in an
//  ink too light for its size (W-A9), a placeholder in the system's own grey
//  (W-A10). The walk measured each from its captures; these pins measure the
//  same thing off a real window in process, so a later change that brings
//  one back trips here rather than in the next walk.
//
//  THE HOST is a real window of the test host's own SCENE (the message
//  line's pins stand theirs the same way), not `HostedSurface`'s free window:
//  a scene window covers the device's screen with the device's own safe-area
//  insets, which is exactly where W-A1 lives, and `drawHierarchy` renders it
//  as the screen would. Its host view and the window carry a SENTINEL colour,
//  so a pixel the app does not draw reads as the sentinel — never as a black
//  or white that a dark room or a white paper could pass for (the walk's own
//  trap: in dark the roots' bare strips matched the black room by
//  coincidence).
//
//  THE PIXELS are sRGB, at the screen's scale, read from a bitmap the render
//  is redrawn into — row 0 is the top of the screen.
//

import Foundation
import SwiftUI
import Testing
import UIKit
@testable import VariorumMobile

/// One pixel's colour, sRGB, each channel 0…1.
struct PixelColor: Equatable, CustomStringConvertible {
    var r: Double
    var g: Double
    var b: Double

    /// A token's colour as this trait collection resolves it.
    init(_ color: UIColor, traits: UITraitCollection) {
        let resolved = color.resolvedColor(with: traits).cgColor
        let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
        let converted = resolved.converted(to: srgb, intent: .defaultIntent, options: nil) ?? resolved
        let parts = converted.components ?? [0, 0, 0, 1]
        if parts.count >= 3 {
            r = Double(parts[0]); g = Double(parts[1]); b = Double(parts[2])
        } else {
            r = Double(parts[0]); g = r; b = r
        }
    }

    init(r: Double, g: Double, b: Double) {
        self.r = r; self.g = g; self.b = b
    }

    var description: String {
        String(format: "#%02X%02X%02X",
               Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
    }

    /// The largest channel difference — 0 for the same colour, 1 for black
    /// against white.
    func distance(to other: PixelColor) -> Double {
        max(abs(r - other.r), abs(g - other.g), abs(b - other.b))
    }

    /// WCAG 2's relative luminance (the sizing sheet's §D arithmetic).
    var luminance: Double {
        func linear(_ c: Double) -> Double {
            c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    }

    /// WCAG 2's contrast ratio, 1…21.
    func contrast(with other: PixelColor) -> Double {
        let a = luminance, b = other.luminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }
}

/// A rendered window, as pixels.
struct RenderedPixels {
    let width: Int
    let height: Int
    let scale: CGFloat
    let bytes: [UInt8]

    func color(at point: CGPoint) -> PixelColor {
        let x = min(max(Int(point.x * scale), 0), width - 1)
        let y = min(max(Int(point.y * scale), 0), height - 1)
        return pixel(x, y)
    }

    func pixel(_ x: Int, _ y: Int) -> PixelColor {
        let i = (y * width + x) * 4
        return PixelColor(
            r: Double(bytes[i]) / 255, g: Double(bytes[i + 1]) / 255, b: Double(bytes[i + 2]) / 255)
    }

    /// Every pixel inside a rect given in points.
    func colors(in rect: CGRect) -> [PixelColor] {
        let x0 = max(Int(rect.minX * scale), 0), x1 = min(Int(rect.maxX * scale), width)
        let y0 = max(Int(rect.minY * scale), 0), y1 = min(Int(rect.maxY * scale), height)
        guard x0 < x1, y0 < y1 else { return [] }
        var found: [PixelColor] = []
        found.reserveCapacity((x1 - x0) * (y1 - y0))
        for y in y0..<y1 { for x in x0..<x1 { found.append(pixel(x, y)) } }
        return found
    }

    /// **The ink of the words inside a rect, against their ground** — the
    /// ground is the rect's commonest colour; the ink is the pixel that
    /// differs from it most (a glyph's full-coverage core at the screen's
    /// scale). Returns nil for a rect with one colour only (no words drawn).
    func inkAndGround(in rect: CGRect) -> (ink: PixelColor, ground: PixelColor)? {
        let all = colors(in: rect)
        guard !all.isEmpty else { return nil }
        var counts: [Int: Int] = [:]
        func key(_ c: PixelColor) -> Int {
            Int((c.r * 255).rounded()) << 16 | Int((c.g * 255).rounded()) << 8 | Int((c.b * 255).rounded())
        }
        for c in all { counts[key(c), default: 0] += 1 }
        guard let groundKey = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        let ground = PixelColor(
            r: Double((groundKey >> 16) & 0xFF) / 255, g: Double((groundKey >> 8) & 0xFF) / 255,
            b: Double(groundKey & 0xFF) / 255)
        guard let ink = all.max(by: { $0.contrast(with: ground) < $1.contrast(with: ground) }),
              ink.distance(to: ground) > 0.02
        else { return nil }
        return (ink, ground)
    }

    /// The first column (in points, from the rect's left) holding a pixel
    /// that differs from `ground` by more than `threshold` — the left edge of
    /// whatever is drawn in the rect.
    func firstInkColumn(in rect: CGRect, ground: PixelColor, threshold: Double = 0.16) -> CGFloat? {
        let x0 = max(Int(rect.minX * scale), 0), x1 = min(Int(rect.maxX * scale), width)
        let y0 = max(Int(rect.minY * scale), 0), y1 = min(Int(rect.maxY * scale), height)
        guard x0 < x1, y0 < y1 else { return nil }
        for x in x0..<x1 {
            for y in y0..<y1 where pixel(x, y).distance(to: ground) > threshold {
                return CGFloat(x) / scale
            }
        }
        return nil
    }
}

/// A real view in a real window of the test host's scene, drawable to pixels.
@MainActor
final class SceneHostedSurface<Content: View> {
    let window: UIWindow
    let host: UIHostingController<Content>

    /// What a pixel the app does not draw reads as (see the header).
    static var sentinel: UIColor { UIColor(red: 1, green: 0, blue: 1, alpha: 1) }

    init(_ view: Content, dark: Bool, additionalInsets: UIEdgeInsets = .zero) throws {
        AccessibilityServer.armOnce()
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
            "the test host has a window scene")
        window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = dark ? .dark : .light
        window.backgroundColor = Self.sentinel
        host = UIHostingController(rootView: view)
        host.view.backgroundColor = Self.sentinel
        host.additionalSafeAreaInsets = additionalInsets
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
    }

    /// The traits the window's tokens resolve under.
    var traits: UITraitCollection { window.traitCollection }

    /// Let SwiftUI run its update passes (one layout pass per turn, as
    /// `HostedSurface.settle` does, so lazy stacks materialize their rows).
    func settle(_ turns: Int = 20) async {
        for _ in 0..<turns {
            try? await Task.sleep(for: .milliseconds(20))
            await Task.yield()
            window.setNeedsLayout()
            window.layoutIfNeeded()
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
        }
    }

    var elements: [NSObject] { HostedSurface<Content>.elements(of: host.view) }

    var labels: [String] { elements.compactMap(\.accessibilityLabel) }

    /// The on-window element with this label (the band's two offscreen roots
    /// are in every walk — `MobileTabBarTests`' recorded fact).
    func onScreen(_ label: String) -> NSObject? {
        let bounds = window.bounds.insetBy(dx: 1, dy: 1)
        return elements.first {
            $0.accessibilityLabel == label && bounds.intersects($0.accessibilityFrame)
        }
    }

    /// The window drawn as the screen would show it, in sRGB at the screen's
    /// scale. Fails loudly when nothing was drawn — a render that captured
    /// nothing must never read as a ground that is missing.
    func render(sourceLocation: SourceLocation = #_sourceLocation) throws -> RenderedPixels {
        window.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = max(window.traitCollection.displayScale, 1)
        format.opaque = true
        format.preferredRange = .standard
        var drew = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
            drew = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        try #require(drew, "drawHierarchy drew nothing — the render, not the app, failed",
                     sourceLocation: sourceLocation)
        let cg = try #require(image.cgImage, "the render has no bitmap", sourceLocation: sourceLocation)
        let width = cg.width, height = cg.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let srgb = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let redrawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: width * 4, space: srgb,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        try #require(redrawn, "the render could not be read", sourceLocation: sourceLocation)
        return RenderedPixels(width: width, height: height, scale: format.scale, bytes: bytes)
    }

    func tearDown() {
        host.dismiss(animated: false)
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// Mount in the scene, settle, run, tear down.
@MainActor
func withSceneSurface<Content: View, T>(
    _ view: Content, dark: Bool, additionalInsets: UIEdgeInsets = .zero,
    _ body: (SceneHostedSurface<Content>) async throws -> T
) async throws -> T {
    let surface = try SceneHostedSurface(view, dark: dark, additionalInsets: additionalInsets)
    defer { surface.tearDown() }
    await surface.settle()
    return try await body(surface)
}
