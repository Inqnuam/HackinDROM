//
//  LoginView.swift
//  HackinDROM
//
//  Created by Inqnuam 23/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var sharedData: HASharedData

    @AppStorageCompat("CurrentUser") var CurrentUser = ""
    @AppStorageCompat("UserID") var UserID = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var Message: String = ""
    var body: some View {
        VStack {
            Text(Message)
                .font(.largeTitle)
            Image("login")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            HStack {
                if #available(OSX 11.0, *) {
                    Image(systemName: "person.fill")
                } else {
                   Text("🐱")
                }
                TextField("Username", text: $username)
                    .disableAutocorrection(true)
            }
            .padding(.leading, 100)
            .padding(.trailing, 100)
            .padding(.top, 20)
            HStack {

                if #available(OSX 11.0, *) {
                    Image(systemName: "lock.fill")
                    SecureField("Password", text: $password)
                    // .textContentType(.password) // blocks .keyboardShortcut(.defaultAction)
                } else {

                    Text("🔑")
                    SecureField("Password", text: $password, onCommit: TryLogin)

                }
            }
            .padding(.leading, 100)
            .padding(.trailing, 100)

            if #available(OSX 11.0, *) {
                Button("Login") {
                    TryLogin()
                }
                .keyboardShortcut(.defaultAction)
                .padding(5)
            } else {
                Button("Login") {
                    TryLogin()
                }

                .padding(5)

            }

        }// .padding(10)
        // .frame(minWidth: 500, maxWidth: .infinity, minHeight: 560, maxHeight: .infinity)
    }

    func TryLogin() {
        LogIn(username: username, password: password) { id in

            if id != "nul" {
                CurrentUser = username
                sharedData.ConnectedUser = username
                UserID = id
                sharedData.GetAllBuildsAndConfigure()
            } else {

                Message = "Incorrect"
            }

        }

    }
}
