//
//  ASN1Tests.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19.06.20.
//  Copyright © 2019-2020 Pavel Tikhonenko. All rights reserved.
//

import XCTest
@testable import TPInAppReceipt

class PerformanceTests: XCTestCase
{
	var receipt: InAppReceipt!
	
	override func setUp()
	{
		receipt = try! InAppReceipt(receiptData: legacyReceipt)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	
	
	func testValidationPerformance() { //  / 0.004
		// This is an example of a performance test case.
		self.measure {
			do
			{
				try receipt.verify()
			}catch{
				XCTFail("Unable to verify: \(error)")
			}
		}
	}

	func testHashValidationPerformance() { // 0.000022 // 0.000034
		// This is an example of a performance test case.
		self.measure {
			do
			{
				try receipt.verifyHash()
			}catch{
				XCTFail("Unable to verify: \(error)")
			}
		}
	}

	func testSignatureValidationPerformance() { // 0.006 // 0.002499
		// This is an example of a performance test case.
		self.measure {
			do
			{
				try receipt.verifySignature()
			}catch{
				XCTFail("Unable to verify: \(error)")
			}
		}
	}

	func testBundleValidationPerformance() { // 0.000012 // 0.000007
		// This is an example of a performance test case.
		self.measure {
			do
			{
				try receipt.verifyBundleIdentifierAndVersion()
			}catch{
				XCTFail("Unable to verify: \(error)")
			}
		}
	}
	
}
