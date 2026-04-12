import ProjectDescription

// Shared build settings for modular frameworks
private let frameworkSettings: Settings = .settings(
    base: [
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "202209021",
        "DEVELOPMENT_TEAM": "3Y8YH8GWMM",
        "MARKETING_VERSION": "2.1.0",
        "SWIFT_VERSION": "5.0",
    ]
)

let project = Project(
    name: "FaceReader",
    organizationName: "com.coby",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .singleScheme,
            codeCoverageEnabled: false,
            testingOptions: []
        ),
        defaultKnownRegions: ["en", "ja", "ko", "Base"],
        developmentRegion: "en",
        disableBundleAccessors: true,
        disableShowEnvironmentVarsInScriptPhases: true,
        disableSynthesizedResourceAccessors: true
    ),
    packages: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: Version(1, 14, 0))),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", .upToNextMajor(from: Version(1, 5, 0))),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", .upToNextMajor(from: Version(1, 9, 0))),
        .package(path: "Packages/FaceReaderLocalization"),
    ],
    settings: .settings(base: ["IPHONEOS_DEPLOYMENT_TARGET": "18.0"]),
    targets: [
        .target(
            name: "FaceReaderCore",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.coby.FaceReader.core",
            deploymentTargets: .iOS("18.0"),
            sources: [.glob("FaceReader/Core/**/*.swift")],
            dependencies: [],
            settings: frameworkSettings
        ),
        .target(
            name: "FaceReaderUI",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.coby.FaceReader.ui",
            deploymentTargets: .iOS("18.0"),
            sources: [.glob("FaceReader/UI/**/*.swift")],
            dependencies: [],
            settings: frameworkSettings
        ),
        .target(
            name: "FaceReaderFeatures",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.coby.FaceReader.features",
            deploymentTargets: .iOS("18.0"),
            sources: [.glob("FaceReader/Features/**/*.swift")],
            dependencies: [
                .target(name: "FaceReaderCore"),
                .target(name: "FaceReaderUI"),
                .package(product: "CasePaths"),
                .package(product: "ComposableArchitecture"),
                .package(product: "Dependencies"),
                .package(product: "FaceReaderLocalization"),
            ],
            settings: frameworkSettings
        ),
        .target(
            name: "FaceReader",
            destinations: .iOS,
            product: .app,
            bundleId: "com.coby.FaceReader",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "FaceReader/Global/Support/Info.plist"),
            sources: [.glob("FaceReader/App/**/*.swift")],
            resources: [
                "FaceReader/Global/Resource/Assets.xcassets",
                "FaceReader/Global/Resource/Base.lproj/LaunchScreen.storyboard",
                "FaceReader/Global/Support/PrivacyInfo.xcprivacy",
                "FaceReader/Global/Support/**/*.strings",
            ],
            dependencies: [
                .target(name: "FaceReaderFeatures"),
                .package(product: "CasePaths"),
                .package(product: "ComposableArchitecture"),
                .package(product: "Dependencies"),
                .package(product: "FaceReaderLocalization"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "CODE_SIGN_STYLE": "Automatic",
                    "CURRENT_PROJECT_VERSION": "202209021",
                    "DEVELOPMENT_TEAM": "3Y8YH8GWMM",
                    "GENERATE_INFOPLIST_FILE": "YES",
                    "INFOPLIST_KEY_UILaunchStoryboardName": "LaunchScreen",
                    "MARKETING_VERSION": "2.1.0",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "SWIFT_VERSION": "5.0",
                    "TARGETED_DEVICE_FAMILY": "1",
                ],
                defaultSettings: .recommended(excluding: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS"])
            )
        ),
    ],
    additionalFiles: [
        "Project.swift",
        "Tuist.swift",
    ],
    resourceSynthesizers: []
)
