//
//  ScriptView.swift
//  SwiftyMenu
//
//  Created by iDurian on 2021/4/29.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI

struct ScriptView: View {

    @Binding var action: ActionModel
    
    let onSave: ((ActionModel) -> ())?
    let onCancel: ((ActionModel) -> ())?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    private var icon: some View {
        return EditImageView(nsImage: action.nsImage) { imageData in
            action.icon = imageData
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
                .cornerRadius(5)
                .padding()
            
            Color(.separatorColor)
                .frame(maxWidth: 1, maxHeight: .infinity)

            VStack(spacing: 15) {
                HStack {
                    Text("script_name_label")
                        .frame(width: 48, alignment: .trailing)
                    TextField(
                        "script_name_placeholder",
                        text: $action.name)
                        .frame(minWidth: 100, idealWidth: 300, maxWidth: .infinity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("script_shell_label")
                        .frame(width: 48, alignment: .trailing)
                        
                    TextField(
                        "/bin/bash",
                        text: $action.shell)
                        .frame(minWidth: 100, idealWidth: 300, maxWidth: .infinity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(alignment: .top) {
                    Text("script_content_label")
                        .frame(width: 48, alignment: .trailing)
                    MacEditorTextView(
                        text: $action.script,
                        isEditable: true,
                        font: NSFont(name: "Menlo", size: 12),
                        onEditingChanged: {

                        }, onCommit: {

                        }, onTextChange: { text in

                        })
                        .padding([.top, .bottom], 5)
                        .border(Color(.separatorColor))
                        .frame(minWidth: 130, idealWidth: 320, maxWidth: .infinity, minHeight: 280)
                }

                HStack {
                    Spacer()
                        .frame(width: 55, alignment: .trailing)

                    Button {
                        onSave?(action)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("script_save_button")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .frame(minWidth: 60)
                    }
                    .controlSize(.large)

                    Button {
                        onCancel?(action)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("script_cancel_button")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .frame(minWidth: 60)
                    }
                    .controlSize(.large)

                    Spacer()
                }

            }
            .padding()
        }
    }
}

struct ScriptView_Previews: PreviewProvider {
    @State static var actionModel = ActionModel(.script, name: "hello", script: "world")
    static var previews: some View {
        ScriptView(action: $actionModel, onSave: nil, onCancel: nil)
    }
}
