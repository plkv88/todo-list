//
//  FileCache.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import Foundation

// MARK: - Enum

enum FileCacheErrors: LocalizedError {
    case alreadyExisting(id: String)
    case invalidJSONFormat
    case fileAccess
    
    var errorDescription: String? {
        switch self {
        case .alreadyExisting(let id):
            return "Задача c id \"\(id)\" уже существует"
        case .invalidJSONFormat:
            return "Неверный формат JSON"
        case .fileAccess:
            return "Проблема доступа в документы приложения"
        }
    }
}

// MARK: - Class

final class FileCache {
    
    // MARK: - Properties
    
    private (set) var todoItems: [TodoItem] = []
    
    // MARK: - Public functions
    
    func addTodoItem(todoItem: TodoItem) throws {
        guard !todoItems.contains(where: { $0.id == todoItem.id }) else {
            throw FileCacheErrors.alreadyExisting(id: todoItem.id)
        }
        todoItems.append(todoItem)
    }
    
    @discardableResult
    func removeTodoItem(id: String) -> TodoItem? {
        if let deletedTodo = todoItems.first(where: { $0.id == id }) {
            todoItems.removeAll(where: { $0.id == id })
            return deletedTodo
        } else {
            return nil
        }
    }
    
    func saveFile(fileName: String) throws {
        let itemsDictArray = todoItems.map { $0.json }
        
        guard let fileURL = getFileURL(by: fileName) else { throw FileCacheErrors.fileAccess }
        try JSONSerialization.data(withJSONObject: itemsDictArray, options: []).write(to: fileURL)
    }
    
    func loadFile(fileName: String) throws {
        guard let fileURL = getFileURL(by: fileName) else { throw FileCacheErrors.fileAccess }
        let fileData = try Data(contentsOf: fileURL)
        let itemsArray = try JSONSerialization.jsonObject(with: fileData, options: [])
        
        guard let itemsArray = itemsArray as? [Any] else { throw FileCacheErrors.invalidJSONFormat }
        
        todoItems.removeAll()
        todoItems = itemsArray.compactMap { TodoItem.parse(json: $0) }
    }
    
    func deleteFile(fileName: String) throws {
        guard let fileURL = getFileURL(by: fileName) else { throw FileCacheErrors.fileAccess }
        try FileManager.default.removeItem(atPath: fileURL.path)
    }
    
    // MARK: - Private functions
    
    private func getFileURL(by name: String) -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name, isDirectory: false)
    }
}
