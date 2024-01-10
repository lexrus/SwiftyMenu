//
//  CheckBox.swift
//  SwiftyMenu
//
//  Created by Lex on 5/7/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

struct CheckBox: View {

    @Binding var isChecked: Bool

    @State private var isHovering = false

    var handler: ((Bool) -> Void)?

    var body: some View {
        Button {
            isChecked.toggle()
            handler?(isChecked)
        } label: {
            Image(
                systemName: isChecked
                    ? "checkmark.circle.fill"
                    : "checkmark.circle"
            )
            .resizable()
            .frame(width: 20, height: 20)
            .font(.title2)
            .foregroundColor(
                isChecked
                    ? Color(.controlAccentColor)
                    : Color(.separatorColor)
            )
            .scaleEffect(isHovering ? 1.2 : 1)
            .transition(.scale)
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .padding([.leading, .trailing], 6)
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 20, minHeight: 20)
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        CheckBox(isChecked: .constant(true)) { _ in

        }
    }
}

struct CheckBox_LibraryContent: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(CheckBox(isChecked: .constant(true)) { _ in

        }, visible: true, title: "CheckBox", category: .control, matchingSignature: "cb")
    }
}
