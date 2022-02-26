//
//  BluetoothDevices.swift
//  HackinDROM
//
//  Created by Inqnuam on 26/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import IOBluetooth


func pairedDevices() -> [BTDevices] {
  var connectedDevices:[BTDevices] = []
  guard let devices = IOBluetoothDevice.pairedDevices() else {
    return []
  }
    
  for item in devices {
    if let device = item as? IOBluetoothDevice {
      if device.isConnected() && !device.name.isEmpty && device.rawRSSI() != 127 {
        connectedDevices.append(BTDevices(name: device.name, RSSI: String(device.rawRSSI())))
          
      }
     
    //  print("Paired?: \(device.isPaired())") https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice/1433674-paireddevices
    }
  }
  return connectedDevices
}
