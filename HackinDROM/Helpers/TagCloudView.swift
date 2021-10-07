//
//  TagCloudView.swift
//  HackinDROM
//
//  Created by Inqnuam on 20/05/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import SwiftUI

struct TagCloudView: View {
    @EnvironmentObject var sharedData: HASharedData
    var types = ["array", "dict"]
    var sectionIndex: Int = 0
    @Binding var sectionEl: HAPlistStruct
    @State private var totalHeight
         = CGFloat.zero       // << variant for ScrollView/List
      //  = CGFloat.infinity   // << variant for VStack
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
       // .frame(maxHeight: totalHeight) // << variant for VStack
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(sectionEl.Childs.indexed(), id:\.element.id) { (idx, tag) in
                
                if types.contains(tag.type) {
                    self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.sectionEl.Childs.filter({types.contains($0.type)}).last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.sectionEl.Childs.filter({types.contains($0.type)}).last! {
                            height = 0 // last item
                        }
                        return result
                    })
                
                }
                
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for item: HAPlistStruct) -> some View {
        
        if let IndeX = sectionEl.Childs.firstIndex(where: {$0 == item}) {
            return Button(sectionEl.type == "array" ? "Item \(IndeX)" : item.name) {
                sharedData.sectionIndex = sectionIndex
                sharedData.selectedChild = IndeX
                sharedData.isShowingSheet = true
            }
        } else {
         return  Button("Removed ?") {}
        }
 
    }
  
 
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
    
   
}

