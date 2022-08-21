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

public enum Priority: String {
    case low
    case basic
    case important
}

public struct TodoItem {
    public let id: String
    public let text: String
    public let done: Bool
    public let priority: Priority
    public let deadline: Date?
    public let dateCreate: Date
    public let dateEdit: Date?

    public init(id: String = UUID().uuidString,
                text: String, done: Bool = false,
                priority: Priority = .basic, deadline: Date? = nil,
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

public extension TodoItem {
    var json: Any {
        var dict: [String: Any] = [:]

        dict[Constants.idKey] = self.id
        dict[Constants.textKey] = self.text
        dict[Constants.doneKey] = self.done
        dict[Constants.priorityKey] = self.priority == .basic ? nil : self.priority.rawValue
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

            var priority = Priority.basic
            if let priorityString = dict[Constants.priorityKey] as? String {
                priority = Priority(rawValue: priorityString) ?? .basic
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

public extension TodoItem {
    init(_ todoItemNetwork: TodoItemNetwork) {
        id = todoItemNetwork.id
        text = todoItemNetwork.text
        priority = Priority(rawValue: todoItemNetwork.priority) ?? .basic
        if let newDeadline = todoItemNetwork.deadline {
            deadline = Date(timeIntervalSince1970: TimeInterval(newDeadline))
        } else {
            deadline = nil
        }
        done = todoItemNetwork.done
        dateCreate = Date(timeIntervalSince1970: TimeInterval(todoItemNetwork.dateCreate))
        if let newDateEdit = todoItemNetwork.dateEdit {
            dateEdit = Date(timeIntervalSince1970: TimeInterval(newDateEdit))
        } else {
            dateEdit = nil
        }
    }
    
    func asCompleted() -> TodoItem {
        TodoItem(id: self.id,
                 text: self.text,
                 done: self.done == false ? true : false,
                 priority: self.priority,
                 deadline: self.deadline,
                 dataCreate: self.dateCreate,
                 dataEdit: self.dateEdit)
    }

}
