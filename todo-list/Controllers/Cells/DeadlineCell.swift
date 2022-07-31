//
//  DeadlineCell.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class DeadlineCell: UITableViewCell {
    
    static var reuseId = "DeadlineCell"
    
    var deadlinePicker: UISwitch {
        return deadlineSwitch
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var deadlineSwitch: UISwitch = {
        var dswitch = UISwitch()
        dswitch.translatesAutoresizingMaskIntoConstraints = false
       // deadlineSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        dswitch.setOn(false, animated: false)
        return dswitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(nameLabel)
        //contentView.addSubview(calendar)
        contentView.addSubview(deadlineSwitch)
    }
    
    func setupConstrains() {
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            //nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            //nameLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 16)
        ])
        
        NSLayoutConstraint.activate([
            deadlineSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            //segmentControl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            deadlineSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            deadlineSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            //deadlineSwitch.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 6 - 16)
        ])
    }
}
