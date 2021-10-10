//
//  HDToggleView.swift
//  HackinDROM
//
//  Created by Inqnuam on 19/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct HDToggleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOn:Bool
    @State var togCol: Color = Color(.systemGreen)
    @State var flash = 0.83
    @State var isDraging:Bool = false
    
    @State var offset: CGFloat = 0
    var disabled:Bool = false
    
    var body: some View {
        
        ZStack {
            //Color("HDToglGrey")
           
            
            RoundedRectangle(cornerRadius: 20)
                .fill(disabled ? .clear : isDraging ? offset > 0 ? togCol : .clear :  isOn ? togCol : .clear)
                .frame(width: 36, height: 21, alignment: .center)
                
            RoundedRectangle(cornerRadius: 20)
                
                .fill(Color.primary.opacity(0.1))
                .shadow(radius: 10)
                .frame(width: 36, height: 21, alignment: .center)
                
          
           
            
            Circle()
         

                .fill(Color.white.opacity(disabled ? 0.6 : 1))
                .shadow(color: .secondary, radius: 0.6)
                .frame(width: 20, height: 20)
                .padding(.all, 2)
                .offset(x: isDraging ? offset : isOn ? 7 : -7 , y: 0)
                
            
           if colorScheme == .dark {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.2))
                .frame(width: 36, height: 21, alignment: .center)
                
            }
          }
        .contentShape(Rectangle())
       // .animation(.linear(duration: 0.15))
        .gesture(
            DragGesture()
                .onChanged { gesture in
               
                    isDraging = true
                    offset = gesture.translation.width
                    
                    if offset > 0 {
                        offset = 7
                        
                    } else  {
                        offset = -7
                        
                    }
                
                }
                .onEnded{ _ in
                 
                    isDraging = false
                  
                    if offset > 0 {
                      isOn = true
                    } else {
                       isOn = false
                    }
                    
                }
            
        )
        .onTapGesture {
          
             isOn.toggle()
            print("Cliked!!")
          
        }
        .allowsHitTesting(!disabled)
        
    }
}

