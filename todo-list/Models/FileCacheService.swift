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
    func loadFile(from file: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addTodoItem(todoItem: TodoItem)
    func removeTodoItem(id: String) -> TodoItem?
}

// class MockFileCacheService: FileCacheService {
//    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
//        let timeout = TimeInterval.random(in: 1..<3)
//        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
//            completion(.success([TodoItem(text: "1")]))
//        }
//    }
// }
