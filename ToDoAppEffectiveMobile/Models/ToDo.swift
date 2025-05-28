//
//  ToDo.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import Foundation

struct ToDoResponse: Codable {
    let todos: [ToDo]
}

struct ToDo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

