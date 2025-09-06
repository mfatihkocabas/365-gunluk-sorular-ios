// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DailyQuestions",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "DailyQuestions",
            targets: ["DailyQuestions"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "DailyQuestions",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)