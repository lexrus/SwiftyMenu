//
//  SwiftyMenuKit.swift
//  SwiftyMenuKit
//
//  Created by Lex on 4/27/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import Foundation
import AppKit
import OSLog
import FinderSync

public struct SwiftyMenuKit {

    private static var mainScriptsDirectory: URL = {
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

    /// URL of the script folder
    /// - Returns: ~/Library/Application Scripts/{bundle_id}/
    public static var scriptsDirectory: URL? {
        mainScriptsDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("sh.lex.SwiftyMenu.Sync")
    }

    public static var runnerURL: URL? {
        scriptsDirectory?.appendingPathComponent("runner.sh")
    }

    public static func installRunner(completionHandler: @escaping (Bool) -> Void) {
        guard let scriptsDirectory = scriptsDirectory else {
            return
        }

        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.canChooseFiles = false
        panel.directoryURL = scriptsDirectory
        panel.begin { response in
            guard
                response == .OK,
                let url = panel.url,
                scriptsDirectory.path.hasPrefix(url.path),
                let runnerURL = runnerURL
            else {
                completionHandler(false)
                return
            }

            // Create the subfolder

            do {
                if !FileManager.default.fileExists(atPath: scriptsDirectory.path) {
                    try FileManager.default.createDirectory(
                        at: scriptsDirectory,
                        withIntermediateDirectories: false,
                        attributes: nil
                    )
                }
            } catch {
                os_log(.debug, "Failed to create script folder %@", error.localizedDescription)
                completionHandler(false)
                return
            }

            let data = runnerContent.data(using: .utf8)

            // It requires 0700 to execute
            if FileManager.default.createFile(atPath: runnerURL.path, contents: data, attributes: [
                FileAttributeKey.posixPermissions: 0o755
            ]) {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }

    public static func checkExtensionEnabled() -> Bool {
        FIFinderSyncController.isExtensionEnabled
    }

    public static func showExtensionPreferences() {
        FIFinderSyncController.showExtensionManagementInterface()
    }

    public static func checkRunnerScriptInstalled() -> Bool {
        guard let runnerURL = runnerURL else {
            return false
        }

        do {
            if FileManager.default.fileExists(atPath: runnerURL.path) {
                if try FileManager.default.attributesOfItem(atPath: runnerURL.path).contains(where: {
                    $0.key == .posixPermissions && ($0.value as? Int) ?? 0 > 0o700
                }) {
                    return true
                } else {
                    try FileManager.default.removeItem(at: runnerURL)
                }
            }
        } catch {
            os_log(.debug, "failed to remove runner: %@ %@", runnerURL.path, error.localizedDescription)
        }

        return false
    }

    public static func openFolderPanel(folderURL: URL? = nil) {
        var comps = URLComponents()
        comps.scheme = "swiftymenurunner"
        comps.host = "addFolder"

        if let folderURL = folderURL {
            comps.queryItems = [
                .init(name: "folder", value: folderURL.path)
            ]
        }

        guard let url = comps.url else {
            return
        }

        if FileManager.default.fileExists(atPath: Bundle.runnerAppURL.path) {
            let openConfig = NSWorkspace.OpenConfiguration()
            openConfig.activates = true
            openConfig.createsNewApplicationInstance = true

            NSWorkspace.shared.open([url], withApplicationAt: Bundle.runnerAppURL, configuration: openConfig) { app, err in
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

    public static func showMainApp(completionHandler: ((NSRunningApplication?, Error?) -> Void)? = nil) {
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
            "Videos"
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

private let runnerContent = """
#!/bin/sh
action="$1"
shift 1
"$action" "$@"
echo "$action\n$@" >/tmp/swiftymenu.log
"""
