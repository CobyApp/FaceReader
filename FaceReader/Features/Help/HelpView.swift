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
            VStack(spacing: 18 * PhoneLayout.metricScale) {
                ForEach(0 ..< 5, id: \.self) { index in
                    gradeCard(index: index)
                }
            }
            .padding(.horizontal, 18 * PhoneLayout.metricScale)
            .padding(.top, 8 * PhoneLayout.metricScale)
            .padding(.bottom, 24 * PhoneLayout.metricScale)
        }
        .background(Color.vhsBase)
        .safeAreaInset(edge: .top, spacing: 0) {
            ZStack {
                Text(L10n.helpDisasterLevelTitle)
                    .font(.app(16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vhsInk)
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Text(L10n.btnBackToMeter)
                        .font(.app(15))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vhsInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onFinished()
                        }
                        .accessibilityAddTraits(.isButton)
                        .padding(.trailing, 6)
                }
            }
            .frame(height: 44)
            .background(Color.vhsBase)
        }
    }

    @ViewBuilder
    private func gradeCard(index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10 * PhoneLayout.metricScale) {
                Image(GradeAssets.imageName(for: index))
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160 * PhoneLayout.metricScale)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.gradeName(for: index))
                        .font(.app(22))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.vhsInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(L10n.gradeInfo(for: index))
                        .font(.app(14))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vhsRed)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(L10n.gradeDetail(for: index))
                    .font(.app(15))
                    .foregroundStyle(Color.vhsInk.opacity(0.85))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14 * PhoneLayout.metricScale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vhsSurface)
            .overlay(
                Rectangle()
                    .stroke(Color.vhsInk, lineWidth: 1.5)
            )

            KitschStamp(L10n.vhsLevelLabel(index), tone: .ink, rotation: 6)
                .padding(.top, 12)
                .padding(.trailing, 12)
        }
        .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 3)
    }
}
