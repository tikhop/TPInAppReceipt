//
// 	Bundle+Private.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 26.06.2020.
//  Copyright © 2020-2021 Pavel Tikhonenko. All rights reserved.
//

import class Foundation.Bundle
extension Foundation.Bundle
{
	static var module: Bundle =
		{
			return Bundle(for: _TPInAppReceipt.self)
		}()
}

fileprivate class _TPInAppReceipt {}
