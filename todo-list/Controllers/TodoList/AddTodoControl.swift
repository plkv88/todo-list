//
//  AddTodoControl.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import UIKit

final class AddTodoControl: UIControl {

    
    // MARK: - Layout and Constants

    private enum Layout {
        
        static let imageName: String = "plus.circle.fill"
    }
    
    // MARK: - Subviews

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        addSubview(imageView)
        imageView.image = UIImage(systemName: Layout.imageName)
        imageView.contentMode = .scaleAspectFill

        addConstraints()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
