//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/10/25.
//

import Foundation

public struct DatetimeOutputParser: BaseOutputParser {
    let format = "yyyy-MM-dd HH:mm:ss"
    static func _generate_end_date() -> Date {
        let currentDate = Date()
        var dateComponent = DateComponents()

        dateComponent.year = 10

        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return futureDate!
    }
    func _generate_random_datetime_strings(
        pattern: String, n: Int = 3, start_date: Date = Date.now, end_date: Date = _generate_end_date()
    ) -> [String] {
        var examples: [String] = []
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        let startString = formatter.string(from: start_date)
        let endString = formatter.string(from: end_date)
        examples.append(startString)
        examples.append(endString)
        return examples
    }
    public func parse(text: String) -> Parsed {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.format
            let dateFromString = dateFormatter.date(from: text)
        if dateFromString != nil {
            return Parsed.date(dateFromString!)
        } else {
            return Parsed.error
        }
    }
    
    public func get_format_instructions() -> String {
        String(format: "Write a datetime string that matches the following pattern: %@. Examples: %@", self.format, _generate_random_datetime_strings(pattern: self.format).joined(separator: " , "))
    }
}
