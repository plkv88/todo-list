//
//  CreateTodoViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import Foundation
import UIKit

struct TodoItemViewModel {
    
    var id: String?
    var text: String?
    var priority: Priority?
    var deadline: Date?
}

final class CreateTodoItemViewController: UIViewController {
    
    private var todoItemViewModel = TodoItemViewModel()
    private var fileCache = FileCache()
    private let filename = "todo.json"
    
    private var keyboardHeight: CGFloat?
    
    // MARK: - Layout
    
    enum Layout {
        
        static let fontSize: CGFloat = 17
        static let backgroundcolor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        
        enum TopStackView {
            static let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            static let height: CGFloat = 50
            static let minimumLineSpacing: CGFloat = 10
            
            static let cancelButtonTextKey = "Отменить"
            static let nameScreenLabelTextKey = "Дело"
            static let saveButtonTextKey = "Сохранить"
        }
        
        enum ScrollView {
            static let insets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        }
        
        enum BigStackView {
            
            static let minimumLineSpacing: CGFloat = 15
        }
        
        enum PriorityView {
            static let height: CGFloat = 60
        }
        
        enum DeadLineView {
            static let height: CGFloat = 60
        }
        
        enum TextView {
            static let height: CGFloat = 150
        }
        
        enum DeleteButton {
            static let cornerRadius: CGFloat = 16
            static let height: CGFloat = 60
        }
        
        enum ContainerForSmallStackView {
            static let cornerRadius: CGFloat = 16
        }
    }
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = {
         let view = UIScrollView()
         view.showsVerticalScrollIndicator = false
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
     }()
        
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Layout.TopStackView.cancelButtonTextKey, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameScreenLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.TopStackView.nameScreenLabelTextKey
        label.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(Layout.TopStackView.saveButtonTextKey, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .bold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray2, for: .disabled)
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var bigStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.BigStackView.minimumLineSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var taskTextView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.customDelegate = self
        return textView
    }()
    
    private lazy var containerForSmallStackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.ContainerForSmallStackView.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var smallStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var priorityView: PriorityView = {
        let view = PriorityView()
        view.setPriority(priority: Priority.normal)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deadLineView: DeadLineView = {
        let view = DeadLineView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var calendarDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = .white
        datePicker.addTarget(self, action: #selector(datePickerTapped(sender:)), for: .valueChanged)
        datePicker.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить", for: .normal)
        button.layer.cornerRadius = Layout.DeleteButton.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.systemGray2, for: .disabled)
        button.setTitleColor(.red, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Layout.backgroundcolor
        
        addSubviews()
        addConstraints()
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try fileCache.loadFile(fileName: filename)
            if let todo = fileCache.todoItems.first {
                todoItemViewModel.priority = todo.priority
                todoItemViewModel.deadline = todo.deadline
                todoItemViewModel.id = todo.id
                todoItemViewModel.text = todo.text
                
                updateView()
                
                fileCache.removeTodoItem(id: todo.id)
            }
        } catch {
            
        }
    }
    
    // MARK: - UI
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @objc private func datePickerTapped(sender: UIDatePicker) {
        datePickerTapped(for: sender.date)
    }
    
    func datePickerTapped(for date: Date) {
        todoItemViewModel.deadline = date
        showDateInLabel(date)
        UIView.animate(withDuration: Double(0.3), animations: {
            self.calendarDatePicker.isHidden = true
        })
    }
    
    func showDateInLabel(_ date: Date) {
        deadLineView.dateChosen(date)
    }
    
    private func addSubviews() {
        view.addSubview(topStackView)
          topStackView.addArrangedSubview(cancelButton)
          topStackView.addArrangedSubview(nameScreenLabel)
          topStackView.addArrangedSubview(saveButton)

          view.addSubview(scrollView)
          scrollView.addSubview(bigStackView)

          bigStackView.addArrangedSubview(taskTextView)
          bigStackView.addArrangedSubview(containerForSmallStackView)

          containerForSmallStackView.addSubview(smallStackView)
          smallStackView.addArrangedSubview(priorityView)
          smallStackView.addArrangedSubview(deadLineView)
          smallStackView.addArrangedSubview(calendarDatePicker)

          bigStackView.addArrangedSubview(deleteButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.TopStackView.insets.left),
            topStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Layout.TopStackView.insets.right),
            topStackView.heightAnchor.constraint(equalToConstant: Layout.TopStackView.height),
            
            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: Layout.ScrollView.insets.top),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.ScrollView.insets.left),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Layout.ScrollView.insets.right),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            bigStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            bigStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bigStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bigStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bigStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.TextView.height),
            priorityView.heightAnchor.constraint(equalToConstant: Layout.PriorityView.height),
            deadLineView.heightAnchor.constraint(equalToConstant: Layout.DeadLineView.height),
            
            smallStackView.topAnchor.constraint(equalTo: containerForSmallStackView.topAnchor),
            smallStackView.leadingAnchor.constraint(equalTo: containerForSmallStackView.leadingAnchor),
            smallStackView.trailingAnchor.constraint(equalTo: containerForSmallStackView.trailingAnchor),
            smallStackView.bottomAnchor.constraint(equalTo: containerForSmallStackView.bottomAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.DeleteButton.height)
        ])
    }
    
    @objc func saveButtonTapped() {
        guard
            let text = todoItemViewModel.text,
            let priority = todoItemViewModel.priority
        else {
            return
        }
        
        let todoItem = TodoItem(text: text, priority: priority, deadline: todoItemViewModel.deadline)
        
        do {
            try fileCache.addTodoItem(todoItem: todoItem)
        } catch {
            
        }
        do {
            try fileCache.saveFile(fileName: filename)
        } catch {
            
        }
        fileCache.removeTodoItem(id: todoItem.id)
    }

    @objc func deleteButtonTapped() {
        todoItemViewModel = TodoItemViewModel()
        updateView()
        
        do {
            try fileCache.deleteFile(fileName: filename)
        } catch {
            
        }
    }
    
    private func updateView() {
        taskTextView.text = todoItemViewModel.text
        taskTextView.customDelegate?.textViewDidChange(with: todoItemViewModel.text ?? "")
        taskTextView.textViewDidEndEditing(taskTextView)
        deadLineView.setSwitch(isOn: todoItemViewModel.deadline == nil ? false : true)
        priorityView.setPriority(priority: todoItemViewModel.priority ?? Priority.normal)
        calendarDatePicker.isHidden = true
    }
    
    private func addObservers() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     private func removeObservers() {
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     @objc private func keyboardWillShow(notification: NSNotification) {
         guard let userInfo = notification.userInfo else { return }
         guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
         let keyboardHeight = keyboardSize.cgRectValue.height
         scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
     }

     @objc private func keyboardWillHide(notification: NSNotification) {
         scrollView.contentInset = .zero
     }
}

// MARK: - DeadLineViewDelegate
extension CreateTodoItemViewController: DeadLineViewDelegate {
    func deadLineSwitchChanged(isOn: Bool) {
        if isOn {
            if todoItemViewModel.deadline == nil {
                todoItemViewModel.deadline = Date.now + 60 * 60 * 24
            }
            
            UIView.animate(withDuration: Double(0.3), animations: {
                self.calendarDatePicker.isHidden = false
            })
            
            calendarDatePicker.setDate(todoItemViewModel.deadline!, animated: false)
            deadLineView.makeLayoutForSwitcherIsON(for: todoItemViewModel.deadline!)
        } else {
            todoItemViewModel.deadline = nil
            UIView.animate(withDuration: Double(0.3), animations: {
                self.calendarDatePicker.isHidden = true
            })
            deadLineView.makeLayoutForSwitcherIsOff()
        }
    }
    
    func dateButtonTapped() {
        if calendarDatePicker.isHidden {
            UIView.animate(withDuration: Double(0.3), animations: {
                self.calendarDatePicker.isHidden = false
            })
        } else {
            UIView.animate(withDuration: Double(0.3), animations: {
                self.calendarDatePicker.isHidden = true
            })
        }
        if let date = todoItemViewModel.deadline {
            calendarDatePicker.setDate(date, animated: false)
        }
    }
    
}

// MARK: - TextViewWithPlaceholderDelegate
extension CreateTodoItemViewController: TextViewWithPlaceholderDelegate {
    
    func textViewDidChange(with text: String) {
        todoItemViewModel.text = text
        
        guard
            !(todoItemViewModel.text == nil || todoItemViewModel.text?.isEmpty == true)
        else {
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        deleteButton.isEnabled = true
    }

}

// MARK: - PriorityViewDelegate
extension CreateTodoItemViewController: PriorityViewDelegate {
    
    func priorityChosen(_ priority: Priority) {
        todoItemViewModel.priority = priority
        
        guard
            !(todoItemViewModel.text == nil || todoItemViewModel.text?.isEmpty == true)
        else {
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        deleteButton.isEnabled = true
    }
}
