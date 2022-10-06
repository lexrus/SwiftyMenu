//
//  SwiftyMenuSync+Running.swift
//  SwiftyMenuSync
//
//  Created by Lex on 5/22/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import Cocoa
import Foundation
import OSLog

extension SwiftyMenuSync {

    func run(scriptURL: URL, shell: String = "/bin/sh", arguments: [String] = []) {
        guard let runnerURL = SwiftyMenuKit.runnerURL else {
            return
        }

        let arguments = [
            shell,
            scriptURL.path,
            arguments.joined(separator: " "),
        ]

        do {
            let task = try NSUserUnixTask(url: runnerURL)

            task.execute(withArguments: arguments) { error in
                error.map { os_log(.debug, "%@", $0.localizedDescription) }
                os_log(.debug, "complete")
            }
        } catch {
            os_log(.debug, "%@", error.localizedDescription)
        }
    }

    func runApplication(_ applicationPath: String, hidesOthers: Bool = false) {
        var comps = URLComponents()
        comps.scheme = "swiftymenurunner"
        comps.host = "runApp"
        comps.queryItems = [
            .init(name: "path", value: applicationPath),
            .init(name: "hidesOthers", value: hidesOthers ? "true" : "false"),
        ]

        validTargets().forEach {
            comps.queryItems?.append(.init(name: "item", value: $0.path))
        }

        guard let url = comps.url else { return }

        if FileManager.default.fileExists(atPath: Bundle.runnerAppURL.path) {
            let openConfig = NSWorkspace.OpenConfiguration()
            openConfig.activates = true
            openConfig.createsNewApplicationInstance = true

            NSWorkspace.shared.open(
                [url],
                withApplicationAt: Bundle.runnerAppURL,
                configuration: openConfig
            ) { app, err in
                if let err = err {
                    Self.alert(err.localizedDescription)
                    os_log(.error, "Failed to open runner: %@", err.localizedDescription)
                } else {
                    app?.activate(options: .activateIgnoringOtherApps)
                    os_log(.debug, "Open runner succeed.")
                }
            }
        } else {
            // kinda impossible
            NSWorkspace.shared.open(url)
        }
    }

    private static func alert(_ message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.informativeText = NSLocalizedString("Error", comment: "")
        alert.messageText = message
        alert.addButton(withTitle: NSLocalizedString("Okay", comment: ""))

        alert.runModal()
    }

}
