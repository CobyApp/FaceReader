<div align="center">

<img src="FaceReader/Global/Resource/Assets.xcassets/AppIcon.appiconset/appstore.png" alt="怪人メーター アイコン" width="120" height="120" />

# 怪人メーター ／ FaceReader

**あなたの顔の災害レベルは？**

*ワンパンマン世界観の怪人協会風アーキビストAIが、あなたの顔を測って怪人の指名手配ポスターを発行する iOS アプリ。*

<br/>

<img height="28" src="https://img.shields.io/badge/iOS-26.0+-silver">
<img height="28" src="https://img.shields.io/badge/Xcode-26-blue">
<img height="28" src="https://img.shields.io/badge/Swift-6-orange">
<img height="28" src="https://img.shields.io/badge/Tuist-4.155-purple">
<img height="28" src="https://img.shields.io/badge/Apple%20Intelligence-on--device-ff69b4">

[App Store](https://apps.apple.com/app/id1642236144)
&nbsp;·&nbsp;
[公式サイト](https://cobyapp.github.io/FaceReader/)
&nbsp;·&nbsp;
[プライバシーポリシー](https://cobyapp.github.io/FaceReader/ja/privacy.html)

![banner](docs/assets/hero-ja.png)

</div>

<br/>

## ✨ 概要

「怪人メーター」は **iPhone のカメラとオンデバイス AI** だけを使って動く、半分ジョーク・半分マジな顔測定アプリです。

1. 顔を一枚撮ると、Vision フレームワークが顔のパーツ比率を解析
2. 比率から **5段階の災害レベル**（狼 / 虎 / 鬼 / 竜 / **神**）を判定
3. **Apple Intelligence（Foundation Models）** がワンパンマン世界観風の **怪人コードネーム + ２行紹介文** を生成
4. レトロ VHS テイストの **指名手配ポスター（1080×1920px）** にまとめて、SNS にそのままシェア可能

データはすべて端末内で完結。LLM もオンデバイス。サーバー送信ゼロ。

<br/>

## 🎬 画面の流れ

上のバナーは実機スクリーンショットを左から並べた１ループです。

| # | 画面 | 内容 |
|---|---|---|
| ① | **怪人図鑑** | 起動直後に開ける、災害レベル ５段階のリファレンス。狼級から神級までのイラスト＋短い解説で、自分の判定結果を読み解く下地に。 |
| ② | **顔の測定** | フロントカメラに顔をかざすと、Vision がランドマークを検出し、目／鼻／口／顔長の比率を即時オーバーレイ。比率からスコアが計算され、シャッターで確定。 |
| ③ | **怪人協会 分析中** | シャッター後の小休止。Apple Intelligence が裏でコードネームと図鑑文を生成し、フォールバック分岐も同時に評価。 |
| ④ | **WANTED ポスター** | コミック効果＋ハーフトーン化された顔写真の上に、生成コードネーム・図鑑文・等級スタンプ・賞金額を組み版。タップひとつでシェア可能。 |

<br/>

## 🎴 主な機能

| | |
|---|---|
| 🎯 **顔の比率測定** | Vision のランドマーク検出で目／鼻／口／顔長の比率を取得 |
| 🤖 **AI 怪人ネーミング** | Apple Intelligence で **ko / ja / en** のいずれかでコードネームと紹介文を即時生成 |
| 🛟 **オフラインフォールバック** | LLM 未対応端末や失敗時のために、言語ごとに 100 件の手書き怪人カタログを内蔵 |
| 🎨 **VHS ポスターレンダリング** | デバイス非依存の固定キャンバスで、どの端末でも同じ仕上がり |
| 🌐 **3言語対応** | 韓国語 / 日本語 / 英語 — UI もポスターも完全多言語化 |
| 🔒 **プライバシー最優先** | カメラ画像も AI 生成結果もすべてオンデバイス処理。アカウント不要 |

<br/>

## 📱 ダウンロード

<div align="center">

<a href="https://apps.apple.com/app/id1642236144">
  <img src="docs/assets/appstore-qr.png" alt="App Store QR" width="180" height="180" />
</a>

iPhone で QR をスキャン、もしくは [App Store リンク](https://apps.apple.com/app/id1642236144) から。

</div>

<br/>

## 🛠 開発環境

```
iOS 26.0+ / Xcode 26 / Swift 6 / Tuist 4.155
```

Xcode プロジェクトは [Tuist](https://tuist.io) で生成します。

```bash
brew install tuist mise
mise install
tuist install
tuist generate
open FaceReader.xcworkspace
```

`Project.swift` または `Tuist.swift` を変更したら、再度 `tuist generate` を実行してください。

<br/>

## 🧩 アーキテクチャ

```
FaceReader
├── App/                  @main エントリポイント
├── Core/                 ロジック層
│   ├── FaceMeasureSession        Vision ラッパー & 比率計算
│   ├── MonsterDescriber          Apple Intelligence（@Generable）
│   └── FallbackMonsterLibrary    JSON ロード式オフラインカタログ
├── Features/             TCA features（Root, FaceMeter, Settings…）
├── UI/                   共有 SwiftUI スタイル（テーマ／フォント／ポスター）
└── Global/Resource/      Assets / Fonts / FallbackMonsters JSON
```

- **状態管理**: [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- **AI 層**: [`FoundationModels`](https://developer.apple.com/documentation/foundationmodels)（オンデバイス）
- **画像処理**: AVFoundation + Vision + CoreImage（`CIComicEffect`）
- **モジュール構成**: `FaceReaderCore` / `FaceReaderUI` / `FaceReaderFeatures` の3つの静的フレームワーク

<br/>

## 🤖 Apple Intelligence プロンプト設計

オンデバイス LLM の出力ブレを抑えるため、以下を採用：

- **英語メタ指示 + ターゲット言語出力** — 非英語（特に韓国語）でも構造化出力が安定
- **`@Generable` 構造体** — コードネームと説明を別フィールドで受け取り
- **5秒タイムアウト + フォールバック** — 失敗・空応答・未対応端末はすべて JSON カタログ抽選
- **身体描写の抑制** — 顔比率は `Vibe` ヒント1個だけ・直接記述禁止指示

詳細は [`FaceReader/Core/MonsterDescriber.swift`](FaceReader/Core/MonsterDescriber.swift) を参照。

<br/>

## 🚀 TestFlight 自動デプロイ

main ブランチへの push または `v*` タグ push で、GitHub Actions が macOS ランナーで archive → IPA → TestFlight アップロードを自動実行します。

```bash
git push origin main          # 即デプロイ
# あるいは
git tag v3.0.1 && git push origin v3.0.1
```

ワークフロー: [.github/workflows/deploy.yml](.github/workflows/deploy.yml) / Fastfile: [fastlane/Fastfile](fastlane/Fastfile)

ヘッドレス CI で安定動作させるための調整:
- `-skipPackagePluginValidation` / `-skipMacroValidation` — Swift マクロの "Trust" GUI プロンプト回避
- 静的フレームワークに `CODE_SIGNING_ALLOWED=NO` — 自動プロビジョニングが全 78 ターゲットへ伝播するのを防止
- App アイコンは RGB（α なし） — actool の検証エラー回避

<br/>

## 📦 依存パッケージ

| 名前 | 経路 |
|---|---|
| [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) | SPM |
| [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) | SPM |
| [swift-case-paths](https://github.com/pointfreeco/swift-case-paths) | SPM |
| `FaceReaderLocalization` | ローカル `Packages/` |

バンドル同梱フォント:
- **Jua-Regular** (韓国語ポップ体)
- **Yusei Magic** (日本語マンガ体)
- **Kosugi Maru** (日本語フォールバック)
- **SangSangAnt** (韓国語フォールバック)

<br/>

## 🔒 プライバシー

- カメラ画像は **端末内** で処理し、サーバーに送信しません
- AI 生成（Apple Intelligence）もすべて **オンデバイス** で完結
- アカウント登録・トラッキング・サードパーティ SDK は使用していません

完全版 → [プライバシーポリシー](https://cobyapp.github.io/FaceReader/ja/privacy.html)

<br/>

## 📄 ライセンス

[MIT License](LICENSE)

<br/>

## 🧑‍💻 作者

| [Coby (김도영)](https://github.com/coby5502) |
|:---:|
| <img width="100" alt="Coby" src="https://user-images.githubusercontent.com/55099365/225215430-0c1fc8ad-6e28-48c2-9473-4f943dd320f8.png"> |

問い合わせ: <coby5502@gmail.com>
