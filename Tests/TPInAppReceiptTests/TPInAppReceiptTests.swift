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
		let r = try! InAppReceipt(receiptData: newReceipt)
		XCTAssert(true)
	}
	
	func testLegacyReceipt()
	{
		let r = try! InAppReceipt(receiptData: receipt)
	}
	
    static var allTests = [
        ("testNewReceipt", testNewReceipt)
    ]
}
