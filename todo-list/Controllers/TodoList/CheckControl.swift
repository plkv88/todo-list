//
//  CheckControl.swift
//  todo-list
//
//  Created by Алексей Поляков on 04.08.2022.
//

import Foundation
import UIKit

// MARK: - Class BigAreaControl

class BigAreaControl: UIControl {

    // MARK: - Layout

    private enum Layout {
        static let minTapArea: CGFloat = 44
    }

    // MARK: - Properties

    var xInset: CGFloat
    var yInset: CGFloat

    // MARK: - Init

    init(xInset: CGFloat = 0, yInset: CGFloat = 0) {
        self.xInset = xInset
        self.yInset = yInset
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        xInset = 0
        yInset = 0
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if xInset == 0 && yInset == 0 {
            if (Layout.minTapArea - bounds.width) > 0 {
                xInset = Layout.minTapArea - bounds.width
            }

            if (Layout.minTapArea - bounds.height) > 0 {
                yInset = Layout.minTapArea - bounds.width
            }
            return bounds.insetBy(dx: -xInset, dy: -yInset).contains(point)
        } else {
            return bounds.insetBy(dx: -xInset, dy: -yInset).contains(point)
        }
    }
}

// MARK: - Class CheckControl

final class CheckControl: BigAreaControl {

    // MARK: - Subviews

    private lazy var checkImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private var circleImageRed = false

    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkImageView.image = UIImage(named: "checkmark")
                checkImageView.tintColor = .systemGreen
            } else {
                checkImageView.image = UIImage(named: "circle")
                checkImageView.tintColor = circleImageRed ? .systemRed : .systemGray3
            }
        }
    }

    // MARK: - Init

    init(circleImageRed: Bool = false, xInset: CGFloat = 0, yInset: CGFloat = 0) {
        self.circleImageRed = circleImageRed
        super.init(xInset: xInset, yInset: xInset)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    // MARK: - UI

    private func configureUI() {
        addSubview(checkImageView)
        checkImageView.image = UIImage(named: "circle")
        checkImageView.tintColor = .gray

        NSLayoutConstraint.activate([
            checkImageView.topAnchor.constraint(equalTo: topAnchor),
            checkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            checkImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Public functions

    func changeCircleImageColorToRed(_ needsRed: Bool) {
        circleImageRed = needsRed
    }
}
