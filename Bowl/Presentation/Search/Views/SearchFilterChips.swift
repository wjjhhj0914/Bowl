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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "필터"
        label.font = AppFont.chipLabel
        label.textColor = AppColor.textSecondary
        label.isUserInteractionEnabled = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.badgeBackground
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = AppColor.divider.cgColor

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(28) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
