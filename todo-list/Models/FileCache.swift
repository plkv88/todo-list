//
//  FileCache.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//


import Foundation

enum FileCacheErrors: LocalizedError {
    case alreadyExisting(id: String)
    case invalidJSONFormat
    
    var errorDescription: String? {
        switch self {
        case .alreadyExisting(let id):
            return "Задача c id \"\(id)\" уже существует"
        case .invalidJSONFormat:
            return "Неправильный формат JSON"
        }
    }
}

final class FileCache {
    private (set) var todoItems: [TodoItem] = []
    
    func addTodoItem(todoItem: TodoItem) throws {
        guard !todoItems.contains(where: { $0.id == todoItem.id }) else {
            throw FileCacheErrors.alreadyExisting(id: todoItem.id)
        }
        todoItems.append(todoItem)
    }
    
    func removeTodoItem(id: String) {
        todoItems.removeAll(where: { $0.id == id })
    }
    
    func getFileURL(by name: String) -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name, isDirectory: false)
    }
    
    func saveFile(fileName: String) throws {
        let itemsDictArray = todoItems.map { $0.json }
        
        if let fileURL = getFileURL(by: fileName) {
            try JSONSerialization.data(withJSONObject: itemsDictArray, options: []).write(to: fileURL)
        }
    }
    
    func loadFile(fileName: String) throws {
        if let fileURL = getFileURL(by: fileName) {
            let fileData = try Data(contentsOf: fileURL)
            let itemsArray = try JSONSerialization.jsonObject(with: fileData, options: [])
            
            guard let itemsArray = itemsArray as? [Any] else { throw FileCacheErrors.invalidJSONFormat }
            
            todoItems.removeAll()
            todoItems = itemsArray.compactMap { TodoItem.parse(json: $0) }
        }
    }
}
