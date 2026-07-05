//
//  HealthChipView.swift
//  Bowl
//
//  A single multi-select health-interest chip. Selected → soft-blue fill
//  with blue text; unselected → light gray with muted text. Includes
//  press-scale feedback and a cross-dissolve on selection changes.
//

import UIKit
import SnapKit

final class HealthChipView: UIControl {

    let concern: String

    private let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionTitle
        label.textAlignment = .center
        return label
    }()

    private var hasStyledOnce = false

    init(concern: String) {
        self.concern = concern
        super.init(frame: .zero)
        layer.cornerRadius = 12
        label.text = concern
        label.isUserInteractionEnabled = false
        addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        setSelected(false)

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }

    func setSelected(_ isSelected: Bool) {
        let apply = {
            self.backgroundColor = isSelected ? AppColor.chipSelectedBackground : AppColor.inputBackground
            self.label.textColor = isSelected ? AppColor.primary : AppColor.textSecondary
        }
        if hasStyledOnce {
            UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
        hasStyledOnce = true
    }
}
