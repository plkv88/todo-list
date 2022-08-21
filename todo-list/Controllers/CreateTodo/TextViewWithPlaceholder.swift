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
        static let textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        static let cornerRadius: CGFloat = 16
        static let textSize: CGFloat = 17
        static let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        static let placeHolderKey = "Что надо сделать?"
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
        font = UIFont.systemFont(ofSize: Layout.textSize, weight: .regular)
        backgroundColor = .white
        layer.cornerRadius = Layout.cornerRadius
        layer.masksToBounds = true
        textContainerInset = Layout.textContainerInset

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
        textColor = Layout.textColor
        text = Layout.placeHolderKey
    }
}

// MARK: - UITextViewDelegate

extension TextViewWithPlaceholder: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        customDelegate?.textViewDidChange(with: text)

        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.placeHolderKey {
            textView.text = Layout.placeHolderKey
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            setTextViewForPlaceHolder()
        } else {
            setTextViewForUserDescription()
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Layout.placeHolderKey {
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.placeHolderKey {
            textView.text = Layout.placeHolderKey
            setTextViewForPlaceHolder()
        } else {
            setTextViewForUserDescription()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == Layout.placeHolderKey {
            textView.text = ""
            setTextViewForUserDescription()
        }
        return true
    }
}
