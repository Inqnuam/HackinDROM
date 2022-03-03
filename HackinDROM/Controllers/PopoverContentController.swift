//
//  PopoverContentController.swift
//  HackinDROM
//
//  Created by lian on 15/12/2021.
//  Copyright © 2021 Inqnuam. All rights reserved.
//

import Cocoa

class PopoverContentController: NSViewController {
    var sharedData: HASharedData?
    
    
    var exitBtn: NSButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 560))
        
        exitBtn = NSButton(title: "Exit", target: self, action: #selector(exit))
        exitBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitBtn)
       
        
      let separator = NSView()
       // separator.setFrameSize(NSSize(width: 500, height: 1))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.wantsLayer = true
        separator.layer?.backgroundColor = NSColor.systemGray.cgColor // NSColor.tertiaryLabelColor.cgColor
        separator.layer?.opacity = 0.5
       
        let topSeparator = separator
        let bottomSeparator = separator
        
        view.addSubview(topSeparator)
       // view.addSubview(bottomSeparator)
        let adminBtn = NSButton(image: NSImage(named: NSImage.listViewTemplateName)!, target: self, action: nil)
        let configBtn = NSButton(image: NSImage(named: NSImage.actionTemplateName)!, target: self, action: nil)
        

        let tb = NSStackView(views: [configBtn, adminBtn])
        tb.orientation = .horizontal
        view.addSubview(tb)
        
        
        let efiListView = NSView()
        efiListView.translatesAutoresizingMaskIntoConstraints = false
        efiListView.wantsLayer = true
        efiListView.layer?.backgroundColor = NSColor.red.cgColor
        efiListView.layer?.opacity = 0.2
        view.addSubview(efiListView)
        
        
        
        
        
        NSLayoutConstraint.activate([
            exitBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            exitBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            topSeparator.topAnchor.constraint(equalTo: exitBtn.bottomAnchor, constant: 5),
            topSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),
            topSeparator.widthAnchor.constraint(equalToConstant: 500),
            efiListView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
            efiListView.heightAnchor.constraint(equalToConstant: 490),
            efiListView.widthAnchor.constraint(equalToConstant: 500),
            tb.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            tb.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ])
        
    }
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    
    
    init(sharedData:HASharedData)
    {
        self.sharedData = sharedData
        
        self.sharedData?.initialEFIs = getEFIList()
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func exit(_ sender: NSButton){
        NSApplication.shared.terminate(self)
    }
}

