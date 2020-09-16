//
//  Device.swift
//  TPInAppReceiptTests
//
//  Created by Pavel Tikhonenko on 19.06.2020.
//  Copyright © 2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation

protocol Device
{
	var receipt: Data { get }
	var uuid: String { get }
}
