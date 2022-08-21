//
//  NetworkService.swift
//  todo-list
//
//  Created by Алексей Поляков on 14.08.2022.
//

import Foundation
import TodoLib

protocol NetworkingService {
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func createTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func updateTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteTodoItem(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func putAllTodoItems(_ todoItems: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void)
}
