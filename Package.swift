// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "ThinCloud",
    products: [
        .library(name: "ThinCloud", targets: ["ThinCloud"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "4.7.2")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "7.0.2")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "1.2.0")),
    ],
    targets: [
        .target(
            name: "ThinCloud",
            dependencies: [
                "Alamofire",
        ]),
        .testTarget(
            name: "ThinCloudTests",
            dependencies: ["ThinCloud", "Nimble", "Quick"]),
    ]
)
