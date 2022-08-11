//
//  DeadLineView.swift
//  todo-final
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

protocol DeadLineViewDelegate: AnyObject {
    func deadLineSwitchChanged(isOn: Bool)
    func dateButtonTapped()
}

final class DeadLineView: UIView {

    // MARK: - Layout

    private enum Layout {

        enum TopLabel {
            static let text = "Сделать до"
            static let textSize: CGFloat = 17
        }

        enum StackView {
            static let insets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: 0)
        }

        enum Switcher {
            static let trailingInset: CGFloat = -16
        }

        enum LineView {
            static let height: CGFloat = 0.5
            static let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        }

        enum BelowLabel {
            static let fontSize: CGFloat = 13
        }
    }

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.TopLabel.text
        label.font = UIFont.systemFont(ofSize: Layout.TopLabel.textSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var belowLabel: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Layout.BelowLabel.fontSize, weight: .regular)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        return UISwitch()
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    weak var delegate: DeadLineViewDelegate?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switcherChanged(_:)), for: .valueChanged)

        addSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func addSubviews() {
        addSubview(switcher)
        addSubview(stackView)
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(belowLabel)
        addSubview(lineView)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.StackView.insets.left),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.Switcher.trailingInset),

            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.LineView.insets.left),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.LineView.insets.right),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Layout.LineView.height)
        ])
    }

    // MARK: - Private Functions

    @objc private func switcherChanged(_ sender: UISwitch) {
        delegate?.deadLineSwitchChanged(isOn: sender.isOn)
    }

    @objc private func dateButtonTapped() {
        delegate?.dateButtonTapped()
    }

    // MARK: - Public Functions

    func dateChosen(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        belowLabel.setTitle(dateString, for: .normal)
    }

    func makeLayoutForSwitcherIsON(for date: Date) {
        lineView.isHidden = false
        belowLabel.isHidden = false
        dateChosen(date)
    }

    func makeLayoutForSwitcherIsOff() {
        lineView.isHidden = true
        belowLabel.isHidden = true
        belowLabel.setTitle(nil, for: .normal)
    }

    func setSwitch(isOn: Bool) {
        switcher.isOn = isOn
        delegate?.deadLineSwitchChanged(isOn: isOn)
    }
}
