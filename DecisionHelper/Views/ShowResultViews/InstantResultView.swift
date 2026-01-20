import SwiftUI

struct InstantResultView: View {
    let options: [String]
    let result: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("結果")
                .font(.headline)

            AnimatedResultTextView(
                options: options,
                finalResult: result,
                duration: 2.5
            )

            Button("關閉") {
                dismiss()
            }
        }
        .padding()
    }
}

