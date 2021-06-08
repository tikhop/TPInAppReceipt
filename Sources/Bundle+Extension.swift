//
//  Bundle+Extension.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 26.06.2020.
//  Copyright © 2020-2021 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension Bundle
{
	/// Appropriate app version for receipt validation
	var appVersion: String?
	{
		#if targetEnvironment(macCatalyst) || os(macOS)
		let dictKey: String = "CFBundleShortVersionString"
		#else
		let dictKey: String = "CFBundleVersion"
		#endif
		
		guard let v = infoDictionary?[dictKey] as? String else
		{
			return nil
		}
		
		return v
	}
}
