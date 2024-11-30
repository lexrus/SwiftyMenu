//
//  SystemButton.swift
//  SwiftyMenu
//
//  Created by Lex on 5/7/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import SwiftUI

struct SystemButton: View {

    let imageName: String

    var handler: () -> Void

    @State var isHovering = false

    @State private var primaryColor = Color(.textColor)

    var body: some View {
        Button(action: handler) {
            Image(systemName: imageName)
                .foregroundColor(Color(.textColor))
                .colorMultiply(primaryColor)
                .imageScale(.large)
        }
        .onHover { hovering in
            isHovering = hovering
            withAnimation(.linear(duration: 0.3)) {
                self.primaryColor = hovering ? Color.red : Color(.textColor)
            }
        }
        .padding([.leading, .trailing], 8)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SystemButton(imageName: "trash") {}
}

struct TrashButton_LibraryContent: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(SystemButton(imageName: "trash") {})
    }
}
