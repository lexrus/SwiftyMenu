//
//  SwiftyMenuKit.swift
//  SwiftyMenuKit
//
//  Created by Lex on 4/27/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import AppKit
import FinderSync
import Foundation
import OSLog

public enum RunnerActions: String {
    case addFolder
    case runApp
}

public enum SwiftyMenuKit {

    fileprivate static var mainScriptsDirectory: URL = {
        let manager = FileManager.default
        var scriptsFolder: URL!

        do {
            scriptsFolder = try manager.url(
                for: .applicationScriptsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        } catch {
            scriptsFolder = manager.urls(
                for: .applicationScriptsDirectory,
                in: .userDomainMask
            ).first!
        }

        return scriptsFolder
    }()

//    public static var runnerURL: URL? {
//        scriptsDirectory?.appendingPathComponent("runner.sh")
//    }

    public static func installScript(
        script: SwiftyMenuScript,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.canChooseFiles = false
        panel.directoryURL = script.dir
        panel.begin { response in
            guard
                response == .OK,
                let url = panel.url,
                script.dir.path.hasPrefix(url.path)
            else {
                completionHandler(false)
                return
            }

            // Create the subfolder

            do {
                if !FileManager.default.fileExists(atPath: script.dir.path) {
                    try FileManager.default.createDirectory(
                        at: script.dir,
                        withIntermediateDirectories: false,
                        attributes: nil
                    )
                }
            } catch {
                os_log(.debug, "Failed to create script folder %@", error.localizedDescription)
                completionHandler(false)
                return
            }

            let data = script.rawValue.data(using: .utf8)

            if !FileManager.default.fileExists(atPath: script.scriptURL.path) {
                // It requires 0700 to execute
                if FileManager.default.createFile(atPath: script.scriptURL.path, contents: data, attributes: [
                    FileAttributeKey.posixPermissions: 0o755,
                ]) {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                completionHandler(true)
            }
        }
    }

    public static func checkExtensionEnabled() -> Bool {
        FIFinderSyncController.isExtensionEnabled
    }

    public static func showExtensionPreferences() {
        FIFinderSyncController.showExtensionManagementInterface()
    }

    public static func checkScriptInstallation(script: SwiftyMenuScript) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: script.scriptURL.path) {
                if try FileManager.default.attributesOfItem(atPath: script.scriptURL.path)
                    .contains(where: {
                        $0.key == .posixPermissions && ($0.value as? Int) ?? 0 > 0o700
                    })
                {
                    return true
                } else {
                    try FileManager.default.removeItem(at: script.scriptURL)
                }
            }
        } catch {
            os_log(
                .debug,
                "failed to remove runner: %@ %@",
                script.scriptURL.path,
                error.localizedDescription
            )
        }

        return false
    }

    public static func openFolderPanel(folderURL: URL? = nil) {
        var comps = URLComponents()
        comps.scheme = "swiftymenurunner"
        comps.host = RunnerActions.addFolder.rawValue

        if let folderURL = folderURL {
            comps.queryItems = [
                .init(name: "folder", value: folderURL.path),
            ]
        }

        guard let url = comps.url else {
            return
        }

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

    public static func showMainApp(
        completionHandler: ((NSRunningApplication?, Error?) -> Void)? = nil
    ) {
        let appURL = Bundle.appRootURL

        let openConfig = NSWorkspace.OpenConfiguration()
        openConfig.createsNewApplicationInstance = false

        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: openConfig,
            completionHandler: completionHandler
        )
    }

    public static func isApplicationInBlacklist(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        guard let appName = url.lastPathComponent.split(separator: ".").first else {
            return false
        }

        return [
            "Calculator",
            "Books",
            "App Store",
            "Calendar",
            "Chess",
            "Contacts",
            "Developer",
            "Dictionary",
            "FaceTime",
            "Maps",
            "Music",
            "Siri",
            "Stocks",
            "Time Machine",
            "Videos",
        ].contains { $0.lowercased() == appName.lowercased() }
    }

}

extension Bundle {

    public static var appRootURL: URL {
        var components = main.bundleURL.path.split(separator: "/")

        func isMainApp(_ comp: Substring) -> Bool {
            comp.hasSuffix(".app") && !comp.hasPrefix("SwiftyMenuRunner")
        }

        if let index = components.lastIndex(where: isMainApp) {
            components.removeLast((components.count - 1) - index)
            return URL(fileURLWithPath: "/" + components.joined(separator: "/"))
        }

        return Bundle.main.bundleURL
    }

    public static var runnerAppURL: URL {
        appRootURL.appendingPathComponent("Contents/Applications/SwiftyMenuRunner.app")
    }

}

public enum SwiftyMenuScript: String {

    case runner = """
        #!/bin/sh
        action="$1"
        shift 1
        "$action" "$@"
        echo "$action\n$@" >/tmp/swiftymenu.log
        """

    /// Workaround for system Finder Sync UI
    /// @seealso https://github.com/aonez/Keka/issues/1464
    /// @seealso https://forums.developer.apple.com/forums/thread/756711?answerId=812519022#812519022
    case enableExtension =
        """
        #!/bin/sh
        pluginkit -e "use" -i sh.lex.SwiftyMenu.Sync
        # pkill "SwiftyMenu"
        # open -a "sh.lex.SwiftyMenu"
        """

    var scriptURL: URL {
        switch self {
        case .runner:
            dir.appendingPathComponent("runner.sh")
        case .enableExtension:
            dir.appendingPathComponent("enable.sh")
        }
    }

    var dir: URL {
        switch self {
        case .runner:
            SwiftyMenuKit.mainScriptsDirectory
                    .deletingLastPathComponent()
                    .appendingPathComponent("sh.lex.SwiftyMenu.Sync")

        case .enableExtension:
            SwiftyMenuKit.mainScriptsDirectory
                    .deletingLastPathComponent()
                    .appendingPathComponent("sh.lex.SwiftyMenu")
        }
    }
}
