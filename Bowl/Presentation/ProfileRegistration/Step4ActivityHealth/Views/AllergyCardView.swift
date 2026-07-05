//
//  AllergyCardView.swift
//  Bowl
//
//  알러지 card: an optional yes/no toggle for whether the cat has allergies.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AllergyCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아이가 알러지가 있나요?"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let badge = OptionalBadgeView()

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = AppColor.primary
        return toggle
    }()

    /// Emits when the user toggles the switch.
    var allergyChanged: Observable<Bool> {
        toggle.rx.controlEvent(.valueChanged).withLatestFrom(toggle.rx.value)
    }

    override init() {
        super.init()
        setupLayout()
    }

    private func setupLayout() {
        [titleLabel, badge, toggle].forEach { addSubview($0) }

        // Single-row card — give it the design's fixed height.
        snp.makeConstraints { $0.height.equalTo(72) }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        badge.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func setOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }
}
