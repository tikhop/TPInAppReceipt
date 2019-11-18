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

    func testReadCer() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "AppleIncRootCertificate", ofType: "cer"),
              let certData = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let wrappedCertData = try? X509Wrapper(cert: certData) else {
                
            XCTFail("No Apple root certificate found")
            return
        }
        
        
        let asn1certData = ASN1Object(data: certData)
        
        for (index, item) in asn1certData.enumerated()
        {
            if(index == 0){
                for (index2, item2) in item.enumerated(){
                    if(index2 == 6) {
                        for(index3, item3) in item2.enumerated() {
                            if(index3 == 1){
                                
                                if(item3.type.rawValue != 3){
                                    return
                                }
                                
                                guard let valueData = item3.valueData else {
                                    return
                                }
                                
                                var kData = ASN1Object(data: item3.extractValue() as! Data)
                                
                                for(index4, item4) in kData.enumerated() {
                                    if index4 == 0 {
                                        print("item 4 \(item4.valueData!.map { String(format: "%02X", $0) }.joined())")
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }

    }

}
