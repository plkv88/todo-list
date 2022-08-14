//
//  NetworkService.swift
//  todo-list
//
//  Created by Алексей Поляков on 14.08.2022.
//

import Foundation
import TodoLib

protocol NetworkService {
    func getAllTodoItems() async throws -> [TodoItem]
    func editTodoItem(_ item: TodoItem) async throws -> TodoItem
    func deleteTodoItem(at id: String) async throws -> TodoItem
}
