//
//  ProfileCardView.swift
//  Bowl
//
//  Base white card used across the profile-registration cards: rounded
//  corners with a soft shadow. Subclasses add their own content.
//

import UIKit

class ProfileCardView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.surface
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
