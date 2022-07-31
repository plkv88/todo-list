//
//  todo_listTests.swift
//  todo-listTests
//
//  Created by Алексей Поляков on 31.07.2022.
//

import XCTest
@testable import todo_list;

class todo_listTests: XCTestCase {

    func testAdd() throws {
        let fileCache = FileCache()
        
        try fileCache.addTodoItem(todoItem: TodoItem(text: "Привет мир!", priority: .high, deadline: Date.now))
        try fileCache.addTodoItem(todoItem: TodoItem(text: "Привет мир 2!", priority: .normal, deadline: Date.now))

        XCTAssertEqual(fileCache.todoItems.count, 2)
    }
    
    func testSaveAndLoad() throws {
        let fileCache = FileCache()

        try fileCache.addTodoItem(todoItem: TodoItem(text: "Привет мир!", priority: .high, deadline: Date.now))
        try fileCache.addTodoItem(todoItem: TodoItem(text: "Привет мир 2!", priority: .low, deadline: Date.now))
        
        let filename = "test.json"
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileCache.getFileURL(by: filename)!.path))

        try fileCache.saveFile(fileName: filename)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileCache.getFileURL(by: filename)!.path))
        
        try fileCache.loadFile(fileName: filename)
        
        XCTAssertEqual(fileCache.todoItems.count, 2)
        
        try FileManager.default.removeItem(atPath: fileCache.getFileURL(by: filename)!.path)
    }
}
