//
//  NewTodoCell.swift
//  todo-list
//
//  Created by Алексей Поляков on 06.08.2022.
//

import UIKit

// MARK: - Protocol

protocol NewTodoCellDelegate: AnyObject {
    func textViewDidChange(text: String)
}

// MARK: - Class

final class NewToDoCell: UITableViewCell {
    
    // MARK: - Layout and Constants

    private enum Layout {

        enum ContentView {
            static let cornerRadius: CGFloat = 16
        }
        
        enum TextView {
            static let textSize: CGFloat = 17
            static let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            static let placeHolderKey = "Новое"
            static let insets = UIEdgeInsets(top: 17, left: 52, bottom: -17, right: 0)
        }
    }
    
    // MARK: - Subviews

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.text = Layout.TextView.placeHolderKey
        textView.textColor = Layout.TextView.textColor
        textView.font = UIFont.systemFont(ofSize: Layout.TextView.textSize, weight: .regular)
        return textView
    }()
    
    // MARK: - Properties

    weak var delegate: NewTodoCellDelegate?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configureCellWith(isFirstCell firstCell: Bool) {
        if firstCell {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    // MARK: - UI
    
    private func configureUI() {
        backgroundColor = .white
        selectionStyle = .none
        layer.cornerRadius = Layout.ContentView.cornerRadius
        
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(textView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.TextView.insets.left),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Layout.TextView.insets.right),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.TextView.insets.top),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                             constant: Layout.TextView.insets.bottom)
        ])
    }
}

// MARK: - UITextViewDelegate

extension NewToDoCell: UITextViewDelegate {
        
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(size)
        if size != newSize {
            guard let tableView = superview as? UITableView else { return }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Layout.TextView.placeHolderKey {
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == Layout.TextView.placeHolderKey {
            textView.text = ""
            textView.textColor = .black
            return true
        }
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        
        textView.resignFirstResponder()
        
        if !textView.text.isEmpty {
            delegate?.textViewDidChange(text: textView.text)
            textView.text = Layout.TextView.placeHolderKey
            textView.textColor = Layout.TextView.textColor
        }
        return false
    }
}
