//
//  FileCacheService.swift
//  todo-list
//
//  Created by Алексей Поляков on 12.08.2022.
//

import Foundation
import TodoLib

protocol FileCacheService {
    //  func save(
    //    to file: String,
    //    completion: @escaping (Result<Void, Error>) -> Void
    //  )
    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void)
    //  func add(_ newItem: TodoItem)
    //  func delete(id: String)
    // ...
}

class MockFileCacheService: FileCacheService {
    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            completion(.success([TodoItem(text: "1")]))
        }
    }
}

class RealMockFileCacheService: FileCacheService {
    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {

    }
}
