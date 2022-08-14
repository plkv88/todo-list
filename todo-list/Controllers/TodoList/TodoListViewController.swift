//
//  TodoListViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import UIKit
import TodoLib
import CocoaLumberjack

// MARK: - Class

final class TodoListViewController: UIViewController {

    // MARK: - Properties

    private var cellViewModels = [TodoCellViewModel]()
    private var doneTasksCount = 0
    private var showDoneTasksIsSelected = false

    private var fileCache = FileCache()
    private let filename = "todo.json"

    private var selectedCellFrame: CGRect?

    // MARK: - Layout

    private enum Layout {
        static let backgroundcolor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        static let title = "Мои дела"
        static let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: -15)
        static let height: CGFloat = 40
        static let bottomInset: CGFloat = -15
        static let size: CGFloat = 60
    }

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.registerHeaderClass(TodoListHeaderView.self)
        tableView.registerCellClass(TodoCell.self)
        tableView.registerCellClass(NewToDoCell.self)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var addTodoControl: AddTodoControl = {
        let control = AddTodoControl()
        control.addTarget(self, action: #selector(addTodoControlTapped), for: .touchUpInside)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // MARK: - Init

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fileCache.loadFile(from: filename) { result in
            switch result {
            case .success:
                DDLogInfo("Load file successful")
                self.updateViewModels()
                self.configureUI()
            case .failure(let error):
                DDLogError("Load file error")
                DDLogError(error)
            }
        }
    }

    // MARK: - UI

    private func configureUI() {
        view.backgroundColor = Layout.backgroundcolor
        navigationItem.title = Layout.title
        navigationController?.navigationBar.prefersLargeTitles = true

        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(addTodoControl)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.insets.left),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Layout.insets.right),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addTodoControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: Layout.bottomInset),
            addTodoControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTodoControl.heightAnchor.constraint(equalToConstant: Layout.size),
            addTodoControl.widthAnchor.constraint(equalToConstant: Layout.size)
        ])
    }

    // MARK: - Private Functions

    private func removeTodoItem(id: String) {
        guard fileCache.removeTodoItem(id: id) != nil else { return }

        fileCache.saveFile(to: filename) { result in
            switch result {
            case .success:
                DDLogInfo("Save file successful")
            case .failure(let error):
                DDLogError("Save file error")
                DDLogError(error)
            }
        }
    }

    private func updateTodoItem(todoItemView: TodoItemViewModel) {
        if let todoItemForUpdate = fileCache.todoItems.first(where: { $0.id == todoItemView.id }) {
            guard let deletedTodoItem = fileCache.removeTodoItem(id: todoItemForUpdate.id) else { return }
            fileCache.addTodoItem(todoItem: TodoItem(id: deletedTodoItem.id,
                                                     text: todoItemView.text ?? "",
                                                     done: deletedTodoItem.done,
                                                     priority: todoItemView.priority,
                                                     deadline: todoItemView.deadline,
                                                     dataCreate: deletedTodoItem.dateCreate,
                                                     dataEdit: Date.now))

        } else {
            fileCache.addTodoItem(todoItem: TodoItem(text: todoItemView.text ?? "",
                                                     priority: todoItemView.priority,
                                                     deadline: todoItemView.deadline))
        }
        fileCache.saveFile(to: filename) { result in
            switch result {
            case .success:
                DDLogInfo("Save file successful")
            case .failure(let error):
                DDLogError("Save file error")
                DDLogError(error)
            }
        }
    }

    private func taskDoneStatusChangedFor(id: String) {
        if let todoItem = fileCache.removeTodoItem(id: id) {
            fileCache.addTodoItem(todoItem: TodoItem(id: todoItem.id,
                                                     text: todoItem.text,
                                                     done: todoItem.done == false ? true : false,
                                                     priority: todoItem.priority,
                                                     deadline: todoItem.deadline,
                                                     dataCreate: todoItem.dateCreate,
                                                     dataEdit: todoItem.dateEdit))
            fileCache.saveFile(to: filename) { result in
                switch result {
                case .success:
                    DDLogInfo("Save file successful")
                case .failure(let error):
                    DDLogError("Save file error")
                    DDLogError(error)
                }
            }
        }
    }

    private func taskCellTappedFor(id: String) {
        guard let todoItem = fileCache.todoItems.first(where: { $0.id == id }) else { return }
        let viewController = CreateTodoItemViewController()
        viewController.delegate = self
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .custom
        viewController.configure(todoItem: todoItem)
        self.present(viewController, animated: true, completion: nil)
    }

    @objc private func addTodoControlTapped() {
        let viewController = CreateTodoItemViewController()
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        guard indexPath.row != lastIndex else { return }

        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        selectedCellFrame = tableView.convert(cell.frame, to: tableView.superview)

        let tappedTaskModelId = cellViewModels[indexPath.row].id
        taskCellTappedFor(id: tappedTaskModelId)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        guard indexPath.row != lastIndex else { return nil }

        let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                                previewProvider: { () -> UIViewController? in
            let tappedTodoId = self.cellViewModels[indexPath.row].id
            let viewController = CreateTodoItemViewController()
            guard let todoItem = self.fileCache.todoItems.first(where: { $0.id == tappedTodoId }) else { return nil }
            viewController.configure(todoItem: todoItem)
            return viewController
        }, actionProvider: nil)
        return config
    }

    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {

        guard let viewController = animator.previewViewController else { return }
        animator.addCompletion {
            self.present(viewController, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if !(tableView.cellForRow(at: indexPath) is TodoCell) { return nil}

        let swipeCheckDone = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let changedTaskModelId = self?.cellViewModels[indexPath.row].id else { return }
            self?.taskDoneStatusChangedFor(id: changedTaskModelId)
            self?.updateViewModels()
        }
        swipeCheckDone.image = UIImage(systemName: "checkmark.circle.fill")
        swipeCheckDone.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [swipeCheckDone])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if !(tableView.cellForRow(at: indexPath) is TodoCell) { return nil}

        let swipeInfo = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let tappedTaskModelId = self?.cellViewModels[indexPath.row].id else { return }
            self?.taskCellTappedFor(id: tappedTaskModelId)
        }
        swipeInfo.image = UIImage(systemName: "info.circle.fill")

        let swipeDelete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let deletedTaskModelId = self?.cellViewModels[indexPath.row].id else { return }
            self?.removeTodoItem(id: deletedTaskModelId)
            self?.updateViewModels()
        }
        swipeDelete.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [swipeDelete, swipeInfo])
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count + 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TodoListHeaderView()
        view.layer.masksToBounds = true
        view.setNumberDoneTodo(doneTasksCount)
        view.changeHideDoneTodoStatus(for: showDoneTasksIsSelected)
        view.delegate = self
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Layout.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastIndex {
            let cell: NewToDoCell? = tableView.dequeueCell(for: indexPath)
            cell?.configureCellWith(isFirstCell: indexPath.row == 0)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        } else {
            let cell: TodoCell? = tableView.dequeueCell(for: indexPath)
            let todoCellViewModel = cellViewModels[indexPath.row]
            cell?.configureCellWith(model: todoCellViewModel, needsTopMaskedCorners: indexPath.row == 0 ? true : false)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        }
    }

    func updateViewModels() {
        cellViewModels = fileCache.todoItems
            .map { TodoCellViewModel.init(from: $0) }
            .filter { showDoneTasksIsSelected || !$0.done }
        doneTasksCount = fileCache.todoItems.filter { $0.done }.count
        tableView.reloadData()
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TodoListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let startFrame = selectedCellFrame else { return nil }
        return PresentFromCellAnimator(cellFrame: startFrame)
    }
}

// MARK: - TaskCellDelegate

extension TodoListViewController: TodoCellDelegate {
    func statusChangedFor(id: String) {
        taskDoneStatusChangedFor(id: id)
        updateViewModels()
    }
}

// MARK: - NewTodoCellDelegate

extension TodoListViewController: NewTodoCellDelegate {
    func textViewDidChange(text: String) {
        updateTodoItem(todoItemView: TodoItemViewModel(text: text))
        updateViewModels()
    }
}

// MARK: - AllTasksHeaderViewDelegate

extension TodoListViewController: TodoListHeaderViewDelegate {
    func showDoneTodoButton(isSelected: Bool) {
        showDoneTasksIsSelected = isSelected
        updateViewModels()
    }
}

// MARK: - CreateTodoViewControllerDelegate

extension TodoListViewController: CreateTodoViewControllerDelegate {
    func removeFromView(id: String) {
        removeTodoItem(id: id)
        updateViewModels()
    }

    func updateFromView(todoItemView: TodoItemViewModel) {
        updateTodoItem(todoItemView: todoItemView)
        updateViewModels()
    }
}

// MARK: - Extensions

extension UITableView {
    func registerCellClass(_ typeCell: UITableViewCell.Type) {
        self.register(typeCell, forCellReuseIdentifier: typeCell.identifier)
    }

    func registerHeaderClass(_ typeView: UIView.Type) {
        self.register(typeView, forHeaderFooterViewReuseIdentifier: typeView.identifier)
    }

    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
}

extension UIView {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
