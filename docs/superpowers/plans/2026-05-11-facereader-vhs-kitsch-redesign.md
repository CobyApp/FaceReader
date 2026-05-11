# FaceReader VHS 호러키치 + 카툰 UI 오버홀 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** FaceReader 앱 4개 화면(캡처/결과/도움말/설정)에 VHS 호러키치 + 카툰 마스코트 톤을 입혀, 항상 켜진 ambient 텍스처와 이벤트 기반 글리치를 도입한다.

**Architecture:** 신규 `FaceReader/UI/VHS/`, `FaceReader/UI/Kitsch/` 디렉터리에 재사용 ViewModifier/뷰를 모은다. 기존 `FaceReaderUI` 정적 프레임워크가 Tuist 글로브로 자동 픽업한다. 색상 토큰은 `AppTheme.swift`에 vhs* 토큰으로 추가하고, 기존 `Color.appText`/`Color.appBackground`는 새 토큰으로 재매핑한다 (호환 유지). 글리치/노이즈는 `accessibilityReduceMotion`과 사용자 토글로 비활성화 가능.

**Tech Stack:** Swift 5/SwiftUI, iOS 18+, Tuist (`tuist generate --no-open`), SPM, ComposableArchitecture (변경 없음). 빌드 검증은 `xcodebuild ... build`. 테스트 타겟이 없으므로 시각 검증은 SwiftUI `#Preview` + 시뮬레이터 스모크 테스트.

**Repo:** `/Users/doyoung_kim/Documents/Git/FaceReader` (자체 git 레포)

---

## 사전 준비

`/Users/doyoung_kim/Documents/Git/FaceReader` 디렉터리에서 작업한다. 새 디렉터리를 처음 추가할 때마다 `tuist generate --no-open`를 실행해 Xcode 프로젝트를 갱신한다.

빌드 확인 명령(에러 없음 = 통과):

```bash
xcodebuild \
  -workspace FaceReader.xcworkspace \
  -scheme FaceReader \
  -destination 'generic/platform=iOS Simulator' \
  -quiet \
  build
```

---

## Task 1: AppTheme — VHS 컬러 토큰 추가

**Files:**
- Modify: `FaceReader/UI/AppTheme.swift`

- [ ] **Step 1: 컬러 토큰 6개를 추가하고 기존 `appText`/`appBackground`를 vhs 토큰으로 재매핑**

`FaceReader/UI/AppTheme.swift` 파일의 `extension Color` 첫 블록을 다음으로 교체:

```swift
extension Color {
    public static let appText = Color(uiColor: .vhsInk)
    public static let appBackground = Color(uiColor: .vhsBase)
    public static let appBrown = Color(hex: 0x4B3E36)

    public static let vhsBase = Color(uiColor: .vhsBase)
    public static let vhsSurface = Color(uiColor: .vhsSurface)
    public static let vhsInk = Color(uiColor: .vhsInk)
    public static let vhsRed = Color(uiColor: .vhsRed)
    public static let vhsCyan = Color(uiColor: .vhsCyan)
    public static let vhsMagenta = Color(uiColor: .vhsMagenta)
}
```

그리고 같은 파일의 `extension UIColor` 블록의 `appMainText`/`appMainBackground` 정의는 그대로 두고, **그 위에** 다음 vhs 정적 색을 추가:

```swift
extension UIColor {
    public static var vhsBase: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#0a0808")
                : UIColor(hex: "#f1e8d0")
        }
    }
    public static var vhsSurface: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#1a1414")
                : UIColor(hex: "#e2d4b2")
        }
    }
    public static var vhsInk: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#f4e9d3")
                : UIColor(hex: "#1a1414")
        }
    }
    public static var vhsRed: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#d6433a")
                : UIColor(hex: "#b8362d")
        }
    }
    public static var vhsCyan: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#48b8c4")
                : UIColor(hex: "#3a96a2")
        }
    }
    public static var vhsMagenta: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#c34d8a")
                : UIColor(hex: "#a83d72")
        }
    }
}
```

기존 `appMainText`/`appMainBackground`는 외부에서 참조 가능성이 있으므로 그대로 둔다 (단, `Color.appText`/`Color.appBackground`는 이제 vhs 토큰을 가리킴).

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 빌드 성공 (경고 없음).

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/AppTheme.swift
git commit -m "feat(theme): VHS 컬러 토큰 6개 추가 및 appText/appBackground 재매핑"
```

---

## Task 2: VHSEffectsPreferences — 사용자 토글 + 환경값

**Files:**
- Create: `FaceReader/UI/VHS/VHSEffectsPreferences.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  VHSEffectsPreferences.swift
//  FaceReader
//

import Combine
import SwiftUI

@MainActor
public final class VHSEffectsPreferences: ObservableObject {
    public static let shared = VHSEffectsPreferences()

    @Published public var reducedEffects: Bool {
        didSet {
            UserDefaults.standard.set(reducedEffects, forKey: Self.reducedKey)
        }
    }

    private static let reducedKey = "vhs_effects_reduced"

    private init() {
        self.reducedEffects = UserDefaults.standard.bool(forKey: Self.reducedKey)
    }
}
```

- [ ] **Step 2: Tuist 재생성**

```bash
tuist generate --no-open
```

새 디렉터리가 추가됐으므로 Xcode 프로젝트 갱신 필요.

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 4: 커밋**

```bash
git add FaceReader/UI/VHS/VHSEffectsPreferences.swift
git commit -m "feat(vhs): 사용자 VHS 효과 축소 토글 (UserDefaults 영구화)"
```

---

## Task 3: 로컬라이제이션 문자열 추가

**Files:**
- Modify: `Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/L10n.swift`
- Modify: `Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/ko.lproj/Localizable.strings`
- Modify: `Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/ja.lproj/Localizable.strings`
- Modify: `Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/en.lproj/Localizable.strings`

- [ ] **Step 1: L10n.swift에 새 접근자 추가**

`L10n.swift` 파일의 `public enum L10n {` 블록 끝(닫는 `}` 직전, `private static func tr` 위)에 다음 추가:

```swift
    // VHS / Kitsch — 일부는 일부러 영문 유지 (VHS 미감의 일부)
    public static var vhsRec: String { tr("vhs_rec") }
    public static var vhsTrackingError: String { tr("vhs_tracking_error") }
    public static var vhsDanger: String { tr("vhs_danger") }
    public static var vhsChSelect: String { tr("vhs_ch_select") }
    public static var vhsReduceEffectsTitle: String { tr("vhs_reduce_effects_title") }
    public static var vhsReduceEffectsFooter: String { tr("vhs_reduce_effects_footer") }

    public static func vhsLevelLabel(_ index: Int) -> String {
        String(format: tr("vhs_level_format"), index + 1)
    }
```

- [ ] **Step 2: ko.lproj에 키 추가**

`Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/ko.lproj/Localizable.strings` 파일 끝에 추가:

```
"vhs_rec" = "REC";
"vhs_tracking_error" = "TRACKING ERROR";
"vhs_danger" = "DANGER";
"vhs_ch_select" = "CH SELECT";
"vhs_level_format" = "LEVEL %02d";
"vhs_reduce_effects_title" = "VHS 효과 줄이기";
"vhs_reduce_effects_footer" = "스캔라인·노이즈·글리치 강도를 낮춥니다. (시스템 ‘모션 줄이기’ 설정도 함께 반영됩니다.)";
```

- [ ] **Step 3: ja.lproj에 키 추가**

`Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/ja.lproj/Localizable.strings` 파일 끝에 추가:

```
"vhs_rec" = "REC";
"vhs_tracking_error" = "TRACKING ERROR";
"vhs_danger" = "DANGER";
"vhs_ch_select" = "CH SELECT";
"vhs_level_format" = "LEVEL %02d";
"vhs_reduce_effects_title" = "VHSエフェクト軽減";
"vhs_reduce_effects_footer" = "スキャンライン・ノイズ・グリッチの強度を下げます。（システムの「視差効果を減らす」設定も反映されます。）";
```

- [ ] **Step 4: en.lproj에 키 추가**

`Packages/FaceReaderLocalization/Sources/FaceReaderLocalization/Resources/en.lproj/Localizable.strings` 파일 끝에 추가:

```
"vhs_rec" = "REC";
"vhs_tracking_error" = "TRACKING ERROR";
"vhs_danger" = "DANGER";
"vhs_ch_select" = "CH SELECT";
"vhs_level_format" = "LEVEL %02d";
"vhs_reduce_effects_title" = "Reduce VHS Effects";
"vhs_reduce_effects_footer" = "Lowers scanline, grain, and glitch intensity. Honors the system Reduce Motion setting as well.";
```

- [ ] **Step 5: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 6: 커밋**

```bash
git add Packages/FaceReaderLocalization
git commit -m "i18n: VHS/키치 컴포넌트용 ko/ja/en 문자열 추가"
```

---

## Task 4: VHSOverlay — 스캔라인 + 비네팅 + 절차적 그레인

**Files:**
- Create: `FaceReader/UI/VHS/VHSOverlay.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  VHSOverlay.swift
//  FaceReader
//

import SwiftUI
import UIKit

/// Ambient 텍스처. 스캔라인 + 비네팅 + 절차적 그레인 노이즈.
/// 카메라 프리뷰 위에는 적용 금지 (FPS 영향). UI 레이어에만 사용.
public struct VHSOverlay: ViewModifier {
    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    public init() {}

    public func body(content: Content) -> some View {
        content
            .overlay(scanlines.allowsHitTesting(false))
            .overlay(vignette.allowsHitTesting(false))
            .overlay(grain.allowsHitTesting(false))
    }

    private var intensity: Double { prefs.reducedEffects ? 0.4 : 1.0 }

    @ViewBuilder private var scanlines: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let stripeHeight: CGFloat = 3
                let alpha = 0.06 * intensity
                var y: CGFloat = 0
                while y < size.height {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: stripeHeight / 2)
                    ctx.fill(Path(rect), with: .color(Color.black.opacity(alpha)))
                    y += stripeHeight
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .blendMode(.multiply)
    }

    @ViewBuilder private var vignette: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.5 * intensity)],
                center: .center,
                startRadius: min(geo.size.width, geo.size.height) * 0.3,
                endRadius: max(geo.size.width, geo.size.height) * 0.75
            )
        }
    }

    @ViewBuilder private var grain: some View {
        Image(uiImage: Self.grainImage)
            .resizable(resizingMode: .tile)
            .opacity(0.08 * intensity)
            .blendMode(.overlay)
    }

    /// 그레인은 모듈 로드 시 한 번만 생성하고 캐시.
    private static let grainImage: UIImage = {
        let side: CGFloat = 128
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<3200 {
                let x = CGFloat.random(in: 0..<side, using: &rng)
                let y = CGFloat.random(in: 0..<side, using: &rng)
                let alpha = CGFloat.random(in: 0.05...0.4, using: &rng)
                cg.setFillColor(UIColor(white: 1, alpha: alpha).cgColor)
                cg.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }()
}

public extension View {
    /// Ambient VHS 텍스처 적용. 카메라 프리뷰 위에는 쓰지 말 것.
    func vhsOverlay() -> some View {
        modifier(VHSOverlay())
    }
}

#Preview("VHSOverlay") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 24) {
            Text("괴인 측정기")
                .font(.app(48))
                .foregroundStyle(Color.vhsInk)
            Text("VHS Ambient Test")
                .font(.app(20))
                .foregroundStyle(Color.vhsInk.opacity(0.7))
        }
    }
    .vhsOverlay()
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/VHS/VHSOverlay.swift
git commit -m "feat(vhs): VHSOverlay (scanline + vignette + grain) ViewModifier"
```

---

## Task 5: GlitchEffect — RGB split + 트래킹 에러

**Files:**
- Create: `FaceReader/UI/VHS/GlitchEffect.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  GlitchEffect.swift
//  FaceReader
//

import SwiftUI

/// 이벤트 기반 글리치. `active`가 false→true 가 되면 한 번 재생.
/// `accessibilityReduceMotion` 또는 사용자 토글이 켜져 있으면 no-op.
public struct GlitchEffect: ViewModifier {
    public enum Kind {
        case rgbSplit   // 캡처/탭: RGB 채널이 좌우로 어긋났다 정렬
        case tracking   // 결과 진입: 수평 슬라이스가 어긋났다 정렬
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    let kind: Kind
    let active: Bool
    let intensity: Double
    let duration: Double

    @State private var t: Double = 0

    public init(
        kind: Kind,
        active: Bool,
        intensity: Double = 1.0,
        duration: Double = 0.3
    ) {
        self.kind = kind
        self.active = active
        self.intensity = intensity
        self.duration = duration
    }

    private var disabled: Bool { reduceMotion || prefs.reducedEffects }

    public func body(content: Content) -> some View {
        Group {
            if disabled {
                content
            } else {
                switch kind {
                case .rgbSplit: rgbSplitBody(content)
                case .tracking: trackingBody(content)
                }
            }
        }
        .onChange(of: active) { _, newValue in
            guard newValue, !disabled else { return }
            play()
        }
    }

    private func play() {
        withAnimation(.easeOut(duration: duration / 2)) { t = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            withAnimation(.easeOut(duration: duration / 2)) { t = 0 }
        }
    }

    @ViewBuilder private func rgbSplitBody(_ content: Content) -> some View {
        let offset = CGFloat(10 * intensity * t)
        ZStack {
            content
            content
                .colorMultiply(Color.vhsCyan)
                .offset(x: -offset, y: 0)
                .opacity(0.6 * t)
                .blendMode(.screen)
                .allowsHitTesting(false)
            content
                .colorMultiply(Color.vhsRed)
                .offset(x: offset, y: 0)
                .opacity(0.6 * t)
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder private func trackingBody(_ content: Content) -> some View {
        GeometryReader { geo in
            let bandY = geo.size.height * 0.45
            let bandHeight = geo.size.height * 0.15
            let shift = CGFloat(40 * intensity * t)
            ZStack {
                content
                content
                    .mask {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: bandY)
                            Color.black.frame(height: bandHeight)
                            Color.clear
                        }
                    }
                    .offset(x: shift, y: 0)
                    .opacity(t)
                    .allowsHitTesting(false)
            }
        }
    }
}

public extension View {
    /// RGB split 글리치 (캡처/탭).
    func glitchRGB(active: Bool, intensity: Double = 1.0, duration: Double = 0.3) -> some View {
        modifier(GlitchEffect(kind: .rgbSplit, active: active, intensity: intensity, duration: duration))
    }

    /// 트래킹 에러 글리치 (결과 진입).
    func glitchTracking(active: Bool, intensity: Double = 1.0, duration: Double = 0.6) -> some View {
        modifier(GlitchEffect(kind: .tracking, active: active, intensity: intensity, duration: duration))
    }
}

#Preview("Glitch RGB") {
    @Previewable @State var fire = false
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 24) {
            Text("REC")
                .font(.app(80))
                .foregroundStyle(Color.vhsRed)
                .glitchRGB(active: fire)
            Button("Trigger") { fire.toggle() }
                .foregroundStyle(Color.vhsInk)
        }
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/VHS/GlitchEffect.swift
git commit -m "feat(vhs): GlitchEffect ViewModifier (RGB split + tracking error)"
```

---

## Task 6: KitschStamp — 비스듬한 도장

**Files:**
- Create: `FaceReader/UI/Kitsch/KitschStamp.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  KitschStamp.swift
//  FaceReader
//

import SwiftUI

/// 비스듬히 기울어진 도장 스탬프. WANTED 포스터 외곽, Help 등급 라벨 등에 사용.
public struct KitschStamp: View {
    public enum Tone {
        case red    // REC / DANGER / TRACKING ERROR
        case ink    // LEVEL 01 등 중성
    }

    let text: String
    let tone: Tone
    let rotation: Double

    public init(_ text: String, tone: Tone = .red, rotation: Double = -8) {
        self.text = text
        self.tone = tone
        self.rotation = rotation
    }

    private var foreground: Color {
        switch tone {
        case .red: return Color.vhsRed
        case .ink: return Color.vhsInk
        }
    }

    public var body: some View {
        Text(text)
            .font(.app(22))
            .fontWeight(.black)
            .foregroundStyle(foreground)
            .padding(.horizontal, 12 * PhoneLayout.metricScale)
            .padding(.vertical, 6 * PhoneLayout.metricScale)
            .overlay(
                Rectangle()
                    .stroke(foreground, lineWidth: 3 * PhoneLayout.metricScale)
            )
            .rotationEffect(.degrees(rotation))
            .opacity(0.92)
            .accessibilityLabel(text)
    }
}

#Preview("Stamps") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 20) {
            KitschStamp("REC", tone: .red, rotation: -6)
            KitschStamp("DANGER", tone: .red, rotation: 4)
            KitschStamp("TRACKING ERROR", tone: .red, rotation: -10)
            KitschStamp("LEVEL 03", tone: .ink, rotation: 6)
        }
    }
}
```

- [ ] **Step 2: Tuist 재생성**

```bash
tuist generate --no-open
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 4: 커밋**

```bash
git add FaceReader/UI/Kitsch/KitschStamp.swift
git commit -m "feat(kitsch): KitschStamp — 비스듬한 도장 컴포넌트"
```

---

## Task 7: ComicBurst — 만화 폭발 말풍선

**Files:**
- Create: `FaceReader/UI/Kitsch/ComicBurst.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  ComicBurst.swift
//  FaceReader
//

import SwiftUI

/// 폭발형 별 모양 말풍선. 결과 화면 점수/등급 강조용.
public struct ComicBurst: View {
    let text: String
    let points: Int
    let rotation: Double

    public init(_ text: String, points: Int = 10, rotation: Double = -4) {
        self.text = text
        self.points = points
        self.rotation = rotation
    }

    public var body: some View {
        ZStack {
            BurstShape(points: points)
                .fill(Color.vhsBase)
            BurstShape(points: points)
                .stroke(Color.vhsInk, lineWidth: 4 * PhoneLayout.metricScale)
            Text(text)
                .font(.app(28))
                .fontWeight(.black)
                .foregroundStyle(Color.vhsInk)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24 * PhoneLayout.metricScale)
                .padding(.vertical, 16 * PhoneLayout.metricScale)
        }
        .rotationEffect(.degrees(rotation))
        .accessibilityLabel(text)
    }
}

private struct BurstShape: Shape {
    let points: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.72
        var path = Path()
        let total = points * 2
        for i in 0..<total {
            let radius = i.isMultiple(of: 2) ? outerR : innerR
            let angle = (Double(i) / Double(total)) * .pi * 2 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

#Preview("Burst") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        ComicBurst("$1,234,567", points: 12, rotation: -6)
            .frame(width: 260, height: 260)
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/Kitsch/ComicBurst.swift
git commit -m "feat(kitsch): ComicBurst — 폭발형 별 말풍선"
```

---

## Task 8: SubtitleBox — VHS 자막 박스

**Files:**
- Create: `FaceReader/UI/Kitsch/SubtitleBox.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  SubtitleBox.swift
//  FaceReader
//

import SwiftUI

/// 옛날 비디오 자막 박스. 검정 띠 배경 + 크림색 글씨 + 얇은 외곽선.
public struct SubtitleBox: View {
    let text: String
    let size: CGFloat

    public init(_ text: String, size: CGFloat = 20) {
        self.text = text
        self.size = size
    }

    public var body: some View {
        Text(text)
            .font(.app(size))
            .foregroundStyle(Color(white: 0.96))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14 * PhoneLayout.metricScale)
            .padding(.vertical, 8 * PhoneLayout.metricScale)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.82))
            )
            .overlay(
                Rectangle()
                    .stroke(Color(white: 0.96).opacity(0.4), lineWidth: 1)
            )
            .accessibilityLabel(text)
    }
}

#Preview("Subtitles") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 16) {
            SubtitleBox("얼굴 비율로 괴인 등급을 측정합니다.", size: 22)
            SubtitleBox("얼굴 사진은 카툰화 이미지로 변경됩니다.", size: 18)
        }
        .padding()
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/Kitsch/SubtitleBox.swift
git commit -m "feat(kitsch): SubtitleBox — VHS 자막 박스"
```

---

## Task 9: CRTFrame — 카메라 4 코너 가이드 + REC 깜빡임

**Files:**
- Create: `FaceReader/UI/VHS/CRTFrame.swift`

- [ ] **Step 1: 파일 생성**

```swift
//
//  CRTFrame.swift
//  FaceReader
//

import FaceReaderLocalization
import SwiftUI

/// 카메라 프리뷰 위 4 코너 갈고리 가이드 + 좌상단 REC 깜빡임.
/// VHSOverlay와 달리 프리뷰 위에 직접 올라가지만, 가벼운 도형만 사용해 FPS 영향 최소화.
public struct CRTFrame: View {
    @ObservedObject private var prefs = VHSEffectsPreferences.shared
    @State private var recBlink: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            corners
            recBadge
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                recBlink = true
            }
        }
    }

    private var inkColor: Color { Color(white: 0.96) }

    @ViewBuilder private var corners: some View {
        GeometryReader { geo in
            let inset: CGFloat = 24 * PhoneLayout.metricScale
            let armLength: CGFloat = 28 * PhoneLayout.metricScale
            let lineWidth: CGFloat = 3
            ZStack {
                CornerHook(corner: .topLeading, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: inset + armLength / 2, y: inset + armLength / 2)
                CornerHook(corner: .topTrailing, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: geo.size.width - inset - armLength / 2, y: inset + armLength / 2)
                CornerHook(corner: .bottomLeading, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: inset + armLength / 2, y: geo.size.height - inset - armLength / 2)
                CornerHook(corner: .bottomTrailing, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: geo.size.width - inset - armLength / 2, y: geo.size.height - inset - armLength / 2)
            }
        }
    }

    @ViewBuilder private var recBadge: some View {
        VStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.vhsRed)
                    .frame(width: 12, height: 12)
                    .opacity(prefs.reducedEffects ? 1.0 : (recBlink ? 1.0 : 0.25))
                Text(L10n.vhsRec)
                    .font(.app(16))
                    .fontWeight(.black)
                    .foregroundStyle(Color(white: 0.96))
                Spacer()
            }
            .padding(.horizontal, 36 * PhoneLayout.metricScale)
            .padding(.top, 30 * PhoneLayout.metricScale)
            Spacer()
        }
    }
}

private struct CornerHook: Shape {
    enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }
    let corner: Corner
    let armLength: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c: CGPoint
        let h1: CGPoint
        let h2: CGPoint
        switch corner {
        case .topLeading:
            c = CGPoint(x: rect.minX, y: rect.minY)
            h1 = CGPoint(x: rect.minX + armLength, y: rect.minY)
            h2 = CGPoint(x: rect.minX, y: rect.minY + armLength)
        case .topTrailing:
            c = CGPoint(x: rect.maxX, y: rect.minY)
            h1 = CGPoint(x: rect.maxX - armLength, y: rect.minY)
            h2 = CGPoint(x: rect.maxX, y: rect.minY + armLength)
        case .bottomLeading:
            c = CGPoint(x: rect.minX, y: rect.maxY)
            h1 = CGPoint(x: rect.minX + armLength, y: rect.maxY)
            h2 = CGPoint(x: rect.minX, y: rect.maxY - armLength)
        case .bottomTrailing:
            c = CGPoint(x: rect.maxX, y: rect.maxY)
            h1 = CGPoint(x: rect.maxX - armLength, y: rect.maxY)
            h2 = CGPoint(x: rect.maxX, y: rect.maxY - armLength)
        }
        p.move(to: h1)
        p.addLine(to: c)
        p.addLine(to: h2)
        return p
    }
}

#Preview("CRT") {
    ZStack {
        Color.black.ignoresSafeArea()
        CRTFrame()
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/UI/VHS/CRTFrame.swift
git commit -m "feat(vhs): CRTFrame — 카메라 4코너 가이드 + REC 깜빡임"
```

---

## Task 10: FaceCaptureView 리뉴얼

**Files:**
- Modify: `FaceReader/Features/FaceMeter/FaceCaptureView.swift`

- [ ] **Step 1: body 전체 교체**

`FaceCaptureView.swift` 파일의 `public var body: some View` 블록 전체를 다음으로 교체:

```swift
    public var body: some View {
        ZStack {
            PreviewLayerHost(previewLayer: engine.previewLayer)
                .ignoresSafeArea()

            FaceLandmarkOverlay(engine: engine)
                .ignoresSafeArea()

            CRTFrame()
                .ignoresSafeArea()

            VStack {
                Spacer()
                SubtitleBox(L10n.faceRatioIntro, size: 22)
                SubtitleBox(L10n.faceRatioTip, size: 16)
                    .padding(.top, 8 * PhoneLayout.metricScale)

                Spacer()

                SubtitleBox(L10n.faceCartoonNotice, size: 18)
                    .padding(.bottom, 14 * PhoneLayout.metricScale)

                Button {
                    captureTapped()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.vhsBase)
                            .frame(width: 84 * PhoneLayout.metricScale, height: 84 * PhoneLayout.metricScale)
                        Circle()
                            .stroke(Color.vhsInk, lineWidth: 4 * PhoneLayout.metricScale)
                            .frame(width: 84 * PhoneLayout.metricScale, height: 84 * PhoneLayout.metricScale)
                        Image("camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48 * PhoneLayout.metricScale, height: 48 * PhoneLayout.metricScale)
                    }
                }
                .disabled(isProcessing)
                .glitchRGB(active: isProcessing, intensity: 1.2, duration: 0.35)
                .padding(.bottom, max(72, 56 * PhoneLayout.metricScale + 24))
            }
            .padding(.horizontal, 22 * PhoneLayout.metricScale)

            if isProcessing {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .navigationTitle(L10n.faceMeasurerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
        .alert(L10n.toastCaptureFace, isPresented: $showNeedFaceAlert) {
            Button(L10n.btnOk, role: .cancel) {}
        }
    }
```

(파일 상단 import 목록은 `FaceReaderUI` 가 이미 있으므로 추가 없음.)

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/Features/FaceMeter/FaceCaptureView.swift
git commit -m "feat(capture): CRT 프레임, 자막 박스, 카툰 셔터로 캡처 화면 리뉴얼"
```

---

## Task 11: MonsterPosterView 외곽 확장 + FaceResultView 진입 글리치

**Files:**
- Modify: `FaceReader/UI/MonsterPosterView.swift`
- Modify: `FaceReader/Features/FaceMeter/FaceResultView.swift`

- [ ] **Step 1: MonsterPosterView에 외곽 스탬프 슬롯 추가**

`MonsterPosterView.swift` 파일의 `public struct MonsterPosterView: View {` 블록을 통째로 교체 (포스터 본 컨텐츠는 동일, 외곽 ZStack overlay 추가):

```swift
public struct MonsterPosterView: View {
    let faceImage: UIImage?
    let nicknameLine: String
    let posterWantedText: String
    let posterDeadOrAliveText: String
    let gradeLineText: String
    let formattedScoreText: String
    let showVHSAccents: Bool

    private let contentWidth: CGFloat

    public init(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        posterDeadOrAliveText: String,
        gradeLineText: String,
        formattedScoreText: String,
        screenWidth: CGFloat = PhoneLayout.width,
        showVHSAccents: Bool = false
    ) {
        self.faceImage = faceImage
        self.nicknameLine = nicknameLine
        self.posterWantedText = posterWantedText
        self.posterDeadOrAliveText = posterDeadOrAliveText
        self.gradeLineText = gradeLineText
        self.formattedScoreText = formattedScoreText
        self.contentWidth = screenWidth
        self.showVHSAccents = showVHSAccents
    }

    public var body: some View {
        let pad: CGFloat = 20 * PhoneLayout.metricScale
        let imageWidth = contentWidth - pad * 2
        let imageHeight = imageWidth * 0.82
        let border: CGFloat = max(4, 5 * PhoneLayout.metricScale)
        ZStack {
            Image("background")
                .resizable(resizingMode: .tile)
            VStack(spacing: 0) {
                Text(posterWantedText)
                    .font(.app(100))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12 * PhoneLayout.metricScale)
                    .padding(.horizontal, pad * 0.5)

                Group {
                    if let faceImage {
                        Image(uiImage: faceImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: imageWidth, height: imageHeight)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.appBrown, lineWidth: border)
                )
                .padding(.horizontal, pad)

                Text(posterDeadOrAliveText)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

                Text(nicknameLine)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

                Text(gradeLineText)
                    .font(.app(25))
                    .foregroundStyle(Color.appBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

                Spacer(minLength: 0)

                Text(formattedScoreText)
                    .font(.app(50))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .padding(.horizontal, pad)
                    .padding(.bottom, 12 * PhoneLayout.metricScale)
            }
            .frame(width: contentWidth, height: contentWidth * 1.8, alignment: .top)

            if showVHSAccents {
                vhsAccents(pad: pad, imageWidth: imageWidth, imageHeight: imageHeight)
            }
        }
        .frame(width: contentWidth, height: contentWidth * 1.8)
    }

    @ViewBuilder
    private func vhsAccents(pad: CGFloat, imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        VStack {
            HStack {
                Spacer()
                KitschStamp("TRACKING ERROR", tone: .red, rotation: -10)
                    .padding(.trailing, pad)
                    .padding(.top, pad * 0.6)
            }
            Spacer()
            HStack {
                KitschStamp("DANGER", tone: .red, rotation: 6)
                    .padding(.leading, pad)
                Spacer()
            }
            .padding(.bottom, pad * 0.4)
        }
        .frame(width: contentWidth, height: contentWidth * 1.8)
    }
}
```

`PosterImageRenderer.render(...)` 함수도 `showVHSAccents` 파라미터를 받도록 확장. 같은 파일에서 `public static func render` 시그너처를 다음으로 변경:

```swift
    @MainActor
    public static func render(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        posterDeadOrAliveText: String,
        gradeLineText: String,
        formattedScoreText: String,
        showVHSAccents: Bool = false
    ) -> UIImage? {
        let view = MonsterPosterView(
            faceImage: faceImage,
            nicknameLine: nicknameLine,
            posterWantedText: posterWantedText,
            posterDeadOrAliveText: posterDeadOrAliveText,
            gradeLineText: gradeLineText,
            formattedScoreText: formattedScoreText,
            showVHSAccents: showVHSAccents
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
```

- [ ] **Step 2: FaceResultView에서 포스터를 VHS 톤 + 진입 글리치로**

`FaceResultView.swift` 파일의 `public var body` 블록을 다음으로 교체:

```swift
    public var body: some View {
        ScrollView {
            MonsterPosterView(
                faceImage: posterUIImage,
                nicknameLine: store.nicknameLine,
                posterWantedText: L10n.posterWanted,
                posterDeadOrAliveText: L10n.posterDeadOrAlive,
                gradeLineText: L10n.gradeLine(for: store.box.session.grade),
                formattedScoreText: L10n.formattedScore(store.box.session.totalScore),
                showVHSAccents: true
            )
            .frame(maxWidth: .infinity)
            .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
        }
        .background(Color.appBackground)
        .vhsOverlay()
        .navigationTitle(L10n.resultScreenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.send(.dismissTapped)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appText)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L10n.actionShare) {
                    prepareShare()
                }
                .foregroundStyle(Color.appText)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                store.send(.explanationTapped)
            } label: {
                Text(L10n.btnMonsterExplanation)
                    .font(.app(23))
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22 * PhoneLayout.metricScale)
                    .background(Color.vhsRed)
                    .foregroundStyle(Color(white: 0.96))
                    .overlay(
                        Rectangle()
                            .stroke(Color.vhsInk, lineWidth: 3)
                    )
            }
        }
        .onAppear {
            store.send(.onAppear)
            triggerReveal()
        }
        .id(store.posterImageData)
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }

    @State private var revealActive: Bool = false

    private var revealIntensity: Double {
        // 등급이 높을수록 강한 글리치 (wolf=0 → god=4 ⇒ 0.4~1.6)
        0.4 + Double(store.box.session.grade) * 0.3
    }

    private func triggerReveal() {
        revealActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            revealActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                revealActive = false
            }
        }
    }
```

그리고 같은 파일의 `prepareShare()` 함수에서 `PosterImageRenderer.render(...)` 호출에 `showVHSAccents: true`를 추가:

```swift
    private func prepareShare() {
        let grade = store.box.session.grade
        let totalScore = store.box.session.totalScore
        let img = PosterImageRenderer.render(
            faceImage: posterUIImage,
            nicknameLine: store.nicknameLine,
            posterWantedText: L10n.posterWanted,
            posterDeadOrAliveText: L10n.posterDeadOrAlive,
            gradeLineText: L10n.gradeLine(for: grade),
            formattedScoreText: L10n.formattedScore(totalScore),
            showVHSAccents: true
        )
        shareImage = img
        showShareSheet = img != nil
    }
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 4: 커밋**

```bash
git add FaceReader/UI/MonsterPosterView.swift FaceReader/Features/FaceMeter/FaceResultView.swift
git commit -m "feat(result): 포스터 외곽 VHS 스탬프 + 진입 트래킹 글리치"
```

---

## Task 12: HelpView 리뉴얼 — 폴라로이드 카드

**Files:**
- Modify: `FaceReader/Features/Help/HelpView.swift`

- [ ] **Step 1: body 전체 교체**

`HelpView.swift` 파일의 `public var body: some View` 블록 전체를 다음으로 교체:

```swift
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
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/Features/Help/HelpView.swift
git commit -m "feat(help): 폴라로이드 + 레벨 스탬프 + RGB 분리 헤더로 도움말 리뉴얼"
```

---

## Task 13: SettingsView 리뉴얼 — CH SELECT + VHS 토글

**Files:**
- Modify: `FaceReader/Features/Settings/SettingsView.swift`

- [ ] **Step 1: body 전체 교체 + VHS 효과 토글 섹션 추가**

`SettingsView.swift` 파일을 통째로 다음으로 교체:

```swift
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
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/Features/Settings/SettingsView.swift
git commit -m "feat(settings): CH SELECT 채널 컨셉 + VHS 효과 줄이기 토글"
```

---

## Task 14: AppView 리뉴얼 — Ambient overlay + 툴바 아이콘

**Files:**
- Modify: `FaceReader/Features/Root/AppView.swift`

- [ ] **Step 1: body 교체 — 카메라 화면 외 ambient overlay 적용**

캡처 화면은 자체에서 CRTFrame이 처리하므로 ambient `vhsOverlay()`는 결과/도움말/설정에만 자동 적용된다(각 화면 내부에서 호출). AppView 자체는 배경/툴바만 정리.

`AppView.swift` 파일의 `var body: some View` 블록을 다음으로 교체:

```swift
    var body: some View {
        NavigationStack {
            Group {
                if store.isShowingHelp {
                    HelpView {
                        store.send(.helpFinished)
                    }
                } else if let resultStore = store.scope(state: \.faceResult, action: \.faceResult) {
                    FaceResultView(store: resultStore)
                } else {
                    FaceCaptureView(
                        box: store.sessionBox,
                        onCommitted: { store.send(.faceCaptureCommitted(posterImageData: $0)) }
                    )
                }
            }
            .id(store.languageRefreshToken)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.settingsButtonTapped)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.vhsBase)
                                .frame(width: 36 * PhoneLayout.metricScale, height: 28 * PhoneLayout.metricScale)
                            Rectangle()
                                .stroke(Color.vhsInk, lineWidth: 2)
                                .frame(width: 36 * PhoneLayout.metricScale, height: 28 * PhoneLayout.metricScale)
                            Text("VHS")
                                .font(.app(10))
                                .fontWeight(.black)
                                .foregroundStyle(Color.vhsInk)
                        }
                    }
                    .accessibilityLabel(L10n.settingsTitle)
                }
            }
        }
        .tint(Color.vhsInk)
        .background(Color.vhsBase.ignoresSafeArea())
        .sheet(isPresented: Binding(
            get: { store.settingsPresented },
            set: { presented in
                if !presented { store.send(.settingsDismissed) }
            }
        )) {
            SettingsView(
                currentOverride: LanguageResolver.storedOverrideTag,
                onSelect: { store.send(.languagePreferenceSaved($0)) },
                onCancel: { store.send(.settingsDismissed) }
            )
        }
    }
```

(import 변경 없음 — 기존 `FaceReaderUI` import에 새 컬러 토큰 포함.)

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' -quiet build
```

Expected: 성공.

- [ ] **Step 3: 커밋**

```bash
git add FaceReader/Features/Root/AppView.swift
git commit -m "feat(root): VHS 카세트 스타일 툴바 아이콘 + vhsBase 배경"
```

---

## Task 15: 시뮬레이터 스모크 테스트

**Files:** 없음 (수동 검증)

- [ ] **Step 1: 시뮬레이터 실행**

```bash
xcodebuild \
  -workspace FaceReader.xcworkspace \
  -scheme FaceReader \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -quiet \
  build
```

빌드 성공 후 Xcode에서 iPhone 15 시뮬레이터 선택 → Run.

- [ ] **Step 2: 캡처 화면 확인**

체크리스트:
- [ ] 카메라 프리뷰가 정상 동작
- [ ] 4 코너 갈고리 가이드가 보임
- [ ] 좌상단 `● REC` 표시가 깜빡임
- [ ] 안내 문구가 검정 자막 박스 안에 표시됨
- [ ] 셔터 버튼이 두꺼운 외곽선 원형, 누르면 RGB 글리치
- [ ] 캡처 → 결과 화면 전환

시뮬레이터에서 카메라 권한이 없으면 실제 디바이스로 테스트.

- [ ] **Step 3: 결과 화면 확인**

체크리스트:
- [ ] 진입 시 0.7초 정도 트래킹 에러 글리치 발생
- [ ] WANTED 포스터 갈색 톤 그대로
- [ ] 우상단 "TRACKING ERROR" 빨간 도장 비스듬히
- [ ] 좌하단 "DANGER" 빨간 도장 비스듬히
- [ ] 하단 "재해 레벨 설명" 버튼이 빨간 배경 + 검정 외곽선
- [ ] 화면 전체에 옅은 스캔라인 + 비네팅 + 그레인
- [ ] 등급 god (가능하면) 시 글리치 강하게, wolf 시 약하게 — 다른 캡처로 확인 가능하면

- [ ] **Step 4: 도움말 화면 확인**

체크리스트:
- [ ] 헤더 텍스트가 살짝 시안/마젠타 그림자로 RGB 분리 인상
- [ ] 5개 등급 카드가 각각 미세하게 다른 각도로 기울어짐
- [ ] 각 카드 우상단에 "LEVEL 01~05" 회색 도장
- [ ] 카드 외곽선이 두꺼운 검정/크림
- [ ] 그림자가 카드 아래 옅게 깔림
- [ ] 배경 스캔라인 + 비네팅 + 그레인

- [ ] **Step 5: 설정 화면 확인**

체크리스트:
- [ ] 상단 "CH SELECT" 빨간 도장
- [ ] 언어 항목이 CH 00 ~ CH 03 라벨로 표시
- [ ] 빨간 체크 아이콘으로 현재 선택 표시
- [ ] "VHS 효과 줄이기" 토글이 동작 (켜면 즉시 다른 화면 글리치/노이즈 약해짐)
- [ ] 언어 변경 시 라벨이 ko/ja/en에 맞춰 갱신

- [ ] **Step 6: 접근성 확인**

체크리스트:
- [ ] iOS Settings → Accessibility → Motion → Reduce Motion ON
- [ ] 다시 앱 실행 → 캡처 셔터 글리치 + 결과 진입 글리치가 발생하지 않음
- [ ] 앱 내 "VHS 효과 줄이기" 토글을 OFF로 두어도 시스템 설정이 우선됨
- [ ] Reduce Motion OFF로 복귀

- [ ] **Step 7: 빌드 경고 0개 확인**

```bash
xcodebuild -workspace FaceReader.xcworkspace -scheme FaceReader -destination 'generic/platform=iOS Simulator' build 2>&1 | grep -E "warning:" | head -20
```

Expected: 결과 없음 (또는 신규 코드와 무관한 시스템 경고만).

- [ ] **Step 8: 모든 화면이 "심심하지 않음"을 확인했는지 사용자에게 보고**

작업 완료 보고 시 다음을 포함:
- 4개 화면 스크린샷 (가능하면)
- 다국어 3개(ko/ja/en) 각각에서 자막/도장 텍스트 잘림 없음 확인
- Reduce Motion 동작 확인 결과

---

## Self-Review

스펙(`docs/superpowers/specs/2026-05-11-vhs-kitsch-redesign-design.md`) 각 섹션 대비 커버리지:

- **컬러 토큰 6개** ✅ Task 1
- **VHSOverlay (scanline + grain + vignette)** ✅ Task 4
- **GlitchEffect (rgbSplit + tracking)** ✅ Task 5
- **`vhsEffectsReduced` 사용자 토글 + Reduce Motion 존중** ✅ Task 2, 5, 13
- **KitschStamp / ComicBurst / SubtitleBox** ✅ Tasks 6/7/8
- **CRTFrame (4 코너 + REC 깜빡임)** ✅ Task 9
- **FaceCaptureView 리뉴얼** ✅ Task 10
- **FaceResultView 진입 글리치 + 포스터 외곽 스탬프** ✅ Task 11
- **HelpView 폴라로이드 + 레벨 스탬프** ✅ Task 12
- **SettingsView CH SELECT + VHS 토글** ✅ Task 13
- **AppView ambient 통합 + 툴바 아이콘** ✅ Task 14
- **다국어 ko/ja/en 신규 키** ✅ Task 3
- **포스터 갈색 정체성 유지** ✅ Task 11 (`Color.appBrown` 그대로, 외곽 ZStack만 추가)
- **마스코트 코너 스탬프** ⚠️ 스펙은 "마스코트 일러스트가 우표 크기로 작게 박힘"이라 했으나 v1에서는 텍스트 도장(TRACKING ERROR/DANGER)만 적용 — 마스코트 도장은 결과 화면 grade-aware 추가 작업으로 별도 필요. 이번 플랜은 외곽 ZStack 슬롯을 만들어 두므로 후속에서 마스코트 우표를 그 ZStack에 추가하기 쉬움.
- **접근성 (대비/VoiceOver)** ✅ Task 8 (`accessibilityLabel`), Task 6/7 동일 패턴. 대비 비율은 Task 15 수동 확인.
- **카메라 프리뷰 위에 무거운 오버레이 금지** ✅ Task 10 — CRTFrame은 가벼운 도형 4개 + 텍스트 + 점만 사용.

타입/시그니처 일관성 확인:
- `glitchRGB(active:intensity:duration:)` / `glitchTracking(active:intensity:duration:)` — Task 5에서 정의, Tasks 10/11에서 동일 시그니처 사용 ✅
- `KitschStamp(_ text: String, tone: Tone, rotation: Double)` — Task 6 정의, Tasks 11/12/13 호출 일치 ✅
- `MonsterPosterView(..., showVHSAccents: Bool)` — Task 11 정의 및 `FaceResultView`에서 호출 일치 ✅
- `VHSEffectsPreferences.shared.reducedEffects` — Task 2 정의, Tasks 4/5/9/13에서 사용 ✅
- `L10n.vhsRec`, `L10n.vhsLevelLabel(_:)` 등 — Task 3 정의, Tasks 9/12에서 사용 ✅

플레이스홀더 스캔: TBD/TODO/"appropriate handling" 등 없음 ✅

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-11-facereader-vhs-kitsch-redesign.md`. 두 가지 실행 옵션:

**1. Subagent-Driven (recommended)** — 각 Task마다 신선한 subagent를 띄워 구현, Task 간 리뷰 체크포인트, 빠른 iteration

**2. Inline Execution** — 이 세션에서 직접 실행, 배치 단위로 체크포인트

어떤 방식으로 갈까요?
