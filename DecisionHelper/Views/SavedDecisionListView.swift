//
//  SavedDecisionListView.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/26.
//
import SwiftUI

struct SavedDecisionListView: View {
    
    @ObservedObject var viewModel: DecisionViewModel
    
    // decision 操作
    let onSelectDecision: (DecisionSet) -> Void
    let onEditDecision: (DecisionSet) -> Void
    let onMoveDecision: (DecisionSet) -> Void
    let onDeleteDecision: (UUID, IndexSet) -> Void
    
    // folder 操作
    let onAddSubfolder: (UUID) -> Void
    let onRenameFolder: (UUID, String) -> Void
    let onDeleteFolder: (UUID) -> Void
    
    // decision 加到最愛
    let onAddToFavorite: (DecisionSet) -> Void
    
    @State private var renamingFolderID: UUID?
    @State private var newFolderName: String = ""
    
    var body: some View {
        List {
            //if let favorite = viewModel.favoriteFolder {
                Section("⭐️ 我的最愛") {
                    FavoriteDecisionListView(
                        decisions: viewModel.favoriteDecisions,
                        onSelectDecision: onSelectDecision,
                        onEditDecision: onEditDecision,
                        onRemoveFromFavorite: { id in
                            viewModel.removeFromFavorite(id)
                        }
                    )
                }
            //}
            Section("資料夾") {
                ForEach(viewModel.normalFolders) { folder in
                    NavigationLink {
                        FolderDetailView(
                            folderID: folder.id,
                            viewModel: viewModel,
                            
                            // decision 操作
                            onSelectDecision: onSelectDecision,
                            onEditDecision: onEditDecision,
                            onMoveDecision: onMoveDecision,
                            onDeleteDecision: onDeleteDecision,
                            
                            // folder 操作
                            onAddSubfolder: onAddSubfolder,
                            onRenameFolder: onRenameFolder,
                            onDeleteFolder: onDeleteFolder,
                            
                            // decision 加到最愛
                            onAddToFavorite: onAddToFavorite
                        )
                    } label: {
                        HStack {
                            Text(folder.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .contextMenu {
                        Button("重新命名") {
                            renamingFolderID = folder.id
                            newFolderName = folder.name
                        }
                        Button("新增子資料夾") {
                            onAddSubfolder(folder.id)
                        }
                        Button("刪除資料夾", role: .destructive) {
                            onDeleteFolder(folder.id)
                        }
                    }
                }
            }
            .alert(
                "重新命名資料夾",
                isPresented: Binding(
                    get: { renamingFolderID != nil },
                    set: { if !$0 { renamingFolderID = nil } }
                )
            ) {
                TextField("資料夾名稱", text: $newFolderName)

                Button("確定") {
                    if let id = renamingFolderID {
                        onRenameFolder(id, newFolderName)
                    }
                    renamingFolderID = nil
                    newFolderName = ""
                }

                Button("取消", role: .cancel) {
                    renamingFolderID = nil
                }
            }
        }
        .navigationTitle("已儲存清單")
    }
}
