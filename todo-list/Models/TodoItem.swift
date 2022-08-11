//
//  TodoItem.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import Foundation

private enum Constants {
    static let idKey = "id"
    static let textKey = "text"
    static let priorityKey = "priority"
    static let deadlineKey = "deadline"
    static let doneKey = "done"
    static let dateCreateKey = "dateCreate"
    static let dateEditKey = "dateEdit"
}

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
         priority: Priority = .normal, deadline: Date? = nil,
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
        
        dict[Constants.idKey] = self.id
        dict[Constants.textKey] = self.text
        dict[Constants.doneKey] = self.done
        dict[Constants.priorityKey] = self.priority == .normal ? nil : self.priority.rawValue
        dict[Constants.deadlineKey] = self.deadline?.timeIntervalSince1970
        dict[Constants.dateCreateKey] = self.dateCreate.timeIntervalSince1970
        dict[Constants.dateEditKey] = self.dateEdit?.timeIntervalSince1970
        
        return dict
    }
    
    static func parse(json: Any) -> TodoItem? {
        if let dict = json as? [String: Any] {
            let id = dict[Constants.idKey] as? String ?? UUID().uuidString
            let text = dict[Constants.textKey] as? String ?? ""
            let done = dict[Constants.doneKey] as? Bool ?? false
            
            var priority = Priority.normal
            if let priorityString = dict[Constants.priorityKey] as? String {
                priority = Priority(rawValue: priorityString) ?? .normal
            }
            
            var deadline: Date?
            if let deadlineDouble = dict[Constants.deadlineKey] as? Double {
                deadline = Date(timeIntervalSince1970: deadlineDouble)
            }
            
            let dateCreate = Date(timeIntervalSince1970: dict[Constants.dateCreateKey] as? Double ?? 0)
            
            var dateEdit: Date?
            if let dateEditDouble = dict[Constants.dateEditKey] as? Double {
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
