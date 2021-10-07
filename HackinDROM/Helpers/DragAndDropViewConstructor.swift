//
//  DragAndDropViewConstructor.swift
//  HackinDROM
//
//  Created by Inqnuam on 08/05/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import SwiftUI



struct DragableImage: View {
    let url: URL
    @State var isHovered: Bool = false
    var body: some View {

        VStack {
            if #available(macOS 11.0, *) {
            Image(systemName: "doc.badge.plus")
                .font(.largeTitle)
                .foregroundColor(.green)
            } else {

                Image("doc.badge.plus")
                .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 38)
                .foregroundColor(.green)
            }

            Text("\(url.lastPathComponent)")
        }

        .opacity(isHovered ? 1 : 0.9)
        .contentShape(Rectangle())
        .onHover { inside in
                    if inside {
                        isHovered = true
                    } else {
                        isHovered = false
                    }
                }

        .onDrag { return NSItemProvider(object: self.url as NSItemProviderWriting) }
    }
}

struct DroppableArea: View {
    @Binding var imageUrls: [Int: URL]
    @Binding var configplists: [URL]
    @State private var active = 0

    var body: some View {
        let dropDelegate = MyDropDelegate(imageUrls: $imageUrls, active: $active, configplists: $configplists)

        return VStack {

            HStack {

                GridCell(active: self.active == 1, url: imageUrls[1] ?? URL(string: "1")!, GridPos: 1, DropHere: "AMD GPU + Broadcom Wifi")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if  imageUrls[1] != nil && imageUrls[1] !=  URL(string: "1")! {
                         
                            
                            configplists.append(imageUrls[1]!)
                            
                        }
                        imageUrls[1] = nil

                    }
                GridCell(active: self.active == 2, url: imageUrls[2] ?? URL(string: "2")!, GridPos: 2, DropHere: "AMD GPU + Intel Wifi")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if  imageUrls[2] != nil && imageUrls[2] !=  URL(string: "2")! {
                       
                            
                            configplists.append(imageUrls[2]!)
                        }
                    imageUrls[2] = nil
                    }
            }

            HStack {
                GridCell(active: self.active == 3, url: imageUrls[3] ?? URL(string: "3")!, GridPos: 3, DropHere: "Intel iGPU + Broadcom Wifi")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if  imageUrls[3] != nil && imageUrls[3] !=  URL(string: "3")! {
                        
                            configplists.append(imageUrls[3]!)
                        }
                     imageUrls[3] = nil
                    }
                GridCell(active: self.active == 4, url: imageUrls[4] ?? URL(string: "4")!, GridPos: 4, DropHere: "Intel iGPU + Intel Wifi")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if  imageUrls[4] != nil && imageUrls[4] !=  URL(string: "4")! {
                     
                            configplists.append(imageUrls[4]!)
                        }
                      
                        imageUrls[4] = nil
                    }
            }

        }
        .background(Rectangle().fill(Color.gray) .opacity(0.2))

        .frame(width: 300, height: 300)
        .onDrop(of: ["public.file-url"], delegate: dropDelegate)

    }
}

struct GridCell: View {
    let active: Bool
    let url: URL
    let GridPos: Int
    let DropHere: String
    @State var hovered: Bool = false
    var body: some View {

        return VStack {

            if url.lastPathComponent.contains(".plist") {
                if #available(macOS 11.0, *) {
                Image(systemName: hovered ? "xmark"  : "doc.badge.gearshape.fill" )
                    .font(.largeTitle)
                    .foregroundColor(GridPos == 1 || GridPos == 2 ? .red : .blue)
            } else {

                Image( hovered ? "xmark"  : "doc.badge.gearshape.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 38)
                    .foregroundColor(GridPos == 1 || GridPos == 2 ? .red : .blue)
            }
                Text(url.lastPathComponent)
                    .multilineTextAlignment(.center)

            } else {

                if #available(macOS 11.0, *) {
                Image(systemName: "doc.badge.gearshape")
                    .font(.largeTitle)
                } else {

                    Image("doc.badge.gearshape")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 38)
                }
                Text(DropHere)
                    .multilineTextAlignment(.center)

            }

        }
        .onHover { inside in
            if inside {
                hovered = true

            } else {
                hovered = false
            }

        }

        .frame(width: 150, height: 150)
        .background(self.active ? Color.green : Color.clear)

    }
}

struct MyDropDelegate: DropDelegate {
    @Binding var imageUrls: [Int: URL]
    @Binding var active: Int
    @Binding var configplists: [URL]
    func validateDrop(info: DropInfo) -> Bool {
        return true // info.hasItemsConforming(to: ["public.file-url"])
    }

    func dropEntered(info: DropInfo) {

    }

    func performDrop(info: DropInfo) -> Bool {

        let gridPosition = getGridPosition(location: info.location)

        self.active = gridPosition

        if let item = info.itemProviders(for: ["public.file-url"]).first {

            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, _) in

                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {

                        if   let draggedURL = URL(string: String(decoding: urlData, as: UTF8.self)) {
                          
                        if let index = configplists.firstIndex(where: { $0.lastPathComponent == draggedURL.lastPathComponent}) {

                            configplists.remove(at: index)
                            self.imageUrls[gridPosition] = draggedURL
                        }

                    
                    }
                    }
                }
            }

            return true

        } else {
            return false
        }

    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = getGridPosition(location: info.location)

        return nil
    }

    func dropExited(info: DropInfo) {
        self.active = 0
    }

    func getGridPosition(location: CGPoint) -> Int {
        if location.x > 150 && location.y > 150 {
            return 4
        } else if location.x > 150 && location.y < 150 {
            return 2
        } else if location.x < 150 && location.y > 150 {
            return 3
        } else if location.x < 150 && location.y < 150 {
            return 1
        } else {
            return 0
        }
    }
}
