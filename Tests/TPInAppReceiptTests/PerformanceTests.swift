//
//  ASN1Tests.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19.06.20.
//  Copyright © 2019-2020 Pavel Tikhonenko. All rights reserved.
//

import XCTest
import SwiftASN1

@testable import TPInAppReceipt

class PerformanceTests: XCTestCase
{
	var receipt: InAppReceipt!
    var receiptDecoded: Array<UInt8>!
    
	override func setUp()
	{
		receipt = try! InAppReceipt(receiptData: noOriginalPurchaseDateCrashReceipt)
        receiptDecoded = Array(crashReceipt)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
    
	func testParsingPerformance() { //  / 0.004
		// This is an example of a performance test case.
		self.measure {
			do
			{
				let receipt = try InAppReceipt(receiptData: legacyReceipt)
			}catch{
				XCTFail("Unable to parse: \(error)")
			}
		}
	}
	
    func testParsingPerformance_SwiftASN1() {
        
        self.measure {
            do {
                let result = try DER.parse(receiptDecoded)
                //let receipt = try AppStoreReceipt(derEncoded: result)
            }catch{
                XCTFail("Unable to parse: \(error)")
            }
        }
        
    }
    
//	func testValidationPerformance() { //  / 0.004
//		// This is an example of a performance test case.
//		self.measure {
//			do
//			{
//				try receipt.validate()
//			}catch{
//				XCTFail("Unable to verify: \(error)")
//			}
//		}
//	}
//
//	func testHashValidationPerformance() { // 0.000022 // 0.000034
//		// This is an example of a performance test case.
//		self.measure {
//			do
//			{
//				try receipt.verifyHash()
//			}catch{
//				XCTFail("Unable to verify: \(error)")
//			}
//		}
//	}
//
//	func testSignatureValidationPerformance() { // 0.006 // 0.002499
//		// This is an example of a performance test case.
//		self.measure {
//			do
//			{
//				try receipt.verifySignature()
//			}catch{
//				XCTFail("Unable to verify: \(error)")
//			}
//		}
//	}
//
//	func testBundleValidationPerformance() { // 0.000012 // 0.000007
//		// This is an example of a performance test case.
//		self.measure {
//			do
//			{
//				try receipt.verifyBundleIdentifierAndVersion()
//			}catch{
//				XCTFail("Unable to verify: \(error)")
//			}
//		}
//	}
	
}
