//
//  HelpView.swift
//  FaceReader
//

import FaceReaderLocalization
import FaceReaderUI
import SwiftUI

/// Disaster-level (怪人) grade reference — third step after the measurement result.
public struct HelpView: View {
    private let onFinished: () -> Void

    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.helpDisasterLevelTitle)
                    .font(.app(22))
                    .foregroundStyle(Color.appText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                ForEach(0 ..< 5, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(GradeAssets.imageName(for: index))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 68 * PhoneLayout.metricScale, height: 68 * PhoneLayout.metricScale)
                                .clipShape(RoundedRectangle(cornerRadius: 11 * PhoneLayout.metricScale))
                            Text(L10n.gradeName(for: index))
                                .font(.app(20))
                                .foregroundStyle(Color.appText)
                        }
                        Text(L10n.gradeDetail(for: index))
                            .font(.app(16))
                            .foregroundStyle(Color.appText.opacity(0.85))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appText.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(18 * PhoneLayout.metricScale)
        }
        .background(Color.appBackground)
        .navigationTitle(L10n.helpDisasterLevelTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.btnBackToMeter) {
                    onFinished()
                }
                .foregroundStyle(Color.appText)
            }
        }
    }
}
