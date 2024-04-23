//
//  DateFormatHelper.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

class DateFormatterManager {
    static let shared = DateFormatterManager()
    
    let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
}
