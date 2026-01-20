import Foundation

enum CSVImportError: Error {
    case invalidFormat
    case emptyOptions
}

struct CSVDecisionImporter {

    static func parse(csvText: String) throws -> ImportedDecision {

        let lines = csvText
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard lines.count >= 2 else {
            throw CSVImportError.invalidFormat
        }

        // 跳過 header
        let dataLines = lines.dropFirst()

        var topic: String?
        var options: [String] = []

        for line in dataLines {
            let columns = line.split(separator: ",", omittingEmptySubsequences: false)
                .map { String($0).trimmingCharacters(in: .whitespaces) }

            guard columns.count >= 2 else { continue }

            if topic == nil && !columns[0].isEmpty {
                topic = columns[0]
            }

            let option = columns[1]
            if !option.isEmpty {
                options.append(option)
            }
        }

        guard let finalTopic = topic, !options.isEmpty else {
            throw CSVImportError.emptyOptions
        }

        return ImportedDecision(
            title: finalTopic,
            options: options,
            source: .manual
        )
    }
}


