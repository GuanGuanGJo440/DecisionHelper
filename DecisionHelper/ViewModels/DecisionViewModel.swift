//
//  DecisionViewModel.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/28.
//

import Foundation
import Combine
import SwiftUI

final class DecisionViewModel: ObservableObject {

    // MARK: - UI 狀態（非持久）
    @Published var topic: String = ""
    @Published var options: [OptionItem] = [
        OptionItem(text: ""),
        OptionItem(text: ""),
        OptionItem(text: "")
    ]
    @Published var result: String = ""

    // MARK: - 核心資料（唯一真實來源）
    @Published private(set) var folders: [DecisionFolder] = []
    
    // MARK: - 我的最愛（只存 ID）
    @Published private(set) var favoriteDecisionIDs: Set<UUID> = []
    
    // MARK: - 目前選中的 decision
    @Published var activeDecision: DecisionSet?
    
    // MARK: - 儲存使用者偏好動畫
    @Published var pickAnimationStyle: PickAnimationStyle = .instant
    
    // MARK: - 分類「我的最愛資料夾」跟「一般資料夾」
    var favoriteFolder: DecisionFolder? {
        folders.first { $0.id == favoriteFolderID }
    }

    var normalFolders: [DecisionFolder] {
        folders.filter { $0.id != favoriteFolderID }
    }
    
    var favoriteDecisions: [DecisionSet] {
        allDecisions.filter { favoriteDecisionIDs.contains($0.id) }
    }
    
    /// 把所有 Decision 攤平
    var allDecisions: [DecisionSet] {
        collectDecisions(from: folders)
    }

    private func collectDecisions(from folders: [DecisionFolder]) -> [DecisionSet] {
        folders.flatMap { folder in
            folder.decisions + collectDecisions(from: folder.folders)
        }
    }

    // MARK: - Persistence
    private let storageKey = "decision_folders"

    // MARK: - Init
    let favoriteFolderID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    init() {
        folders = loadFolders()
        favoriteDecisionIDs = loadFavorites()
        
        if !folders.contains(where: { $0.id == favoriteFolderID }) {
            folders.insert(
                DecisionFolder(
                    id: favoriteFolderID,
                    name: "⭐ 我的最愛",
                    folders: [],
                    decisions: []
                ),
                at: 0
            )
        }
    }

    // MARK: - Random Pick
    func pickRandomOption() {
        let texts = options
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        result = texts.randomElement() ?? "請輸入選項"
    }
    
    // MARK: - Delete An Option
    func removeOption(at index: Int) {
        options.remove(at: index)
    }

    // MARK: - Save Decision
    func saveCurrentDecision(to folderID: UUID) {
        guard let decision = makeCurrentDecision() else { return }
        addDecision(decision, to: folderID)
    }
    
    func addDecision(_ decision: DecisionSet, to folderID: UUID) {
        if insertDecision(decision, into: &folders, folderID: folderID) {
            persist()
        }
    }

    // MARK: - Update Decision
    func updateDecision(_ updated: DecisionSet) {
        if updateDecisionRecursive(updated, in: &folders) {
            persist()
        }
    }

    // MARK: - Move Decision
    func moveDecision(_ decision: DecisionSet, to folderID: UUID) {
        removeDecisionRecursive(decisionID: decision.id, from: &folders)
        _ = insertDecision(decision, into: &folders, folderID: folderID)
        persist()
    }

    // MARK: - Delete Decision
    func deleteDecision(folderID: UUID, offsets: IndexSet) {
        if deleteDecisionRecursive(folderID: folderID, offsets: offsets, in: &folders) {
            persist()
        }
    }

    // MARK: - Folder Management

    /// 新增最外層資料夾
    func addFolder(name: String) {
        folders.append(makeFolder(name: name))
        persist()
    }

    /// 新增子資料夾（無限層）
    func addSubfolder(parentID: UUID, name: String) {
        let newFolder = makeFolder(name: name)

        let inserted = insertSubfolder(
            parentID: parentID,
            into: &folders
        ) { parent in
            parent.folders.append(newFolder)
        }

        if inserted {
            persist()
        } else {
            assertionFailure("❌ Parent folder not found: \(parentID)")
        }
    }
    
    /// 建立資料夾
    private func makeFolder(name: String) -> DecisionFolder {
        DecisionFolder(
            id: UUID(),
            name: name.isEmpty ? "未命名資料夾" : name,
            folders: [],
            decisions: []
        )
    }
    
    /// Rename Folder
    func renameFolder(folderID: UUID, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        if renameFolderRecursive(folderID: folderID,
                                 newName: newName,
                                 in: &folders) {
            persist()
        }
    }

    /// Delete Folder
    func deleteFolder(folderID: UUID) {
        if deleteFolderRecursive(folderID: folderID, in: &folders) {
            persist()
        }
    }
    
    // MARK: - Folder Lookup

    func findFolder(by id: UUID) -> DecisionFolder? {
        findFolderRecursive(id: id, in: folders)
    }

    private func findFolderRecursive(
        id: UUID,
        in folders: [DecisionFolder]
    ) -> DecisionFolder? {

        for folder in folders {
            if folder.id == id {
                return folder
            }

            if let found = findFolderRecursive(
                id: id,
                in: folder.folders
            ) {
                return found
            }
        }

        return nil
    }

    // MARK: - Reset
    func resetAll() {
        topic = ""
        options = [OptionItem(text: "")]
        result = ""
    }
    
    // MARK: - 我的最愛
    /// 加入我的最愛
    func addToFavorite(_ decision: DecisionSet) {
        favoriteDecisionIDs.insert(decision.id)
        persistFavorites()
    }
    
    /// 從我的最愛移除
    func removeFromFavorite(_ decisionID: UUID) {
        favoriteDecisionIDs.remove(decisionID)
        persistFavorites()
    }
    
    /// 判斷是不是我的最愛
    func isFavorite(_ decisionID: UUID) -> Bool {
        favoriteDecisionIDs.contains(decisionID)
    }
    
    private let favoriteKey = "favorite_decision_ids"

    private func persistFavorites() {
        let ids = Array(favoriteDecisionIDs)
        UserDefaults.standard.set(
            try? JSONEncoder().encode(ids),
            forKey: favoriteKey
        )
    }

    private func loadFavorites() -> Set<UUID> {
        guard
            let data = UserDefaults.standard.data(forKey: favoriteKey),
            let ids = try? JSONDecoder().decode([UUID].self, from: data)
        else { return [] }

        return Set(ids)
    }
}

// MARK: - Recursive Helpers

private extension DecisionViewModel {

    // 建立 Decision
    func makeCurrentDecision() -> DecisionSet? {
        let texts = options
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !texts.isEmpty else { return nil }

        return DecisionSet(
            id: UUID(),
            topic: topic,
            options: texts
        )
    }

    // 插入 Decision
    @discardableResult
    func insertDecision(
        _ decision: DecisionSet,
        into folders: inout [DecisionFolder],
        folderID: UUID
    ) -> Bool {

        for index in folders.indices {
            if folders[index].id == folderID {
                folders[index].decisions.append(decision)
                return true
            }

            if insertDecision(decision,
                              into: &folders[index].folders,
                              folderID: folderID) {
                return true
            }
        }

        return false
    }

    // 更新 Decision
    func updateDecisionRecursive(
        _ updated: DecisionSet,
        in folders: inout [DecisionFolder]
    ) -> Bool {

        for index in folders.indices {
            if let i = folders[index].decisions.firstIndex(where: { $0.id == updated.id }) {
                folders[index].decisions[i] = updated
                return true
            }

            if updateDecisionRecursive(updated, in: &folders[index].folders) {
                return true
            }
        }

        return false
    }

    // 移除 Decision
    func removeDecisionRecursive(
        decisionID: UUID,
        from folders: inout [DecisionFolder]
    ) {

        for index in folders.indices {
            folders[index].decisions.removeAll { $0.id == decisionID }
            removeDecisionRecursive(decisionID: decisionID,
                                    from: &folders[index].folders)
        }
    }

    // 刪除 Decision（List 專用）
    func deleteDecisionRecursive(
        folderID: UUID,
        offsets: IndexSet,
        in folders: inout [DecisionFolder]
    ) -> Bool {

        for index in folders.indices {
            if folders[index].id == folderID {
                folders[index].decisions.remove(atOffsets: offsets)
                return true
            }

            if deleteDecisionRecursive(folderID: folderID,
                                       offsets: offsets,
                                       in: &folders[index].folders) {
                return true
            }
        }

        return false
    }

    // 插入子資料夾（唯一）
    @discardableResult
    private func insertSubfolder(
        parentID: UUID,
        into folders: inout [DecisionFolder],
        onMatch: (inout DecisionFolder) -> Void
    ) -> Bool {
        for index in folders.indices {
            if folders[index].id == parentID {
                onMatch(&folders[index])
                return true
            }

            if insertSubfolder(
                parentID: parentID,
                into: &folders[index].folders,
                onMatch: onMatch
            ) {
                return true
            }
        }
        return false
    }
    
    // 重新命名資料夾（遞迴）
    func renameFolderRecursive(
        folderID: UUID,
        newName: String,
        in folders: inout [DecisionFolder]
    ) -> Bool {

        for index in folders.indices {
            if folders[index].id == folderID {
                folders[index].name = newName
                return true
            }

            if renameFolderRecursive(folderID: folderID,
                                     newName: newName,
                                     in: &folders[index].folders) {
                return true
            }
        }

        return false
    }
    
    // 刪除資料夾（遞迴）
    func deleteFolderRecursive(
        folderID: UUID,
        in folders: inout [DecisionFolder]
    ) -> Bool {

        // 先檢查這一層能不能直接刪
        if let index = folders.firstIndex(where: { $0.id == folderID }) {
            folders.remove(at: index)
            return true
        }

        // 再往子資料夾找
        for index in folders.indices {
            if deleteFolderRecursive(folderID: folderID,
                                     in: &folders[index].folders) {
                return true
            }
        }

        return false
    }
}

private extension DecisionViewModel {

    func persist() {
        if let data = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadFolders() -> [DecisionFolder] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([DecisionFolder].self, from: data)
        else {
            return []
        }

        return decoded
    }
}
