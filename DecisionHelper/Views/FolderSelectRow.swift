//
//  FolderSelectRow.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/28.
//

import SwiftUI

struct FolderSelectRow: View {
    let folder: DecisionFolder
    @Binding var selectedFolderID: UUID?

    var body: some View {
        DisclosureGroup {
            ForEach(folder.folders) { subFolder in
                FolderSelectRow(
                    folder: subFolder,
                    selectedFolderID: $selectedFolderID
                )
            }
        } label: {
            HStack {
                Text(folder.name)
                Spacer()
                if selectedFolderID == folder.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedFolderID = folder.id
            }
        }
    }
}

