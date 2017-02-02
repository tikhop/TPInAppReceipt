// Package.swift
//
//  Created by Pavel Tikhonenko on 01/10/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import PackageDescription

let targetFirst  = Target(name: "TPInAppReceipt", dependencies: [dep1, dep2])
let targetSecond = Target(name: "TPInAppReceipt-macos", dependencies: [dep2, dep3])

package.targets.append(targetFirst)  
package.targets.append(targetSecond)  
