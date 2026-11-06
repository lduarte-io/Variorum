//
//  BookExtentSheet.swift
//  Variorum (Mac) — Core/Views (the shared home)
//
//  The extent faces (word target / post cap — the machinery that existed
//  since v1 with "no UI face at all", plus v1_11's words unit): a book row's
//  Length & Extent… door.
//
//  VX-829 (the VX-878 run, batch 1): moved here from `ShelfView.swift` at its
//  second consumer — the book row menu beyond the Bookcase draws the door too
//  (CLAUDE.md: a view two features consume lives in the shared home). It
//  decides nothing: it reports the two parsed values to its host's `save`
//  (the one brain, `BookRowDoors.saveExtents`), where the operations run.
//

import SwiftUI
import VariorumCore

struct BookExtentSheet: View {
    let reading: Reading
    /// The host's act: the word target, then the cap (nil clears either).
    let save: (_ wordTarget: Int?, _ maxPosts: Int?) async -> Void
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Length & Extent — “\(reading.name)”").font(.headline)
            Text("A word target shows progress on the Bookcase; at its end, extend it or start a new book. The note cap refuses further adds when full. Blank clears.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Form {
                TextField("Word target (e.g. 10000)", text: $wordTargetField)
                TextField("Note cap (max notes)", text: $maxPostsField)
            }
            if let parseError {
                Text(parseError).font(.caption).alarmVoice()
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    guard let target = ExtentInput.parse(wordTargetField),
                          let cap = ExtentInput.parse(maxPostsField)
                    else {
                        parseError = "Extents are plain positive numbers (e.g. 10000) — nothing was changed."
                        return
                    }
                    Task {
                        await save(target.intValue, cap.intValue)
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
        .onAppear {
            wordTargetField = reading.wordTarget.map(String.init) ?? ""
            maxPostsField = reading.maxPosts.map(String.init) ?? ""
        }
    }
}
