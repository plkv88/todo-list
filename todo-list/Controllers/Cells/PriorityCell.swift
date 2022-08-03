//
//  PriorityCell.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class PriorityCell: UITableViewCell {
    
    static var reuseId = "PriorityCell"
    
    var priorityPicker: UISegmentedControl {
        return segmentControl
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segmentItems = ["Low", "Normal", "High"]
        let segmentControl = UISegmentedControl(items: segmentItems)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 1
        segmentControl.setImage(UIImage(named: "low")!.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
        segmentControl.setTitle("нет", forSegmentAt: 1)
        segmentControl.setImage(UIImage(named: "high")!.withRenderingMode(.alwaysOriginal), forSegmentAt: 2)
        return segmentControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(segmentControl)
    }
    
    private func setupConstrains() {
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nameLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 16)
        ])
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            segmentControl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            segmentControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            segmentControl.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 16)
        ])
    }
}

