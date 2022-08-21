//
//  DefaultNetworkingService.swift
//  todo-list
//
//  Created by Алексей Поляков on 17.08.2022.
//

import Foundation
import TodoLib

enum NetworkError: Error {
    case incorrectUrl
    case requestError
    case authError
    case unknownError
    case serviceError(_ statusCode: Int)
    case notFound
}

final class DefaultNetworkingService: NetworkingService {

    private let queue = DispatchQueue(label: "NetworkQueue", attributes: [.concurrent])
    private let path: String = "https://beta.mrdekk.ru/todobackend/list"

    private var revision: Int = 0

    var auth = ""

    private var session: URLSession = {
        let session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30.0
        return session
    }()

    func createURL(path: String) -> URLRequest? {
        guard let url = URL(string: path) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(auth, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard var urlRequest = createURL(path: path) else {
            completion(.failure(NetworkError.incorrectUrl)); return
        }
        urlRequest.httpMethod = "GET"
        let task = createTaskList(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func createTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard var urlRequest = createURL(path: path) else { completion(.failure(NetworkError.incorrectUrl)); return }
        let networkRequest = RequestElement(element: TodoItemNetwork(todoItem))
        urlRequest.setValue(String(self.revision), forHTTPHeaderField: "X-Last-Known-Revision")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(networkRequest)
        let task = createTaskElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func updateTodoItem(_ todoItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard var urlRequest = createURL(path: "\(path)/\(todoItem.id)") else {
            completion(.failure(NetworkError.incorrectUrl)); return }
        let networRequest = RequestElement(element: TodoItemNetwork(todoItem))
        urlRequest.setValue(String(self.revision), forHTTPHeaderField: "X-Last-Known-Revision")
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = try? JSONEncoder().encode(networRequest)
        let task = createTaskElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func deleteTodoItem(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard var urlRequest = createURL(path: "\(path)/\(id)") else {
            completion(.failure(NetworkError.incorrectUrl)); return }
        urlRequest.setValue(String(self.revision), forHTTPHeaderField: "X-Last-Known-Revision")
        urlRequest.httpMethod = "DELETE"
        let task = createTaskElement(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func putAllTodoItems(_ todoItems: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard var urlRequest = createURL(path: path) else {
            completion(.failure(NetworkError.incorrectUrl)); return }
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue(String(self.revision), forHTTPHeaderField: "X-Last-Known-Revision")
        let todoItemsNetwork = todoItems.map({TodoItemNetwork($0)})
        let networRequest = RequestList(list: todoItemsNetwork)
        urlRequest.httpBody = try? JSONEncoder().encode(networRequest)
        let task = createTaskList(completion: completion, urlRequest: urlRequest)
        queue.async {
            task.resume()
        }
    }

    func createTaskList(completion: @escaping (Result<[TodoItem], Error>) -> Void,
                        urlRequest: URLRequest) -> URLSessionDataTask {
        let task = self.session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if response != nil, let data = data,
                      let networkResponse = try? JSONDecoder().decode(ResponceList.self, from: data) {
                let todoItems = networkResponse.list.map({TodoItem($0)})
                self.revision = networkResponse.revision
                completion(.success(todoItems))
            } else if let response = response as? HTTPURLResponse {
                completion(.failure(self.findResponseError(response.statusCode)))
            } else {
                completion(.failure(NetworkError.unknownError))
            }
        }
        return task
    }

    func createTaskElement(completion: @escaping (Result<TodoItem, Error>) -> Void,
                           urlRequest: URLRequest) -> URLSessionDataTask {
        let task = self.session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                let networkResponse = try? JSONDecoder().decode(ResponceElement.self, from: data) {
                self.revision = networkResponse.revision
                completion(.success(TodoItem(networkResponse.element)))
            } else if let response = response as? HTTPURLResponse {
                completion(.failure(self.findResponseError(response.statusCode)))
            } else {
                completion(.failure(NetworkError.unknownError))
            }
        }
        return task
    }

    func findResponseError(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400:
            return .requestError
        case 401:
            return .authError
        case 404:
            return .notFound
        default:
            return .serviceError(statusCode)
        }
    }
}
