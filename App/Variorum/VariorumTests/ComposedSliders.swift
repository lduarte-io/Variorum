//
//  ComposedSliders.swift
//  VariorumTests
//
//  18k C6 — KnownIssues row 65, items 3–4 (the two scrubber pins) and the
//  Outline's zero-slider arm beside them.
//
//  **Why the scrubber pins cannot count an AppKit class any more, measured
//  on macOS 27.0:** SwiftUI's `Slider` no longer puts an `NSSlider` — or any
//  NSView at all — in the hosting view. A bare `Slider` hosted on 27 leaves
//  `NSHostingView`, a `KeyViewProxy` and focus-ring views and nothing else,
//  while `ProgressView` is still an `NSProgressIndicator` and a segmented
//  `Picker` still an `NSSegmentedControl` (so those counts elsewhere keep
//  their teeth). The accessibility tree is no road either: in-process, with
//  no assistive client attached, SwiftUI builds no accessibility nodes —
//  `accessibilityChildren()` is empty and 750 hit-tests along the bar all
//  answer the hosting view's own group.
//
//  **So these pins read the COMPOSITION**, the road `SurfaceComposition`
//  already sanctions for SwiftUI-drawn content (its header states the limit:
//  it proves a control is COMPOSED, not that it is VISIBLE; the hosted window
//  beside it proves the surface builds and lays out). Two things keep it
//  honest here:
//  - **Nodes, not text.** A `Slider` node is counted when a value's OWN type
//    is `SwiftUI.Slider<…>`. Searching the dump's text would count every
//    ancestor whose generic signature spells the Slider out (24 lines for the
//    one Slider in the paged bar).
//  - **"And it works."** Each node carries the `Binding<Double>` it drives,
//    found by TYPE (never by SwiftUI's internal field names — `LibraryPanel
//    HostTests`' "inspector" pin is what trusting an OS-internal name costs).
//    A pin sets it and watches the surface move: the same setter a click on
//    the track calls.
//
//  The walk stays inside the composition: it descends into SwiftUI's own
//  values (structs, enums, and SwiftUI's own storage classes such as
//  `AnyView`'s), never into the app's models a view captures, and each
//  SwiftUI class is visited once.
//

import Foundation
import SwiftUI

@MainActor
enum ComposedSliders {
    /// One entry per `Slider` node in `view`'s composition, in walk order,
    /// each with the binding that node drives (nil when none was found by
    /// type — a pin that needs it `#require`s it).
    static func find<V: View>(in view: V) -> [Binding<Double>?] {
        var found: [Binding<Double>?] = []
        var visited = Set<ObjectIdentifier>()
        walk(view, depth: 0, visited: &visited, into: &found)
        return found
    }

    private static func walk(
        _ value: Any, depth: Int,
        visited: inout Set<ObjectIdentifier>, into found: inout [Binding<Double>?]
    ) {
        guard depth < 400 else { return }
        let name = String(reflecting: type(of: value))
        if name.hasPrefix("SwiftUI.Slider<") {
            found.append(binding(in: value, depth: 0))
            return
        }
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .class {
            guard name.hasPrefix("SwiftUI.") else { return }  // an app model, not composition
            let id = ObjectIdentifier(value as AnyObject)
            guard visited.insert(id).inserted else { return }
        }
        for child in mirror.children {
            walk(child.value, depth: depth + 1, visited: &visited, into: &found)
        }
    }

    private static func binding(in value: Any, depth: Int) -> Binding<Double>? {
        if let binding = value as? Binding<Double> { return binding }
        guard depth < 8 else { return nil }
        for child in Mirror(reflecting: value).children {
            if let binding = binding(in: child.value, depth: depth + 1) { return binding }
        }
        return nil
    }
}
