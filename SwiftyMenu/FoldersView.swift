//
//  FoldersView.swift
//  SwiftyMenu
//
//  Created by Lex on 4/26/21.
//  Copyright © 2024 lex.sh. All rights reserved.
//

import OSLog
import SwiftUI

struct FoldersView: View {

    @Environment(\.openURL) var openURL

    @State var folders: [FolderModel] = []

    @State var refreshID = UUID()

    var body: some View {
        VStack(alignment: .leading) {
            Text("folders_view_title")

            List {
                ForEach(0..<folders.count, id: \.self) { index in
                    FolderCell(Binding(get: {
                        folders[index]
                    }, set: {
                        folders[index] = $0
                    })) {
                        folders[index].isEnabled = $0
                        save()
                    } deleteHandler: { path in
                        folders.removeAll(where: { $0.folder.path == path })
                        save()
                    }
                }
            }
            .onReceive(
                DistributedNotificationCenter.default()
                    .publisher(for: .FolderDidUpdate)
            ) { _ in
                folders = D.folders
                refreshID = UUID()
            }
            .id(refreshID)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(.separatorColor), lineWidth: 1)
            )

            Button {
                SwiftyMenuKit.openFolderPanel()
            } label: {
                Image(systemName: "folder.fill.badge.plus")
                Text("add_folder_button")
            }
            .controlSize(.large)
            .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            folders = D.folders
        }
    }

    private func save() {
        D.folders = folders
        DistributedNotificationCenter.default()
            .post(name: .FolderDidUpdate, object: nil)
    }
}

#Preview {
    FoldersView()
}
