//
//  TodoItemNetworkModel.swift
//  todo-list
//
//  Created by Алексей Поляков on 17.08.2022.
//

import Foundation

public struct ResponceList: Codable {
    public let status: String
    public let list: [TodoItemNetwork]
    public let revision: Int
}

public struct ResponceElement: Codable {
    public let status: String
    public let element: TodoItemNetwork
    public let revision: Int
}

public struct RequestElement: Encodable {
    public var element: TodoItemNetwork
    public init(element: TodoItemNetwork) {
        self.element = element
    }
}

public struct RequestList: Encodable {
    public var list: [TodoItemNetwork]
    public init(list: [TodoItemNetwork]) {
        self.list = list
    }
}

public struct TodoItemNetwork: Codable {
    public let id: String
    public let text: String
    public let priority: String
    public let done: Bool
    public let deadline: Int?
    public let dateCreate: Int
    public let dateEdit: Int?
    public let last_updated_by: String
    
    public init(_ todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        priority = todoItem.priority.rawValue
        done = todoItem.done
        deadline = todoItem.deadline == nil ? nil : Int(todoItem.deadline!.timeIntervalSince1970)
        dateCreate = Int(todoItem.dateCreate.timeIntervalSince1970)
        dateEdit = todoItem.dateEdit == nil ? nil : Int(todoItem.dateEdit!.timeIntervalSince1970)
        last_updated_by = "device"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.priority = try container.decode(String.self, forKey: .priority)
        self.done = try container.decode(Bool.self, forKey: .done)
        do {
            self.deadline = try container.decode(Int?.self, forKey: .deadline)
        } catch {
            self.deadline = nil
        }
        self.dateCreate = try container.decode(Int.self, forKey: .dateCreate)
        self.dateEdit = try container.decode(Int?.self, forKey: .dateEdit)
        self.last_updated_by = try container.decode(String.self, forKey: .last_updated_by)
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case priority = "importance"
        case done
        case deadline
        case dateCreate = "created_at"
        case dateEdit = "changed_at"
        case last_updated_by
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(priority, forKey: .priority)
        try container.encode(done, forKey: .done)
        if deadline != nil {
            try container.encode(deadline, forKey: .deadline)
        }
        try container.encode(dateCreate, forKey: .dateCreate)
        if dateEdit != nil {
            try container.encode(dateEdit, forKey: .dateEdit)
        } else {
            try container.encode(dateCreate, forKey: .dateEdit)
        }
        try container.encode(last_updated_by, forKey: .last_updated_by)
    }
}
