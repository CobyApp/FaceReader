//
//  HelpView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct HelpView: View {
    @Bindable var store: StoreOf<HelpFeature>

    var body: some View {
        NavigationStack {
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
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle(L10n.helpDisasterLevelTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.btnOk) {
                        store.send(.closeTapped)
                    }
                    .foregroundStyle(Color.appText)
                }
            }
        }
    }
}
