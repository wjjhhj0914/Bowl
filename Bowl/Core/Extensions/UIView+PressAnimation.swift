//
//  UIView+PressAnimation.swift
//  Bowl
//
//  Reusable tactile press feedback: scale down slightly on touch-down, then
//  spring back to the original size on release. Used by selectable controls
//  (gender buttons, body-type cards) for a consistent, physical feel.
//

import UIKit

extension UIView {

    /// Scales the view down slightly to signal a press.
    func animatePressDown() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    /// Springs the view back to its original size on release.
    func animatePressUp() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction]
        ) {
            self.transform = .identity
        }
    }
}
