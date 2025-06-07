//
//  SwiftyMenuRunnerApp.swift
//  SwiftyMenuRunner
//
//  Created by Lex on 5/17/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import Cocoa
import OSLog
import SwiftUI

@main
struct Runner: App {

    init() {
        os_log(.debug, "%@", "Runner initialized.")

        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    var body: some Scene {
        // This is an invisible window that listens for URL schemes.
        WindowGroup {
            Group {}
                .onOpenURL(perform: handleOpenURL)
                .frame(maxWidth: 0, maxHeight: 0)
        }
        .defaultSize(width: 0, height: 0)
        .defaultPosition(.topTrailing)
    }

    private func handleOpenURL(_ url: URL) {
        guard
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = comps.host,
            let action = RunnerActions(rawValue: host)
        else {
            return
        }

        switch action {
        case .addFolder:
            let folder = comps.queryItems?
                .first(where: { $0.name == "folder" })?
                .value
                .map(URL.init(fileURLWithPath:))

            openFolderPanel(defaultFolder: folder) { _ in
                exit(0)
            }
            return

        case .runApp:
            guard
                let queries = comps.queryItems,
                let application = queries.first(where: { $0.name == "path" })?.value
            else {
                return
            }
            let items = queries.filter { $0.name == "item" }.compactMap(\.value)
            let hidesOthers = queries.first(where: { $0.name == "hidesOthers" })?.value == "true"

            runApp(application, items: items, hidesOthers: hidesOthers)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            exit(0)
        }
    }

}
