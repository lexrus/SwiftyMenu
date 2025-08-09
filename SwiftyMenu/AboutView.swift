//
//  AboutView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI
import AppAboutView

struct AboutView: View {

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            AppAboutView.fromMainBundle(
                appIcon: Image(nsImage: NSImage(named: NSImage.applicationIconName)!),
                feedbackEmail: "lexrus@gmail.com",
                appStoreID: "1567748223",
                privacyPolicy: URL(string: "https://lex.sh/swiftymenu/privacypolicy")!,
                copyrightText: "©2025 lex.sh",
                coffeeTips: ["coffee_tip"]
            )
        }
        .frame(maxWidth: .infinity)
    }

}

#Preview {
    VStack {
        AboutView().preferredColorScheme(.light)
    }
}
