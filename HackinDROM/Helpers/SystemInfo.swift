//
//  SystemInfo.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 05/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import IOKit
let masterPort = IOServiceGetMatchingService(kIOMasterPortDefault, nil)
let gOptionsRef = IORegistryEntryFromPath(masterPort, "IODeviceTree:/options")
let systemid = IORegistryEntryFromPath(masterPort, "IODeviceTree:/efi/platform")
let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
func modelIdentifier() -> String {

    defer { IOObjectRelease(service) }

    let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, "model", CFStringBuiltInEncodings.UTF8.rawValue)
    let newwayofdoing = IORegistryEntryCreateCFProperty(service, nameRef, kCFAllocatorDefault, 0).takeRetainedValue() as CFTypeRef

    let converteddata = String(decoding: newwayofdoing as! Data, as: UTF8.self).dropLast()

    return String(converteddata)

}

func BoardID() -> String {
    defer { IOObjectRelease(service) }
    if let modelData = IORegistryEntryCreateCFProperty(service, "board-id" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {

        return  String(decoding: modelData, as: UTF8.self)
    } else {
        return ""

    }
}

func GetStorageSerialNumber(_ DevicePath: String) -> String {
    var SerialNumberValue = String(Int.random(in: 100..<999))

    if (DevicePath).contains("IOAHCIBlockStorageDevice") {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, "Device Characteristics", CFStringBuiltInEncodings.UTF8.rawValue)

        if let valeur =  IORegistryEntryCreateCFProperty(IORegistryEntryFromPath(masterPort, DevicePath), nameRef, kCFAllocatorDefault, 0)?.takeRetainedValue() {

            if let DeviceAttr = valeur as? [String: CFTypeRef] {
            if let sm = DeviceAttr["Serial Number"] as? String {

                SerialNumberValue = sm

            }

            }
        }
    } else if (DevicePath).contains("IOUSBMassStorageInterfaceNub") {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, "kUSBSerialNumberString", CFStringBuiltInEncodings.UTF8.rawValue)
        let foundPath = DevicePath.DevPathIO(from: "IOService", to: "IOUSBMassStorageInterfaceNub")

       if let valeur =  IORegistryEntryCreateCFProperty(IORegistryEntryFromPath(masterPort, foundPath), nameRef, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String {

            SerialNumberValue = valeur

        }

    } else if (DevicePath).contains("IONVMeController") {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, "Serial Number", CFStringBuiltInEncodings.UTF8.rawValue)

        if let foundPath = DevicePath.DevPathIO(from: "IOService", to: "IONVMeController") {
       if let valeur =  IORegistryEntryCreateCFProperty(IORegistryEntryFromPath(masterPort, foundPath), nameRef, kCFAllocatorDefault, 0)?.takeRetainedValue()  as? String {

            SerialNumberValue = valeur
        }

        }
    }
    return SerialNumberValue.removeWhitespace()
}

class NVRAM {
    func SetOFVariable(_ name: String, value: String) {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.UTF8.rawValue)
        let valueRef = value.data(using: String.Encoding.ascii)

        IORegistryEntrySetCFProperty(gOptionsRef, nameRef, valueRef as CFTypeRef?)
    }

    func GetOFVariable(_ name: String) -> String {
        var returnhing = ""
        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.UTF8.rawValue)

        if let valueRef = IORegistryEntryCreateCFProperty(gOptionsRef, nameRef, kCFAllocatorDefault, 0) {
            // Read as NSData

            if let data = valueRef.takeUnretainedValue() as? Data {

                returnhing = String(decoding: data, as: UTF8.self)
                // NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            } else if let data = valueRef.takeUnretainedValue() as? String {

                returnhing = data
            }

        } else {
            returnhing = ""
        }

        return returnhing
    }

    func GetMySIP() -> String {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, "csr-active-config", CFStringBuiltInEncodings.UTF8.rawValue)

        if let valueRef = IORegistryEntryCreateCFProperty(gOptionsRef, nameRef, kCFAllocatorDefault, 16) {
            // Read as NSData

            if let data2 = valueRef.takeUnretainedValue() as? Data {

                return Base64toHex(data2.base64EncodedString())

        } else {
            return ""
        }

        }
        return ""
    }

    func systemID(_ name: String) -> String {

        if let valueRef = IORegistryEntryCreateCFProperty(systemid, name as CFString, kCFAllocatorDefault, 16) {

            if let tapor = valueRef.takeRetainedValue() as? Data {

            let byte = tapor.map { String(format: "%02X", $0) }

            if byte.count == 16 {
                return byte[0] + byte[1] + byte[2] + byte[3] + "-" + byte[4] + byte[5] + "-" + byte[6] + byte[7] + "-" + byte[8] + byte[9] + "-" + byte[10] + byte[11] + byte[12] + byte[13]  + byte[14] + byte[15]

            } else {

                return byte.joined(separator: "")
            }

            } else {

                return "System UUID not found"
            }

        } else {

            return "System UUID not found"
        }

    }

    func systemROM(_ name: String) -> String {

        var romoo = ""
        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.UTF16.rawValue)

        if let valueRef = IORegistryEntryCreateCFProperty(gOptionsRef, nameRef, kCFAllocatorDefault, 0) {

        if let data = valueRef.takeUnretainedValue() as? Data {

            romoo = Base64toHex(data.base64EncodedString())
        }
        }

        return romoo
    }

    func PrintOFVariables() {

        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        let result = IORegistryEntryCreateCFProperties(gOptionsRef, dict, kCFAllocatorDefault, 0)

        if let resultDict = dict.pointee?.takeUnretainedValue() as Dictionary? {
            print(resultDict, result)
        }
    }

    func GetPlatformAttributeForKey(_ key: String) -> String {

        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, key, CFStringBuiltInEncodings.UTF8.rawValue)

        let valueRef = IORegistryEntryCreateCFProperty(service, nameRef, kCFAllocatorDefault, 0)

        // Read as NSData
        if let data = valueRef?.takeUnretainedValue() as? Data {
            return NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
        } else {
            // Read as String
            return valueRef!.takeRetainedValue() as! String
        }
    }

    func ClearOFVariable(_ key: String) {

        IORegistryEntrySetCFProperty(gOptionsRef, kIONVRAMDeletePropertyKey as CFString?, key as CFTypeRef?)
    }

}

var HardwareUUID: String? {

    guard service > 0 else {
        return nil
    }

    guard let serialNumber = (IORegistryEntryCreateCFProperty(service, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
        return nil
    }

    IOObjectRelease(service)

    return serialNumber
}

/**
 Retrieves the serial number of your mac device.
 
 - Returns: The string with the serial.
 */
func getMacSerialNumber() -> String {
    var serialNumber: String? {

        guard service > 0 else {
            return nil
        }

        guard let serialNumber = (IORegistryEntryCreateCFProperty(service, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return nil
        }

        IOObjectRelease(service)

        return serialNumber
    }

    return serialNumber ?? "Unknown"
}

public struct GPUSensors: Hashable {
    public let totalPower: UInt
    public let temperature: UInt
    public let fanSpeedPercent: UInt
    public let fanSpeedRPM: UInt
}

public struct GPUInfos: Hashable {

    public let name: String
    public let isOn: Bool
    public let utilization: UInt
    public let vramTotalMB: UInt
    public let vramFreeMB: UInt
    public let coreClockMHz: UInt
    public let memoryClockMHz: UInt
    public let sensors: GPUSensors
}

func getGPUUsage() throws -> [GPUInfos] {

    let pcidevices = try getIOProperties(ioClassname: "IOPCIDevice").filter { (dict: [String: Any]) -> Bool in
        return dict["model"] != nil
    }
    return try getIOProperties(ioClassname: "IOAccelerator").map({ (accelerator: [String: Any]) -> GPUInfos in
        guard let agcInfo = accelerator["AGCInfo"] as? [String: Int] else {
            throw SystemMonitorError.IOKitError(error: "IOAccelerator -> AGCInfo")
        }
        guard let performanceStatistics = accelerator["PerformanceStatistics"] as? [String: Any] else {
            throw SystemMonitorError.IOKitError(error: "IOAccelerator -> PerformanceStatistics")
        }
        guard let pci = try pcidevices.first(where: { (pcidevice: [String: Any]) -> Bool in
            guard let deviceID = pcidevice["device-id"] as? Data, let vendorID = pcidevice["vendor-id"] as? Data else {
                throw SystemMonitorError.IOKitError(error: "IOPCIDevice -> device-id, vendor-id")
            }
            let pciMatch = "0x" + Data([deviceID[1], deviceID[0], vendorID[1], vendorID[0]]).map { String(format: "%02hhX", $0) }.joined()
            let accMatch = accelerator["IOPCIMatch"] as? String ?? accelerator["IOPCIPrimaryMatch"] as? String ?? ""
            return accMatch.range(of: pciMatch) != nil
        }) else {
            throw SystemMonitorError.IOKitError(error: "IOAccelerator IOPCIDevice not corresponding")
        }

        return GPUInfos(
            name: String(data: pci["model"]! as! Data, encoding: String.Encoding.ascii)!,
            isOn: agcInfo["poweredOffByAGC"] == 0,
            utilization: performanceStatistics["Device Utilization %"] as? UInt ?? 0,
            vramTotalMB: accelerator["VRAM,totalMB"] as? UInt ?? pci["VRAM,totalMB"] as? UInt ?? 0,
            vramFreeMB: (performanceStatistics["vramFreeBytes"] as? UInt ?? 0) / (1024 * 1024),
            coreClockMHz: performanceStatistics["Core Clock(MHz)"] as? UInt ?? 0,
            memoryClockMHz: performanceStatistics["Memory Clock(MHz)"] as? UInt ?? 0,
            sensors: GPUSensors(
                totalPower: performanceStatistics["Total Power(W)"] as? UInt ?? 0,
                temperature: performanceStatistics["Temperature(C)"] as? UInt ?? 0,
                fanSpeedPercent: performanceStatistics["Fan Speed(%)"] as? UInt ?? 0,
                fanSpeedRPM: performanceStatistics["Fan Speed(RPM)"] as? UInt ?? 0
            )
        )
    })
}

func getIOProperties(ioClassname: String) throws -> [[String: Any]] {
    var results = [[String: Any]]()
    let matchDict = IOServiceMatching(ioClassname)
    var iterator = io_iterator_t()
    if IOServiceGetMatchingServices(kIOMasterPortDefault, matchDict, &iterator) == kIOReturnSuccess {
        var regEntry: io_registry_entry_t = IOIteratorNext(iterator)
        while regEntry != io_object_t(0) {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(regEntry, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess {
                guard let prop = properties?.takeUnretainedValue() as? [String: Any] else {
                    throw SystemMonitorError.IOKitError(error: ioClassname)
                }
                properties?.release()
                results.append(prop)
            }
            IOObjectRelease(regEntry)
            regEntry = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
    }
    return results
}

enum SystemMonitorError: Error {
    case sysctlError(arg: String, errno: String)
    case hostCallError(arg: Int32, errno: String)
    case conversionFailed(invalidUnit: String)
    case statfsError(errno: String)
    case IOKitError(error: String)
    // case getifaddrsError()
    case SMCError(error: String)
}
