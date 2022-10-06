//
//  TabButton.swift
//  SwiftyMenu
//
//  Created by Lex on 4/24/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI

struct TabButton: View {

    @State
    var title = ""

    @State
    var iconName = ""

    var selected = false

    @State
    var hovering = false

    @State
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 2) {
                Image(systemName: iconName)
                    .renderingMode(.original)
                    .font(.title)
                    .frame(maxWidth: 30, maxHeight: 30)
                    .scaleEffect(hovering ? 0.9 : 1)
                    .transition(.scale)
                Text(LocalizedStringKey(title))
            }
            .padding(8)
            .frame(minWidth: 60, minHeight: 60)
            .background(
                selected
                    ? Color(.selectedControlColor)
                    : (hovering ? Color(.selectedControlColor).opacity(0.2) : Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .whenHovered { isHovering in
            withAnimation(.easeOut(duration: 0.15)) {
                hovering = isHovering
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

}

struct TabButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            HStack(spacing: 8) {
                TabButton(title: "Install", iconName: "externaldrive.badge.plus", selected: true) {
                    print(1)
                }
                TabButton(title: "Buttons", iconName: "square.grid.3x1.folder.badge.plus") {
                    print(1)
                }
                TabButton(title: "About", iconName: "info.circle") {
                    print(1)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(.windowBackgroundColor))

            HStack(spacing: 8) {
                TabButton(title: "Install", iconName: "externaldrive.badge.plus", selected: true) {
                    print(1)
                }
                TabButton(title: "Buttons", iconName: "square.grid.3x1.folder.badge.plus") {
                    print(1)
                }
                TabButton(title: "About", iconName: "info.circle") {
                    print(1)
                }
            }
            .preferredColorScheme(.light)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(.windowBackgroundColor))
        }
    }

}
