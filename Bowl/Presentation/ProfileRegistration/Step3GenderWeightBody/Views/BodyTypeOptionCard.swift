//
//  BodyTypeOptionCard.swift
//  Bowl
//
//  A single selectable body-type option (title + subtitle). Selected → blue
//  fill with white/light-blue text; unselected → light gray with muted text.
//  A UIControl so taps bind via Rx.
//

import UIKit
import SnapKit

final class BodyTypeOptionCard: UIControl {

    let bodyType: CatBodyType

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionTitle
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionSubtitle
        label.textAlignment = .center
        return label
    }()

    init(bodyType: CatBodyType) {
        self.bodyType = bodyType
        super.init(frame: .zero)
        layer.cornerRadius = 12
        titleLabel.text = bodyType.title
        subtitleLabel.text = bodyType.subtitle
        setupLayout()
        setSelected(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 70)
    }

    private func setupLayout() {
        titleLabel.isUserInteractionEnabled = false
        subtitleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }

    func setSelected(_ isSelected: Bool) {
        backgroundColor = isSelected ? AppColor.primary : AppColor.inputBackground
        titleLabel.textColor = isSelected ? AppColor.onPrimary : AppColor.textSecondary
        subtitleLabel.textColor = isSelected ? AppColor.onPrimarySubtext : AppColor.textTertiary
    }
}
