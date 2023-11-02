// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KUIPopOver",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "KUIPopOver",
            targets: ["KUIPopOver"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KUIPopOver",
            dependencies: [],
            path: "KUIPopOver",
            sources: ["Classes"],
            publicHeadersPath: "Classes"
        )
    ],
    swiftLanguageVersions: [.v5]
)
