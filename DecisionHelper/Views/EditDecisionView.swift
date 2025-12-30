//
//  EditDecisionView.swift
//  DecisionHelper
//
//  Created by 關關的m4 macbook pro on 2025/12/27.
//
import SwiftUI

struct EditDecisionView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var topic: String
    @State private var options: [String]

    let decision: DecisionSet
    let onSave: (DecisionSet) -> Void
    let onCancel: () -> Void

    init(decision: DecisionSet, onSave: @escaping (DecisionSet) -> Void, onCancel: @escaping () -> Void) {
        self.decision = decision
        self.onSave = onSave
        self.onCancel = onCancel
        _topic = State(initialValue: decision.topic)
        _options = State(initialValue: decision.options)
    }

    var body: some View {
        Form {
            Section("主題") {
                TextField("主題", text: $topic)
            }

            Section("選項") {
                ForEach(options.indices, id: \.self) { index in
                    TextField("選項 \(index + 1)", text: $options[index])
                }

                Button("新增選項") {
                    options.append("")
                }
            }
        }
        .navigationTitle("編輯選項")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("儲存") {
                    let updated = DecisionSet(
                        id: decision.id,
                        topic: topic,
                        options: options
                    )
                    onSave(updated)
                    dismiss()
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
        }
    }
}

