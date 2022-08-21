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

    private var todoService = TodoService()

    var auth = ""

    private var selectedCellFrame: CGRect?
    var activityIndicator = UIActivityIndicatorView(style: .medium)

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

        configureUI()

        todoService.auth = auth
        todoService.delegate = self

        startAnimatingActivityIndicator()
        todoService.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
                self.stopAnimatingActivityIndicator()
            case .failure(let error):
                DDLogError(error)
                self.stopAnimatingActivityIndicator()
            }
        }
    }

    // MARK: - UI

    private func configureUI() {
        view.backgroundColor = Layout.backgroundcolor
        navigationItem.title = Layout.title
        navigationController?.navigationBar.prefersLargeTitles = true

        let activityIndicatorButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(activityIndicatorButtonItem, animated: false)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true

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

    private func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    private func startAnimatingActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func taskCellTappedFor(id: String) {
        guard let todoItem = todoService.getTodoItems().first(where: { $0.id == id }) else { return }
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
            guard let todoItem = self.todoService.getTodoItems().first(where: { $0.id == tappedTodoId }) else {
                return nil
            }
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
            guard let id = self?.cellViewModels[indexPath.row].id else { return }
            guard let self = self else { return }
            guard let updatedTodoItem = self.todoService.getTodoItem(id: id) else { return }
            let doneTodoItem = updatedTodoItem.asCompleted()
            self.startAnimatingActivityIndicator()
            self.todoService.updateTodoItem(todoItem: doneTodoItem) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                    self.stopAnimatingActivityIndicator()
                case .failure(let error):
                    DDLogError(error)
                    self.stopAnimatingActivityIndicator()
                }
            }
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
            guard let self = self else { return }
            self.startAnimatingActivityIndicator()
            self.todoService.removeTodoItem(id: deletedTaskModelId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                    self.stopAnimatingActivityIndicator()
                case .failure(let error):
                    DDLogError(error)
                    self.stopAnimatingActivityIndicator()
                }
            }
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
        let todoItems = todoService.getTodoItems()
        cellViewModels = todoItems
            .map { TodoCellViewModel.init(from: $0) }
            .filter { showDoneTasksIsSelected || !$0.done }
        doneTasksCount = todoItems.filter { $0.done }.count
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
        guard let updatedTodoItem = todoService.getTodoItem(id: id) else { return }
        let doneTodoItem = updatedTodoItem.asCompleted()
        startAnimatingActivityIndicator()
        todoService.updateTodoItem(todoItem: doneTodoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
                self.stopAnimatingActivityIndicator()
            case .failure(let error):
                DDLogError(error)
                self.stopAnimatingActivityIndicator()
            }
        }
    }
}

// MARK: - NewTodoCellDelegate

extension TodoListViewController: NewTodoCellDelegate {
    func textViewDidChange(text: String) {
        startAnimatingActivityIndicator()
        todoService.createTodoItem(todoItem: TodoItem(text: text)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
                self.stopAnimatingActivityIndicator()
            case .failure(let error):
                DDLogError(error)
                self.stopAnimatingActivityIndicator()
            }
        }
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
        self.startAnimatingActivityIndicator()
        self.todoService.removeTodoItem(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateViewModels()
                self.stopAnimatingActivityIndicator()
            case .failure(let error):
                DDLogError(error)
                self.stopAnimatingActivityIndicator()
            }
        }
    }

    func updateFromView(todoItemView: TodoItemViewModel) {
        if let updatedId = todoItemView.id {
            guard let updatedTodoItem = todoService.getTodoItem(id: updatedId) else { return }
            startAnimatingActivityIndicator()
            todoService.updateTodoItem(todoItem: TodoItem(id: updatedId,
                                                          text: todoItemView.text ?? "",
                                                          done: updatedTodoItem.done,
                                                          priority: todoItemView.priority,
                                                          deadline: todoItemView.deadline,
                                                          dataCreate: updatedTodoItem.dateCreate,
                                                          dataEdit: Date.now)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                    self.stopAnimatingActivityIndicator()
                case .failure(let error):
                    DDLogError(error)
                    self.stopAnimatingActivityIndicator()
                }
            }
        } else {
            startAnimatingActivityIndicator()
            todoService.createTodoItem(todoItem: TodoItem(text: todoItemView.text ?? "",
                                                          priority: todoItemView.priority,
                                                          deadline: todoItemView.deadline)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.updateViewModels()
                    self.stopAnimatingActivityIndicator()
                case .failure(let error):
                    DDLogError(error)
                    self.stopAnimatingActivityIndicator()
                }
            }
        }
    }
}

extension TodoListViewController: TodoServiceDelegate {
    func update() {
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
