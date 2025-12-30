//
//  SaveToFolderView.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/26.
//

import SwiftUI

// 建立選資料夾畫面
struct SaveToFolderView: View {
    let folders: [DecisionFolder]
    @Binding var selectedFolderID: UUID?
    let onSave: () -> Void

    var body: some View {
        List {
            ForEach(folders) { folder in
                FolderSelectRow(
                    folder: folder,
                    selectedFolderID: $selectedFolderID
                )
            }
        }
        .navigationTitle("選擇資料夾")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("儲存") {
                    onSave()
                }
                .disabled(selectedFolderID == nil)
            }
        }
    }
}


