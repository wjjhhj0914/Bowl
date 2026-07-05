//
//  OptionalBadgeView.swift
//  Bowl
//
//  Small "선택사항" (optional) badge shown next to optional section titles.
//

import UIKit
import SnapKit

final class OptionalBadgeView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.badgeBackground
        layer.cornerRadius = 10

        let label = UILabel()
        label.text = "선택사항"
        label.font = AppFont.optionSubtitle
        label.textColor = AppColor.textTertiary
        label.textAlignment = .center
        addSubview(label)

        snp.makeConstraints { $0.height.equalTo(20) }
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
