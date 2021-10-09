//
//  HDUpdateView.swift
//  HDUpdateView
//
//  Created by Inqnuam on 09/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import SwiftUI

struct HDUpdateView: View {
    @Binding var isUpdating: Bool
    @Binding var updatingPosition: Double
    @Binding var updatingColor: Color
    var body: some View {
        HStack {
            Color.red
                .opacity(0.0)
            Slider(value: $updatingPosition)
        }
        .background(Color(.black).opacity(0.5))
        .contextMenu(menuItems: {
            Button("Cancel") {
                withAnimation {
                    isUpdating = false
                }
            }
        })
        HStack {
            Color.red
                .opacity(0.0)
            
        }.frame(width: CGFloat(updatingPosition) * 450)
        .background(updatingColor.opacity(0.6))
        .contextMenu(menuItems: {
            Button("Cancel") {
                withAnimation {
                    isUpdating = false
                }
                
            }
        })
        if #available(macOS 11.0, *) {
            ProgressView()
        }
    }
}

