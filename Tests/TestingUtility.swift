import Foundation
import SwiftASN1
import X509

@testable import TPInAppReceipt

public enum TestingUtility {
    public static func readFile(_ path: String) -> String {
        let absolutePath = Bundle.module.url(forResource: path, withExtension: "")!
        return try! String(contentsOf: absolutePath, encoding: .utf8)
    }

    public static func readBytes(_ path: String) -> Data {
        let absolutePath = Bundle.module.url(forResource: path, withExtension: "")!
        return try! Data(contentsOf: absolutePath)
    }

    public static func readReceipt(_ path: String) -> Data {
        let file = readFile(path)
        return Data(base64Encoded: file)!
    }

    public static func parseReceipt(_ path: String) throws -> AppReceipt {
        let receiptData = TestingUtility.readReceipt(path)
        let result = try BER.parse(Array(receiptData))
        return try AppReceipt(berEncoded: result)
    }

    public static func certificateToData(_ certificate: Certificate) throws -> Data {
        var serializer = DER.Serializer()
        try serializer.serialize(certificate)
        return Data(serializer.serializedBytes)
    }

    public static func loadRootCertificate() -> Data {
        TestingUtility.readBytes("Assets/AppleIncRootCertificate.cer")
    }

    public static func loadXcodeRootCertificate() -> Data {
        TestingUtility.readBytes("Assets/StoreKitTestCertificate.cer")
    }
}

extension Data {
    var bytes: [UInt8] {
        Array(self)
    }
}
