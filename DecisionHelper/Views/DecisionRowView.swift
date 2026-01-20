import SwiftUI

/*struct DecisionRowView: View {
    let decision: DecisionSet
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading) {
                Text(decision.topic)
                Text(decision.options.joined(separator: "、"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}*/

struct DecisionRowView: View {

    let decision: DecisionSet

    let onSelect: (DecisionSet) -> Void
    let onEdit: (DecisionSet) -> Void
    let onMove: (DecisionSet) -> Void
    let onDelete: (DecisionSet) -> Void

    @Environment(\.editMode) private var editMode

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        HStack {
            Button {
                onSelect(decision)
            } label: {
                VStack(alignment: .leading) {
                    Text(decision.topic)
                        .font(.headline)
                    Text(decision.options.joined(separator: "、"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .contextMenu {
            Button("編輯") {
                onEdit(decision)
            }

            Button("移動") {
                onMove(decision)
            }

            Button("刪除", role: .destructive) {
                onDelete(decision)
            }
        }
    }
}
