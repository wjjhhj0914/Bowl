//
//  EmptyFoodStateView.swift
//  Bowl
//
//  Empty state for the "현재 급여 중인 사료" section, shown when no food is
//  registered yet. The whole card is tappable and guides the user to
//  register their first food (search / scan). A UIControl so taps bind via Rx.
//

import UIKit
import SnapKit

final class EmptyFoodStateView: UIControl {

    private let iconCircle: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.chipSelectedBackground
        view.layer.cornerRadius = 24
        view.isUserInteractionEnabled = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        icon.tintColor = AppColor.primary
        view.addSubview(icon)
        icon.snp.makeConstraints { $0.center.equalToSuperview() }
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 급여 중인 사료가 없어요!"
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 먹이고 있는 사료를 등록하고\n맞춤 영양 분석을 받아보세요."
        label.font = AppFont.cardSubtitle
        label.textColor = AppColor.textTertiary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.surface
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
        setupLayout()

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [iconCircle, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.isUserInteractionEnabled = false
        stack.setCustomSpacing(14, after: iconCircle)
        addSubview(stack)

        iconCircle.snp.makeConstraints { $0.size.equalTo(48) }
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.bottom.equalToSuperview().offset(-28)
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }
}
