// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "ThinCloud",
    products: [
        .library(name: "ThinCloud", targets: ["ThinCloud"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "4.7.2")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "7.3.1")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "1.3.2")),
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
