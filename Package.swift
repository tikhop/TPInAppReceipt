// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TPInAppReceipt",
	platforms: [.macOS(.v10_11),
				.iOS(.v9),
				.tvOS(.v9),
				.watchOS(.v2)],
    products: [
        .library(name: "TPInAppReceipt", targets: ["TPInAppReceipt"]),
    ],
    targets: [
        .target(
            name: "TPInAppReceipt",
			path: "TPInAppReceipt/Source")
    ]
)
