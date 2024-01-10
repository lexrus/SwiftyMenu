//
//  ButtonsView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

struct ActionsView: View {

    @EnvironmentObject var hud: HUDState

    @State var actions: [ActionModel] = []

    @State var showScriptView = false

    @State private var currentActionModel = ActionModel.defaultScript

    @State private var dragOver = false

    @State private var collapseContextMenu = D.collapseContextMenu

    @State private var showSwiftyButton = D.showSwiftyButton

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 0) {
                    Toggle(isOn: $collapseContextMenu) {
                        Text("collapse_context_menu")
                            .foregroundColor(Color(.selectedTextColor))
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .onChange(of: collapseContextMenu) {
                        D.collapseContextMenu = $0
                    }
                }

                HStack(spacing: 0) {
                    Toggle(isOn: $showSwiftyButton) {
                        Text("show_swifty_button")
                            .foregroundColor(Color(.selectedTextColor))
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .onChange(of: showSwiftyButton) {
                        D.showSwiftyButton = $0
                    }
                }

                Spacer()
            }
            .padding(.init(top: 10, leading: 28, bottom: 10, trailing: 28))
            .background(Color(.windowBackgroundColor))

            List {
                ForEach(0..<actions.count, id: \.self) { index in
                    ActionCell(Binding(get: {
                        actions[index]
                    }, set: {
                        actions[index] = $0
                    })) {
                        actions[index].isEnabled = $0
                        save()
                    } tapHandler: { uuid in
                        currentActionModel = getCurrentActionModel(of: uuid)
                        showScriptView.toggle()
                    } deleteHandler: { uuid in
                        actions.removeAll { $0.uuid == uuid }
                        save()
                    }
                }
                .onMove(perform: { indices, newOffset in
                    actions.move(fromOffsets: indices, toOffset: newOffset)
                    save()
                })
            }
            .onAppear {
                actions = D.actions
            }
            .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                providers.forEach { p in
                    p.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, _ in
                        if
                            let data = data,
                            let path = String(data: data, encoding: .utf8),
                            let url = URL(string: path), url.lastPathComponent.hasSuffix(".app"),
                            !SwiftyMenuKit.isApplicationInBlacklist(path: url.path)
                        {
                            addApplicationAction(url.path)
                        }
                    }
                }

                save()

                return true
            }
            .frame(maxWidth: .infinity)

            HStack {
                Button {
                    chooseApplication()
                } label: {
                    Image(systemName: "plus.app.fill")
                    Text("add_application_button")
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .controlSize(.large)

                Button {
                    addCopyPath()
                } label: {
                    Image(systemName: "plus.app.fill")
                    Text("add_copy_path_button")
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .controlSize(.large)

                Button {
                    promptScriptsFolderIfNeeded()
                } label: {
                    Image(systemName: "applescript.fill")
                    Text("add_script_button")
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .controlSize(.large)
                .keyboardShortcut(KeyEquivalent("a"), modifiers: [.command, .option])

                Spacer()
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showScriptView) {
            SheetView(actionModel: $currentActionModel) { action in
                if let index = actions.firstIndex(where: { $0.uuid == action.uuid }) {
                    actions[index] = action
                } else {
                    actions.insert(action, at: 0)
                }

                save()
            } onCancel: { _ in

            }
        }
    }

    private func promptScriptsFolderIfNeeded() {
        guard let runnerURL = SwiftyMenuKit.runnerURL else {
            return
        }
        if !SwiftyMenuKit.checkRunnerScriptInstalled() {
            let alert = NSAlert()
            alert.informativeText = runnerURL.path
            alert.messageText = NSLocalizedString("scripts_permission_message", comment: "")
            alert
                .addButton(withTitle: NSLocalizedString(
                    "scripts_permission_allow_button",
                    comment: ""
                ))
            alert
                .addButton(withTitle: NSLocalizedString(
                    "scripts_permission_deny_button",
                    comment: ""
                ))

            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn:
                installRunner()
            default:
                break
            }
        } else {
            showScriptEditor()
        }
    }

    private func installRunner() {
        SwiftyMenuKit.installRunner { installed in
            if installed {
                showScriptEditor()
            } else {
                hud.show("hud_script_installation_failed")
            }
        }
    }

    private func showScriptEditor() {
        currentActionModel = getCurrentActionModel()
        showScriptView = true
    }

    private func getCurrentActionModel(of uuid: String? = nil) -> ActionModel {
        actions.first(where: { $0.uuid == uuid }) ?? ActionModel.defaultScript
    }

    private func chooseApplication() {
        currentActionModel = getCurrentActionModel()

        let dialog = NSOpenPanel()

        dialog.title = NSLocalizedString("chose_application_panel_title", comment: "")
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        dialog.allowsMultipleSelection = true
        dialog.directoryURL = URL(fileURLWithPath: "/Applications")
        dialog.allowedContentTypes = [.application]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            dialog.urls.forEach { addApplicationAction($0.path) }
            save()
        }
    }

    private func addApplicationAction(_ path: String) {
        let action = ActionModel(applicationPath: path)
        let icon = NSWorkspace.shared.icon(forFile: path)
        let compressIcon = icon.resized(to: NSSize(width: 256, height: 256))

        action.icon = compressIcon.tiffRepresentation

        actions.insert(action, at: 0)

        save()
    }

    private func addCopyPath() {
        let action = ActionModel(applicationPath: "smart:CopyPath")
        action.name = String(localized: "copy_path_action")
        let icon = NSImage(named: "SmartActionIcon")!

        action.icon = icon.tiffRepresentation
        actions.insert(action, at: 0)

        save()
    }

    private func save() {
        D.actions = actions
        DistributedNotificationCenter.default()
            .post(name: .ActionDidUpdate, object: nil)
    }

    private var localConfigURL: URL? {
        guard let url = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        return url.appendingPathComponent("ActionsConfig")
    }
}

struct SheetView: View {
    @Binding var actionModel: ActionModel

    let onSave: ((ActionModel) -> Void)?
    let onCancel: ((ActionModel) -> Void)?

    var body: some View {
        if actionModel.actionType == .script {
            ScriptView(action: $actionModel, onSave: onSave, onCancel: onCancel)
        } else {
            ApplicationView($actionModel, onSave: onSave, onCancel: onCancel)
        }
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
    }
}

extension ActionModel {
    static var defaultScript: ActionModel {
        ActionModel(
            .script,
            name: "Script \(Int(CACurrentMediaTime()))",
            script: """
                #!/bin/bash
                export DIR="$1"
                osascript -l JavaScript <<EOD
                var app = Application.currentApplication()
                app.includeStandardAdditions = true
                // ObjC.import('Foundation')

                var iTerm = Application('iTerm')
                iTerm.activate()
                iTerm.createWindowWithDefaultProfile()
                var session = iTerm.currentWindow().currentSession()
                var dir = app.systemAttribute('DIR')
                var cmd = "cd \\"" + dir + "\\";clear"
                session.write({'text': cmd})
                EOD
                """
        )
    }
}
