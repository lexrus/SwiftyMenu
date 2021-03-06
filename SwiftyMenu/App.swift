//
//  App.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI
import OSLog

@main
struct SwiftMenu: App {

    @StateObject var hud = HUDState()

    @State
    var selectedIndex: Int = 0

    enum TabItems: Int, CaseIterable {
        case enable
        case folders
        case actions
        case about

        var title: String {
            switch self {
            case .enable: return "Enable"
            case .folders: return "Folders"
            case .actions: return "Actions"
            case .about: return "About"
            }
        }

        var iconName: String {
            switch self {
            case .enable: return "sparkles"
            case .folders: return "folder.badge.plus"
            case .actions: return "filemenu.and.selection"
            case .about: return "info.circle.fill"
            }
        }
        
        var detailView: AnyView {
            switch self {
            case .enable: return AnyView(EnableView())
            case .folders: return AnyView(FoldersView())
            case .actions: return AnyView(ActionsView())
            case .about: return AnyView(AboutView())
            }
        }
    }
    
    var body: some Scene {
        WindowGroup("SwiftyMenu") {
            VStack(spacing: 0) {
                ZStack {
                    TabItems(rawValue: selectedIndex)?.detailView
                }
                .transition(.slide)
                .background(Color(.controlBackgroundColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                HStack(alignment: .center, spacing: 15) {
                    ForEach(TabItems.allCases, id: \.rawValue) { item in
                        TabButton(title: item.title, iconName: item.iconName, selected: selectedIndex == item.rawValue) {
                            withAnimation(.easeOut) {
                                selectedIndex = item.rawValue
                            }
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
            }
            .frame(minWidth: 530, maxWidth: 600, minHeight: 450)
            .onAppear {
                restartExtension()
            }
            .environmentObject(hud)
            .hud(isPresented: $hud.isPresented) {
                Text(hud.title)
            }
            .onOpenURL(perform: handleOpenURL)
            .onDisappear {
                exit(0)
            }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button {
                    SwiftyMenuKit.showMainApp()
                } label: {
                    Text("Main window")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .windowToolbarStyle(ExpandedWindowToolbarStyle())
        .windowStyle(TitleBarWindowStyle())
    }

    private func handleOpenURL(_ url: URL) {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        if comps.host == "addFolder" {
            if let folder = comps.queryItems?.first(where: { $0.name == "folder" })?.value {
                selectedIndex = TabItems.folders.rawValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SwiftyMenuKit.openFolderPanel(folderURL: URL(fileURLWithPath: folder))
                }
            }
        }
    }

    private func restartExtension() {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/bin/pluginkit"
        task.arguments = ["-e", "use", "-i", "sh.lex.SwiftyMenu.Sync"]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()

        if let result = String(data: file.readDataToEndOfFile(), encoding: .utf8) {
            os_log(.debug, "%@", result)
        }
    }

}
