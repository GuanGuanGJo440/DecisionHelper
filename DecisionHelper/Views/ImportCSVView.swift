import SwiftUI

struct ImportCSVView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var csvText = ""
    @State private var errorMessage: String?

    let onImport: (ImportedDecision) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("匯入 CSV")
                .font(.headline)

            TextEditor(text: $csvText)
                .frame(height: 200)
                .border(Color.gray)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("匯入") {
                do {
                    let imported = try CSVDecisionImporter.parse(csvText: csvText)
                    onImport(imported)
                    dismiss()
                } catch {
                    errorMessage = "CSV 格式錯誤，請檢查內容"
                }
            }
        }
        .padding()
    }
}


