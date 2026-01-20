//
//  ImportedDecision.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2026/1/20.
//

import Foundation

// 定義外部資料輸入的資料模型
struct ImportedDecision {
    var title: String
    var options: [String]
    var source: ImportSource
}

enum ImportSource {
    case googleSheet
    case notion
    case manual
}
