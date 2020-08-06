// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TPInAppReceipt",
	platforms: [.macOS(.v10_11),
				.iOS(.v10),
				.tvOS(.v10),
				.watchOS("6.2")],
	
    products: [
        .library(name: "TPInAppReceipt", targets: ["TPInAppReceipt"]),
    ],
	dependencies: [.package(name: "ASN1Swift", url: "https://github.com/tikhop/ASN1Swift", .branch("master"))],
    targets: [
        .target(
            name: "TPInAppReceipt",
			dependencies: ["ASN1Swift"],
			path: "Sources",
			exclude: ["Bundle+Extension.swift"],
			resources: [.process("AppleIncRootCertificate.cer"), .process("StoreKitTestCertificate.cer")]
		),
		.testTarget(
			name: "TPInAppReceiptTests",
			dependencies: ["TPInAppReceipt"])
	]
)

    
