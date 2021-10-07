//
//  AppKitsharedData.swift
//  HackinDROM
//
//  Created by Inqnuam on 26/06/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import AppKit
import SwiftUI

//struct TextFieldTyped: NSViewRepresentable {
//
//    @Binding var text: String
//
//    func makeUIView(context: Context) -> NSTextField {
//        let textField = NSTextField(frame: .zero)
//
//        _ = NotificationCenter.default.publisher(for: NSTextField.textDidChangeNotification, object: textField)
//            .compactMap {
//                guard let field = $0.object as? NSTextField else {
//                    return nil
//                }
//                return field.stringValue
//            }
//            .sink {
//                self.text = $0
//            }
//
//        return textField
//    }
//
//    func updateUIView(_ uiView: NSTextField, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, NSTextFieldDelegate {
//        var parent: TextFieldTyped
//
//        init(_ textField: TextFieldTyped) {
//            self.parent = textField
//        }
//
////        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////            if let value = textField.text {
////                parent.text = value
////                parent.onChange?(value)
////            }
////
////            return true
////        }
//    }
//}

