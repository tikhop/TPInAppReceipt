// swift-tools-version:6.0

import PackageDescription

#if canImport(Darwin)
let privacyManifestExclude: [String] = []
let privacyManifestResource: [PackageDescription.Resource] = [.copy("Resources/PrivacyInfo.xcprivacy")]
#else
// Exclude on other platforms to avoid build warnings.
let privacyManifestExclude: [String] = ["Resources/PrivacyInfo.xcprivacy"]
let privacyManifestResource: [PackageDescription.Resource] = []
#endif

let package = Package(
    name: "TPInAppReceipt",
	platforms: [.macOS(.v10_15),
				.iOS(.v13),
				.tvOS(.v13),
                .watchOS("6.2"),
                .visionOS(.v1),
                .macCatalyst(.v13)],
	
    products: [
        .library(name: "TPInAppReceipt", targets: ["TPInAppReceipt"]),
    ],
	dependencies: [
        .package(url: "https://github.com/apple/swift-asn1", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.15.1")),
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "4.2.0"))
	],
    targets: [
        .target(
            name: "TPInAppReceipt",
			dependencies: [
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
			path: "Sources",
            exclude: privacyManifestExclude,
			resources: privacyManifestResource + [
                .process("Resources/AppleIncRootCertificate.cer"),
                .process("Resources/StoreKitTestCertificate.cer")
            ]
		),
		.testTarget(
			name: "TPInAppReceiptTests",
			dependencies: [
                "TPInAppReceipt",
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            path: "Tests",
            resources: [.copy("Assets")]
        )
	]
)

    
