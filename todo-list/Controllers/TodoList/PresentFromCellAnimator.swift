//
//  PresentFromCellAnimator.swift
//  todo-list
//
//  Created by Алексей Поляков on 06.08.2022.
//

import UIKit

final class PresentFromCellAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    private let cellFrame: CGRect

    // MARK: - Init

    init(cellFrame: CGRect) {
        self.cellFrame = cellFrame
    }

    // MARK: - Internal functions

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toVC = transitionContext.viewController(forKey: .to),
              let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }
        let endFrame = transitionContext.finalFrame(for: toVC)

        snapshot.frame = cellFrame

        toVC.view.isHidden = true

        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(snapshot)

        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                    snapshot.frame = endFrame
                })
        }, completion: { _ in
            toVC.view.isHidden = false

            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
