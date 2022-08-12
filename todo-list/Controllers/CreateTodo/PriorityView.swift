//
//  PriorityView.swift
//  todo-final
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

protocol PriorityViewDelegate: AnyObject {

    func priorityChosen(_ priority: Priority)
}

final class PriorityView: UIView {

    // MARK: - Layout

    private enum Layout {
        static let leadingInset: CGFloat = 16
        static let text = "Важность"
        static let priorityLabelFontSize: CGFloat = 17
        static let segmentControlInsets = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: -16)
        static let segmentControlWidth: CGFloat = 48
        static let segmentControlFontSize: CGFloat = 15
        static let height: CGFloat = 0.5
        static let lineInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    }

    // MARK: - Subviews

    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.text
        label.font = UIFont.systemFont(ofSize: Layout.priorityLabelFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["low", "normal", "high"])

        segmentControl.setImage(UIImage(named: "low")!.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
        segmentControl.setTitle("нет", forSegmentAt: 1)
        segmentControl.setImage(UIImage(named: "high")!.withRenderingMode(.alwaysOriginal), forSegmentAt: 2)

        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 0)
        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 1)
        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 2)

        let font: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font:
                                                    UIFont.systemFont(ofSize: Layout.segmentControlFontSize)]
        segmentControl.setTitleTextAttributes(font, for: .normal)

        segmentControl.addTarget(self, action: #selector(segmentControlTapped(sender:)), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties
    weak var delegate: PriorityViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func configureUI() {
        backgroundColor = .white
        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        addSubview(priorityLabel)
        addSubview(segmentControl)
        addSubview(lineView)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([

            priorityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingInset),

            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: Layout.segmentControlInsets.top),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                     constant: Layout.segmentControlInsets.right),

            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                   constant: Layout.segmentControlInsets.bottom),

            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Layout.height),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.lineInsets.left),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.lineInsets.right)
        ])
    }

    // MARK: - Private Functions

    @objc private func segmentControlTapped(sender: UISegmentedControl) {
        var priority = Priority.normal

        switch segmentControl.selectedSegmentIndex {
        case 0:
            priority = .low
        case 1:
            priority = .normal
        case 2:
            priority = .high
        default:
            priority = .normal
        }
        delegate?.priorityChosen(priority)
    }

    func setPriority(priority: Priority) {
        switch priority {
        case .low:
            segmentControl.selectedSegmentIndex = 0
        case .normal:
            segmentControl.selectedSegmentIndex = 1
        case .high:
            segmentControl.selectedSegmentIndex = 2
        }
    }
}
