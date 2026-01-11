//
//  ContentView.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/24.
//

import SwiftUI

// 定義一個 sheet 類型
enum ActiveSheet: Identifiable {
    case savedList
    case saveToFolder
    case editDecision(DecisionSet)

    var id: String {
        switch self {
        case .savedList:
            return "savedList"
        case .saveToFolder:
            return "saveToFolder"
        case .editDecision(let decision):
            return decision.id.uuidString
        }
    }
}

// 新增資料夾情境
enum AddFolderTarget: Identifiable {
    case root
    case subfolder(UUID)

    var id: String {
        switch self {
        case .root:
            return "root"
        case .subfolder(let id):
            return id.uuidString
        }
    }
}

// 定義動畫模式
enum PickAnimationStyle: String, CaseIterable, Identifiable {
    case instant = "直接顯示"
    case wheel = "轉盤"

    var id: String { rawValue }
}

struct ContentView: View {
    
        
    @StateObject private var viewModel = DecisionViewModel()
    
    //@State private var showAddFolder = false
    @State private var newFolderName = ""
    //@State private var parentFolderID: UUID?

    //@State private var showSaveSheet = false
    @State private var activeSheet: ActiveSheet?
    @State private var selectedFolderID: UUID?
    
    @State private var isSavingNewDecision = false
    
    // 新增某個資料夾的子資料夾
    //@State private var targetFolderID: UUID? = nil
    @State private var addFolderTarget: AddFolderTarget?
    
    @State private var decisionToEdit: DecisionSet?
    @State private var decisionToMove: DecisionSet?
    
    // 動畫狀態
    @State private var showResult = false
        
        var body: some View {
            NavigationStack{
                ScrollView{
                    VStack(spacing: 16) {
                        
                        Text("選擇困難幫手")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Button {
                            viewModel.fillDinnerSample()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("使用範例選單")
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }

                        
                        TextField("主題（例如：晚餐吃什麼？）", text: $viewModel.topic)
                            .textFieldStyle(.roundedBorder)
                        
                        ForEach(viewModel.options.indices, id: \.self) { index in
                            OptionRow(
                                index: index,
                                option: $viewModel.options[index],
                                canDelete: viewModel.options.count > 1
                            ) {
                                viewModel.removeOption(at: index)
                            }
                        }
                        // 新增選項按鈕
                        Button {
                            viewModel.options.append(OptionItem(text: ""))
                        } label: {
                            Label("新增選項", systemImage: "plus.circle")
                        }
                        // 選擇按鈕
                        HStack {
                            Button {
                                viewModel.pickRandomOption()
                                showResult = true
                            } label: {
                                Text("幫我選！")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Menu {
                                Picker("動畫效果", selection: $viewModel.pickAnimationStyle) {
                                    ForEach(PickAnimationStyle.allCases) { style in
                                        Text(style.rawValue).tag(style)
                                    }
                                }
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                        .sheet(isPresented: $showResult) {
                            switch viewModel.pickAnimationStyle {
                            case .instant:
                                InstantResultView(
                                    options: viewModel.options.map { $0.text },
                                    result: viewModel.result)
                                
                            case .wheel:
                                WheelResultView(
                                    options: viewModel.options.map { $0.text },
                                    finalResult: viewModel.result
                                )
                            }
                        }
                        /*if !viewModel.result.isEmpty {
                         VStack(spacing: 4) {
                         if !viewModel.topic.isEmpty {
                         Text(viewModel.topic)
                         .font(.headline)
                         }
                         Text("🎉 結果：\(viewModel.result)")
                         .font(.title2)
                         }
                         }*/
                        // 儲存按鈕
                        Button("儲存選單") {
                            isSavingNewDecision = true
                            activeSheet = .saveToFolder
                        }
                        // 重置按鈕
                        Button("清除") {
                            viewModel.resetAll()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        Spacer()
                    }
                    .onChange(of: viewModel.activeDecision){
                        guard let decision = viewModel.activeDecision else { return }
                        
                        viewModel.topic = decision.topic
                        viewModel.options = decision.options.map { OptionItem(text: $0) }
                        viewModel.result = ""
                    }
                    .padding()
                }
            }
            .padding()
            // 已儲存清單的按鈕
            Button("📂 已儲存選單") {
                activeSheet = .savedList
            }
            // 顯示清單的畫面
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .savedList:
                    NavigationStack {
                        SavedDecisionListView(
                            viewModel: viewModel,
                            onSelectDecision: { selected in
                                viewModel.activeDecision = selected
                                activeSheet = nil
                            },
                            onEditDecision: { decision in
                                activeSheet = .editDecision(decision)
                            },
                            onMoveDecision: { decision in
                                decisionToMove = decision
                                isSavingNewDecision = false
                                activeSheet = .saveToFolder
                            },
                            onDeleteDecision: { folderID, offsets in
                                viewModel.deleteDecision(folderID: folderID, offsets: offsets)
                            },
                            onAddSubfolder: { folderID in
                                addFolderTarget = .subfolder(folderID)
                            },
                            onRenameFolder: { folderID, newName in
                                viewModel.renameFolder(folderID: folderID, newName: newName)
                            },
                            onDeleteFolder: { folderID in
                                viewModel.deleteFolder(folderID: folderID)
                            },
                            onAddToFavorite: { decision in
                                viewModel.addToFavorite(decision)
                            }
                        )
                        .toolbar {
                            Button {
                                addFolderTarget = .root
                            } label: {
                                Image(systemName: "folder.badge.plus")
                            }
                        }
                    }
                    .alert(
                        "新增資料夾",
                        isPresented: Binding(
                            get: { addFolderTarget != nil },
                            set: { if !$0 { addFolderTarget = nil } }
                        )
                    ) {
                        TextField("資料夾名稱", text: $newFolderName)

                        Button("新增") {
                            switch addFolderTarget {
                            case .root:
                                viewModel.addFolder(name: newFolderName)

                            case .subfolder(let parentID):
                                viewModel.addSubfolder(parentID: parentID, name: newFolderName)

                            case .none:
                                break
                            }

                            newFolderName = ""
                            addFolderTarget = nil
                        }

                        Button("取消", role: .cancel) {
                            addFolderTarget = nil
                        }
                    }

                case .saveToFolder:
                    NavigationStack {
                        SaveToFolderView(
                            folders: viewModel.folders,
                            selectedFolderID: $selectedFolderID
                        ) {
                            guard let folderID = selectedFolderID else { return }

                            if isSavingNewDecision {
                                // ✅ 情境 1：儲存「目前畫面」的 decision
                                viewModel.saveCurrentDecision(to: folderID)
                            } else if let decision = decisionToMove {
                                // 🔁 情境 2：移動既有 decision
                                viewModel.moveDecision(decision, to: folderID)
                            }

                            // reset 狀態
                            isSavingNewDecision = false
                            decisionToMove = nil
                            selectedFolderID = nil
                            activeSheet = nil
                        }
                    }
                case .editDecision(let decision):
                    NavigationStack {
                        EditDecisionView(
                            decision: decision,
                            onSave: { updatedDecision in
                                viewModel.updateDecision(updatedDecision)
                                activeSheet = nil
                            },
                            onCancel: {
                                activeSheet = nil
                            }
                        )
                    }
                }
            }
        }
    }
    
    #Preview {
        ContentView()
    }

