//
//  DiskArbitration.swift
//  iArbitrate
//
//  Created by Ewen Brun on 18/10/2018.
//  Copyright © 2018 3wnbr1. All rights reserved.
//

import Foundation
import DiskArbitration
import LocalAuthentication

var dissenter = DADissenterCreate(kCFAllocatorDefault, DAReturn(kDAReturnExclusiveAccess), "Mount denied" as CFString)

func releaseCallback(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    print("[Release] Disk \(String(describing: DADiskGetBSDName(disk)))")
    return Unmanaged<DADissenter>.fromOpaque(&dissenter)
}

func claimCallback(_ disk: DADisk, _ dissenter: DADissenter?, _ context: UnsafeMutableRawPointer?) {
    print("[Claiming] Disk \(String(describing: DADiskGetBSDName(disk)))")
}

func diskAppeard(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) {
    print("[+] Disk \(String(describing: DADiskGetBSDName(disk)))")
    DADiskClaim(disk, DADiskClaimOptions(kDADiskClaimOptionDefault), releaseCallback, nil, claimCallback, nil)
}

func diskDisappeard(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) {
    print("[-] Disk \(String(describing: DADiskGetBSDName(disk)))")
}

func approveMount() -> Bool {
    let localAuthenticationContext = LAContext()
    var permission: Bool = false
    localAuthenticationContext.localizedFallbackTitle = "Enter Password to unlock disk"
    var error: NSError?
    if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        let reason = "unlock disk"
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            if success {
                permission = true
            } else {
                print(error?.localizedDescription ?? "Failed to authenticate")
            }
        }
    } else {
        print(error?.localizedDescription ?? "Can't evaluate policy")
    }
    print("Returning value.")
    return permission
}

func approveDiskMount(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    print("[i] Mounting behavior \(DiskArbitrator.mount)")
    if DiskArbitrator.mount {
        print("[+] Mounting")
        return nil
    } else {
        print("[+] Mount Denied")
        let ptr_dissenter = Unmanaged.passRetained(dissenter).toOpaque()
        return Unmanaged<DADissenter>.fromOpaque(ptr_dissenter)
    }
}

class DiskArbitrator {

    init() {
        self.register()
        DASessionSetDispatchQueue(session!, queue)
    }

    let queue = DispatchQueue(label: "Arbitration")
    var session = DASessionCreate(kCFAllocatorDefault)
    var matching: CFDictionary?

    static var mount: Bool = true

    func register() {
        DARegisterDiskPeekCallback(self.session!, self.matching, 0, diskAppeard, nil)
        DARegisterDiskDisappearedCallback(self.session!, self.matching, diskDisappeard, nil)
        DARegisterDiskMountApprovalCallback(self.session!, self.matching, approveDiskMount, nil)
    }

    func unregister() {
        // Unregister callback
    }
}
