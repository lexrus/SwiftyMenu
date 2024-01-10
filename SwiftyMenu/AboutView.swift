//
//  AboutView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

struct AboutView: View {

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()

            Image(nsImage: NSImage(named: "AppIcon")!)
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(
                    color: Color(.sRGB, red: 0.1, green: 0.3, blue: 1, opacity: 0.3),
                    radius: 10,
                    x: 0,
                    y: 5
                )

            Text(verbatim: "SwiftyMenu")
                .font(.system(size: 20, weight: .medium, design: .rounded))
            Text(bundleVersion).font(.body)

            Button {
                feedback()
            } label: {
                Text("Feedback: \("lexrus@gmail.com")")
            }
            .font(.system(size: 14, weight: .regular, design: .rounded))

            Button {
                openURL(URL(string: "https://lex.sh/swiftymenu/privacypolicy")!)
            } label: {
                Text("privacy_policy")
            }

            Spacer()

            Text("copyright_footnote")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color(.controlBackgroundColor))
    }

    private func feedback() {
        guard var comps = URLComponents(string: "mailto:lexrus@gmail.com") else {
            return
        }

        let subject = NSLocalizedString("feedback_subject", comment: "")
        let body = NSLocalizedString("feedback_message", comment: "")

        comps.queryItems = [
            .init(name: "subject", value: subject),
            .init(name: "body", value: body),
        ]

        if let url = comps.url {
            openURL(url)
        }
    }

    private var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
    }

}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.light)

    }
}
