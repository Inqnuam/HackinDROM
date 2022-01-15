//
//  TopToolbarController.swift
//  HackinDROM
//
//  Created by lian on 16/12/2021.
//  Copyright © 2021 Inqnuam. All rights reserved.
//

import Foundation
import AppKit

class TopToolbarView: NSView {
    
    var sharedData: HASharedData?
    private lazy var topSeparator = NSView(frame: NSRect(x: 0, y: 0, width: 560, height: 1))
    init(sharedData:HASharedData)
    {
        super.init(frame: NSRect(x: 0, y: 525, width: 560, height: 200))
        self.sharedData = sharedData
        
        topSeparator.wantsLayer = true
        topSeparator.layer?.backgroundColor = NSColor.systemGray.cgColor // NSColor.tertiaryLabelColor.cgColor
        topSeparator.layer?.opacity = 0.5
        self.addSubview(topSeparator)
        
        let exitBtn = NSButton(title: "Exit", target: self, action: #selector(exit))
        let adminBtn = NSButton(image: NSImage(named: NSImage.listViewTemplateName)!, target: self, action: nil)
        let configBtn = NSButton(image: NSImage(named: NSImage.actionTemplateName)!, target: self, action: nil)
        

        let tb = NSStackView(views: [configBtn, adminBtn, exitBtn])
        tb.orientation = .horizontal
       
        tb.edgeInsets = NSEdgeInsets(top: 0, left: 5, bottom: 200, right: 5)
        self.addSubview(tb)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func exit(_ sender: NSButton){
        NSApplication.shared.terminate(self)
    }
    
    @objc func textFieldDidChange(_ obj: Notification) {
        
    }
}
