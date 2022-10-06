//
//  SwiftyMenuSyncMenuItems.swift
//  SwiftyMenuSync
//
//  Created by Lex on 2020/11/29.
//  Copyright © 2020 lex.sh. All rights reserved.
//

import Cocoa
import FinderSync
import OSLog

extension NSMenuItem {
    var actionModel: ActionModel? {
        let models = ActionModel.allEnabledActions
        return models.count > tag ? models[tag] : nil
    }
}

extension SwiftyMenuSync {

    func currentSelectedTargets() -> [URL] {
        var urls = [URL]()

        FIFinderSyncController.default().selectedItemURLs()?.forEach {
            urls.append($0)
        }

        if let targetedURL = FIFinderSyncController.default().targetedURL(), urls.isEmpty {
            urls.append(targetedURL)
        }

        return urls
    }

    func menuItem(offset: Int, action: ActionModel) -> NSMenuItem {
        let item: NSMenuItem

        let key = offset < 9 ? "\(offset + 1)" : ""

        switch action.actionType {
        case .application:
            item = NSMenuItem(
                title: action.name,
                action: #selector(openApplication),
                keyEquivalent: key
            )

        case .script:
            item = NSMenuItem(title: action.name, action: #selector(openScript), keyEquivalent: key)
        }

        item.image = action.nsImage
        item.tag = offset

        return item
    }

    @objc private func openApplication(_ item: NSMenuItem) {
        guard let application = item.actionModel, let path = application.applicationPath else {
            return
        }

        runApplication(
            path,
            hidesOthers: application.hidesOthers
        )
    }

    @IBAction private func openScript(_ item: NSMenuItem) {
        guard let action = item.actionModel else {
            return
        }

        let scriptURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(action.name).sh")
        let scriptData = action.script.data(using: .utf8)

        if FileManager.default.createFile(
            atPath: scriptURL.path,
            contents: scriptData,
            attributes: [
                FileAttributeKey.posixPermissions: 0o755,
            ]
        ) {
            os_log(.debug, "script copied to %@", scriptURL.path)
        } else {
            os_log(.debug, "failed to copy script file")
        }

        var parameters = [String]()

        currentSelectedTargets().forEach {
            parameters.append($0.path)
        }

        run(scriptURL: scriptURL, shell: action.shell, arguments: parameters)
    }

    // MARK: - Configure

    var addFolderItem: NSMenuItem {
        let item = NSMenuItem(
            title: NSLocalizedString("add_current_folder", comment: ""),
            action: #selector(addFolder),
            keyEquivalent: ""
        )
        item.image = NSImage(named: "AddFolderIcon")
        return item
    }

    var configMenuItem: NSMenuItem {
        let item = NSMenuItem(
            title: "SwiftyMenu",
            action: #selector(presentConfig),
            keyEquivalent: ""
        )
        item.image = NSImage(named: "MenuIcon")
        return item
    }

    @IBAction func presentConfig(_ sender: NSMenuItem) {
        SwiftyMenuKit.showMainApp()
    }

    @IBAction func addFolder(_ sender: NSMenuItem) {
        guard let currentTarget = FIFinderSyncController.default().targetedURL() else {
            return
        }

        SwiftyMenuKit.openFolderPanel(folderURL: currentTarget)
    }

}
