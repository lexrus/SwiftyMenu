//
//  ApplicationView.swift
//  SwiftyMenu
//
//  Created by Lex on 5/11/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

struct ApplicationView: View {

    @Binding var action: ActionModel

    @State var name = ""

    private var onSave: ((ActionModel) -> Void)?
    private var onCancel: ((ActionModel) -> Void)?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isChecked = false
    @State private var isNameHover = false

    init(
        _ action: Binding<ActionModel>,
        onSave: ((ActionModel) -> Void)?,
        onCancel: ((ActionModel) -> Void)?
    ) {
        self._action = action
        self.onSave = onSave
        self.onCancel = onCancel

        isChecked = action.wrappedValue.hidesOthers
    }

    private var iconView: some View {
        VStack(alignment: .leading, spacing: 15) {
            EditImageView(
                nsImage: action.nsImage
                    .resized(to: NSSize(width: 128, height: 128))
            ) { icon in
                action.icon = icon
            }
            .shadow(color: Color(.selectedControlColor).opacity(0.5), radius: 10, x: 0.0, y: 5)
        }
        .padding()
    }

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            iconView

            TextField(
                NSLocalizedString("application_name_placeholder", comment: ""),
                text: $name
            )
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .frame(minWidth: 100, idealWidth: 300, maxWidth: .infinity, minHeight: 30)
            .textFieldStyle(PlainTextFieldStyle())
            .multilineTextAlignment(.center)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(color: Color(.sRGB, white: 0.1, opacity: 0.1), radius: 5, x: 1, y: 1)
            .scaleEffect(isNameHover ? 1.2 : 1)
            .onAppear {
                name = action.name
            }
            .onHover { isHovering in
                withAnimation(.easeOut(duration: 0.2)) {
                    isNameHover = isHovering
                }
            }

            if action.applicationPath?.hasPrefix("smart:") != true {
                HStack(spacing: 0) {
                    Toggle(isOn: $isChecked) {
                        Text("application_hides_others")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .onChange(of: isChecked) {
                        action.hidesOthers = $0
                    }
                }
            }

            Spacer()

            HStack(alignment: .center, spacing: 20) {
                Button {
                    action.name = name
                    onSave?(action)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 15))
                        Text("application_save_button")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .frame(minWidth: 60)
                }
                .controlSize(.large)

                Button {
                    onCancel?(action)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("application_cancel_button")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .frame(minWidth: 60)
                }
                .controlSize(.large)
            }

            Spacer()

        }
        .padding()
        .onAppear {
            isChecked = action.hidesOthers
        }
    }
}

struct ApplicationView_Previews: PreviewProvider {
    @State static var action = ActionModel(applicationPath: "/Applications/Sublime Text.app/")
    static var previews: some View {
        VStack {
            ApplicationView($action, onSave: nil, onCancel: nil)
        }
    }
}
