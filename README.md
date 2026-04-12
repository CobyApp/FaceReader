
<br/>
<br/>

<div align="leading"> 
  
<h1>괴인측정기</h1>

</div>

<br/>

### 📱 Screenshots
![banner](https://github.com/user-attachments/assets/0c6fca89-6d1b-4494-accf-7637b7be1a1a)
<br/>

### 🛠 Development Environment

<img height="30" src="https://img.shields.io/badge/iOS-18.0+-silver"> <img height="30" src="https://img.shields.io/badge/Xcode-15.0-blue">

The Xcode project is generated with [Tuist](https://tuist.io). Install the CLI (for example `brew install tuist`), then from the repo root run `tuist generate` whenever you change `Project.swift` or `Tuist.swift`. Open **`FaceReader.xcworkspace`**. Add `FaceReader/Global/Resource/Fonts/SangSangAnt.otf` (or your font path) to the app target `resources` in `Project.swift` if you add fonts, then run `tuist generate` again.

### :sparkles: Skills & Tech Stack
* SwiftUI
* Composable Architecture (TCA)
* AVFoundation & Vision
* On-device storage (Application Support: JPEG + JSON manifest)
* SwiftPM local package (`FaceReaderLocalization`)

### 🎁 Library

| Name | Version | |
| ---- | :-----: | ----- |
| swift-composable-architecture | SPM | |
| swift-dependencies / CasePaths | SPM | |
| FaceReaderLocalization | local `Packages/FaceReaderLocalization` | SPM |

### 🗂 Folder Structure

```
FaceReader
  ├── App/                 — @main, app entry
  ├── Core/                — models, local store, geometry
  ├── Features/            — TCA features & views
  ├── UI/                  — shared SwiftUI styling
  └── Global/              — resources, Info.plist, privacy
```

<br/>

  
### 🧑‍💻 Authors

<div align="leading"> 

| [김도영(Coby)](https://github.com/coby5502) |
|:---:|
|<img width="100" alt="Coby" src="https://user-images.githubusercontent.com/55099365/225215430-0c1fc8ad-6e28-48c2-9473-4f943dd320f8.png">|

  
</div>
