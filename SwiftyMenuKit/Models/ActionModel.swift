//
//  ActionModel.swift
//  SwiftyMenuKit
//
//  Created by Lex on 4/30/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import AppKit
import Foundation

extension Notification.Name {
    public static let ActionDidUpdate = Notification.Name("ActionDidUpdate")
}

public enum ActionType: Int, Codable {
    case script
    case application
}

public class ActionModel: Codable, ObservableObject {
    public let actionType: ActionType
    public let uuid: String
    public var name: String
    public var icon: Data?
    public var applicationPath: String?
    public var shell: String
    public var script: String
    public var isEnabled = true
    public var silent = false
    public var hidesOthers = false

    public init(_ type: ActionType, name: String, script: String, shell: String = "/bin/bash") {
        self.actionType = type
        self.uuid = UUID().uuidString
        self.name = name
        self.shell = shell
        self.script = script
    }

    public init(applicationPath: String) {
        self.actionType = .application
        self.applicationPath = applicationPath
        self.uuid = UUID().uuidString
        self.name = URL(fileURLWithPath: applicationPath)
            .lastPathComponent
            .split(separator: ".")
            .dropLast()
            .joined(separator: ".")
        self.shell = ""
        self.script = ""
    }
}

extension ActionModel {
    public static var allEnabledActions: [ActionModel] {
        D.actions
            .filter(\.isEnabled)
    }
}

extension NSImage {
    public func resized(to newSize: NSSize) -> NSImage {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(
                in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height),
                from: .zero,
                operation: .copy,
                fraction: 1.0
            )
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return self
    }
}

extension ActionModel {
    public var nsImage: NSImage {
        if let icon {
            NSImage(data: icon)!
        } else if let applicationPath = applicationPath, !applicationPath.isEmpty {
            NSWorkspace.shared.icon(forFile: applicationPath)
        } else if actionType == .script {
            NSImage(named: "TerminalIcon")!
        } else {
            NSImage(named: NSImage.applicationIconName)!
        }
    }
}
