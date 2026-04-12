// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FaceReaderLocalization",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "FaceReaderLocalization", targets: ["FaceReaderLocalization"]),
    ],
    targets: [
        .target(
            name: "FaceReaderLocalization",
            dependencies: [],
            resources: [.process("Resources")]
        ),
    ]
)
