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
        
        enum PriorityLabel {
            static let leadingInset: CGFloat = 16
            static let text = "Важность"
        }
        
        enum SegmentControl {
            static let insets = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: -16)
            static let arrow = "↓"
            static let noText = "нет"
            static let exclamationMark = "‼"
        }
        
        enum LineView {
            static let height: CGFloat = 1
            static let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        }
    }
    
    // MARK: - Subviews
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.PriorityLabel.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(
            items: [
                Layout.SegmentControl.arrow,
                Layout.SegmentControl.noText,
                Layout.SegmentControl.exclamationMark
            ]
        )
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
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.PriorityLabel.leadingInset),

            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: Layout.SegmentControl.insets.top),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.SegmentControl.insets.right),

            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Layout.SegmentControl.insets.bottom),

            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Layout.LineView.height),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.LineView.insets.left),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.LineView.insets.right)
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
