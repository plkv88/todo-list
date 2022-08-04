//
//  TextViewWithPlaceholder.swift
//  todo-final
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

protocol TextViewWithPlaceholderDelegate: AnyObject {
    
    func textViewDidChange(with text: String)
}

final class TextViewWithPlaceholder: UITextView {

    // MARK: - Layout
    private enum Layout {

        enum TextView {
            static let insets = UIEdgeInsets(top: 0, left: 16, bottom: -16, right: -16)
            static let height: CGFloat = 78
            static let textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            static let cornerRadius: CGFloat = 16
            static let textSize: CGFloat = 15
            static let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            static let placeHolderKey = "Что надо сделать?"
        }
        
        enum ContainerForSmallStackView {
            static let cornerRadius: CGFloat = 16
        }
    }

    // MARK: - Properties
    weak var customDelegate: TextViewWithPlaceholderDelegate?

    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        configureUI()
        addTextViewGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private func configureUI() {
        delegate = self
        font = UIFont.systemFont(ofSize: Layout.TextView.textSize, weight: .medium)
        backgroundColor = .white
        layer.cornerRadius = Layout.TextView.cornerRadius
        layer.masksToBounds = true
        textContainerInset = Layout.TextView.textContainerInset

        setTextViewForPlaceHolder()
    }

    // MARK: - Private Functions
    private func addTextViewGesture() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        addGestureRecognizer(gesture)
    }

    @objc private func textViewTapped() {
        becomeFirstResponder()
    }
    
    private func setTextViewForUserDescription() {
        textColor = .black
    }
    
    private func setTextViewForPlaceHolder() {
        textColor = Layout.TextView.textColor
        text = Layout.TextView.placeHolderKey
    }
}

// MARK: - UITextViewDelegate
extension TextViewWithPlaceholder: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        customDelegate?.textViewDidChange(with: text)

        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.TextView.placeHolderKey {
            textView.text = Layout.TextView.placeHolderKey
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            setTextViewForPlaceHolder()
        } else {
            setTextViewForUserDescription()
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Layout.TextView.placeHolderKey {
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.TextView.placeHolderKey {
            textView.text = Layout.TextView.placeHolderKey
            setTextViewForPlaceHolder()
        } else {
            setTextViewForUserDescription()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == Layout.TextView.placeHolderKey {
            textView.text = ""
            setTextViewForUserDescription()
        }
        return true
    }
}
