import XCTest
@testable import TPInAppReceipt

final class TPInAppReceiptTests: XCTestCase {
	func testCrashReceipts() {
		var r = try? InAppReceipt(receiptData: noOriginalPurchaseDateCrashReceipt)
	}
	
	func testNewReceipt() {
		self.measure {
			let r = try! InAppReceipt(receiptData: newReceipt)
			print(r.creationDate)
		}
		
	}
	
	func testLegacyReceipt() {
		self.measure {
			let r = try! InAppReceipt(receiptData: legacyReceipt)
		}
		
	}
	
    static var allTests = [
        ("testNewReceipt", testNewReceipt)
    ]
}
