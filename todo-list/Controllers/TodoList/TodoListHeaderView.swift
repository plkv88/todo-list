//
//  TodoListHeaderView.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import UIKit

// MARK: - Protocol

protocol TodoListHeaderViewDelegate: AnyObject {

    func showDoneTodoButton(isSelected: Bool)
}

// MARK: - Class

final class TodoListHeaderView: UITableViewHeaderFooterView {

    // MARK: - Layout

    private enum Layout {

        enum ShowHideButton {
            static let fontSize: CGFloat = 15
            static let trailingInset: CGFloat = -15
            static let textForNormalKey = "Показать"
            static let textForSelectedKey = "Скрыть"
        }

        enum DoneLabel {
            static let leadingInset: CGFloat = 15
            static let textKey = "Выполнено — "
        }
    }

    // MARK: - Subviews

    private lazy var doneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var showHideButton: UIButton = {
        let button = UIButton()
        button.setTitle(Layout.ShowHideButton.textForNormalKey, for: .normal)
        button.setTitle(Layout.ShowHideButton.textForSelectedKey, for: .selected)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: Layout.ShowHideButton.fontSize, weight: .semibold)
        button.addTarget(self, action: #selector(showHideButtonTapped(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: TodoListHeaderViewDelegate?

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func configureUI() {
        backgroundView?.backgroundColor = .clear
        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        addSubview(doneLabel)
        addSubview(showHideButton)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            doneLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.DoneLabel.leadingInset),

            showHideButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            showHideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.ShowHideButton.trailingInset)
        ])
    }

    // MARK: - Private Functions

    @objc private func showHideButtonTapped(sender: UIButton) {
        delegate?.showDoneTodoButton(isSelected: !sender.isSelected)
    }

    // MARK: - Public Functions

    func setNumberDoneTodo(_ number: Int) {
        doneLabel.text = Layout.DoneLabel.textKey + "\(number)"
    }

    func changeHideDoneTodoStatus(for isSelected: Bool) {
        showHideButton.isSelected = isSelected
    }
}
