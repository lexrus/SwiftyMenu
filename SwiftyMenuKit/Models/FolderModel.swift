//
//  ButtonModel.swift
//  SwiftyMenuKit
//
//  Created by iDurian on 2021/4/29.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import AppKit
import Foundation

extension Notification.Name {
    public static let FolderDidUpdate = Notification.Name("FolderDidUpdate")
}

public class FolderModel: Codable, ObservableObject {

    public var folder: URL
    public var bookmarkData: Data?
    public var isEnabled: Bool

    public init(folder: URL, isEnabled: Bool = true) {
        self.folder = folder
        self.isEnabled = isEnabled
    }
}

extension FolderModel {
    public static var enabledPaths: [String] {
        D.folders
            .filter(\.isEnabled)
            .map(\.folder.path)
    }
}
