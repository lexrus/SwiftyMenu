//
//  InstallView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI
import OSLog

struct EnableView: View {

    @State var isExtensionEnabled = false

    @EnvironmentObject var hud: HUDState

    @State private var currentSlide = 0

    private let didBecomeActive = NotificationCenter.default
        .publisher(for: NSApplication.didBecomeActiveNotification)

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if isExtensionEnabled {
                if currentSlide == 0 {
                    Image(.finderToolbarCustomize).resizable().scaledToFit()
                        .transition(.opacity).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    currentSlide = 1
                                }
                            }
                        }
                } else {
                    Image(.finderButtonDemo).resizable().scaledToFit()
                        .transition(.opacity).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    currentSlide = 0
                                }
                            }
                        }
                }
            } else {
                if #available(macOS 15.2, *) {
                    Image(.extensionEnabledScreenshot152).resizable().scaledToFit()
                } else if #available(macOS 15.0, *) {

                } else {
                    Image(.extensionEnabledScreenshot).resizable().scaledToFit()
                }
            }

            VStack(alignment: .center, spacing: 20) {
                if isExtensionEnabled {
                    Text("extension_enabled_message")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Text("finder_button_introduction").font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    if #available(macOS 15.2, *) {
                        Text("system_preferences_introduction_15_2")
                        systemPreferenceButton()
                    } else if #available(macOS 15.0, *) {
                        Button {
                            NSPasteboard.general.setString("pluginkit -e \"use\" -i sh.lex.SwiftyMenu.Sync", forType: .string)
                            hud.show("copied")
                        } label: {
                            Text(verbatim: "pluginkit -e \"use\" -i sh.lex.SwiftyMenu.Sync")
                        }
                        .buttonStyle(.plain)
                        .padding(5)
                        .border(.secondary, width: 1)


                        Text("sequoia_enable_message")
                        sequoiaEnableButton()
                    } else {
                        Text("system_preferences_introduction")
                        systemPreferenceButton()
                    }
                }
            }

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isExtensionEnabled = SwiftyMenuKit.checkExtensionEnabled()
        }
        .onReceive(didBecomeActive) { _ in
            isExtensionEnabled = SwiftyMenuKit.checkExtensionEnabled()
        }
    }

    private func systemPreferenceButton() -> some View {
        Button {
            SwiftyMenuKit.showExtensionPreferences()
        } label: {
            Text("system_preferences_button")
        }
        .padding(.init(top: 4, leading: 10, bottom: 5, trailing: 10))
        .background(Color(.selectedControlColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 0)
        .buttonStyle(PlainButtonStyle())
        .font(.system(size: 16, weight: .regular, design: .rounded))
    }

    private func sequoiaEnableButton() -> some View {
        Button {
            installEnableScript()
        } label: {
            Text("sequoia_enable_button")
        }
        .padding(.init(top: 8, leading: 15, bottom: 8, trailing: 15))
        .background(Color(.selectedControlColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 0)
        .buttonStyle(PlainButtonStyle())
        .font(.system(size: 18, weight: .regular, design: .rounded))
    }

    private func installEnableScript() {
        SwiftyMenuKit.installScript(script: .enableExtension) { installed in
            if installed {
                runEnableScript()

                isExtensionEnabled = SwiftyMenuKit.checkExtensionEnabled()
            } else {
                hud.show("hud_script_installation_failed")
            }
        }
    }

    private func runEnableScript() {
        let enableURL = SwiftyMenuScript.enableExtension.scriptURL

        let arguments = [
            "/bin/sh",
            enableURL.path,
            "",
        ]

        do {
            let task = try NSUserUnixTask(url: enableURL)

            task.execute(withArguments: arguments) { error in
                error.map { os_log(.debug, "%@", $0.localizedDescription) }
                os_log(.debug, "complete")
            }
        } catch {
            os_log(.debug, "%@", error.localizedDescription)
        }
    }

}

#Preview {
    EnableView()
}
