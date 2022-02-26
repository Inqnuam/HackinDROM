//
//  func.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 06/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation

import SwiftUI
import Zip
import UserNotifications
import Version

func shell(_ command: String, completionHandler: (_ result: String, _ error: String) -> Void) {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL =  URL(fileURLWithPath: "/bin/zsh")

    do {
        try task.run()
       
    } catch {

    }
    // task.

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(data: data, encoding: .utf8) ?? ""

    completionHandler(output.trimmingCharacters(in: .whitespacesAndNewlines), "")

}

@discardableResult
func shellAsync(_ command: String) async -> String {
    
    // #FIXME: Handle error
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL =  URL(fileURLWithPath: "/bin/zsh")

    do {
        try task.run()
       
    } catch {
        print(error)
    }
    // task.

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(data: data, encoding: .utf8) ?? ""

   
    return output.trimmingCharacters(in: .whitespacesAndNewlines)

}



func macserial(_ model: String) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-m", model]
    task.executableURL =  Bundle.main.url(forResource: "macserial", withExtension: "")

    do {
        try task.run()
    } catch {

    }
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(data: data, encoding: .utf8) ?? ""

    return output
}

func runningkexts() -> [RunningKextsStruct] {

    var runningkexts: [RunningKextsStruct] = []

    shell("kextstat | grep -v com.apple | awk '{print $6 \":\"  $7}'") { result, _ in

        let separetaed = result.components(separatedBy: "\n")

        if let indeXX =  separetaed.firstIndex(where: { $0 == "Name:(Version)"}) {
            let    mykexts =  separetaed.dropFirst(indeXX + 1)

            for kext in mykexts {

                let data =  kext.components(separatedBy: ":")

                let lastpoint = data[0].lastIndex(of: ".")?.utf16Offset(in: data[0]) // Result: 2

                runningkexts.append(RunningKextsStruct(
                                        name: String(data[0].dropFirst(lastpoint! + 1)),
                                        version: data[1].slice(from: "(", to: ")") ?? ""))

            }

            runningkexts.sort {
                $0.name < $1.name
            }

        }
    }

    return runningkexts
}

func GetKexts(_ plist: HAPlistStruct) -> [Kexts] {

    var AllKexts: [Kexts] = []
    if let allKexts =  plist.get(["Kernel", "Add"]) {
        
        
        for kxt in allKexts.Childs {
            
            let dArch =  kxt.get(["Arch"])
            let dBundlePath =  kxt.get(["BundlePath"])
            let dComment =  kxt.get(["Comment"])
            let dEnabled =  kxt.get(["Enabled"])
            let dExecutablePath =  kxt.get(["ExecutablePath"])
            let dMaxKernel =  kxt.get(["MaxKernel"])
            let dMinKernel =  kxt.get(["MinKernel"])
            let dPlistPath =  kxt.get(["PlistPath"])
            
            AllKexts.append(Kexts(Arch: dArch?.StringValue ?? "",
                                  BundlePath: dBundlePath?.StringValue ?? "",
                                  Comment: dComment?.StringValue ?? "",
                                  Enabled: dEnabled?.BoolValue ?? false,
                                  ExecutablePath: dExecutablePath?.StringValue ?? "",
                                  MaxKernel: dMaxKernel?.StringValue ?? "",
                                  MinKernel: dMinKernel?.StringValue ?? "",
                                  PlistPath: dPlistPath?.StringValue ?? "")
            )
        }
        
    }
    return AllKexts
}

func GetAMLs(_ plist: HAPlistStruct) -> [AMLs] {
    
    var AllAMLs: [AMLs] = []
    
        if let allALMS =  plist.get(["ACPI", "Add"]) {
            
            
            for driv in allALMS.Childs {
                
                let dPath = driv.get(["Path"])
                let dEnabled = driv.get(["Enabled"])
                let dComment = driv.get(["Comment"])
                
                if !(dPath?.StringValue.isEmpty)! {
                    
                    AllAMLs.append(AMLs(
                                    Comment: dComment?.StringValue ?? "",
                                    Enabled: dEnabled?.BoolValue ?? false,
                                    Path: dPath?.StringValue ?? "")
                    )
                }
                
            }
        }
    
    return AllAMLs
}

func GetDrivers(_ plist: HAPlistStruct, updateTo:String? = nil) -> [Drivers] {

    var AllDrivers: [Drivers] = []
    
   // var mutatingPlist = plist
        if let DriversEl =  plist.get(["UEFI", "Drivers"]) {
            if !DriversEl.Childs.isEmpty {
            if DriversEl.Childs[0].type == "string" {
                        for driv in DriversEl.Childs {
                            AllDrivers.append( Drivers(Path: driv.StringValue, Enabled: !driv.StringValue.hasPrefix("#")))
                        }
                    }
            else if DriversEl.Childs[0].type == "dict" {
                        
                        for driv in DriversEl.Childs {
                            
                            let dPath = driv.get(["Path"])
                            let dEnabled = driv.get(["Enabled"])
                            let dArguments = driv.get(["Arguments"])
                            let dComment = driv.get(["Comment"])
                            
                           
                            var drv = Drivers()
                            
                            if let updateTo = updateTo {
                                
                                drv = Drivers(
                                    Path: dPath?.StringValue ?? "",
                                    Arguments: dArguments?.StringValue ?? "",
                                    
                                    Enabled: dEnabled?.BoolValue ?? false
                                )
                                if Version(updateTo)! > Version("0.7.3")!{
                                    drv.Comment = dComment?.StringValue ?? ""
                                }
                                
                            } else {
                                drv = Drivers(
                                    Path: dPath?.StringValue ?? "",
                                    Arguments: dArguments?.StringValue ?? "",
                                    Comment: dComment?.StringValue ?? "",
                                   
                                    Enabled: dEnabled?.BoolValue ?? false
                                )
                            }
                            AllDrivers.append(drv)
                        }
                    }
        }
        }
    
    return AllDrivers
}

func SetNotif(_ title: String, _ subtitle: String) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle

        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)

}



struct GetState: Decodable {
    var active: Bool
    var status: String
}

func activate(id: String, active: Bool, type: String)  {
  
    var sendthis = active
    sendthis.toggle()
    let url = URL(string: "https://hackindrom.zapto.org/app/state?id=\(id)&active=\(sendthis)&type=\(type)")
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let _ = data else {return}

        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode) == 200 {

              
                
            }
        }

    }
    task.resume()
}
func warning(id: String, warning: Bool)  {
  
    var sendthis = warning
    sendthis.toggle()
    let url = URL(string: "https://hackindrom.zapto.org/app/warning?id=\(id)&warning=\(sendthis)")
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let _ = data else {return}

        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode) == 200 {

            }
        }

    }
    task.resume()
}

func delete(id: String, type: String, uid: String) -> String {
    var gang: String = ""
    let group = DispatchGroup()
    group.enter()
    let session = URLSession(configuration: .default)
    let url = "https://hackindrom.zapto.org/app/del?id=\(id)&type=\(type)"
    session.dataTask(with: URL(string: url)!) {(_, response, err) in
        if err != nil {
            print(err!.localizedDescription)
            return
        }
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode) == 200 {
                gang = "ok"
                group.leave()
            }
        }

    }
    .resume()
    group.wait()

    return gang

}

func SetLatest(bid: String, lid: String, uid: String) -> String {
    var gang: String = ""
    let group = DispatchGroup()
    group.enter()
    let session = URLSession(configuration: .default)
    let url = "https://hackindrom.zapto.org/app/SetLatest?bid=\(bid)&lid=\(lid)"
    session.dataTask(with: URL(string: url)!) {(_, response, err) in
        if err != nil {
            print(err!.localizedDescription)
            return
        }
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode) == 200 {
                gang = "ok"
                group.leave()
            }
        }

    }
    .resume()
    group.wait()

    return gang

}

func GetAllBuilds(completion : @escaping ([AllBuilds])->()) {

    let url = "https://hackindrom.zapto.org/app/builds"

    URLSession.shared.dataTask(with: URL(string: url)!) {(data, response, err) in
        if err != nil {
            print(err!.localizedDescription)
            return
        }

        guard let data = data else {return}

        do {
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {

                    let tups = try JSONDecoder().decode([AllBuilds].self, from: data)

                    completion(tups)
                } else {
                    completion([])
                }
            }

        } catch let jsonErr {

            print(jsonErr)

        }

    }
    .resume()

}

func UpdatePlist(_ file: String, _ AML: [AMLs], _ Kext: [Kexts], _ Driver: [Drivers], CaseyLatestPlist: String, v: String, completion : @escaping (String)->()) {

    
    let Old =  String(decoding: fileManager.contents(atPath: file)!, as: UTF8.self).toBase64URL()
    let Latest =  String(decoding: fileManager.contents(atPath: CaseyLatestPlist)!, as: UTF8.self).toBase64URL()

    let url = URL(string: "https://hackindrom.zapto.org/app/test2?v=\(v)")
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let userdata = Updater(Old: Old, AML: AML, Kext: Kext, Driver: Driver, Latest: Latest)

   let jsonData = try! JSONEncoder().encode(userdata)

   request.httpBody = jsonData

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}

        do {

            //  print("Response data:\n \(todoItemModel.firstname)")
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {
                   let valod = try JSONDecoder().decode(DataResponse.self, from: data)

                    completion(valod.link)

                } else {
                  //  let res = try JSONDecoder().decode(ErrStatus.self, from: data)

                   // gang = AuthGet(firstname: "", lastname: "", lang: res.error)
                }
            }

        } catch let jsonErr {
            print(jsonErr)
        }

    }
    task.resume()

}

func OpenSafari(_ url: String) {
    NSWorkspace.shared.open(URL(string: url)!)

}

func CalculateRequierdSpace(_ BackUp: Int, _ CaseySize: Int) -> Int {

    let BackUpsToFolder = UserDefaults.standard.bool(forKey: "BackUpToFolder")

    if !BackUpsToFolder {
        if BackUp >= CaseySize {

            return BackUp * 2
        } else {

            return BackUp + CaseySize
        }

    } else {

        return CaseySize

    }

}




func GetExtDisk(_ disk: DADisk) -> ExternalDisks {

    var FoundDisk = ExternalDisks(location: "", name: "", size: "", SSD: "")

    let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]

    var size = desc["DAMediaSize"]! as! Int
    size = size/1000000000
    size = Int(Float(size))

    FoundDisk.location = "/dev/" + String(cString: DADiskGetBSDName(disk)!)
    FoundDisk.name = desc["DADeviceModel"]! as! String
    FoundDisk.size = "\(String(size)) Gb"
    FoundDisk.SSD = desc["DADeviceProtocol"]! as! String
    return FoundDisk
}

func GetAllExtDisks() -> [ExternalDisks] {

    var FoundDisk: [ExternalDisks] = []

    shell("diskutil list | grep 'external' | awk '{print $1}'") { req, _ in

        let ExtDisks = req.split(whereSeparator: \.isNewline)

        for disk in ExtDisks {

            let BSDNAME = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, String(disk))!

            FoundDisk.append(GetExtDisk(BSDNAME))

        }
    }

    return FoundDisk
}

func randomHEXByte() -> String {
    let letters = "ABCDEF0123456789"
    return String((0..<2).map { _ in letters.randomElement()! })
}





// func GetIOMediaDAta(_ deviceToFind: String) {
//
//
//
//    var storageIterator = io_iterator_t()
//    var object : io_object_t
//    var result: kern_return_t = KERN_FAILURE
//    let classesToMatchDict = IOServiceMatching("IOMedia")
//
//    result = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatchDict, &storageIterator)
//
//    if KERN_SUCCESS == result && storageIterator != 0 {
//      repeat {
//        object = IOIteratorNext(storageIterator)
//        let data = IORegistryEntryCreateCFProperty(object, kIONameMatchKey as CFString, kCFAllocatorDefault, 0)
//
//      } while object != 0
//      IOObjectRelease(storageIterator)
//    }
//
//    do {
//   try devstats()
//    } catch {
//
//
//    }
// }
// func devstats() throws -> [String: [String: UInt64]] {
//  let drives = try record_all_devices()
//    print(drives)
//  var reports: [String: [String: UInt64]] = [:]
//  for drv in drives {
//    var properties: Unmanaged<CFMutableDictionary>?
//    guard
//      KERN_SUCCESS == IORegistryEntryCreateCFProperties(drv.driver, &properties, kCFAllocatorDefault, 0),
//      let prop = properties?.takeUnretainedValue() as? [String:Any],
//
//      let stat = prop["Statistics"] as? [String: Any]
//
//
//    else {
//      break
//    }//end guard
//
//    properties?.release()
//
//    var report: [String: UInt64] = [:]
//
//    report["bytes_read"] = stat["Bytes (Read)"] as? UInt64 ?? 0
//    report["bytes_written"] = stat["Bytes (Write)"] as? UInt64 ?? 0
//    report["operations_read"] = stat["Operations (Read)"] as? UInt64 ?? 0
//    report["operations_written"] = stat["Operations (Write)"] as? UInt64 ?? 0
//    report["latency_time_read"] = stat["Latency Time (Read)"] as? UInt64 ?? 0
//    report["latency_time_written"] = stat["Latency Time (Write)"] as? UInt64 ?? 0
//    reports[drv.name] = report
//  }
//  return reports
// }
//
//
// func record_all_devices(maxshowdevs: Int = 5) throws -> [DriverStats] {
//  var drivestat = [DriverStats]()
//  guard
//    let ioMedia = IOServiceMatching("IOMedia"),
//
//    let iomatch = ioMedia as? [String: Any] else {
//    throw Panic.MatchIOMediaFailed
//  }
//
//  var match = iomatch
//  match["Whole"] = kCFBooleanTrue
//
//  var drivelist = io_iterator_t()
//
//  guard
//    KERN_SUCCESS == IOServiceGetMatchingServices(kIOMasterPortDefault, match as CFDictionary, &drivelist) else {
//    throw Panic.MatchIOMediaFailed
//  }//end guard
//  var drive = io_object_t(0)
//
//
//  for _ in 0 ... maxshowdevs {
//    drive = IOIteratorNext(drivelist)
//    print(drive)
//    if drive == io_object_t(0) {
//
//    }else {
//      do {
//        let st = try record_device(drive)
//        drivestat.append(st)
//      }catch {
//
//      }//ignore
//    }
//    IOObjectRelease(drive)
//  }//next
//  IOObjectRelease(drivelist)
//  return drivestat
// }
//
//
// struct DriverStats {
//  public var driver = io_registry_entry_t()
//  public var name = ""
//  public var blocksize = UInt64(0)
//  public var total_bytes = UInt64(0)
//  public var total_transfers = UInt64(0)
//  public var total_time = UInt64(0)
// }
//
// let MAXDRIVENAME = 16
// public enum Panic : Error {
//  case DeviceHasNoParent
//  case DeviceDoesNotConformToStorageDriver
//  case DeivceHasNoProperties
//  case MatchIOMediaFailed
//  case SysCtlFailed
// }
//
//
// func record_device(_ drive: io_registry_entry_t) throws -> DriverStats {
//  var parent = io_registry_entry_t()
//  guard KERN_SUCCESS == IORegistryEntryGetParentEntry(drive, kIOServicePlane, &parent) else {
//    throw Panic.DeviceHasNoParent
//  }//end guard
//  guard 0 != IOObjectConformsTo(parent, "IOBlockStorageDriver") else {
//    IOObjectRelease(parent)
//    throw Panic.DeviceDoesNotConformToStorageDriver
//  }//end if
//  var drv = DriverStats()
//  drv.driver = parent
//  var properties: Unmanaged<CFMutableDictionary>? = nil
//  guard
//    KERN_SUCCESS == IORegistryEntryCreateCFProperties(drive, &properties, kCFAllocatorDefault, 0),
//    let prop = properties?.takeUnretainedValue() as? [String:Any],
//    let name = prop[kIOBSDNameKey] as? String
//    else {
//      throw Panic.DeivceHasNoProperties
//  }
//  properties?.release()
//  drv.name = name
//  drv.blocksize = prop["Preferred Block Size"] as? UInt64 ?? 0
//  return drv
// }
