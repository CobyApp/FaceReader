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

    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    private struct LanguageRow: Identifiable {
        let id: String
        let storageTag: String?
        let title: String
        let channel: String
    }

    private var languageRows: [LanguageRow] {
        [
            LanguageRow(id: "system", storageTag: nil, title: L10n.languageOptionSystem, channel: "CH 00"),
            LanguageRow(id: "en", storageTag: "en", title: "English", channel: "CH 01"),
            LanguageRow(id: "ja", storageTag: "ja", title: "日本語", channel: "CH 02"),
            LanguageRow(id: "ko", storageTag: "ko", title: "한국어", channel: "CH 03"),
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20 * PhoneLayout.metricScale) {
                    KitschStamp(L10n.vhsChSelect, tone: .red, rotation: -4)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(spacing: 0) {
                        ForEach(Array(languageRows.enumerated()), id: \.element.id) { idx, row in
                            Button {
                                onSelect(row.storageTag)
                            } label: {
                                HStack {
                                    Text(row.channel)
                                        .font(.app(14))
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.vhsRed)
                                        .frame(width: 56 * PhoneLayout.metricScale, alignment: .leading)
                                    Text(row.title)
                                        .font(.app(18))
                                        .foregroundStyle(Color.vhsInk)
                                    Spacer()
                                    if isSelected(row) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.vhsRed)
                                    }
                                }
                                .padding(.horizontal, 16 * PhoneLayout.metricScale)
                                .padding(.vertical, 14 * PhoneLayout.metricScale)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if idx < languageRows.count - 1 {
                                Rectangle()
                                    .fill(Color.vhsInk.opacity(0.25))
                                    .frame(height: 1)
                                    .padding(.horizontal, 12 * PhoneLayout.metricScale)
                            }
                        }
                    }
                    .background(Color.vhsSurface)
                    .overlay(
                        Rectangle()
                            .stroke(Color.vhsInk, lineWidth: 2)
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $prefs.reducedEffects) {
                            Text(L10n.vhsReduceEffectsTitle)
                                .font(.app(17))
                                .foregroundStyle(Color.vhsInk)
                        }
                        .tint(Color.vhsRed)
                        .padding(.horizontal, 16 * PhoneLayout.metricScale)
                        .padding(.vertical, 14 * PhoneLayout.metricScale)
                        .background(Color.vhsSurface)
                        .overlay(
                            Rectangle()
                                .stroke(Color.vhsInk, lineWidth: 2)
                        )

                        Text(L10n.vhsReduceEffectsFooter)
                            .font(.app(13))
                            .foregroundStyle(Color.vhsInk.opacity(0.7))
                            .padding(.horizontal, 4)
                    }
                }
                .padding(18 * PhoneLayout.metricScale)
            }
            .scrollContentBackground(.hidden)
            .background(Color.vhsBase)
            .vhsOverlay()
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.settingsDone) {
                        onCancel()
                    }
                    .foregroundStyle(Color.vhsInk)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(Color.vhsInk)
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
