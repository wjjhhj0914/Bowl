//
//  ProfileSelectionCardView.swift
//  Bowl
//
//  White card holding a section title and a tappable selection row, with an
//  optional accessory (e.g. the age chip) that can show/hide. Like the name
//  card, the accessory lives in a stack so the card height adapts.
//

import UIKit
import SnapKit

final class ProfileSelectionCardView: UIView {

    let fieldRow: SelectionFieldRow

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [fieldRow])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()

    private var accessoryView: UIView?

    init(title: String, placeholder: String) {
        fieldRow = SelectionFieldRow(placeholder: placeholder)
        super.init(frame: .zero)
        titleLabel.text = title
        configure()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure() {
        backgroundColor = AppColor.surface
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(contentStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - API

    func setValue(_ value: String?) {
        fieldRow.setValue(value)
    }

    /// Installs an accessory below the field row (hidden until shown).
    func setAccessory(_ view: UIView) {
        accessoryView = view
        view.isHidden = true
        contentStack.addArrangedSubview(view)
    }

    /// Shows/hides the accessory, animating the card's height.
    func setAccessoryVisible(_ visible: Bool) {
        guard let accessoryView, accessoryView.isHidden == visible else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            accessoryView.isHidden = !visible
            self.superview?.layoutIfNeeded()
        }
    }
}
