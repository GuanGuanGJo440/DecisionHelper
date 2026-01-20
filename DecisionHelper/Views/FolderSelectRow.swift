import SwiftUI

struct FolderSelectRow: View {
    let folder: DecisionFolder
    @Binding var selectedFolderID: UUID?

    var body: some View {
        DisclosureGroup {
            ForEach(folder.folders) { subFolder in
                FolderSelectRow(
                    folder: subFolder,
                    selectedFolderID: $selectedFolderID
                )
            }
        } label: {
            HStack {
                Text(folder.name)
                Spacer()
                if selectedFolderID == folder.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedFolderID = folder.id
            }
        }
    }
}

