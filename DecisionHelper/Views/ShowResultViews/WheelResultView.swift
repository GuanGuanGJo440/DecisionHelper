import SwiftUI

struct WheelResultView: View {
    let options: [String]
    let finalResult: String
    
    // 讓三角形只針對準圓
    let wheelRadius: CGFloat = 22
    var pointerOffset: CGFloat {
        wheelRadius + 5
    }

    @Environment(\.dismiss) private var dismiss
    @State private var rotation: Double = 0
    
    @State private var hasStarted = false

    var body: some View {
        VStack(spacing: 16) {

            if hasStarted { // 確保同時啟動
                AnimatedResultTextView(
                    options: options,
                    finalResult: finalResult,
                    duration: 2.8
                )
            } else {
                Text("準備好了嗎？") // 預留空間避免畫面跳動
                    .font(.title).bold().opacity(0)
            }

            ZStack {
                WheelView(options: options)
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(rotation))

                Circle()
                    .stroke(Color.black.opacity(0.7), lineWidth: 10)
                    .frame(width: 300, height: 300)

                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 44, height: 44)

                Triangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 18, height: 12)
                    .offset(y: -pointerOffset)
            }
            .onAppear {
                hasStarted = true
                // 1. 取得目標角度
                let targetAngle = angleForResult(result: finalResult, options: options)
                
                // 2. 設定圈數（至少 5 圈確保華麗感）
                let extraSpins: Double = 360 * 5
                
                // 3. 執行執行
                withAnimation(.timingCurve(0.15, 0.5, 0.2, 1, duration: 2.8)) {
                    rotation = extraSpins + targetAngle
                }
            }
            Button("關閉轉盤") {
                dismiss()
            }
        }
        .padding()
    }
    func rotationForResult(
        result: String,
        options: [String]
    ) -> Double {
        guard let index = options.firstIndex(of: result) else {
            return 0
        }

        let count = options.count
        let sliceAngle = 360.0 / Double(count)
        let sliceMidAngle = sliceAngle * (Double(index) + 0.5)

        let targetRotation = 360 - sliceMidAngle
        let correctedTarget = targetRotation - 90
        let extraSpins = Double.random(in: 3...5) * 360

        return extraSpins + correctedTarget
    }
    // 把「結果角度」抽成「單一 function」
    func angleForResult(result: String, options: [String]) -> Double {
        guard let index = options.firstIndex(of: result) else { return 0 }
        
        let degreePerSlice = 360.0 / Double(options.count)
        let midAngleOfSlice = degreePerSlice * Double(index) + (degreePerSlice / 2)
        
        // 因為旋轉是順時針為正，我們要對準正上方，所以是 360 減去該角度
        // 或者直接用 -midAngleOfSlice 也可以
        return 360.0 - midAngleOfSlice
    }
}

struct WheelView: View {
    let options: [String]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(options.indices, id: \.self) { index in
                    WheelSlice(
                        text: options[index],
                        index: index,
                        total: options.count
                    )
                }
            }
        }
    }
}

struct WheelSlice: View {
    let text: String
    let index: Int
    let total: Int
    let radius: CGFloat = 140

    var body: some View {
        let degreePerSlice = 360.0 / Double(total)
        let startDeg = degreePerSlice * Double(index) - 90 // 從正上方開始
        let midDeg = startDeg + (degreePerSlice / 2)

        ZStack {
            // 扇形
            Path { path in
                let center = CGPoint(x: radius, y: radius)
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(startDeg),
                    endAngle: .degrees(startDeg + degreePerSlice),
                    clockwise: false
                )
            }
            .fill(sliceColor)

            // 👉 真正放在扇形中央的文字
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
                .rotationEffect(.degrees(midDeg + 90))
                .position(
                    x: radius + cos(Angle.degrees(midDeg).radians) * radius * 0.65,
                    y: radius + sin(Angle.degrees(midDeg).radians) * radius * 0.65
                )
        }
    }

    private var sliceColor: Color {
        Color(
            hue: Double(index) / Double(total),
            saturation: 0.75,
            brightness: 0.9
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}



