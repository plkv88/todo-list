//
//  CalendarCell.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class CalendarCell: UITableViewCell {
    
    static var reuseId = "CalendarCell"
    
    var calendarPicker: UIDatePicker {
        return calendar
    }
    
    private lazy var calendar: UIDatePicker = {
        var cal = UIDatePicker()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.datePickerMode = .date
        cal.preferredDatePickerStyle = .inline
        
        return cal
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
        contentView.addSubview(calendar)
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            calendar.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            calendar.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16),
            calendar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}
