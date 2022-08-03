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
    
    private func setupViews() {
        contentView.addSubview(calendar)
    }
    
    private func setupConstrains() {
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: contentView.topAnchor),
            calendar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            calendar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            calendar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
