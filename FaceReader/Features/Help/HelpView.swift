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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22 * PhoneLayout.metricScale) {
                introCard

                sectionHeader(L10n.helpGradesSectionTitle)
                    .padding(.top, 4)

                VStack(spacing: 26 * PhoneLayout.metricScale) {
                    ForEach(0 ..< 5, id: \.self) { index in
                        gradeCard(index: index)
                            .padding(.top, 16 * PhoneLayout.metricScale)
                    }
                }
            }
            .padding(.horizontal, 18 * PhoneLayout.metricScale)
            .padding(.top, 16 * PhoneLayout.metricScale)
            .padding(.bottom, 28 * PhoneLayout.metricScale)
        }
        .background(Color.vhsBase)
        .safeAreaInset(edge: .top, spacing: 0) {
            ZStack {
                Text(L10n.helpScreenTitle)
                    .font(.app(16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vhsInk)
                    .frame(maxWidth: .infinity)

                HStack {
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
                        .padding(.leading, 6)
                    Spacer()
                }
            }
            .frame(height: 44)
            .background(Color.vhsBase)
        }
    }

    // MARK: - Intro

    @ViewBuilder
    private var introCard: some View {
        VStack(alignment: .leading, spacing: 14 * PhoneLayout.metricScale) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.vhsCyan)
                Text(L10n.helpIntroTitle)
                    .font(.app(20))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.vhsInk)
            }

            VStack(alignment: .leading, spacing: 12 * PhoneLayout.metricScale) {
                introBullet(icon: "ruler", color: .vhsCyan, text: L10n.helpIntroBullet1)
                introBullet(icon: "viewfinder", color: .vhsMagenta, text: L10n.helpIntroBullet2)
                introBullet(icon: "arrow.up.right.circle.fill", color: .vhsRed, text: L10n.helpIntroBullet3)
            }
        }
        .padding(16 * PhoneLayout.metricScale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vhsSurface)
        .overlay(
            Rectangle()
                .stroke(Color.vhsInk, lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func introBullet(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 24, alignment: .center)
                .padding(.top, 2)
            Text(text)
                .font(.app(15))
                .foregroundStyle(Color.vhsInk)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color.vhsInk.opacity(0.4))
                .frame(width: 18, height: 2)
            Text(text)
                .font(.app(13))
                .fontWeight(.heavy)
                .foregroundStyle(Color.vhsInk.opacity(0.8))
                .textCase(.uppercase)
            Rectangle()
                .fill(Color.vhsInk.opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: 1)
                .frame(height: 1)
        }
    }

    // MARK: - Grade card

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
                .foregroundStyle(Color.vhsInk.opacity(0.95))
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
                .offset(y: -10 * PhoneLayout.metricScale)
                .padding(.horizontal, 16 * PhoneLayout.metricScale)
        }
    }

    private struct StampSpec {
        let tone: KitschStamp.Tone
        let color: Color
        let alignment: Alignment
        let rotation: Double
    }

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
