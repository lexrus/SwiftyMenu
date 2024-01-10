//
//  EditImageView.swift
//  SwiftyMenu
//
//  Created by iDurian on 2021/5/12.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import Foundation
import Quartz
import SwiftUI

struct EditImageView: View {
    @State var nsImage: NSImage?

    let onImageUpdate: ((Data?) -> Void)?

    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                Image(nsImage: nsImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(2)
                    .scaleEffect(hovering ? 1.2 : 1)
                    .transition(.scale)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
            }.padding(10)
            Group {
                Image(systemName: "photo")
                    .imageScale(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 24, alignment: .center)
            .background(Color.black.opacity(0.3))
            .opacity(hovering ? 1 : 0)
            .offset(x: 0, y: hovering ? 0 : 10)
            .transition(.opacity.combined(with: .offset()))
        }
        .background(
            Image(nsImage: nsImage!)
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .blur(radius: hovering ? 5 : 10)
                .opacity(hovering ? 1 : 0.2)
                .saturation(1)
                .transition(.opacity)
        )
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.6)) {
                self.hovering = hovering
            }
        }
        .onTapGesture {

            let pictureTaker = IKPictureTaker.pictureTaker()
            if pictureTaker!.runModal() == NSApplication.ModalResponse.OK.rawValue {
                self.nsImage = pictureTaker?.outputImage()
                    .resized(to: NSSize(width: 256, height: 256))
                onImageUpdate?(self.nsImage?.tiffRepresentation)
            }
        }
    }
}

struct EditImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditImageView(nsImage: NSImage(named: NSImage.applicationIconName)!, onImageUpdate: nil)
    }
}
