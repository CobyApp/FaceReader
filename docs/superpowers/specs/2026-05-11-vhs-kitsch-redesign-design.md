# FaceReader UI/UX Overhaul — VHS 호러키치 + 카툰 마스코트

**Date:** 2026-05-11
**Status:** Approved for planning
**Author:** brainstorming session

## 배경

현재 `FaceReader` 앱은 `#eeeeee` / `#111111` 흑백 베이스 + 둥근 고딕체(SangSangAnt/KosugiMaru)로 구성된 미니멀 디자인이다. "괴인측정기"라는 컨셉에 비해 시각적으로 심심하다.

이 스펙은 앱 전체를 **VHS 호러키치 + 카툰 마스코트** 톤으로 탈바꿈하는 작업을 정의한다. 컨셉상 옛날 일본 호러 비디오의 트래킹 에러, 자막, 도장 스탬프 같은 요소를 가져오고, 기존 5등급 마스코트 일러스트(wolf/tiger/demon/dragon/god)를 카툰 강조 포인트로 활용한다.

## 목표

1. 카메라 캡처, 결과(WANTED 포스터), 도움말, 설정 4개 화면에 일관된 VHS/카툰 디자인 언어 적용
2. **항상 켜진(ambient) 텍스처**와 **이벤트 기반(event-driven) 글리치**를 분리해 배터리/접근성 균형 유지
3. WANTED 포스터의 갈색 정체성은 유지하되 외곽을 VHS화
4. 접근성: Reduce Motion 존중 + 명시적 "VHS 효과 줄이기" 토글
5. 일본어/한국어/영어 모두에서 가독성 확보

## 비목표

- 폰트 시스템 전면 교체 (기존 `SangSangAnt`/`KosugiMaru` 유지)
- TCA 아키텍처 변경
- 새로운 기능 추가 (캡처/결과/도움말/설정 흐름은 그대로)
- 5등급 일러스트 자산 자체의 재제작 (재활용)
- 라이브 카메라 프리뷰 위 무거운 GPU 셰이더 (FPS 영향)

## 비주얼 랭귀지

### 컬러 토큰 (`AppTheme.swift` 확장)

다크 모드 우선. 라이트 모드는 자동 변형.

| 토큰 | 다크 | 라이트 | 용도 |
|---|---|---|---|
| `vhsBase` | `#0a0808` | `#f1e8d0` | 화면 배경 |
| `vhsSurface` | `#1a1414` | `#e2d4b2` | 카드/오버레이 |
| `vhsInk` | `#f4e9d3` | `#1a1414` | 본문 텍스트, 외곽선 |
| `vhsRed` | `#d6433a` | `#b8362d` | REC 표시, 위험, 도장 |
| `vhsCyan` | `#48b8c4` | `#3a96a2` | 글리치 채널 분리 |
| `vhsMagenta` | `#c34d8a` | `#a83d72` | 글리치 채널 분리 |
| `appBrown` | `#4B3E36` | `#4B3E36` | WANTED 포스터 (기존 유지) |

`Color.appText` / `Color.appBackground`는 호환 위해 유지하되 내부적으로 `vhsInk` / `vhsBase`에 매핑.

### 타이포그래피

- **본문**: 기존 `Font.app(_:)` 유지 — `SangSangAnt` (ko/en), `KosugiMaru` (ja)
- **임팩트 헤더**: 같은 폰트 위에 SwiftUI `overlay`로 외곽선(2~3pt stroke) + `shadow` 두 번 (시안 1pt 우하 + 마젠타 1pt 좌상)로 키치한 RGB 분리 인상
- 신규 폰트 추가 **없음** (사이즈/이펙트로만 톤 차이)

### 텍스처

세 가지를 `VHSOverlay` 단일 ViewModifier로 묶어 ambient로 항상 적용:

1. **스캔라인**: 가로 라인 패턴, `opacity 0.06`, `blendMode .overlay`
2. **그레인 노이즈**: 미세 PNG 텍스처 타일, `opacity 0.08`
3. **CRT 비네팅**: 모서리 어두워지는 라디얼 그라데이션

카메라 프리뷰 레이어 위에는 적용하지 **않음** (FPS 보호). 프리뷰 외 UI 레이어에만.

## 글리치 시스템

`GlitchEffect` ViewModifier가 `Phase`를 받아 동작.

```swift
enum GlitchPhase {
    case idle           // 비활성 (no-op)
    case capture        // 셔터 — 0.3s RGB split + 흰 플래시
    case reveal         // 결과 진입 — 0.6s 트래킹 에러 (수평 슬라이스)
    case tap            // 버튼 탭 — 0.1s 미세 RGB split
}
```

구현: `TimelineView(.animation)` + 시간 기반 오프셋. RGB 분리는 동일 콘텐츠를 시안/마젠타로 두 번 더 렌더링해 `.offset(x:)`로 어긋나게 합성. 셰이더 사용 안 함.

**등급별 강도**: 결과 화면 `reveal`은 `grade` 값에 비례해 진폭/지속시간 차등 (신/용은 강함, 늑대는 약함).

**접근성**: `@Environment(\.accessibilityReduceMotion)`이 true이거나 사용자 설정의 "VHS 효과 줄이기"가 켜지면 모든 phase가 no-op으로 떨어짐.

## 카툰 / 키치 컴포넌트 (신설)

세 가지 재사용 컴포넌트:

### `KitschStamp(text:tone:)`
- 비스듬히(±5~12°) 기울어진 도장 스탬프
- 두꺼운 외곽선 박스 안에 굵은 텍스트
- `tone`: `.red` (REC/DANGER), `.ink` (LEVEL 03 등 중성)
- 살짝 갈라진 가장자리 느낌 (선 dash + 약간 거친 외곽)

### `ComicBurst(text:)`
- 폭발형 별 모양 말풍선 (8~12 꼭짓점)
- 결과 화면 점수/등급 강조용
- 두꺼운 검정 외곽선 + 누런 크림 배경

### `SubtitleBox(text:)`
- 화면 하단/중단에 박히는 옛날 자막 박스
- 검정 띠 배경(`opacity 0.85`) + 크림색 흰 글씨 + 얇은 외곽선
- 캡처 안내 텍스트 등에 사용

## 화면별 적용

### FaceCaptureView

- **CRT 프레임**: 카메라 프리뷰 모서리 4개에 갈고리형 가이드 마크 + 좌상단 깜빡이는 빨간 `● REC` 표시
- **자막 박스 처리**: `L10n.faceRatioIntro`, `L10n.faceRatioTip`, `L10n.faceCartoonNotice`를 `SubtitleBox`로 감쌈
- **셔터 버튼**: 기존 `camera` 이미지에 두꺼운 검정 외곽선 + 누르면 `GlitchEffect(.tap)` → 캡처 진행 중에는 `.capture` phase
- **VHS ambient**: 프리뷰 외 영역에만 스캔라인/그레인 적용

### FaceResultView

- **진입 시**: 0.6초간 `GlitchEffect(.reveal)` (등급 기반 강도)
- **포스터 자체**: 기존 갈색 정체성 유지 — 골격 안 건드림
- **포스터 외곽**: 상단에 `KitschStamp(text: "TRACKING ERROR", tone: .red)` 한두 개 비스듬히 박힘
- **포스터 코너**: 등급 마스코트 일러스트가 우표 크기로 작게 박힘 (4번 코너 중 1~2개)
- **하단 "괴인 설명" 버튼**: 두꺼운 카툰 외곽선 + 누르면 `.tap` 글리치

### HelpView

- **카드 스타일 변경**: 기존 둥근 사각형 → 폴라로이드 스타일 (살짝 기울어진 사진 + 테이프 자국 PNG 두 군데)
- **등급 라벨**: 각 카드에 `KitschStamp(text: "LEVEL 0\(index+1)", tone: .ink)` 우상단에 박힘
- **헤더**: `L10n.helpDisasterLevelTitle`을 임팩트 헤더 스타일(외곽선 + 시안/마젠타 그림자)로
- **카드 사이 spacing**: 살짝 회전 각도 교차 (-2°, +1°, -1°, +2°, -1.5°)

### SettingsView

- **언어 선택을 "채널 변경" 컨셉으로 재포장**
- 상단에 큰 `KitschStamp(text: "CH SELECT")` + 각 언어 항목을 CH 1/2/3 처럼 라벨
- 선택 시 짧은 `.tap` 글리치
- **신규 토글**: "VHS 효과 줄이기" — 글리치/노이즈 강도 약화

### Toolbar (AppView)

- 톱니바퀴 아이콘을 두꺼운 카툰 외곽선이 적용된 SF Symbol로 (`gearshape.fill`에 `.foregroundStyle(Color.vhsInk)` + outline overlay)
- 또는 SF Symbol `tv.fill` (VHS/TV 컨셉) — 둘 중 시각적으로 더 좋은 쪽으로

## 파일 구조

```
FaceReader/UI/
├── AppTheme.swift                  (수정 — vhs* 컬러 토큰 추가, 기존 토큰 유지)
├── VHS/
│   ├── VHSOverlay.swift           (신설 — scanline + grain + vignette)
│   ├── GlitchEffect.swift         (신설 — phase 기반 RGB split)
│   ├── CRTFrame.swift             (신설 — 카메라 캡처 화면 프레임)
│   └── ReduceMotionGate.swift     (신설 — 접근성/사용자 토글 통합)
├── Kitsch/
│   ├── KitschStamp.swift          (신설)
│   ├── ComicBurst.swift           (신설)
│   └── SubtitleBox.swift          (신설)
├── ActivityView.swift              (변경 없음)
├── GradeAssets.swift               (변경 없음)
├── MonsterPosterView.swift         (수정 — 외곽 stamp/mascot 추가, 골격 유지)
└── PhoneLayout.swift               (변경 없음)

FaceReader/Features/
├── FaceMeter/FaceCaptureView.swift     (수정 — SubtitleBox, CRTFrame, 글리치)
├── FaceMeter/FaceResultView.swift      (수정 — 진입 글리치, 외곽 stamp)
├── Help/HelpView.swift                 (수정 — 폴라로이드 카드, stamp)
├── Settings/SettingsView.swift         (수정 — 채널 컨셉, VHS 토글)
└── Root/AppView.swift                  (수정 — 툴바 아이콘, ambient overlay)

FaceReader/Core/
└── UserPreferences.swift           (신설 또는 기존 확장 — vhsEffectsReduced)

FaceReader/Global/Resource/
└── (asset catalog)
    ├── grain (그레인 노이즈 PNG 512x512 타일)
    └── tape (HelpView 테이프 PNG, 2~3 variant)
```

## 데이터 / 상태 변경

- **사용자 설정**: "VHS 효과 줄이기" Bool 추가 → `UserDefaults` 또는 기존 설정 저장소 활용
- **TCA 영향**: `AppFeature` / `FaceResultFeature` 리듀서 변경 **없음**. 모든 변경이 뷰 레이어/모디파이어/오버레이.
- **FaceCaptureEngine**: 변경 없음 (글리치는 뷰 위 오버레이)

## 접근성

- `accessibilityReduceMotion` 환경값 자동 존중 → 글리치 phase 모두 no-op
- 사용자 토글로 추가 제어 (강도 약화)
- 스캔라인/그레인은 `opacity` 낮아 본문 텍스트 대비 4.5:1 이상 유지 확인
- 자막 박스 배경 불투명도 충분 (`0.85+`) → 카메라 프리뷰 위에서도 읽힘
- VoiceOver: 신규 컴포넌트(`KitschStamp`, `ComicBurst`, `SubtitleBox`)는 텍스트 콘텐츠를 그대로 `accessibilityLabel`로 전달, 장식 요소는 `accessibilityHidden(true)`

## 성능

- 카메라 프리뷰 레이어(`PreviewLayerHost`) 위에는 텍스처 오버레이 **불가** — 그 외 UI 레이어에만
- 글리치 phase는 0.1~0.6초 단발성, 평소엔 idle (no-op)
- 그레인 PNG는 한 번 로드 후 SwiftUI `Image(...).resizable(resizingMode: .tile)`로 타일링 — 매 프레임 새로 그리지 않음
- `TimelineView(.animation)`은 활성 phase에서만 활성화

## 다국어

- 신규 문자열: "TRACKING ERROR", "REC", "CH SELECT", "LEVEL 01~05", "DANGER", "VHS 효과 줄이기"
- `FaceReaderLocalization` 패키지의 ko/ja/en에 추가
- 일부(REC, TRACKING ERROR)는 일본어/한국어 화면에서도 영문 유지 (VHS 톤의 일부)
- "LEVEL 01~05"은 기존 `gradeName` 시스템과 별개의 키치 라벨

## 단계적 적용 순서

스펙은 단일 디자인이지만 구현은 의존성을 고려해 단계 분리:

1. **Foundation**: `AppTheme.swift` 컬러 토큰 + `VHSOverlay` + `ReduceMotionGate` + 신규 문자열 + 그레인 자산
2. **Kitsch 컴포넌트**: `KitschStamp`, `ComicBurst`, `SubtitleBox` (각 #Preview 포함)
3. **Glitch 시스템**: `GlitchEffect` ViewModifier + 셔터 캡처 연결
4. **화면 적용 — 캡처**: `FaceCaptureView` 리뉴얼 (CRT 프레임, 자막, 글리치)
5. **화면 적용 — 결과**: `FaceResultView` 리뉴얼 + `MonsterPosterView` 외곽 확장
6. **화면 적용 — 도움말/설정**: `HelpView` 폴라로이드, `SettingsView` 채널 컨셉 + VHS 토글
7. **툴바/마무리**: `AppView` ambient overlay 통합 + 툴바 아이콘

각 단계는 다음 단계를 차단하지 않고 빌드/실행 가능.

## 리스크 / 미해결 사항

- **카메라 프리뷰 위 UI 가독성**: 자막 박스 불투명도/배경이 카메라 노출 변화에 강건한지 실제 디바이스 확인 필요
- **그레인 타일 시각 패턴**: 64x64 vs 512x512 시각 차이 — 실제 보고 결정
- **마스코트 코너 스탬프 크기**: 포스터 본 컨텐츠를 방해하지 않는 한도 — 디자인 토큰화 가능
- **CH SELECT 아이콘**: 툴바 아이콘으로 `gearshape.fill` 유지 vs `tv.fill`로 변경 — 컨셉 일관성은 후자, 익숙함은 전자. 첫 구현은 후자 시도, 어색하면 되돌림.

## 성공 기준

- 4개 화면(캡처/결과/도움말/설정) 모두 VHS 톤 일관 적용
- Reduce Motion / VHS 토글 켰을 때 글리치 0회 발생
- 세 언어(ko/ja/en) 모두 자막 박스에서 텍스트 잘림 없음
- 빌드 경고 0개, 기존 TCA 리듀서 테스트 (있다면) 변경 없이 통과
- 직접 디바이스에서 캡처 → 결과 → 도움말 흐름을 돌렸을 때 "심심하지 않다"
