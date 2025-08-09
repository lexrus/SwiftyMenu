# SwiftyMenu

[![Swift](https://img.shields.io/badge/Swift-6.0-ED523F.svg?style=flat)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-blue)](https://developer.apple.com/xcode/swiftui/)
[![AppKit](https://img.shields.io/badge/AppKit-✓-orange)](https://developer.apple.com/xcode/swiftui/)
[![macOS 14+](https://img.shields.io/badge/macOS-14+-green)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![@lexrus](https://img.shields.io/badge/contact-@lexrus-336699.svg?style=flat)](https://twitter.com/lexrus)

[<img src="https://cloud.githubusercontent.com/assets/219689/5575342/963e0ee8-9013-11e4-8091-7ece67d64729.png" width="135" height="40" alt="AppStore"/>](https://apps.apple.com/app/swiftymenu/id1567748223)

> A powerful macOS Finder extension that adds customizable context menus to quickly open selected folders or files with your favorite applications and scripts.

![swiftymenu](https://user-images.githubusercontent.com/219689/174636051-dd86c7fe-0b3d-4863-9a0d-ecd986f6a3c9.png)

## Structure

### SwiftyMenuSync

The Finder Sync extension which represents the Finder menu and brings up the SwiftyMenuRunner via app scheme.

### SwiftyMenu

The main interface of the configuration app. Built with SwiftUI.

### SwiftyMenuRunner

We have to have this faceless app in order to share URL bookmarks between the configuration interface and the Finder Sync extension. It executes actual applications and scripts.

### SwiftyMenuKit

The tool kit.

## License

This code is distributed under the terms and conditions of the MIT license.
