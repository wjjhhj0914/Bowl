//
//  QuickActionCardView.swift
//  Bowl
//
//  A single "빠른 실행" shortcut card: a pastel icon circle above a label.
//  A UIControl with press feedback so taps bind via Rx.
//

import UIKit
import SnapKit

final class QuickActionCardView: UIControl {

    let action: HomeQuickAction

    private let iconCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        return view
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionTitle
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    init(action: HomeQuickAction) {
        self.action = action
        super.init(frame: .zero)
        backgroundColor = AppColor.surface
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)

        iconCircle.backgroundColor = action.circleColor
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        iconView.image = UIImage(systemName: action.symbolName, withConfiguration: config)
        iconView.tintColor = action.iconColor
        titleLabel.text = action.title

        setupLayout()

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 110)
    }

    private func setupLayout() {
        [iconCircle, titleLabel].forEach {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }
        iconCircle.addSubview(iconView)

        iconCircle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(48)
        }
        iconView.snp.makeConstraints { $0.center.equalToSuperview() }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconCircle.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }
}
