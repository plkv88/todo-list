//
//  FileCacheService.swift
//  todo-list
//
//  Created by Алексей Поляков on 14.08.2022.
//

import Foundation
import TodoLib

protocol FileCacheService {
    func saveFile(to fileName: String) async throws
    func loadFile(from file: String) async throws
    func addTodoItem(todoItem: TodoItem)
    func removeTodoItem(id: String) -> TodoItem?
}
