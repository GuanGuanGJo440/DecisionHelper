import SwiftUI

struct SavedDecisionListView: View {
    
    @ObservedObject var viewModel: DecisionViewModel
    
    // decision 操作
    let onSelectDecision: (DecisionSet) -> Void
    let onEditDecision: (DecisionSet) -> Void
    let onImportDecision: (DecisionSet) -> Void
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
    
    // 加入 importCSV 後會跳出 EditDecisionView 的狀態
    @State private var showImportCSV = false
    @State private var navigateToEdit = false
    @State private var importedDecisionID: UUID?
    
    // 這樣就不用管 ContentView 裡面的順序了
    init(
        viewModel: DecisionViewModel,
        onSelectDecision: @escaping (DecisionSet) -> Void,
        onEditDecision: @escaping (DecisionSet) -> Void,
        onImportDecision: @escaping (DecisionSet) -> Void,
        onMoveDecision: @escaping (DecisionSet) -> Void,
        onDeleteDecision: @escaping (UUID, IndexSet) -> Void,
        onAddSubfolder: @escaping (UUID) -> Void,
        onRenameFolder: @escaping (UUID, String) -> Void,
        onDeleteFolder: @escaping (UUID) -> Void,
        onAddToFavorite: @escaping (DecisionSet) -> Void
    ) {
        self.viewModel = viewModel
        self.onSelectDecision = onSelectDecision
        self.onEditDecision = onEditDecision
        self.onImportDecision = onImportDecision
        self.onMoveDecision = onMoveDecision
        self.onDeleteDecision = onDeleteDecision
        self.onAddSubfolder = onAddSubfolder
        self.onRenameFolder = onRenameFolder
        self.onDeleteFolder = onDeleteFolder
        self.onAddToFavorite = onAddToFavorite
    }
    
    var body: some View {
        List {
            //if let favorite = viewModel.favoriteFolder {
                Section("❤️ 我的最愛") {
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
        
        .navigationTitle("已儲存選單")
        Button("匯入 CSV") {
            showImportCSV = true
        }
        .sheet(isPresented: $showImportCSV) {
            ImportCSVView { imported in
                let decision = DecisionSet(
                    id: UUID(),
                    topic: imported.title,
                    options: imported.options
                )

                showImportCSV = false
                onImportDecision(decision)
            }
        }
    }
}
