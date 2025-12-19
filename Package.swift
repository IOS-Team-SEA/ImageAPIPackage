// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "ImageAPI",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(name: "ImageAPI", targets: ["ImageAPI"])
    ],
    dependencies: [
        .package(path: "../PlatformSpineKit"),
        .package(path: "../SocketConnectionPackage")
    ],
    targets: [
        .target(
            name: "ImageAPI",
            dependencies: [
                .product(name: "CommonFoundation", package: "PlatformSpineKit"),
                .product(name: "LoggerKit", package: "PlatformSpineKit"),
                .product(name: "AnalyticsKit", package: "PlatformSpineKit"),
                .product(name: "VisionCapabilities", package: "PlatformSpineKit"),
                .product(name: "ImagePipelineCore", package: "PlatformSpineKit"),
                .product(name: "SocketConnection", package: "SocketConnectionPackage")
            ]
        ),
        .testTarget(
            name: "ImageAPITests",
            dependencies: ["ImageAPI"]
        )
    ]
)
