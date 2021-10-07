//
//  testingFunc.swift
//  HackinDROM
//
//  Created by Inqnuam on 22/05/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//
import SwiftUI
import AppKit
struct MaterialTextField: View {
    let placeholder: String
    @Binding var text: String
    @State var isFocus: Bool = false
    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            BorderlessTextField(placeholder: placeholder, text: $text, isFocus: $isFocus)
//                .frame(maxHeight: 40)
//            Rectangle()
//               // .foregroundColor(isFocus ? Color.separatorFocus : Color.separator)
//                .frame(height: isFocus ? 2 : 1)
//        }
        BorderlessTextField(placeholder: placeholder, text: $text, isFocus: $isFocus)
    }
}
class FocusAwareTextField: NSTextField {
    var onFocusChange: (Bool) -> Void = { _ in }
    override func becomeFirstResponder() -> Bool {
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        textView?.insertionPointColor = NSColor.red
        onFocusChange(true)
        return super.becomeFirstResponder()
    }
}
struct BorderlessTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var isFocus: Bool
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeNSView(context: Context) -> NSTextField {
        let textField = FocusAwareTextField()
        textField.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: NSColor.placeholderTextColor
            ]
        )
//        textField.isBordered = false
//        textField.delegate = context.coordinator
//        textField.backgroundColor = NSColor.clear
//
//        textField.focusRingType = .none
        textField.onFocusChange = { isFocus in
            self.isFocus = isFocus
        }
        return textField
    }
    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: BorderlessTextField
        init(_ textField: BorderlessTextField) {
            self.parent = textField
        }
        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.isFocus = false
        }
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.text = textField.stringValue
        }
    }
}
