//
//  FileCacheSQL.swift
//  todo-list
//
//  Created by Алексей Поляков on 26.08.2022.
//

import Foundation
import SQLite
import TodoLib

// MARK: - Class

final class FileCacheSQL {

    // MARK: - Properties

    private (set) var todoItems: [TodoItem] = []

    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let priority = Expression<String>("priority")
    private let deadline = Expression<Date?>("deadline")
    private let done = Expression<Bool>("done")
    private let dateCreate = Expression<Date>("dateCreate")
    private let dateEdit = Expression<Date?>("dateEdit")
    private let todoItemsTable = Table("TodoItems")

    private var dbUrl: URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            return nil
        }
        let path = documentDirectory.appendingPathComponent("todo5.sqlite3")
        return path
    }

    public init() {
        do {
            try createTables()
        } catch let error {
            print("\(error)")
        }
    }

    func createTables() throws {
        guard let dbUrl = dbUrl else { return }
        FileManager.createFileIfNotExists(with: dbUrl)
        let connection = try Connection(dbUrl.path)
        try connection.run(todoItemsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(text)
            table.column(priority)
            table.column(deadline)
            table.column(done)
            table.column(dateCreate)
            table.column(dateEdit)
        })
    }

    func load() throws {
        try getItems { [weak self] items in
            self?.todoItems = items
        }
    }

    func getItems(completion: ([TodoItem]) -> Void) throws {
        guard let dbUrl = dbUrl else { return }
        todoItems.removeAll()
        let connection = try Connection(dbUrl.path)
        var newTodoItems: [TodoItem] = []
        for row in try connection.prepare(todoItemsTable) {
            if let todoItem = TodoItem.parseSQL(row: row) {
                newTodoItems.append(todoItem)
            }
        }
        completion(newTodoItems)
    }

    func save(_ items: [TodoItem], completion: ([TodoItem]) -> Void) throws {
        guard let dbUrl = dbUrl else { return }
        var dbItems: [TodoItem] = []
        try getItems { items in
            dbItems = items
        }
        let connection = try Connection(dbUrl.path)
        let itemsIds = items.map({$0.id})
        let dbItemsIds = dbItems.map({$0.id})
        let itemsToDelete = todoItemsTable.filter(!itemsIds.contains(id))
        let itemsToCreate = items.filter({!dbItemsIds.contains($0.id)})
        let itemsToUpdate = items.filter({dbItemsIds.contains($0.id)})
        try connection.run(itemsToDelete.delete())
        for item in itemsToCreate {
            try create(item)
        }
        for item in itemsToUpdate {
            try update(item)
        }
        completion(items)
    }

    func create(_ todoItem: TodoItem) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        try connection.run(todoItem.sqlInsertStatement)
        todoItems.append(todoItem)
    }

    func update(_ todoItem: TodoItem) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        let updatedTodoItem = todoItemsTable.filter(id == todoItem.id)
        try connection.run(updatedTodoItem.update(text <- todoItem.text,
                                                  priority <- todoItem.priority.rawValue,
                                                  deadline <- todoItem.deadline,
                                                  done <- todoItem.done,
                                                  dateEdit <- todoItem.dateEdit))
    }

    func deleteTodoItem(_ id: String) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        let todoItem = todoItemsTable.filter(self.id == id)
        try connection.run(todoItem.delete())
    }
}

extension FileManager {
    static public func createFileIfNotExists(with path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
        }
    }
}
