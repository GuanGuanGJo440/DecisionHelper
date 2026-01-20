import SwiftUI

/*struct FolderDetailView: View {
    @StateObject private var viewModel = DecisionViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    let folder: DecisionFolder

    var body: some View {
        List {

            // 📁 子資料夾
            Section("資料夾") {
                ForEach(folder.folders) { subfolder in
                    NavigationLink {
                        FolderDetailView(folder: subfolder)
                    } label: {
                        Label(subfolder.name, systemImage: "folder")
                    }
                }
            }

            // 📄 選項
            Section("選項") {
                ForEach(folder.decisions) { decision in
                    DecisionRowView(
                        decision: decision,
                        onSelect: { selected in selectDecision(decision) },
                        onEdit: { _ in },
                        onMove: { _ in },
                        onDelete: { _ in }
                    )
                }
            }
        }
        .navigationTitle(folder.name)
    }

    func selectDecision(_ decision: DecisionSet) {
        viewModel.activeDecision = decision
        dismiss()
    }
}*/

struct FolderDetailView: View {
    let folderID: UUID
    @ObservedObject var viewModel: DecisionViewModel
    
    var folder: DecisionFolder {
        viewModel.findFolder(by: folderID)!
    }

    let onSelectDecision: (DecisionSet) -> Void
    let onEditDecision: (DecisionSet) -> Void
    let onMoveDecision: (DecisionSet) -> Void
    let onDeleteDecision: (UUID, IndexSet) -> Void
    
    let onAddSubfolder: (UUID) -> Void
    let onRenameFolder: (UUID, String) -> Void
    let onDeleteFolder: (UUID) -> Void
    
    let onAddToFavorite: (DecisionSet) -> Void
    
    @State private var renamingFolderID: UUID?
    @State private var newFolderName: String = ""

    var body: some View {
        List {

            // 子資料夾
            Section (
                header: HStack {
                    Text("子資料夾")
                    Spacer()
                    Button {
                        onAddSubfolder(folder.id)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            ){
                ForEach(folder.folders) { subfolder in
                    NavigationLink {
                        FolderDetailView(
                            folderID: subfolder.id,
                            viewModel: viewModel,
                            onSelectDecision: onSelectDecision,
                            onEditDecision: onEditDecision,
                            onMoveDecision: onMoveDecision,
                            onDeleteDecision: onDeleteDecision,
                            onAddSubfolder: onAddSubfolder,
                            onRenameFolder: onRenameFolder,
                            onDeleteFolder: onDeleteFolder,
                            onAddToFavorite: onAddToFavorite
                        )
                    } label: {
                        Text(subfolder.name)
                    }
                    .contextMenu {
                        Button("重新命名") {
                            renamingFolderID = subfolder.id
                            newFolderName = subfolder.name
                        }
                        Button("新增子資料夾") {
                            onAddSubfolder(subfolder.id)
                        }
                        Button("刪除資料夾", role: .destructive) {
                            onDeleteFolder(subfolder.id)
                        }
                    }
                }
            }
            // Decisions
            Section("選單") {
                ForEach(folder.decisions) { decision in
                    DecisionRowView(
                        decision: decision,
                        onSelect: { selected in
                            onSelectDecision(selected)
                        },
                        onEdit: { selected in
                            onEditDecision(selected)
                        },
                        onMove: { selected in
                            onMoveDecision(selected)
                        },
                        onDelete: { selected in
                            // 🔥 單筆刪除（來自 contextMenu）
                            if let index = folder.decisions.firstIndex(where: { $0.id == selected.id }) {
                                onDeleteDecision(folder.id, IndexSet(integer: index))
                            }
                        }
                    )
                    .contextMenu {
                        Button("編輯") {
                            onEditDecision(decision)
                        }
                        Button("移動") {
                            onMoveDecision(decision)
                        }
                        Button("加到我的最愛") {
                            onAddToFavorite(decision)
                        }
                    }
                }
                // 🔥 List 的滑動刪除（保留）
                .onDelete { offsets in
                    onDeleteDecision(folder.id, offsets)
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
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("新增子資料夾") {
                        onAddSubfolder(folder.id)
                    }

                    Button("重新命名") {
                        renamingFolderID = folder.id
                        newFolderName = folder.name
                    }

                    Button("刪除資料夾", role: .destructive) {
                        onDeleteFolder(folder.id)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}



