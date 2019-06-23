//
//  main.swift
//  Example
//
//  Created by Pavel Tikhonenko on 23/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import TPInAppReceipt

print("Hello, World!")

func testNoOpenssl()
{
    //self.measure
    //{
    let mock = try! PKCS7WrapperMock()
    mock.extractASN1Data().enumerateASN1AttributesNoOpenssl(withBlock: { (item) in
        
    })
    
    //}
}

func test()
{
    //        self.measure
    //            {
    let mock = try! PKCS7WrapperMock()
    mock.extractASN1Data().enumerateASN1Attributes(withBlock: { (item) in
        
    })
    
    //        }
}

testNoOpenssl()
