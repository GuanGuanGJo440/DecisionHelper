//
//  DecisionFolder.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/26.
//
import Foundation

// 新增資料夾模型（可以有子資料夾）
struct DecisionFolder: Identifiable, Codable {
    let id: UUID
    var name: String

    var folders: [DecisionFolder]   // 子資料夾
    var decisions: [DecisionSet]     // 該層的選項
}


