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
        /// 라벨 텍스트를 어떤 언어용 폰트로 그릴지 — 활성 언어가 아니라 '라벨 자체의 언어' 기준.
        /// 예: '日本語' 는 항상 일본어 폰트, '한국어' 는 항상 한국어 폰트.
        let fontTag: String?
    }

    private var languageRows: [LanguageRow] {
        [
            LanguageRow(id: "system", storageTag: nil, title: L10n.languageOptionSystem, fontTag: nil),
            LanguageRow(id: "en", storageTag: "en", title: "English", fontTag: "en"),
            LanguageRow(id: "ja", storageTag: "ja", title: "日本語", fontTag: "ja"),
            LanguageRow(id: "ko", storageTag: "ko", title: "한국어", fontTag: "ko"),
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24 * PhoneLayout.metricScale) {
                    section(header: L10n.settingsLanguage) {
                        VStack(spacing: 0) {
                            ForEach(Array(languageRows.enumerated()), id: \.element.id) { idx, row in
                                languageCell(row)
                                if idx < languageRows.count - 1 {
                                    Rectangle()
                                        .fill(Color.vhsInk.opacity(0.18))
                                        .frame(height: 1)
                                        .padding(.horizontal, 12 * PhoneLayout.metricScale)
                                }
                            }
                        }
                        .background(Color.vhsSurface)
                        .overlay(
                            Rectangle()
                                .stroke(Color.vhsInk, lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 18 * PhoneLayout.metricScale)
                .padding(.vertical, 20 * PhoneLayout.metricScale)
            }
            .scrollContentBackground(.hidden)
            .background(Color.vhsBase)
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.vhsInk)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onCancel()
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(L10n.settingsDone)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(Color.vhsInk)
    }

    @ViewBuilder
    private func section<Content: View>(header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.app(13))
                .fontWeight(.heavy)
                .foregroundStyle(Color.vhsInk.opacity(0.7))
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            content()
        }
    }

    @ViewBuilder
    private func languageCell(_ row: LanguageRow) -> some View {
        HStack {
            Text(row.title)
                .font(.app(17, languageTag: row.fontTag))
                .foregroundStyle(Color.vhsInk)
            Spacer()
            if isSelected(row) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.vhsRed)
            }
        }
        .padding(.horizontal, 16 * PhoneLayout.metricScale)
        .padding(.vertical, 14 * PhoneLayout.metricScale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(row.storageTag)
        }
        .accessibilityAddTraits(.isButton)
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
