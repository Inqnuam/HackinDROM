//
//  Extensions.swift
//  HackinDROM
//
//  Created by Inqnuam 12/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import SwiftUI

extension Data {
    
    
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
                
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
    
    /// A hexadecimal string representation of the bytes.
    func hexEncodedString() -> String {
        let hexDigits = Array("0123456789ABCDEF".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}
extension String {
    /// Expanded encoding
    ///
    /// - bytesHexLiteral: Hex string of bytes
    /// - base64: Base64 string
    enum ExpandedEncoding {
        /// Hex string of bytes
        case bytesHexLiteral
        /// Base64 string
        case base64
    }
    
    /// Convert to `Data` with expanded encoding
    ///
    /// - Parameter encoding: Expanded encoding
    /// - Returns: data
    func data(using encoding: ExpandedEncoding) -> Data? {
        switch encoding {
        case .bytesHexLiteral:
            guard String(self).count % 2 == 0 else { return nil }
            var data = Data()
            var byteLiteral = ""
            for (index, character) in String(self).enumerated() {
                if index % 2 == 0 {
                    byteLiteral = String(character)
                } else {
                    byteLiteral.append(character)
                    guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                    data.append(byte)
                }
            }
            return data
        case .base64:
            return Data(base64Encoded: self)
        }
    }
    
    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func DevPathIO(from: String, to: String) -> String? {
        
        return (range(of: from)?.lowerBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.upperBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func fromBase64URL() -> String? {
        var base64 = self
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64URL() -> String {
        var result = Data(self.utf8).base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
    
}

extension UserDefaults {
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension Date {
    init(dateString: String) {
        self = Date.iso8601Formatter.date(from: dateString)!
    }
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]
        return formatter
    }()
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }
    
    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = fileManager.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }
    
    /// returns the directory total size on disk
    func sizeOnDisk() throws -> Int {
        
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return 0 }
        //        print(size)
        //        URL.byteCountFormatter.allowedUnits = ByteCountFormatter.Units.useMB
        //        URL.byteCountFormatter.countStyle = ByteCountFormatter.CountStyle.file
        //        URL.byteCountFormatter.includesUnit = false
        //        URL.byteCountFormatter
        //        //URL.byteCountFormatter.countStyle = .file
        //
        //        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        //        return byteCount + " on disk"
        return size
    }
    
    func sizeWithUnits() throws -> Double {
        
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return 0.0 }
        
        URL.byteCountFormatter.allowedUnits = ByteCountFormatter.Units.useMB
        URL.byteCountFormatter.countStyle = ByteCountFormatter.CountStyle.file
        URL.byteCountFormatter.includesUnit = false
        // URL.byteCountFormatter
        // URL.byteCountFormatter.countStyle = .file
        
        guard let byteCount = Double(URL.byteCountFormatter.string(for: size)!.replacingOccurrences(of: ",", with: ".")) else { return 0.0}
        return byteCount
        // return size
    }
    static let byteCountFormatter = ByteCountFormatter()
}

extension Array where Element == UInt8 {
    func bytesToHex(spacing: String) -> String {
        var hexString: String = ""
        var count = self.count
        for byte in self {
            hexString.append(String(format: "%02X", byte))
            count = count - 1
            if count > 0 {
                hexString.append(spacing)
            }
        }
        return hexString
    }
    
}

extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

struct Tooltip: NSViewRepresentable {
    let tooltip: String
    
    func makeNSView(context: NSViewRepresentableContext<Tooltip>) -> NSView {
        let view = NSView()
        view.toolTip = tooltip
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Tooltip>) {
    }
}

public extension View {
    func toolTip(_ toolTip: String) -> some View {
        self.overlay(Tooltip(tooltip: toolTip))
    }
}
extension HAPlistStruct {
    func find(_ findingName: String) -> HAPlistStruct {
        return self.Childs.first(where: {$0.name == findingName}) ?? HAPlistStruct()
    }
    
    func get(_ values: [Any]) -> HAPlistStruct? {
        
        var foundElement:HAPlistStruct? = self
        for val in values {
            
            let valType = String(describing: Swift.type(of: val ))
            
            if (valType == "String") {
                if foundElement != nil {
                    if let gevor = foundElement!.Childs.first(where: {$0.name == val as! String}) {
                        foundElement = gevor
                    }
                } else {return nil}
            } else if valType == "Int" {
                if foundElement != nil {
                    if  self.Childs.indices.contains(val as! Int) {
                        foundElement =  foundElement!.Childs[val as! Int]
                    }
                } else {return nil}
            }
            
        }
        
        return foundElement
    }
    
    func getHAPlistPath(from: [Any])-> [Int] {
        
        var indexs:[Int] = []
        var foundElement:HAPlistStruct = self
        for key in from {
            
            let valType =  Swift.type(of: key)
            
            if valType is String.Type {
                
                if let gevor = foundElement.Childs.firstIndex(where: {$0.name == key as! String}) {
                    indexs.append(gevor)
                    foundElement = foundElement.Childs[gevor]
                } else {return []}
                
            } else if valType is Int.Type {
                
                if  foundElement.Childs.indices.contains(key as! Int) {
                    indexs.append(key as! Int)
                    foundElement = foundElement.Childs[key as! Int]
                } else {return []}
                
            }
            
        }
        return indexs
    }
    
    mutating func set(_ val:HAPlistStruct, to: [Any])-> Bool {
        var settingValue = val
        var indexs:[Int] = getHAPlistPath(from: to)
        
        if !indexs.isEmpty {
            var settingPath: WritableKeyPath = \HAPlistStruct.Childs[indexs[0]]
            indexs.removeFirst()
            for ind in indexs {
                settingPath =  settingPath.appending(path: \.Childs[ind])
            }
            
            settingValue.ParentName = self[keyPath: settingPath].ParentName
            self[keyPath: settingPath] = settingValue
            return true
        } else {return false}
    }
    
}
extension Binding {
    func toggled(_ hav: Int, _ name:String, _ handler: @escaping (ToggleChanged) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(ToggleChanged(which: hav, yes: newValue as! Bool, name: name))
                
            }
        )
    }
    
    func stringChanged(_ hav: Int, _ handler: @escaping (StringChanged) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(StringChanged(which: hav, what: newValue as! String))
                
            }
        )
    }
    
    func pickerChanged(_ handler: @escaping (Int) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! Int)
                
            }
        )
    }
    
    func buildChanged(_ handler: @escaping (AllBuilds) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! AllBuilds)
                
            }
        )
    }
    
    func plistChanged(_ handler: @escaping (PlistData) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! PlistData)
                
            }
        )
    }
    func configChanged(_ handler: @escaping (BuildConfigs) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! BuildConfigs)
                
            }
        )
    }
    func pickerSelected(_ handler: @escaping (String) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! String)
                
            }
        )
    }
    
    func externalSelected(_ handler: @escaping (ExternalDisks) -> Void) -> Binding<Value> {
        
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue as! ExternalDisks)
                
            }
        )
    }
    
}


func Base64toHex(_ dataString: String) -> String {
    var returnthis = ""
    
    if let nsdata1 = Data(base64Encoded: dataString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
        
        let arr2 = nsdata1.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt8>(start: $0, count: nsdata1.count/MemoryLayout<UInt8>.size))
            
        }
        
        returnthis =  arr2.bytesToHex(spacing: "")
    }
    return returnthis
}


func ConvertToMB(_ size: Int) -> String {
    
    //  let byteCountFormatter2 = ByteCountFormatter()
    
    URL.byteCountFormatter.allowedUnits = ByteCountFormatter.Units.useMB
    URL.byteCountFormatter.countStyle = ByteCountFormatter.CountStyle.file
    URL.byteCountFormatter.includesUnit = true
    
    return   URL.byteCountFormatter.string(for: size)!
    
}



extension FloatingPoint {
    var isInteger: Bool { rounded() == self }
}

class BridgeNSWindow: ObservableObject {
    @ObservedObject var sharedData: HASharedData
    @ObservedObject var HAPlist: HAPlistContent
    var win: NSWindow
    
    
    init (HAPlist: HAPlistContent, sharedData: HASharedData) {
        self.sharedData = sharedData
        self.HAPlist = HAPlist
        win = NSWindow()
        let controller = NSHostingController(rootView: PlistEditorMainView(HAPlist: self.HAPlist).environmentObject(self.sharedData))
        self.win.contentViewController = controller
        
        
        
        let toolbarButtons = NSHostingView(rootView: ToolbarButtons(HAPlist: HAPlist).environmentObject(sharedData))
        toolbarButtons.frame.size = toolbarButtons.fittingSize
        
        let titlebarAccessory = NSTitlebarAccessoryViewController()
        titlebarAccessory.view = toolbarButtons
        titlebarAccessory.layoutAttribute = .trailing
        
        win.styleMask = [.titled,
                         .unifiedTitleAndToolbar,
                         .closable,
                         .miniaturizable,
                         .resizable,
                         .fullSizeContentView]
        win.backingType = .buffered
        win.titleVisibility = .hidden
        win.addTitlebarAccessoryViewController(titlebarAccessory)
        win.makeMain()
        win.makeFirstResponder(nil)
        
        
        win.appearance =  NSAppearance(named: .vibrantLight)
        win.setContentSize(NSSize(width: 800, height: 700))
        win.title = "Plist Editor"
        win.makeKeyAndOrderFront(nil)
        
    }
    
    
    func toggleWindow()-> NSWindow {
        !win.isVisible ? win.makeKeyAndOrderFront(nil) : nil
        return win
    }
}

func openIn(HAPlist: HAPlistContent, sharedData: HASharedData) {
    
    
    let controller = NSHostingController(rootView:PlistEditorMainView(HAPlist: HAPlist).environmentObject(sharedData))
    let win = NSWindow(contentViewController: controller)
    
    
    
    let toolbarButtons = NSHostingView(rootView: ToolbarButtons(HAPlist: HAPlist).environmentObject(sharedData))
    toolbarButtons.frame.size = toolbarButtons.fittingSize
    
    let titlebarAccessory = NSTitlebarAccessoryViewController()
    titlebarAccessory.view = toolbarButtons
    titlebarAccessory.layoutAttribute = .trailing
    
    win.styleMask = [.titled,
                     .unifiedTitleAndToolbar,
                     .closable,
                     .miniaturizable,
                     .resizable,
                     .fullSizeContentView]
    win.backingType = .buffered
    win.titleVisibility = .hidden
    win.addTitlebarAccessoryViewController(titlebarAccessory)
    win.makeMain()
    win.makeFirstResponder(nil)
    
    
    win.appearance =  NSAppearance(named: .vibrantLight)
    win.setContentSize(NSSize(width: 800, height: 700))
    win.title = "Plist Editor"
    win.makeKeyAndOrderFront(nil)
    
}
