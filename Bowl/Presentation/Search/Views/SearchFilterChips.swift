//
//  SearchFilterChips.swift
//  Bowl
//
//  The filter row under the 사료 검색 search field: blue removable chips for
//  each active filter, plus a trailing gray "필터" button that opens the
//  filter sheet.
//

import UIKit
import SnapKit

/// A blue pill for an active filter, with a ✕ to remove it.
final class ActiveFilterChipView: UIControl {

    /// Fired when the chip (its ✕) is tapped.
    var onRemove: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.chipLabel
        label.textColor = .white
        label.isUserInteractionEnabled = false
        return label
    }()

    private let closeLabel: UILabel = {
        let label = UILabel()
        label.text = "✕"
        label.font = .systemFont(ofSize: 9, weight: .bold)
        label.textColor = AppColor.onPrimarySubtext
        label.isUserInteractionEnabled = false
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        backgroundColor = AppColor.primary
        layer.cornerRadius = 14

        let stack = UIStackView(arrangedSubviews: [titleLabel, closeLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 5
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(28) }

        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func didTap() { onRemove?() }
}

/// The trailing gray "필터" button that opens the filter sheet.
final class FilterButton: UIControl {

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let view = UIImageView(image: UIImage(systemName: "slider.horizontal.3", withConfiguration: config))
        // Match the navigation-bar button tint (see HomeHeaderView).
        view.tintColor = AppColor.textPrimary
        view.contentMode = .center
        view.isUserInteractionEnabled = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "필터"
        label.font = AppFont.chipLabel
        label.textColor = AppColor.textPrimary
        label.isUserInteractionEnabled = false
        return label
    }()

    /// Highlights the button while the sheet is open or filters are applied.
    var isActive = false {
        didSet {
            guard oldValue != isActive else { return }
            updateStyle(animated: true)
        }
    }

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 14
        layer.borderWidth = 1

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 5
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(28) }
        updateStyle(animated: false)

        // Global press-scale feedback (see UIView+PressAnimation).
        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }

    /// Active → soft-blue fill, blue border, blue icon/text. Inactive → the
    /// neutral gray pill matching the navigation-bar button theme.
    private func updateStyle(animated: Bool) {
        let apply = {
            self.backgroundColor = self.isActive ? AppColor.chipSelectedBackground : AppColor.badgeBackground
            self.layer.borderColor = (self.isActive ? AppColor.primary : AppColor.divider).cgColor
            let accent = self.isActive ? AppColor.primary : AppColor.textPrimary
            self.iconView.tintColor = accent
            self.titleLabel.textColor = accent
        }
        if animated {
            UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
    }
}
