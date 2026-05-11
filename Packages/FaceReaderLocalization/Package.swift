// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FaceReaderLocalization",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v15),
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
