//
//  SettingsView.swift
//  FaceReader
//

import FaceReaderLocalization
import FaceReaderUI
import SwiftUI

struct SettingsView: View {
    let currentOverride: String?
    let onSelect: (String?) -> Void
    let onCancel: () -> Void

    private struct LanguageRow: Identifiable {
        let id: String
        let storageTag: String?
        let title: String
    }

    private var languageRows: [LanguageRow] {
        [
            LanguageRow(id: "system", storageTag: nil, title: L10n.languageOptionSystem),
            LanguageRow(id: "en", storageTag: "en", title: "English"),
            LanguageRow(id: "ja", storageTag: "ja", title: "日本語"),
            LanguageRow(id: "ko", storageTag: "ko", title: "한국어"),
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(languageRows) { row in
                        Button {
                            onSelect(row.storageTag)
                        } label: {
                            HStack {
                                Text(row.title)
                                    .font(.app(17))
                                    .foregroundStyle(Color.appText)
                                Spacer()
                                if isSelected(row) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.appText)
                                }
                            }
                        }
                    }
                } header: {
                    Text(L10n.settingsLanguage)
                        .font(.app(13))
                        .foregroundStyle(Color.appText.opacity(0.75))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.settingsDone) {
                        onCancel()
                    }
                    .foregroundStyle(Color.appText)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(Color.appText)
    }

    private func isSelected(_ row: LanguageRow) -> Bool {
        switch (row.storageTag, currentOverride) {
        case (nil, nil):
            return true
        case let (a?, b?):
            return a == b
        default:
            return false
        }
    }
}
