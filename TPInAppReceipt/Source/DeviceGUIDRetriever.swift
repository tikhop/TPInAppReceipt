//
//  DeviceGUIDRetriever.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

#if os(macOS)
import IOKit
#endif

class DeviceGUIDRetriever
{
    static func guid() -> Data
    {
        #if os(iOS) || os(watchOS) || os(tvOS)
            return TPInAppReceipt.UIDevice.current.guidData
        #elseif os(macOS)
            var masterPort = mach_port_t()
            var kernResult: kern_return_t = IOMasterPort(mach_port_t(MACH_PORT_NULL), &masterPort)
            if (kernResult != KERN_SUCCESS)
            {
                assertionFailure("Failed to initialize master port")
            }
            
            var matchingDict = IOBSDNameMatching(masterPort, 0, "en0")
            if (matchingDict == nil)
            {
                assertionFailure("Failed to retrieve guid")
            }
            
            var iterator = io_iterator_t()
            kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, &iterator)
            if (kernResult != KERN_SUCCESS)
            {
                assertionFailure("Failed to retrieve guid")
            }
            
            // Iterate over the result
            var guidCFData: CFData!
            var service = IOIteratorNext(iterator)
            var parentService = io_object_t()
            
            defer
            {
                IOObjectRelease(iterator)
            }
            while(service != 0)
            {
                kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
                if (kernResult == KERN_SUCCESS)
                {
                    guidCFData = IORegistryEntryCreateCFProperty(parentService, "IOMACAddress" as CFString, nil, 0) as! CFData?
                    IOObjectRelease(parentService)
                }
                IOObjectRelease(service)
                
                if let _ = guidCFData
                {
                    break
                }
            }
            
            return guidCFData as Data
        #endif
    }
}
