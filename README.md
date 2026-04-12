
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

<img height="30" src="https://img.shields.io/badge/iOS-15.0+-silver"> <img height="30" src="https://img.shields.io/badge/Xcode-15.0-blue">

### :sparkles: Skills & Tech Stack
* UIKit
* AVFoundation
* Vision
* Supabase (Postgres + Storage)
* Lottie
* SDWebImage
* SwiftPM local package (localization)

### 🎁 Library

| Name | Version | |
| ---- | :-----: | ----- |
| Supabase | `Up to Next Major Version` | `SPM` |
| Lottie | branch `master` | `SPM` |
| SDWebImage | `Up to Next Major Version` | `SPM` |
| FaceReaderLocalization | local `Packages/FaceReaderLocalization` | `SPM` |

### Supabase credentials

Put **Supabase URL and publishable key** in repo-root `.env` (copy from `.env.example`, gitignored). The **FaceReaderEnv** aggregate target runs `scripts/generate-secrets-xcconfig.sh` before the app target and writes `Secrets.generated.xcconfig`, which `FaceReader.*.xcconfig` includes; values flow into `Info.plist` as `$(SUPABASE_URL)` / `$(SUPABASE_PUBLISHABLE_KEY)`. Never bundle the **secret** key in the app. See `supabase/README.md`.

### 🗂 Folder Structure

```
FaceReader
  └── FaceReader
        ├── Features/   (stores, clients, factories, sessions)
        ├── Screen/
        └── Global/
```

<br/>

  
### 🧑‍💻 Authors

<div align="leading"> 

| [김도영(Coby)](https://github.com/coby5502) |
|:---:|
|<img width="100" alt="Coby" src="https://user-images.githubusercontent.com/55099365/225215430-0c1fc8ad-6e28-48c2-9473-4f943dd320f8.png">|

  
</div>
