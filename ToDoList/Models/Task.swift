//
//  Task.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import Foundation

struct Task {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let isDone: Bool
}
