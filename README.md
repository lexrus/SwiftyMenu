# SwiftyMenu

[![Swift 5.5](https://img.shields.io/badge/Swift-5.5-ED523F.svg?style=flat)](https://swift.org/)
[![AppKit](https://img.shields.io/badge/AppKit-✓-orange)](https://developer.apple.com/xcode/swiftui/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-orange)](https://developer.apple.com/xcode/swiftui/)
[![macOS 12](https://img.shields.io/badge/macOS12-Compatible-green)](https://developer.apple.com/xcode/swiftui/)
[![@lexrus](https://img.shields.io/badge/contact-@lexrus-336699.svg?style=flat)](https://twitter.com/lexrus)

[<img src="https://cloud.githubusercontent.com/assets/219689/5575342/963e0ee8-9013-11e4-8091-7ece67d64729.png" width="135" height="40" alt="AppStore"/>](https://apps.apple.com/app/swiftymenu/id1567748223)

> A nifty extension for Finder which presents a customizable menu to rapidly open selected folders or files with your favorite applications or scripts.

![swiftymenu](https://user-images.githubusercontent.com/219689/174636051-dd86c7fe-0b3d-4863-9a0d-ecd986f6a3c9.png)

## Structure

### SwiftyMenuSync

The Finder Sync extension which represents the Finder menu and brings up the SwiftyMenuRunner via app scheme.

### SwiftyMenu

The main interface of the configuration app. Built with SwiftUI.

### SwiftyMenuRunner

We have to have this faceless app in order to share URL bookmarks between the configuration interface and the Finder Sync extension. It excutes actual applications and scripts.

### SwiftyMenuKit

The tool kit.

## License

This code is distributed under the terms and conditions of the MIT license.
