//
//  InstallView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

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
                Image(.extensionEnabledScreenshot).resizable().scaledToFit()
            }

            VStack(alignment: .center, spacing: 20) {
                if isExtensionEnabled {
                    Text("extension_enabled_message")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Text("finder_button_introduction").font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    Text("system_preferences_introduction")
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

}

struct InstallView_Previews: PreviewProvider {
    static var previews: some View {
        EnableView()
    }
}
