//
//  FileCache.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import Foundation
import TodoLib

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

final class FileCache: FileCacheService {

    // MARK: - Properties

    private (set) var todoItems: [TodoItem] = []

    // MARK: - Public functions

    func addTodoItem(todoItem: TodoItem) {
        guard !todoItems.contains(where: { $0.id == todoItem.id }) else { return }
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

    func removeAll() {
        todoItems.removeAll()
    }

    func saveFile(to fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {

        DispatchQueue.global().async(qos: .background) { [weak self] in

            guard let self = self else { return }
            let itemsDictArray = self.todoItems.map { $0.json }

            guard let fileURL = self.getFileURL(by: fileName) else {
                DispatchQueue.main.async {
                    completion(.failure(FileCacheErrors.fileAccess))
                }
                return
            }
            do {
                try JSONSerialization.data(withJSONObject: itemsDictArray, options: []).write(to: fileURL)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(FileCacheErrors.invalidJSONFormat))
                }
            }
        }
    }

    func loadFile(from fileName: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {

        DispatchQueue.global().async(qos: .background) { [weak self] in

            guard let self = self else { return }
            guard let fileURL = self.getFileURL(by: fileName) else {
                DispatchQueue.main.async {
                    completion(.failure(FileCacheErrors.fileAccess))
                }
                return
            }
            do {
                let fileData = try Data(contentsOf: fileURL)
                let itemsArray = try JSONSerialization.jsonObject(with: fileData, options: [])

                guard let itemsArray = itemsArray as? [Any] else {
                    DispatchQueue.main.async {
                        completion(.failure(FileCacheErrors.invalidJSONFormat))
                    }
                    return
                }

                self.todoItems.removeAll()
                self.todoItems = itemsArray.compactMap { TodoItem.parse(json: $0) }

                DispatchQueue.main.async {
                    completion(.success((self.todoItems)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(FileCacheErrors.invalidJSONFormat))
                }
            }
        }
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
