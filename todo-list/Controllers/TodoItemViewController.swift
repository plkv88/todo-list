//
//  TodoItemViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class TodoItemViewController: UIViewController {
    
    private let fileCache = FileCache()
    private let filename = "todo.json"
    
    private var priority: Priority = .normal {
        didSet { mainTableView.reloadData() }
    }
    
    private var deadline: Date? {
        didSet { mainTableView.reloadData() }
    }
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        contentView.frame.size = contentSize
        
        return contentView
    }()
    
    private lazy var todoItemTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 16
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        return textView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(deleteTodo), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var mainTableView: UITableView = {
        let mainTableView = UITableView()
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        mainTableView.layer.cornerRadius = 16
        mainTableView.backgroundColor = .white
        mainTableView.separatorStyle = .singleLine
        mainTableView.dataSource = self
        mainTableView.delegate = self

        mainTableView.register(PriorityCell.self, forCellReuseIdentifier: PriorityCell.reuseId)
        mainTableView.register(DeadlineCell.self, forCellReuseIdentifier: DeadlineCell.reuseId)
        mainTableView.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.reuseId)
        return mainTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .done, target: self, action: #selector(cancelled))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTodo))
        navigationItem.title = "Дело"
        
        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try fileCache.loadFile(fileName: filename)
        } catch {
            
        }
        
        if let currentTodo = fileCache.todoItems.first {
            todoItemTextView.text = currentTodo.text
            priority = currentTodo.priority
            deadline = currentTodo.deadline
            fileCache.removeTodoItem(id: currentTodo.id)
        }
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(todoItemTextView)
        contentView.addSubview(mainTableView)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            todoItemTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            todoItemTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            todoItemTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            todoItemTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: todoItemTextView.bottomAnchor, constant: 16),
            mainTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            mainTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            mainTableView.heightAnchor.constraint(equalToConstant: 400)
         ])
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: mainTableView.bottomAnchor, constant: 16),
            deleteButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc
    private func saveTodo() {
        let currentTodo = TodoItem(text: todoItemTextView.text, priority: priority, deadline: deadline)
        do {
            try fileCache.addTodoItem(todoItem: currentTodo)
        } catch {
            
        }
        do {
            try fileCache.saveFile(fileName: filename)
        } catch {
            
        }
        fileCache.removeTodoItem(id: currentTodo.id)
    }
    
    @objc
    private func deleteTodo() {
        todoItemTextView.text = ""
        deadline = nil
        priority = .normal
        
        mainTableView.reloadData()
        
        do {
            try fileCache.deleteFile(fileName: filename)
        } catch {
            
        }
    }
    
    @objc
    private func cancelled() {
        dismiss(animated: true)
    }
    
    @objc
    private func segmentControl(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            priority = .low
            break
        case 1:
            priority = .normal
            break
        case 2:
            priority = .high
            break
        default:
            break
        }
    }
    
    @objc
    private func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            deadline = Date.now.addingTimeInterval(60 * 60 * 24)
        }
        else {
            deadline = nil
        }
    }
    
    @objc
    private func calendarControl(_ calendarControl: UIDatePicker) {
        deadline = calendarControl.date
    }
}

enum CalendarCellType: Int, CaseIterable {
    case priority = 0
    case deadline
    case calendar
}

extension TodoItemViewController: UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cellType = CalendarCellType(rawValue: indexPath.row) {
            switch cellType {
            case .priority:
                return 60
            case .deadline:
                return 60
            case .calendar:
                return 300
            }
        }
        return 0
    }
}

extension TodoItemViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deadline == nil ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = CalendarCellType(rawValue: indexPath.row)
        
        switch cellType {
        case .priority:
            let cell = tableView.dequeueReusableCell(withIdentifier: PriorityCell.reuseId, for: indexPath) as! PriorityCell
            cell.priorityPicker.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
            switch priority {
            case .low:
                cell.priorityPicker.selectedSegmentIndex = 0
            case .normal:
                cell.priorityPicker.selectedSegmentIndex = 1
            case .high:
                cell.priorityPicker.selectedSegmentIndex = 2
            }
            return cell
            
        case .deadline:
            let cell = tableView.dequeueReusableCell(withIdentifier: DeadlineCell.reuseId, for: indexPath) as! DeadlineCell
            cell.deadlinePicker.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
            if deadline == nil {
                cell.deadlinePicker.isOn = false
            } else {
                cell.deadlinePicker.isOn = true
            }
            return cell
            
        case .calendar:
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarCell.reuseId, for: indexPath) as! CalendarCell
            cell.calendarPicker.addTarget(self, action: #selector(calendarControl(_:)), for: .valueChanged)

            if deadline != nil {
                cell.calendarPicker.date = deadline!
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
