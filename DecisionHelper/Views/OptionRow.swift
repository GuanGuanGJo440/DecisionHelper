//
//  OptionRow.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/26.
//
import SwiftUI

// SwiftUI 的 ForEach 一定要知道每一列是誰
struct OptionItem: Identifiable {
    let id = UUID()
    var text: String
}

// 建立單一選項輸入列
struct OptionRow: View {
    
    let index: Int
    @Binding var option: OptionItem
    let canDelete: Bool // 保留最後一個選項不能刪
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text("選項 \(index + 1)")
                .frame(width: 60, alignment: .leading)
            
            TextField("請輸入", text:$option.text)
                .textFieldStyle(.roundedBorder)
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(canDelete ? .red : .gray)
            }
            .disabled(!canDelete)
        }
    }
}
