//
//  DateFormatterManager.swift
//  ToDoList
//
//  Created by Илья Волощик on 23.01.25.
//

import Foundation

final class DateFormatterManager {
    
    static let shared = DateFormatterManager()
    
    private init() {}
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
}
