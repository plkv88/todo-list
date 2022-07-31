//
//  TodoItemViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class TodoItemViewController: UIViewController {
    
    let fileCache = FileCache()
    let filename = "todo.json"
    
    var priority: Priority = .normal {
        didSet {
            calendarTableView.reloadData()
        }
    }
    
    var deadline: Date? {
        didSet {
            calendarTableView.reloadData()
        }
    }
    
    private lazy var todoItemTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 20
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(deleteTodo), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var calendarTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 20
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PriorityCell.self, forCellReuseIdentifier: PriorityCell.reuseId)
        tableView.register(DeadlineCell.self, forCellReuseIdentifier: DeadlineCell.reuseId)
        tableView.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.reuseId)
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if fileCache.todoItems.count != 0 {
            todoItemTextView.text = fileCache.todoItems.first?.text
            priority = fileCache.todoItems.first?.priority ?? .normal
            deadline = fileCache.todoItems.first?.deadline
            fileCache.removeTodoItem(id: fileCache.todoItems.first!.id)
        }
        
   
        
        calendarTableView.reloadData()
    }
    
    @objc private func saveTodo() {
        
        let currentTodo = TodoItem(text: todoItemTextView.text, priority: priority, deadline: deadline)
        do {
            try fileCache.addTodoItem(todoItem: currentTodo)
        } catch {
            
        }
//        do {
//            try fileCache.deleteFile(fileName: filename)
//        } catch {
//
//        }
        do {
            try fileCache.saveFile(fileName: filename)
        } catch {
            
        }
        
        fileCache.removeTodoItem(id: currentTodo.id)
        print(fileCache.todoItems)
    }
    
    @objc
    func deleteTodo() {
        
        todoItemTextView.text = ""
        deadline = nil
        priority = .normal
        
        calendarTableView.reloadData()
        
        do {
            try fileCache.deleteFile(fileName: filename)
        } catch {
            
        }
    }
    
    @objc private func cancelled() {
        dismiss(animated: true)
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)

        view.addSubview(todoItemTextView)
        view.addSubview(calendarTableView)
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        
        
        NSLayoutConstraint.activate([
            todoItemTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            todoItemTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            todoItemTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            todoItemTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            calendarTableView.topAnchor.constraint(equalTo: todoItemTextView.bottomAnchor, constant: 20),
            calendarTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            calendarTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            calendarTableView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: calendarTableView.bottomAnchor, constant: 16),
            deleteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            deleteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc
    func segmentControl(_ segmentedControl: UISegmentedControl) {
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
    
    @objc func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true){
            deadline = Date.now.addingTimeInterval(60 * 60 * 24)
        }
        else{
            deadline = nil
        }
    }
    
    @objc
    func calendarControl(_ calendarControl: UIDatePicker) {
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
