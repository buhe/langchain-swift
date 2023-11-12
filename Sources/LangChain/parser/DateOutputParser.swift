//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/10/25.
//

import Foundation

public struct DateOutputParser: BaseOutputParser {
    public init() {
    }
    
    let format = "yyyy MM dd"
    static func _generate_end_date() -> Date {
        let currentDate = Date()
        var dateComponent = DateComponents()

        dateComponent.year = 10

        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return futureDate!
    }
    func _generate_random_datetime_strings(
        pattern: String, n: Int = 3, start_date: Date = Date.now, end_date: Date = _generate_end_date()
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        let startString = formatter.string(from: start_date)
        return startString
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
    let PYDANTIC_FORMAT_INSTRUCTIONS = """
    The output should be formatted as a date string below.

    %@

    The output must be remove all other content and only keep the date string.

    Provide an output example such as:

    %@
    Question: 
"""
    public func get_format_instructions() -> String {
        String(format: PYDANTIC_FORMAT_INSTRUCTIONS, self.format, _generate_random_datetime_strings(pattern: self.format))
    }
}
