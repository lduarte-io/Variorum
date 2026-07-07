//
//  EntryListView.swift
//  VariorumMobile
//
//  Phase 8, Step 4 — the past-entries list. Reading is cheap: SwiftUI's
//  list machinery virtualizes; no live editor exists here at all (P3).
//  Functional and unstyled.
//

import SwiftUI
import VariorumCore

struct EntryListView: View {
    @Bindable var model: EntryListViewModel
    let open: (String) -> Void
    @State private var showingDatePicker = false
    @State private var pickedDate = Date()

    var body: some View {
        List {
            if let error = model.lastError {
                Text(error).font(.caption).foregroundStyle(.red)
            }
            ForEach(model.visible, id: \.postID) { item in
                Button {
                    open(item.postID)
                } label: {
                    VStack(alignment: .leading) {
                        Text(rowTitle(item))
                        if model.scope == .all, let entryDate = item.entryDate {
                            Text(entryDate).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Scope", selection: $model.scope) {
                    ForEach(EntryListViewModel.Scope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Today") {
                    Task {
                        if let id = await model.openToday() { open(id) }
                    }
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Entry for a date…") { showingDatePicker = true }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack(spacing: 16) {
                Text("Open or create the entry for a day")
                    .font(.headline)
                DatePicker("Day", selection: $pickedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Button("Open entry") {
                    showingDatePicker = false
                    Task {
                        if let id = await model.open(on: model.dayString(for: pickedDate)) {
                            open(id)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func rowTitle(_ item: Queries.TimelineItem) -> String {
        if model.scope == .journal {
            return item.entryDate ?? item.title ?? "Untitled"
        }
        return item.title ?? item.entryDate ?? "Untitled"
    }
}
