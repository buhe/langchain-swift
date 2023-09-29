// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "langchain-swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LangChain",
            targets: ["LangChain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dylanshine/openai-kit", .upToNextMajor(from: "1.8.2")),
        .package(url: "https://github.com/supabase-community/supabase-swift", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/drmohundro/SWXMLHash", .upToNextMajor(from: "7.0.2")),
        .package(url: "https://github.com/scinfu/SwiftSoup", .upToNextMajor(from: "2.6.1")),
        .package(url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.18.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LangChain",
            dependencies: [
                .product(name: "OpenAIKit", package: "openai-kit"),
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "SWXMLHash", package: "SWXMLHash"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
            ]
        
        ),
        .testTarget(
            name: "LangChainTests",
            dependencies: ["LangChain"]),
    ]
)
