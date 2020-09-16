import XCTest
@testable import TPInAppReceipt

final class TPInAppReceiptTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    }

	func testNewReceipt()
	{
		self.measure {
			let r = try! InAppReceipt(receiptData: newReceipt)
			//XCTAssert(r.appVersion == 1)
		}
		
	}
	
	func testLegacyReceipt()
	{
		self.measure {
			let r = try! InAppReceipt(receiptData: legacyReceipt)
		}
		
	}
	
    static var allTests = [
        ("testNewReceipt", testNewReceipt)
    ]
}
