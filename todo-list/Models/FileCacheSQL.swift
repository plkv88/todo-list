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
    
    let id = Expression<String>("id")
    let text = Expression<String>("text")
    let priority = Expression<String>("priority")
    let deadline = Expression<Int?>("deadline")
    let done = Expression<Bool>("done")
    let createdAt = Expression<Int>("createdAt")
    let updatedAt = Expression<Int?>("updatedAt")
    let todoItemsTable = Table("TodoItems")
    
    var dbUrl: URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            return nil
        }
        let path = documentDirectory.appendingPathComponent("TodoList.sqlite3")
        return path
    }
    
    public init() {
        do {
            try createTables()
        } catch let error {
            print(":( \(error)")
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
            table.column(createdAt)
            table.column(updatedAt)
        })
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

