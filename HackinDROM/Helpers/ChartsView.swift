//
//  ChartsView.swift
//  HackinDROM
//
//  Created by Inqnuam 05/03/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct ChartsView: View {
    @Binding var lesvaleurs: [ChartsEmojis]

    var body: some View {

        ZStack {

            VStack(alignment: .leading, spacing: 0) {

                    Divider()
                        .padding(.top, 67)

                    Color.red
                        .opacity(0.0)

            }
            .frame(minHeight: 100.0)
            .padding(.top, 0)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {

                    Color.red
                        .opacity(0.0)

                }

                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.purple]), startPoint: .bottom, endPoint: .top).opacity(0.1))
                .frame(minHeight: 30.0)

                HStack(alignment: .top) {

                    Color.red
                        .opacity(0.0)

                }

                .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.green]), startPoint: .bottom, endPoint: .top).opacity(0.2))
                .frame(minHeight: 37.0)

                HStack(alignment: .top) {

                    Color.red
                        .opacity(0.0)

                }

                .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .bottom, endPoint: .top).opacity(0.2))
                .frame(minHeight: 13.0)

                HStack(alignment: .top) {

                    Color.red
                        .opacity(0.0)

                }

                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .bottom, endPoint: .top).opacity(0.2))
                .frame(minHeight: 10.0)

                HStack(alignment: .top) {

                    Color.red
                        .opacity(0.0)

                }

                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 110.0, green: 7.0, blue: 0.0), Color.red]), startPoint: .bottom, endPoint: .top).opacity(0.1))
                .frame(minHeight: 10.0)

            }.frame(minHeight: 100.0)

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 0) {

                    ForEach(lesvaleurs, id: \.self) { val in

                        Text(val.Emoji)
                            .font(.system(size: 7))
                            .padding(.top, CGFloat(val.valeur))
                      
                            .toolTip("-\(val.valeur)dBm")

                    }
                    Color.red
                        .opacity(0.0)

                }
                .frame(minHeight: 100.0)

            }.frame(minHeight: 100.0)

        }

    }

}

func GetEmojifromVal(_ valeur: Int) -> String {

    var Emoji = ""

    if valeur >= 90 {

        Emoji = "💩"
    } else  if valeur >= 80 && valeur < 90 {

        Emoji = "🤕"
    } else if valeur >= 75 && valeur < 80 {

        Emoji = "🙁"

    } else  if valeur >= 72 && valeur < 75 {

        Emoji = "🙄"

    } else  if valeur >= 68 && valeur < 72 {

        Emoji = "☺️"

    } else  if valeur >= 60 && valeur < 68 {

        Emoji = "😊"

    } else if valeur >= 50 && valeur < 60 {

        Emoji = "😎"

    } else if valeur >= 40 && valeur < 50 {

        Emoji = "🥳"

    } else if valeur >= 30 && valeur < 40 {

        Emoji = "🤩"

    } else if valeur < 30 {

        Emoji = "👽"

    }

    return Emoji
}
