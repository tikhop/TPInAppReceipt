import Foundation

// MARK: - Device Identifier

/// Provides platform-specific device identifiers for receipt hash verification.
public enum DeviceIdentifier {}

// MARK: - iOS/tvOS/watchOS Implementation

#if !targetEnvironment(macCatalyst) && (os(iOS) || os(watchOS) || os(tvOS))
#if canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

extension DeviceIdentifier {
    /// Retrieves the vendor identifier for the current device.
    ///
    /// - Returns: The device identifier as `Data`, or nil if unavailable.
    public static var data: Data? {
        get async {
            #if canImport(WatchKit)
            let uuid = WKInterfaceDevice.current().identifierForVendor
            #elseif canImport(UIKit)
            let uuid = await UIDevice.current.identifierForVendor
            #endif
            return uuid?.data
        }
    }

    @_spi(Blocking)
    public static var data_blocking: Data? {
        #if canImport(WatchKit)
        let uuid = WKInterfaceDevice.current().identifierForVendor
        #elseif canImport(UIKit)
        let uuid = UIDevice.current.identifierForVendor
        #endif
        return uuid?.data
    }
}
#endif

// MARK: - macOS Implementation

#if targetEnvironment(macCatalyst) || os(macOS)
import IOKit

extension DeviceIdentifier {
    /// Retrieves the MAC address for the current device.
    ///
    /// - Returns: The device identifier as `Data`, or nil if unavailable.
    public static var data: Data? {
        get async {
            obtainMACAddress()
        }
    }

    @_spi(Blocking)
    public static var data_blocking: Data? {
        obtainMACAddress()
    }

    private static func ioService(named name: String, wantBuiltIn: Bool) -> io_service_t? {
        let defaultPort: mach_port_t

        if #available(macOS 12.0, macCatalyst 15.0, *) {
            defaultPort = kIOMainPortDefault
        } else {
            defaultPort = 0
        }

        var iterator = io_iterator_t()
        defer {
            if iterator != IO_OBJECT_NULL {
                IOObjectRelease(iterator)
            }
        }

        guard
            IOServiceGetMatchingServices(
                defaultPort,
                IOBSDNameMatching(defaultPort, 0, name),
                &iterator
            ) == KERN_SUCCESS
        else {
            return nil
        }

        var candidate = IOIteratorNext(iterator)
        while candidate != IO_OBJECT_NULL {
            if let cfBuiltIn = IORegistryEntryCreateCFProperty(
                candidate,
                "IOBuiltin" as CFString,
                kCFAllocatorDefault,
                0
            ) {
                let isBuiltIn = cfBuiltIn.takeRetainedValue() as? Bool ?? false
                if isBuiltIn == wantBuiltIn {
                    return candidate
                }
            }
            IOObjectRelease(candidate)
            candidate = IOIteratorNext(iterator)
        }

        return nil
    }

    private static func obtainMACAddress() -> Data? {
        let interfaces = ["en0", "en1", "en2", "en3", "en4"]

        for interface in interfaces {
            if let service = ioService(named: interface, wantBuiltIn: true),
                let cfData = IORegistryEntrySearchCFProperty(
                    service,
                    kIOServicePlane,
                    "IOMACAddress" as CFString,
                    kCFAllocatorDefault,
                    IOOptionBits(kIORegistryIterateRecursively | kIORegistryIterateParents)
                ) as? Data
            {
                IOObjectRelease(service)
                return cfData
            }
        }

        return nil
    }
}
#endif
