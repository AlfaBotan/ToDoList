//
//  ToDo.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import Foundation

struct ToDoResulte: Codable {
    let todos: [ToDo]
}

struct ToDo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}
