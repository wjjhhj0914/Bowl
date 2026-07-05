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

    private var hasStyledOnce = false

    init(bodyType: CatBodyType) {
        self.bodyType = bodyType
        super.init(frame: .zero)
        layer.cornerRadius = 12
        titleLabel.text = bodyType.title
        subtitleLabel.text = bodyType.subtitle
        setupLayout()
        setSelected(false)

        // Tactile press feedback.
        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }

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
        // Cross-dissolve so the background and text colors glide between states.
        let apply = {
            self.backgroundColor = isSelected ? AppColor.primary : AppColor.inputBackground
            self.titleLabel.textColor = isSelected ? AppColor.onPrimary : AppColor.textSecondary
            self.subtitleLabel.textColor = isSelected ? AppColor.onPrimarySubtext : AppColor.textTertiary
        }
        // First paint (on load) is instant; later changes animate.
        if hasStyledOnce {
            UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
        hasStyledOnce = true
    }
}
