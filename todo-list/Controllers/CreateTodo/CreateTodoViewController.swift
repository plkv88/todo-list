//
//  CreateTodoViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import Foundation
import UIKit
import CocoaLumberjack
import TodoLib

// MARK: - Protocol

protocol CreateTodoViewControllerDelegate: AnyObject {
    func removeFromView(id: String)
    func updateFromView(todoItemView: TodoItemViewModel)
}

// MARK: - Class

final class CreateTodoItemViewController: UIViewController {

    // MARK: - Properties

    private var todoItemViewModel = TodoItemViewModel()
    weak var delegate: CreateTodoViewControllerDelegate?

    // MARK: - Layout

    private enum Layout {
        static let fontSize: CGFloat = 17
        static let backgroundcolor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        static let topStackViewInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        static let topStackViewHeight: CGFloat = 50
        static let topStackViewMinimumLineSpacing: CGFloat = 10
        static let cancelButtonTextKey = "Отменить"
        static let nameScreenLabelTextKey = "Дело"
        static let saveButtonTextKey = "Сохранить"
        static let scrollViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        static let bigStackViewMinimumLineSpacing: CGFloat = 16
        static let textViewHeight: CGFloat = 120
        static let otherHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
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
        button.setTitle(Layout.cancelButtonTextKey, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nameScreenLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.nameScreenLabelTextKey
        label.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(Layout.saveButtonTextKey, for: .normal)
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
        stackView.spacing = Layout.bigStackViewMinimumLineSpacing
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
        view.layer.cornerRadius = Layout.cornerRadius
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
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить", for: .normal)
        button.layer.cornerRadius = Layout.cornerRadius
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

        DDLogInfo("CreateTodoItem view controller did load!")

        view.backgroundColor = Layout.backgroundcolor
        addSubviews()
        addConstraints()
        addObservers()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.orientation.isLandscape {
            deleteButton.isHidden = true
            containerForSmallStackView.isHidden = true
            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight).isActive = false
            taskTextView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width
                                                 - Layout.scrollViewInsets.top * 2
                                                 - Layout.topStackViewHeight).isActive = true
        } else {
            deleteButton.isHidden = false
            containerForSmallStackView.isHidden = false
            taskTextView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width
                                                 - Layout.scrollViewInsets.top * 2).isActive = false
            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight).isActive = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }

    // MARK: - Init

    deinit {
        removeObservers()
    }

    // MARK: - UI

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
            topStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: Layout.topStackViewInsets.left),
            topStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: Layout.topStackViewInsets.right),
            topStackView.heightAnchor.constraint(equalToConstant: Layout.topStackViewHeight),

            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: Layout.scrollViewInsets.top),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: Layout.scrollViewInsets.left),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: Layout.scrollViewInsets.right),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            bigStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            bigStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bigStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bigStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bigStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight),
            priorityView.heightAnchor.constraint(equalToConstant: Layout.otherHeight),
            deadLineView.heightAnchor.constraint(equalToConstant: Layout.otherHeight),

            smallStackView.topAnchor.constraint(equalTo: containerForSmallStackView.topAnchor),
            smallStackView.leadingAnchor.constraint(equalTo: containerForSmallStackView.leadingAnchor),
            smallStackView.trailingAnchor.constraint(equalTo: containerForSmallStackView.trailingAnchor),
            smallStackView.bottomAnchor.constraint(equalTo: containerForSmallStackView.bottomAnchor),

            deleteButton.heightAnchor.constraint(equalToConstant: Layout.otherHeight)
        ])
    }

    // MARK: - Public functions

    func configure(todoItem: TodoItem) {
        todoItemViewModel = TodoItemViewModel(from: todoItem)
        updateView()
    }

    // MARK: - Private functions

    private func updateView() {
        taskTextView.text = todoItemViewModel.text
        taskTextView.customDelegate?.textViewDidChange(with: todoItemViewModel.text ?? "")
        taskTextView.textViewDidEndEditing(taskTextView)
        deadLineView.setSwitch(isOn: todoItemViewModel.deadline == nil ? false : true)
        priorityView.setPriority(priority: todoItemViewModel.priority)
        calendarDatePicker.isHidden = true
    }

    @objc private func datePickerTapped(sender: UIDatePicker) {
        datePickerTapped(for: sender.date)
    }

    private func datePickerTapped(for date: Date) {
        todoItemViewModel.deadline = date
        showDateInLabel(date)
        UIView.animate(withDuration: Double(0.3), animations: {
            self.calendarDatePicker.isHidden = true
        })
    }

    private func showDateInLabel(_ date: Date) {
        deadLineView.dateChosen(date)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func saveButtonTapped() {
        delegate?.updateFromView(todoItemView: todoItemViewModel)
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func deleteButtonTapped() {
        guard let id = todoItemViewModel.id else { return }
        delegate?.removeFromView(id: id)
        self.dismiss(animated: true, completion: nil)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
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
            guard let deadline = todoItemViewModel.deadline else { return }
            calendarDatePicker.setDate(deadline, animated: false)
            deadLineView.makeLayoutForSwitcherIsON(for: deadline)
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
