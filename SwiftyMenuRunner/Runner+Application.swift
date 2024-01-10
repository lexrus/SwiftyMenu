//
//  Runner+Application.swift
//  SwiftyMenuRunner
//
//  Created by Lex on 5/18/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import AppKit
import Foundation
import OSLog

extension Runner {

    func runApp(_ path: String, items: [String], hidesOthers: Bool = false) {
        runWithFolderAccess {

            var urls = items.compactMap {
                URL(fileURLWithPath: $0).standardized
            }

            if path.contains("iTerm.app") || path.contains("Terminal.app") {
                let paths: [String] = urls.map {
                    if !$0.hasDirectoryPath {
                        return $0.deletingLastPathComponent().path
                    }
                    return $0.path
                }
                urls = Array(Set(paths)).compactMap {
                    URL(fileURLWithPath: $0).standardized
                }
            }

            if path.hasPrefix("smart:") {
                runSmartAction(path.replacingOccurrences(of: "smart:", with: ""), urls: urls)
                return
            }

            let openConfig = NSWorkspace.OpenConfiguration()
            openConfig.createsNewApplicationInstance = false
            openConfig.hidesOthers = hidesOthers

            do {
                try NSWorkspace.shared.open(
                    urls,
                    withApplicationAt: URL(fileURLWithPath: path),
                    options: hidesOthers ? [.andHideOthers] : [],
                    configuration: [:]
                )
            } catch {
                os_log(.error, "Failed to open: %{public}s", error.localizedDescription)

                NSWorkspace.shared.open(
                    urls,
                    withApplicationAt: URL(fileURLWithPath: path),
                    configuration: openConfig
                ) { _, err in
                    if let err = err {
                        os_log(
                            .error,
                            "Failed to open application: %{public}s",
                            err.localizedDescription
                        )
                    }
                }
            }
        }
    }

    private func runSmartAction(_ action: String, urls: [URL]) {
        switch action {
        case "CopyPath":
            NSPasteboard.general.declareTypes([.string], owner: nil)
            if urls.count == 1, let first = urls.first {
                NSPasteboard.general.setString(first.path, forType: .string)
            } else {
                NSPasteboard.general.setString(
                    urls.map(\.path).joined(separator: "\n"),
                    forType: .string
                )
            }

        default:
            break

        }
    }

}
