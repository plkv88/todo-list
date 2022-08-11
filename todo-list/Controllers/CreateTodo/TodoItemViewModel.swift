//
//  TodoItemViewModel.swift
//  todo-list
//
//  Created by Алексей Поляков on 07.08.2022.
//

import Foundation

struct TodoItemViewModel {
    
    var id: String?
    var text: String?
    var priority: Priority = .normal
    var deadline: Date?
    
    init(from todoItem: TodoItem) {
        self.id = todoItem.id
        self.text = todoItem.text
        self.priority = todoItem.priority
        self.deadline = todoItem.deadline
    }
    
    init(text: String = "") {
        self.id = nil
        self.text = text
        self.deadline = nil
    }
}
