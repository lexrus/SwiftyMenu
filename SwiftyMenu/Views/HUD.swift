//
//  HUD.swift
//  SwiftyMenu
//
//  Created by Lex on 5/22/21.
//  Copyright © 2021 lex.sh. All rights reserved.
//

import SwiftUI

final class HUDState: ObservableObject {
    @Published var isPresented = false
    var title = ""

    func show(_ title: String) {
        self.title = NSLocalizedString(title, comment: "")
        withAnimation {
            isPresented = true
        }
    }
}

struct HUD<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(14)
            .background(
                Capsule()
                    .foregroundColor(Color.white)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: 12,
                        x: 0,
                        y: 5
                    )
            )
            .foregroundColor(.black)
            .font(.system(size: 14, weight: .medium, design: .rounded))
    }
}

extension View {
    func hud<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            self

            if isPresented.wrappedValue {
                ZStack {
                    HUD(content: content)
                }
                .padding()
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    }
                }
                .zIndex(1)
            }
        }
    }
}

struct HUD_Previews: PreviewProvider {
    static var previews: some View {
        HUD {
            Text("Succeed!")
        }
    }
}
