// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLCoding",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XMLDocument",
            targets: ["XMLDocument"]
        ),
        .library(
            name: "XMLFormatter",
            targets: ["XMLFormatter"]
        ),
        .library(
            name: "XMLReader",
            targets: ["XMLReader"]
        ),
        .library(
            name: "XMLWriter",
            targets: ["XMLWriter"]
        ),
        .library(
            name: "XMLCoding",
            targets: ["XMLCoding"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XMLDocument",
            dependencies: []
        ),
        .target(
            name: "XMLFormatter",
            dependencies: []
        ),
        .target(
            name: "XMLReader",
            dependencies: ["XMLDocument"]
        ),
        .target(
            name: "XMLWriter",
            dependencies: ["XMLDocument"]
        ),
        .target(
            name: "XMLCoding",
            dependencies: ["XMLDocument", "XMLReader", "XMLWriter", "XMLFormatter"]
        ),
        .testTarget(
            name: "XMLDocumentTests",
            dependencies: ["XMLDocument"]
        ),
        .testTarget(
            name: "XMLFormatterTests",
            dependencies: ["XMLFormatter"]
        ),
        .testTarget(
            name: "XMLReaderTests",
            dependencies: ["XMLReader"]
        ),
        .testTarget(
            name: "XMLWriterTests",
            dependencies: ["XMLWriter"]
        ),
        .testTarget(
            name: "XMLCodingTests",
            dependencies: ["XMLCoding"]
        ),
    ]
)
