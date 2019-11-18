//
//  X509Tests.swift
//  TPInAppReceiptTests
//
//  Created by Soulchild on 18/11/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import XCTest
@testable import TPInAppReceipt

class X509Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadCerAndExtractPublicKey() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "AppleIncRootCertificate", ofType: "cer"),
              let certData = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let wrappedCertData = try? X509Wrapper(cert: certData) else {
                
            XCTFail("No Apple root certificate found")
            return
        }
        
        guard let publicKeyData = wrappedCertData.extractPublicKey() else {
            XCTFail("Unable to extract public key from Apple root certificate")
            return
        }
        
        let publicKeyHexString = publicKeyData.map { String(format: "%02X", $0) }.joined()
        
        let actualHexString = "00E491A9091F91DB1E4750EB05ED5E79842DEB36A2574C55EC8B1989DEF94B6CF507AB223002E8183EF85009D37F41A898F9D1CA669C246B11D0A3BBE41B2AC31F959E7A0CA4478B5BD4163733CBC40F4DCE1469D1C91972F55D0ED57F5F9BF22503BA558F4D5D0DF1643523154B15591DB394F7F69C9ECF50BAC15850678F08B420F7CBAC2C206F70B63F01308CB743CF0F9D3DF32B49281AC8FECEB5B90ED95E1CD6CB3DB53AADF40F0E00920BB121162E74D53C0DDB6216ABA37192475355C1AF2F41B3F8FBE370CDE6A34C457E1F4C6B50964189C474620B10834187338A81B13058EC5A04328C68B38F1DDE6573FF675E65BC49D8769F331465A17794C92D"
        
        XCTAssertEqual(publicKeyHexString, actualHexString)
    }
}
