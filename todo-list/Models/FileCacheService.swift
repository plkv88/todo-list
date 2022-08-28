//
//  FileCacheService.swift
//  todo-list
//
//  Created by Алексей Поляков on 14.08.2022.
//

import Foundation
import TodoLib

protocol FileCacheService {
    func save(items: [TodoItem], completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void)
    func load(completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void)
    func create(_ item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void)
    func update(_ item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void)
    func delete(_ id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void)
}
