//
//  FolderCell.swift
//  SwiftyMenu
//
//  Created by Lex on 5/7/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI

struct FolderCell: View {

    typealias ToggleHandler = (Bool) -> Void
    typealias DeleteHandler = (String) -> Void

    var toggleHandler: ToggleHandler?
    var deleteHandler: DeleteHandler?

    @Binding var folder: FolderModel

    @State var hovering = false

    init(
        _ folder: Binding<FolderModel>,
        toggleHandler: ToggleHandler?,
        deleteHandler: DeleteHandler?
    ) {
        self._folder = folder
        self.toggleHandler = toggleHandler
        self.deleteHandler = deleteHandler
    }

    private func trashButton(handler: @escaping () -> Void) -> some View {
        Button(action: handler) {
            Image(systemName: "trash")
        }
        .padding(.trailing, 5)
        .buttonStyle(PlainButtonStyle())
    }

    var body: some View {
        HStack {
            CheckBox(isChecked: $folder.isEnabled) {
                toggleHandler?($0)
            }

            Image(systemName: "folder.circle.fill")
                .renderingMode(.original)
                .font(.largeTitle)

            Text(folder.folder.path)
                .font(.system(size: 16, weight: .regular, design: .rounded))

            Spacer()

            if hovering {
                SystemButton(imageName: "trash") {
                    deleteHandler?(folder.folder.path)
                }
            }
        }
        .padding(5)
        .whenHovered {
            hovering = $0
        }
        .background(hovering ? Color(.selectedControlColor).opacity(0.5) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct FolderCell_Previews: PreviewProvider {
    static var previews: some View {
        FoldersView()
    }
}
