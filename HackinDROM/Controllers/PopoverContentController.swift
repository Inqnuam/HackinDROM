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
  
    private lazy var bottomSeparator = NSView(frame: NSRect(x: 0, y: 30, width: 560, height: 1))
    private lazy var inputArea = NSView(frame: NSRect(x: 300, y: 480, width: 400, height: 100))
    private lazy var btnArea = NSView(frame: NSRect(x: 300, y: 400, width: 400, height: 100))
    
    var txtField = NSTextField(string: "Miaou")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        txtField.placeholderString = "Yoooo"
        
       //#FIXME separate main view in 3 NSView -> Top Toobar, EFI List and Bottom Toolbar
        let myBtn = NSButton(title: "Print and Clear", target: self, action: #selector(test))
        //myBtn.appearance = NSAppearance(named: .vibrantLight)
        inputArea.addSubview(txtField)
     
     
        
        bottomSeparator.wantsLayer = true
        bottomSeparator.layer?.backgroundColor = NSColor.tertiaryLabelColor.cgColor
        view.addSubview(bottomSeparator)
        view.addSubview(inputArea)
        btnArea.addSubview(myBtn)
        view.addSubview(btnArea)
       
        let topToolBar = TopToolbarView(sharedData: sharedData!)
        view.addSubview(topToolBar)
    }
    
    @IBAction func test(_ sender: NSButton) {
        print(txtField.stringValue)
        
        txtField.stringValue = ""
        dump(sharedData?.initialEFIs[1])
        sharedData!.initialEFIs[1].mounted =  sharedData!.initialEFIs[1].mount()
        
        dump(sharedData?.initialEFIs[1])
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: NSScreen.main?.frame.width ?? 100, height: NSScreen.main?.frame.height ?? 100))
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
    
}

