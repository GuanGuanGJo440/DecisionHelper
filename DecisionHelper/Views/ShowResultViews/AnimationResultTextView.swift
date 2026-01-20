import SwiftUI

struct AnimatedResultTextView: View {
    let options: [String]
    let finalResult: String
    let duration: Double

    @State private var displayText = ""

    var body: some View {
        Text(displayText)
            .font(.title)
            .bold()
            .onAppear {
                animate()
            }
    }

    private func animate() {
        let start = Date()

        func step() {
            let elapsed = Date().timeIntervalSince(start)
            let progress = min(elapsed / duration, 1.0)

            // 👉 easeOut 曲線
            let easedProgress = 1 - pow(1 - progress, 4)

            if progress >= 1.0 {
                // 確保最後結果一定是 finalResult
                withAnimation(.spring()) {
                    displayText = "🎉 \(finalResult)"
                }
                return
            }

            // 隨機跳動文字
            displayText = options.randomElement() ?? ""

            // 👉 一開始快，後面慢
            let currentInterval = 0.05 + (easedProgress * 0.35)

            DispatchQueue.main.asyncAfter(deadline: .now() + currentInterval) {
                step()
            }
        }

        step()
    }
}


