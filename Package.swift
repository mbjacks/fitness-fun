// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PersonalFitnessTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PersonalFitnessTracker",
            targets: ["PersonalFitnessTracker"])
    ],
    targets: [
        .target(
            name: "PersonalFitnessTracker",
            path: "PersonalFitnessTracker",
            exclude: [
                "Assets.xcassets",
                "Info.plist",
                "Services/.gitkeep",
                "Repositories/.gitkeep",
                "ViewModels/.gitkeep"
            ]
        )
    ]
)
