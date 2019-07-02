//
//  ViewController.swift
//  TPInAppReceipt-iOS-Test
//
//  Created by Pavel Tikhonenko on 01/07/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import UIKit
import TPInAppReceipt

var rBase64 = "You Receupt"

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let r = try! InAppReceipt(receiptData: Data(base64Encoded: rBase64)!)
        try! r.verify()
        // Do any additional setup after loading the view.
    }
    
    
}

