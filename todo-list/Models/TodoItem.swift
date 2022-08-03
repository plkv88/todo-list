//
//  TodoItem.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import Foundation

enum Priority: String {
    case low
    case normal
    case high
}

struct TodoItem {
    let id: String
    let text: String
    let done: Bool
    let priority: Priority
    let deadline: Date?
    let dateCreate: Date
    let dateEdit: Date?
    
    init(id: String = UUID().uuidString,
         text: String, done: Bool = false,
         priority: Priority, deadline: Date? = nil,
         dataCreate: Date = Date.now, dataEdit: Date? = nil) {
        self.id = id
        self.text = text
        self.done = done
        self.priority = priority
        self.deadline = deadline
        self.dateCreate = dataCreate
        self.dateEdit = dataEdit
    }
}

extension TodoItem {
    var json: Any {
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["text"] = self.text
        dict["done"] = self.done
        dict["priority"] = self.priority == .normal ? nil : self.priority.rawValue
        dict["deadline"] = self.deadline?.timeIntervalSince1970
        dict["dateCreate"] = self.dateCreate.timeIntervalSince1970
        dict["dateEdit"] = self.dateEdit?.timeIntervalSince1970
        
        return dict
    }
    
    static func parse(json: Any) -> TodoItem? {
        if let dict = json as? [String: Any] {
            let id = dict["id"] as? String ?? UUID().uuidString
            let text = dict["text"] as? String ?? ""
            let done = dict["done"] as? Bool ?? false
            
            var priority = Priority.normal
            if let priorityString = dict["priority"] as? String {
                priority = Priority(rawValue: priorityString) ?? .normal
            }
            
            var deadline: Date?
            if let deadlineDouble = dict["deadline"] as? Double {
                deadline = Date(timeIntervalSince1970: deadlineDouble)
            }
            
            let dateCreate = Date(timeIntervalSince1970: dict["dateCreate"] as? Double ?? 0)
            
            var dateEdit: Date?
            if let dateEditDouble = dict["dateEdit"] as? Double {
                dateEdit = Date(timeIntervalSince1970: dateEditDouble)
            }
            
            return self.init(id: id,
                             text: text, done: done,
                             priority: priority,
                             deadline: deadline,
                             dataCreate: dateCreate,
                             dataEdit: dateEdit)
        } else {
            return nil
        }
    }
}
