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
            VStack(spacing: 26 * PhoneLayout.metricScale) {
                ForEach(0 ..< 5, id: \.self) { index in
                    gradeCard(index: index)
                        .padding(.top, 16 * PhoneLayout.metricScale)  // 위로 튀어나온 스탬프 공간
                }
            }
            .padding(.horizontal, 18 * PhoneLayout.metricScale)
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
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.vhsInk)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onFinished()
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(L10n.btnBackToMeter)
                        .padding(.trailing, 6)
                }
            }
            .frame(height: 44)
            .background(Color.vhsBase)
        }
    }

    @ViewBuilder
    private func gradeCard(index: Int) -> some View {
        let spec = Self.stampSpec(for: index)
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
                    .foregroundStyle(spec.color)
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
        .overlay(alignment: spec.alignment) {
            KitschStamp(L10n.vhsLevelLabel(index), tone: spec.tone, rotation: spec.rotation)
                .offset(y: -18 * PhoneLayout.metricScale)
                .padding(.horizontal, 16 * PhoneLayout.metricScale)
        }
        .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 3)
    }

    private struct StampSpec {
        let tone: KitschStamp.Tone
        let color: Color
        let alignment: Alignment
        let rotation: Double
    }

    /// 등급별 스탬프 색상/위치/회전. 좌우 교대 + 위협도 색상.
    private static func stampSpec(for index: Int) -> StampSpec {
        let left = (index % 2 == 0)
        let alignment: Alignment = left ? .topLeading : .topTrailing
        let rotation: Double = left ? -8 : 8
        switch index {
        case 0: return StampSpec(tone: .cyan, color: .vhsCyan, alignment: alignment, rotation: rotation)
        case 1: return StampSpec(tone: .magenta, color: .vhsMagenta, alignment: alignment, rotation: rotation)
        case 2: return StampSpec(tone: .red, color: .vhsRed, alignment: alignment, rotation: rotation)
        case 3: return StampSpec(tone: .magenta, color: .vhsMagenta, alignment: alignment, rotation: rotation)
        default: return StampSpec(tone: .red, color: .vhsRed, alignment: alignment, rotation: rotation)
        }
    }
}
