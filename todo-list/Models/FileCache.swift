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

final class FileCache: FileCacheService {

    // MARK: - Properties

    private let queue = DispatchQueue(label: "FileCacheQueue")

    private (set) var todoItems: [TodoItem] = []

    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let priority = Expression<String>("priority")
    private let deadline = Expression<Date?>("deadline")
    private let done = Expression<Bool>("done")
    private let dateCreate = Expression<Date>("dateCreate")
    private let dateEdit = Expression<Date?>("dateEdit")
    private let todoItemsTable = Table("TodoItems")
    private let fileName = "todoItems.sqlite3"

    private var dbUrl: URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            return nil
        }
        let path = documentDirectory.appendingPathComponent(fileName)
        return path
    }

    // MARK: - Init

    public init() {
        do {
            try createTables()
        } catch let error {
            print("\(error)")
        }
    }

    // MARK: - Public Functions

    func load(completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.getItems()
                completion(.success(self.todoItems))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func save(items: [TodoItem], completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.saveToDatabase(items) { items in
                    completion(.success(items))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func create(_ item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.createToDatabase(item)
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func update(_ item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.updateToDatabase(item)
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func delete(_ id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.deleteFromDatabase(id)
                completion(.success(()))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Functions

    private func createTables() throws {
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

    private func getItems() throws {
        guard let dbUrl = dbUrl else { return }
        todoItems.removeAll()
        let connection = try Connection(dbUrl.path)
        for row in try connection.prepare(todoItemsTable) {
            if let todoItem = TodoItem.parseSQL(row: row) {
                todoItems.append(todoItem)
            }
        }
    }

    private func saveToDatabase(_ items: [TodoItem], completion: ([TodoItem]) -> Void) throws {
        guard let dbUrl = dbUrl else { return }

        try getItems()

        let itemsIds = items.map({$0.id})
        let dbItemsIds = todoItems.map({$0.id})
        let itemsToDelete = todoItemsTable.filter(!itemsIds.contains(id))
        let itemsToCreate = items.filter({!dbItemsIds.contains($0.id)})
        let itemsToUpdate = items.filter({dbItemsIds.contains($0.id)})

        let connection = try Connection(dbUrl.path)
        try connection.run(itemsToDelete.delete())

        for item in itemsToCreate {
            try createToDatabase(item)
        }
        for item in itemsToUpdate {
            try updateToDatabase(item)
        }
        todoItems = items
        completion(items)
    }

    private func createToDatabase(_ todoItem: TodoItem) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        try connection.run(todoItem.sqlInsertStatement)
        todoItems.append(todoItem)
    }

    private func updateToDatabase(_ todoItem: TodoItem) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        let updatedTodoItem = todoItemsTable.filter(id == todoItem.id)
        try connection.run(updatedTodoItem.update(text <- todoItem.text,
                                                  priority <- todoItem.priority.rawValue,
                                                  deadline <- todoItem.deadline,
                                                  done <- todoItem.done,
                                                  dateEdit <- todoItem.dateEdit))
        todoItems.removeAll(where: { $0.id == todoItem.id })
        todoItems.append(todoItem)
    }

    private func deleteFromDatabase(_ id: String) throws {
        guard let dbUrl = dbUrl else { return }
        let connection = try Connection(dbUrl.path)
        let todoItem = todoItemsTable.filter(self.id == id)
        try connection.run(todoItem.delete())
        todoItems.removeAll(where: { $0.id == id })
    }
}

// MARK: - Extension

extension FileManager {
    static public func createFileIfNotExists(with path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
        }
    }
}
