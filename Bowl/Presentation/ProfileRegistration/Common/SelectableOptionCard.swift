//
//  SelectableOptionCard.swift
//  Bowl
//
//  A generic title + subtitle option used in single-select rows (e.g. the
//  활동량 options). Selected → blue fill with white/light-blue text. Includes
//  press-scale feedback and a cross-dissolve on selection changes.
//

import UIKit
import SnapKit

final class SelectableOptionCard<Value>: UIControl {

    let value: Value

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionSubtitle
        label.textAlignment = .center
        return label
    }()

    private var hasStyledOnce = false

    init(value: Value, title: String, subtitle: String, titleFont: UIFont = AppFont.optionTitle, cornerRadius: CGFloat = 12) {
        self.value = value
        super.init(frame: .zero)
        layer.cornerRadius = cornerRadius
        titleLabel.font = titleFont
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setupLayout()
        setSelected(false)

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
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

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }

    func setSelected(_ isSelected: Bool) {
        let apply = {
            self.backgroundColor = isSelected ? AppColor.primary : AppColor.inputBackground
            self.titleLabel.textColor = isSelected ? AppColor.onPrimary : AppColor.textSecondary
            self.subtitleLabel.textColor = isSelected ? AppColor.onPrimarySubtext : AppColor.textTertiary
        }
        if hasStyledOnce {
            UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
        hasStyledOnce = true
    }
}
