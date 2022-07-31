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
    
    func addTodoItem(id: String = UUID().uuidString, text: String, priority: Priority, deadline: Date? = nil) throws {
        if todoItems.contains(where: { $0.id == id }) {
            throw FileCacheErrors.alreadyExisting(id: id)
        } else {
            todoItems.append(TodoItem.init(id: id, text: text, done: false, priority: priority, deadline: deadline, dateCreate: Date.now, dateEdit: nil))
        }
    }
    
    func removeTodoItem(id: String) {
        todoItems.removeAll(where: { $0.id == id })
    }
    
    func saveFile(fileName: String) throws {
        var itemsArray: [Any] = []
        for item in todoItems {
            itemsArray.append(item.json)
        }
        
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName, isDirectory: false) {
            try JSONSerialization.data(withJSONObject: itemsArray, options: []).write(to: fileURL)
        }
    }
    
    func loadFile(fileName: String) throws {
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName, isDirectory: false) {
            let fileData = try Data(contentsOf: fileURL)
            let itemsArray = try JSONSerialization.jsonObject(with: fileData, options: [])
            
            guard let itemsArray = itemsArray as? [Any] else { throw FileCacheErrors.invalidJSONFormat }
            
            todoItems.removeAll()
            
            for item in itemsArray {
                if let newItem = TodoItem.parse(json: item) {
                    todoItems.append(newItem)
                }
            }
        }
    }
}
