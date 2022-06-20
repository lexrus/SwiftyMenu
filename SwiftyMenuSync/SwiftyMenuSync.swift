//
//  SwiftyMenuSync.swift
//  SwiftyMenuSync
//
//  Created by Lex on 2020/10/3.
//  Copyright © 2020 lex.sh. All rights reserved.
//

import Cocoa
import FinderSync
import AppKit
import Combine

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
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
//        NSLog("beginObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    
    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
//        NSLog("endObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    override func requestBadgeIdentifier(for url: URL) {
//        NSLog("requestBadgeIdentifierForURL: %@", url.path as NSString)
        
        // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
//        let whichBadge = abs(url.path.hash) % 3
//        let badgeIdentifier = ["", "One", "Two"][whichBadge]
//        FIFinderSyncController.default().setBadgeIdentifier(badgeIdentifier, for: url)
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "SwiftyMenu"
    }
    
    override var toolbarItemToolTip: String {
        return "SwiftyMenu, a handy Finder button for third part apps."
    }
    
    override var toolbarItemImage: NSImage {
        let image = NSImage(named: "SwiftyMenuIcon")!
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
                item.image = NSImage(named: "MenuIcon")

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

