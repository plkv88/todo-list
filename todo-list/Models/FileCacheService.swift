//
//  FileCacheService.swift
//  todo-list
//
//  Created by Алексей Поляков on 14.08.2022.
//

import Foundation
import TodoLib

protocol FileCacheService {
    func saveFile(to fileName: String, completion: @escaping (Result<Void, Error>) -> Void)
    func loadFile(from fileName: String, completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func addTodoItem(todoItem: TodoItem)
    func removeTodoItem(id: String) -> TodoItem?
}
