//
//  TodoService.swift
//  todo-list
//
//  Created by Алексей Поляков on 20.08.2022.
//

import Foundation
import TodoLib
import CocoaLumberjack

protocol TodoServiceDelegate: AnyObject {
    func update()
}

// MARK: - Class

final class TodoService {

    // MARK: - Properties

    private var fileCache = FileCache()
    private var networkService = DefaultNetworkingService()

    private let filename = "todo.json"
    var auth = "" {
        didSet {
            networkService.auth = auth
        }
    }

    private var isDirty = false

    weak var delegate: TodoServiceDelegate?

    // MARK: - Public functions

    func getTodoItems() -> [TodoItem] { return fileCache.todoItems }

    func getTodoItem(id: String) -> TodoItem? { return fileCache.todoItems.first(where: { $0.id == id }) }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        fileCache.loadFile(from: filename) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todoItems):
                DispatchQueue.main.async { self.delegate?.update() }
                self.networkService.putAllTodoItems(todoItems) { result in
                    switch result {
                    case .success(let todoItems):
                        self.fileCache.removeAll()
                        for todoItem in todoItems {
                            self.fileCache.addTodoItem(todoItem: todoItem)
                        }
                        self.fileCache.saveFile(to: self.filename) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    case .failure:
                        self.isDirty = true
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    }
                }
            case .failure:
                self.networkService.getAllTodoItems { result in
                    switch result {
                    case .success(let todoItems):
                        for todoItem in todoItems {
                            self.fileCache.addTodoItem(todoItem: todoItem)
                        }
                        self.fileCache.saveFile(to: self.filename) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }

    func createTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCache.addTodoItem(todoItem: todoItem)
        fileCache.saveFile(to: filename) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                self.fileCache.addTodoItem(todoItem: todoItem)
                            }
                            self.fileCache.saveFile(to: self.filename) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.createTodoItem(todoItem) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure:
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateTodoItem(todoItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard fileCache.removeTodoItem(id: todoItem.id) != nil else { return }
        fileCache.addTodoItem(todoItem: todoItem)
        fileCache.saveFile(to: filename) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                self.fileCache.addTodoItem(todoItem: todoItem)
                            }
                            self.fileCache.saveFile(to: self.filename) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.updateTodoItem(todoItem) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure:
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func removeTodoItem( id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard fileCache.removeTodoItem(id: id) != nil else { return }
        fileCache.saveFile(to: filename) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.delegate?.update() }
                if self.isDirty {
                    self.networkService.putAllTodoItems(self.fileCache.todoItems) { result in
                        switch result {
                        case .success(let todoItems):
                            self.fileCache.removeAll()
                            for todoItem in todoItems {
                                self.fileCache.addTodoItem(todoItem: todoItem)
                            }
                            self.fileCache.saveFile(to: self.filename) { result in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        completion(.success(()))
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case .failure:
                            self.isDirty = true
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    self.networkService.deleteTodoItem(id) { [weak self] result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                        case .failure(let error):
                            self?.isDirty = true
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}