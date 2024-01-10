//
//  SwiftyMenuSync.swift
//  SwiftyMenuSync
//
//  Created by Lex on 2020/10/3.
//  Copyright © 2020 lex.sh. All rights reserved.
//

import AppKit
import Cocoa
import Combine
import FinderSync

class SwiftyMenuSync: FIFinderSync {

    private var cancellable = Set<AnyCancellable>()

    override init() {
        super.init()

        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)

        let urls = Set(FolderModel.enabledPaths.map(URL.init(fileURLWithPath:)))
        FIFinderSyncController.default().directoryURLs = urls

        DistributedNotificationCenter.default().publisher(for: .FolderDidUpdate)
            .sink(receiveValue: updateFolders)
            .store(in: &cancellable)
    }

    func updateFolders(_ any: Any) {
        let urls = Set(FolderModel.enabledPaths.map(URL.init(fileURLWithPath:)))
        FIFinderSyncController.default().directoryURLs = urls
    }

    // MARK: - Primary Finder Sync protocol methods

    override func beginObservingDirectory(at url: URL) {

    }

    override func endObservingDirectory(at url: URL) {

    }

    override func requestBadgeIdentifier(for url: URL) {

    }

    // MARK: - Menu and toolbar item support

    override var toolbarItemName: String {
        "SwiftyMenu"
    }

    override var toolbarItemToolTip: String {
        "SwiftyMenu, a handy Finder button for third part apps."
    }

    override var toolbarItemImage: NSImage {
        let image = NSImage.swiftyMenuIcon
        image.isTemplate = true
        return image
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "SwiftyMenu")
        menu.showsStateColumn = false

        let hidesConfigButton = !D.showSwiftyButton

        if validTargets().isEmpty {
            addSwiftyMenuItems(in: menu)
        } else if menuKind == .toolbarItemMenu {
            addSwiftyMenuItems(in: menu, hidesConfigButton: hidesConfigButton)
        } else {
            if D.collapseContextMenu {
                let item = NSMenuItem(title: "SwiftyMenu", action: nil, keyEquivalent: "")
                item.image = NSImage.menuIcon

                let submenu = NSMenu()
                item.submenu = submenu
                addSwiftyMenuItems(in: submenu)
                menu.addItem(item)
            } else {
                addSwiftyMenuItems(in: menu, hidesConfigButton: hidesConfigButton)
            }
        }

        return menu
    }

    private func addSwiftyMenuItems(in menu: NSMenu, hidesConfigButton: Bool = false) {
        if !validTargets().isEmpty {
            ActionModel
                .allEnabledActions
                .enumerated()
                .map(menuItem(offset:action:))
                .forEach(menu.addItem)
        } else {
            menu.addItem(addFolderItem)
        }

        if !hidesConfigButton {
            let configItem = configMenuItem
            if menu.title != "SwiftyMenu" {
                configItem.title = "..."
            }
            menu.addItem(configItem)
        }
    }

    func validTargets() -> [URL] {
        currentSelectedTargets().filter(permittedURL)
    }

    private func permittedURL(_ url: URL) -> Bool {
        FIFinderSyncController.default().directoryURLs.contains { validURL in
            url.path.hasPrefix(validURL.path)
        }
    }

}
