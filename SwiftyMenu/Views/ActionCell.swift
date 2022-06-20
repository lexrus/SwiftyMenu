//
//  ActionCell.swift
//  SwiftyMenu
//
//  Created by Lex on 5/6/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI

struct ActionCell: View {

    @Binding var action: ActionModel
    
    @State var hovering: Bool = false

    typealias TapHandler = (String) -> Void
    typealias ToggleHandler = (Bool) -> Void
    typealias DeleteHandler = (String) -> Void

    let toggleHandler: ToggleHandler?
    let tapHandler: TapHandler?
    let deleteHandler: DeleteHandler?

    init(
        _ action: Binding<ActionModel>,
        toggleHandler: ToggleHandler?,
        tapHandler: TapHandler?,
        deleteHandler: DeleteHandler?
    ) {
        self._action = action
        self.toggleHandler = toggleHandler
        self.tapHandler = tapHandler
        self.deleteHandler = deleteHandler
    }

    var body: some View {
        HStack {
            CheckBox(isChecked: $action.isEnabled) {
                toggleHandler?($0)
            }

            Image(nsImage: action.nsImage.resized(to: .init(width: 96, height: 96)))
                .resizable(resizingMode: Image.ResizingMode.stretch)
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32, alignment: .center)
                .cornerRadius(5)

            Text(action.name)
                .font(.system(size: 16, weight: .regular, design: .rounded))

            Spacer()

            if hovering {
                SystemButton(imageName: "square.and.pencil") {
                    tapHandler?(action.uuid)
                }
                
                SystemButton(imageName: "trash") {
                    deleteHandler?(action.uuid)
                }
            }
        }
        .padding(5)
        .whenHovered { isHovering in
            withAnimation(.easeOut(duration: 0.2)) {
                hovering = isHovering
            }
        }
        .background(hovering ? Color(.selectedControlColor).opacity(0.5) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ActionCell_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
    }
}
