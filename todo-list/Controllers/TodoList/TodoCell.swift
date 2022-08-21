//
//  TodoCell.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import UIKit

// MARK: - Protocol

protocol TodoCellDelegate: AnyObject {

    func statusChangedFor(id: String)
}

// MARK: - Class

final class TodoCell: UITableViewCell {

    // MARK: - Layout and Constants

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let spacing: CGFloat = 2
        static let insets = UIEdgeInsets(top: 17, left: 12, bottom: -17, right: -12)
        static let numberOfLines = 3
        static let todoLabelTextSize: CGFloat = 17
        static let deadlineLabelTextSize: CGFloat = 15
        static let leadingInset: CGFloat = 16
        static let size: CGFloat = 30
        static let trailingInset: CGFloat = -16
        static let imageName: String = "chevron.right"
        static let height: CGFloat = 0.5
    }

    // MARK: - Subviews

    private lazy var checkControl: CheckControl = {
        let control = CheckControl()
        control.addTarget(self, action: #selector(controlTapped(sender:)), for: .touchUpInside)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Layout.numberOfLines
        label.font = UIFont.systemFont(ofSize: Layout.todoLabelTextSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deadLineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Layout.deadlineLabelTextSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: Layout.imageName)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    weak var delegate: TodoCellDelegate?
    private var todoCellViewModel: TodoCellViewModel?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Layout.cornerRadius

        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        contentView.addSubview(checkControl)
        contentView.addSubview(stackView)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(lineView)
        stackView.addArrangedSubview(todoLabel)
        stackView.addArrangedSubview(deadLineLabel)
    }

    private func addConstraints() {

        let heightConstraint = checkControl.heightAnchor.constraint(equalToConstant: Layout.size)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            checkControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.leadingInset),
            heightConstraint,
            checkControl.widthAnchor.constraint(equalToConstant: Layout.size),
            checkControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: Layout.trailingInset),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.insets.top),
            stackView.leadingAnchor.constraint(equalTo: checkControl.trailingAnchor, constant: Layout.insets.left),
            stackView.trailingAnchor.constraint(equalTo: chevronImageView.trailingAnchor,
                                                constant: Layout.insets.right),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Layout.insets.bottom),

            lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Layout.height)
        ])
    }

    // MARK: - Configure

    func configureCellWith(model: TodoCellViewModel, needsTopMaskedCorners: Bool) {
        todoCellViewModel = model
        todoLabel.attributedText = model.text
        deadLineLabel.attributedText = model.deadlineWithCalendar
        if model.priority == .important {
            checkControl.changeCircleImageColorToRed(true)
        } else {
            checkControl.changeCircleImageColorToRed(false)
        }
        checkControl.isSelected = model.done

        if needsTopMaskedCorners {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            contentView.layer.maskedCorners = []
        }
    }

    // MARK: - Private Functions

    @objc private func controlTapped(sender: UIControl) {
        guard let model = todoCellViewModel else { return }
        delegate?.statusChangedFor(id: model.id)
    }
}
