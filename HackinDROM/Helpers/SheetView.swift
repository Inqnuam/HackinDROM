//
//  SheetView.swift
//  HackinDROM
//
//  Created by Inqnuam 12/03/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetView: View {
  @Environment(\.presentationMode) var presentationMode
    @Binding var build: AllBuilds
    var body: some View {
     
        VStack {

            HStack {
                Text(build.name)
                    .font(.title)
                    .padding(.leading, 0)
                Spacer()
                Text("OC \(build.latest.ocvs)")
                    .font(.system(size: 14))
                    .padding(.trailing, 0)
            }
            Divider()
            ScrollView {
            Text(build.latest.notes)

                .multilineTextAlignment(.leading)

            }
            HStack {

                HStack {
                    if !build.latest.followLink.isEmpty {

                        HStack {
                           // Image(systemName: "safari.fill")
                            Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.orange)
                                .frame(width: 15, height: 15)

                        }

                        .onTapGesture {
                            OpenSafari(build.latest.followLink)
                    }

                    }

                    Text("by " + build.leader)
                        .font(.subheadline)
                }.padding(.leading, 0)
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.trailing, 0)

            }

        }
        .frame(width: 400, height: 450)
        .padding()
        
    }

}
