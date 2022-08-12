//
//  TodoCellViewModel.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import UIKit
import TodoLib

struct TodoCellViewModel {

    // MARK: - Properties

    let id: String
    var text: NSMutableAttributedString
    var priority: Priority
    var deadlineWithCalendar: NSMutableAttributedString?
    var done: Bool {
        didSet {
            text = TodoCellViewModel.getStrikeThroughTextIfNeeded(for: text, done: done)
        }
    }

    // MARK: - Init

    init(from item: TodoItem) {
        self.id = item.id
        self.priority = item.priority
        self.done = item.done

        let textMutableString = TodoCellViewModel.getImportantTextIfNeeded(for: item.text, priority: item.priority)
        text = TodoCellViewModel.getStrikeThroughTextIfNeeded(for: textMutableString, done: item.done)

        guard let deadline = item.deadline else { return }
        let dateString = TodoCellViewModel.transferDateToString(from: deadline)
        self.deadlineWithCalendar = TodoCellViewModel.addCalendarImage(for: dateString)
    }

    // MARK: - Helpers for Init

    private static func getImportantTextIfNeeded(for text: String, priority: Priority) -> NSMutableAttributedString {
        let fullTextString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let taskTextMutableString = NSMutableAttributedString(string: text)
        if priority == .high {
            let exclamationString = NSMutableAttributedString(string: "!! ")
            exclamationString.addAttributes([.foregroundColor: UIColor.red],
                                            range: NSRange(location: 0, length: exclamationString.length))
            fullTextString.append(exclamationString)
        }
        fullTextString.append(taskTextMutableString)
        return fullTextString
    }

    private static func getStrikeThroughTextIfNeeded(for string: NSMutableAttributedString,
                                                     done: Bool) -> NSMutableAttributedString {
        if done {
            string.addAttributes(
                [
                    .foregroundColor: UIColor.systemGray,
                    .strikethroughStyle: 1
                ],
                range: NSRange(location: 0, length: string.length)
            )
        } else {
            string.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: string.length))
        }
        return string
    }

    private static func transferDateToString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        let dateString = formatter.string(from: date)
        return dateString
    }

    private static func addCalendarImage(for string: String) -> NSMutableAttributedString {
        let fullString = NSMutableAttributedString(string: "")

        let imageCalendarAttachment = NSTextAttachment()
        imageCalendarAttachment.image = UIImage(named: "calendar")?.withTintColor(.systemGray)
        let imageString = NSAttributedString(attachment: imageCalendarAttachment)

        fullString.append(imageString)
        fullString.append(NSAttributedString(string: " " + string))

        fullString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.systemGray
            ],
            range: NSRange(location: 0, length: fullString.length)
        )

        return fullString
    }
}
