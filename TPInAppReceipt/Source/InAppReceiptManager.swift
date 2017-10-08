//
//  InAppReceiptManager.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

/// A InAppReceiptManager instance coordinates access to a local receipt.
public class InAppReceiptManager
{
    /// Creates and returns the 'InAppReceipt' instance
    ///
    /// - Returns: 'InAppReceipt' instance
    /// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
    @available(*, deprecated, message: "Use InAppReceipt.localReceipt() instead")
    public func receipt() throws -> InAppReceipt
    {
        return try InAppReceipt.localReceipt()
    }
    
    /// Returns the default singleton instance.
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}
