//
//  MainViewController.swift
//  Ambar
//
//  Created by Inqnuam on 12/11/19.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import AppKit
import SwiftUI
class MainViewController: NSViewController {

    override func viewDidAppear() {
        super.viewDidAppear()
       
        // You can use a notification and observe it in a view model where you want to fetch the data for your SwiftUI view every time the popover appears.
        // NotificationCenter.default.post(name: Notification.Name("ViewDidAppear"), object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: MainViewController.notificationName, object: nil)
    }
    
   
}


