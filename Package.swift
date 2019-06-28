// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TPInAppReceipt",
    products: [
        .library(name: "TPInAppReceipt", targets: ["TPInAppReceipt"]),
    ],
    targets: [
        .target(
            name: "TPInAppReceipt",
			path: "TPInAppReceipt/Source")
    ]
)
