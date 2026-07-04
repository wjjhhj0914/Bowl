//
//  SelectionFieldRow.swift
//  Bowl
//
//  A tappable filled row that shows either a placeholder or a selected
//  value with a trailing checkmark. Used for the 묘종 and 생일 fields, each
//  opening a bottom sheet when tapped. A UIControl so taps bind via Rx.
//

import UIKit
import SnapKit

final class SelectionFieldRow: UIControl {

    private let placeholder: String

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.fieldValue
        return label
    }()

    /// Pale-blue circle badge with a blue checkmark (matches the Figma design).
    private let checkBadge: UIView = {
        let badge = UIView()
        badge.backgroundColor = AppColor.checkBadgeBackground
        badge.layer.cornerRadius = 9
        badge.isHidden = true

        let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
        check.tintColor = AppColor.primary
        check.contentMode = .center
        badge.addSubview(check)
        check.snp.makeConstraints { $0.center.equalToSuperview() }
        return badge
    }()

    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        backgroundColor = AppColor.inputBackground
        layer.cornerRadius = 10
        setupLayout()
        setValue(nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    private func setupLayout() {
        // Labels must not swallow the row's touches.
        valueLabel.isUserInteractionEnabled = false
        checkBadge.isUserInteractionEnabled = false

        addSubview(valueLabel)
        addSubview(checkBadge)

        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(checkBadge.snp.leading).offset(-8)
        }

        checkBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
    }

    /// nil → show the placeholder (grey, no checkmark); non-nil → show the
    /// value (dark, with checkmark).
    func setValue(_ value: String?) {
        if let value {
            valueLabel.text = value
            valueLabel.textColor = AppColor.textSecondary
            checkBadge.isHidden = false
        } else {
            valueLabel.text = placeholder
            valueLabel.textColor = AppColor.placeholder
            checkBadge.isHidden = true
        }
    }
}
