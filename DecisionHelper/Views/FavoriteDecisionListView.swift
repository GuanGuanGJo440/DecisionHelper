//
//  FavoriteDecisionFolderView.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/29.
//

import SwiftUI

struct FavoriteDecisionListView: View {

    let decisions: [DecisionSet]

    let onSelectDecision: (DecisionSet) -> Void
    let onEditDecision: (DecisionSet) -> Void
    let onRemoveFromFavorite: (UUID) -> Void

    var body: some View {
        ForEach(decisions) { decision in
            FavoriteDecisionRowView(
                decision: decision,
                onSelect: {
                    onSelectDecision(decision)
                },
                onEdit: {
                    onEditDecision(decision)
                },
                onRemoveFromFavorite: {
                    onRemoveFromFavorite(decision.id)
                }
            )
        }
    }
}

struct FavoriteDecisionRowView: View {

    let decision: DecisionSet

    let onSelect: () -> Void
    let onEdit: () -> Void
    let onRemoveFromFavorite: () -> Void

    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(decision.topic.isEmpty ? "未命名選擇" : decision.topic)
                    .font(.headline)
                
                Text(decision.options.joined(separator: "、"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button("編輯") {
                onEdit()
            }

            Button("移除我的最愛", role: .destructive) {
                onRemoveFromFavorite()
            }
        }
    }
}


