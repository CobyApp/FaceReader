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
            VStack(spacing: 22 * PhoneLayout.metricScale) {
                Text(L10n.helpDisasterLevelTitle)
                    .font(.app(28))
                    .fontWeight(.black)
                    .foregroundStyle(Color.vhsInk)
                    .shadow(color: Color.vhsCyan, radius: 0, x: -1, y: 1)
                    .shadow(color: Color.vhsRed, radius: 0, x: 1, y: -1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                ForEach(0 ..< 5, id: \.self) { index in
                    polaroidCard(index: index, rotation: HelpView.tilt(for: index))
                }
            }
            .padding(18 * PhoneLayout.metricScale)
        }
        .background(Color.vhsBase)
        .vhsOverlay()
        .navigationTitle(L10n.helpDisasterLevelTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.btnBackToMeter) {
                    onFinished()
                }
                .foregroundStyle(Color.vhsInk)
            }
        }
    }

    @ViewBuilder
    private func polaroidCard(index: Int, rotation: Double) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                Image(GradeAssets.imageName(for: index))
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160 * PhoneLayout.metricScale)
                    .clipped()
                Text(L10n.gradeName(for: index))
                    .font(.app(22))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.vhsInk)
                Text(L10n.gradeDetail(for: index))
                    .font(.app(16))
                    .foregroundStyle(Color.vhsInk.opacity(0.85))
            }
            .padding(14 * PhoneLayout.metricScale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vhsSurface)
            .overlay(
                Rectangle()
                    .stroke(Color.vhsInk, lineWidth: 2)
            )

            KitschStamp(L10n.vhsLevelLabel(index), tone: .ink, rotation: 6)
                .padding(.top, -10)
                .padding(.trailing, 8)
        }
        .rotationEffect(.degrees(rotation))
        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 2, y: 4)
    }

    private static func tilt(for index: Int) -> Double {
        switch index % 5 {
        case 0: return -2
        case 1: return 1.5
        case 2: return -1
        case 3: return 2
        default: return -1.5
        }
    }
}
