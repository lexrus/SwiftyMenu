//
//  SwiftyDefaults.swift
//  SwiftyMenuKit
//
//  Created by Lex on 4/30/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import Foundation

struct D {

    @UserDefault(key: "showSwiftyMenu", defaultValue: true)
    static var showSwiftyButton: Bool

    @UserDefault(key: "collapseContextMenu", defaultValue: false)
    static var collapseContextMenu: Bool

    @UserDefault(key: "folders", defaultValue: [])
    static var folders: [FolderModel]

    @UserDefault(key: "actions", defaultValue: [])
    static var actions: [ActionModel]

}

public protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    var defaultValue: Value
    var container = UserDefaults(suiteName: "5SKD83S59G.swiftymenu")!

    var wrappedValue: Value {
        get { getter() }
        set { setter(newValue) }
    }

    var projectedValue: Bool {
        true
    }

    private func getter() -> Value {
        if
            let data = container.data(forKey: key),
            let array = try? JSONDecoder().decode(Value.self, from: data)
        {
            return array
        }
        return container.object(forKey: key) as? Value ?? defaultValue
    }

    func anyRaw(_ value: Any) -> Codable? {
        if let any = value as? String {
            return any
        } else if let any = value as? Bool {
            return any
        } else if let any = value as? Int {
            return any
        } else if let any = value as? Double {
            return any
        }
        return nil
    }

    private func setter(_ newValue: Value) {
        if let optional = newValue as? AnyOptional, optional.isNil {
            container.removeObject(forKey: key)
        } else {
            if let raw = anyRaw(newValue) {
                container.set(raw, forKey: key)
            } else {
                if let data = try? JSONEncoder().encode(newValue) {
                    container.set(data, forKey: key)
                }
            }
        }
    }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(key: key, defaultValue: nil)
    }
}
