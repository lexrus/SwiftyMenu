//
//  Runner+Folder.swift
//  SwiftyMenuRunner
//
//  Created by Lex on 5/18/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import Foundation
import AppKit
import OSLog

extension Runner {

    func openFolderPanel(defaultFolder: URL? = nil, completionHandler: (Bool) -> Void) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose a Directory"
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false

        // 默认打开 $HOME
        dialog.directoryURL = defaultFolder ?? URL(fileURLWithPath: NSHomeDirectory())

        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            guard let result = dialog.url else { return }

            let folder = FolderModel(folder: result)
            var folders = D.folders
            folders.append(folder)
            D.folders = folders
            saveFolderBookmark(result)

            DistributedNotificationCenter.default().post(name: .FolderDidUpdate, object: nil)
            completionHandler(true)
        } else {
            completionHandler(false)
            os_log(.error, "Failed to open panel.")
        }
    }

    func runWithFolderAccess(closure: () -> Void) {
        let folders = D.folders

        var restoredFolders = [URL]()

        folders.forEach {
            guard
                let bookmarkData = $0.bookmarkData,
                let folder = restoreFolderBookmark(bookmarkData, folderURL: $0.folder)
            else {
                os_log(.error, "Failed to restore bookmark of %{public}s", $0.folder.path)
                return
            }

            restoredFolders.append(folder)
            let succeed = folder.startAccessingSecurityScopedResource()

            os_log(
                .debug,
                "Restore bookmark of %{public}s %{public}ld %{public}@",
                folder.path,
                bookmarkData.count,
                succeed ? "succeed" : "failed"
            )
        }

        closure()

        restoredFolders.forEach {
            $0.stopAccessingSecurityScopedResource()
        }
    }

    private func saveFolderBookmark(_ folderURL: URL) {
        var bookmarkData: Data?

        do {
            bookmarkData = try folderURL.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            os_log(.debug, "Saved bookmark: \(bookmarkData!.count)bytes")
        } catch {
            os_log(.error, "Failed to save bookmark: %{public}s", error.localizedDescription)
        }

        var folders = D.folders
        if let exisitingIndex = folders.firstIndex(where: { $0.folder == folderURL }) {
            let folder = folders[exisitingIndex]
            folders.remove(at: exisitingIndex)
            folder.bookmarkData = bookmarkData
            folders.insert(folder, at: exisitingIndex)
        } else {
            let folder = FolderModel(folder: folderURL)
            folder.bookmarkData = bookmarkData
            folders.append(folder)
        }
        
        D.folders = folders
    }

    private func restoreFolderBookmark(_ bookmarkData: Data, folderURL: URL) -> URL? {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope, .withoutUI],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                // bookmarks could become stale as the OS changes
                os_log(.debug, "Bookmark is stale, need to save a new one... ")
                saveFolderBookmark(folderURL)
            }
            os_log(.debug, "Bookmark restored: %{public}@", url.path)
            return url
        } catch {
            os_log(.error, "Error resolving bookmark: %{public}s", error.localizedDescription)
            return nil
        }
    }

}
