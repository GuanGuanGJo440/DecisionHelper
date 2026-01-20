import Foundation

// 定義「一組決定」的資料模型
struct DecisionSet: Identifiable, Codable, Equatable {
    let id: UUID
    var topic: String
    var options: [String]
}
