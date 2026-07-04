//
//  NameInputCardView.swift
//  Bowl
//
//  The "이름" card on profile step 1: a white rounded card holding a label,
//  a filled text field, and a coral helper rule. Expose `textField` so the
//  owning view controller can bind its text reactively.
//

import UIKit
import SnapKit

final class NameInputCardView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = AppFont.fieldLabel
        label.textColor = AppColor.textSecondary
        return label
    }()

    let textField: UITextField = {
        let field = UITextField()
        field.font = AppFont.input
        field.textColor = AppColor.textPrimary
        field.backgroundColor = AppColor.inputBackground
        field.layer.cornerRadius = 10
        field.attributedPlaceholder = NSAttributedString(
            string: "고양이 이름을 입력하세요",
            attributes: [
                .foregroundColor: AppColor.placeholder,
                .font: AppFont.input
            ]
        )
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.clearButtonMode = .whileEditing
        // 16pt left inset so text/placeholder start where the design shows.
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        return field
    }()

    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "한글, 영문, 숫자를 혼합한 1~8자만 사용 가능해요"
        label.font = AppFont.helper
        label.textColor = AppColor.warning
        label.numberOfLines = 0
        return label
    }()

    /// Field + helper stacked vertically. When the helper is hidden the stack
    /// drops its spacing too, so the card collapses to fit just the field.
    private lazy var inputStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, helperLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    init() {
        super.init(frame: .zero)
        configure()
        setupHierarchy()
        setupLayout()
        // Hidden until the user types something invalid. Because helperLabel is
        // an arranged subview, hiding it also collapses the stack's spacing.
        helperLabel.alpha = 0
        helperLabel.isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Fades the red validation rule in or out, animating the card's height as
    /// the stack collapses/expands.
    func setValidationMessage(visible: Bool) {
        guard helperLabel.isHidden == visible else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.helperLabel.isHidden = !visible
            self.helperLabel.alpha = visible ? 1 : 0
            // Animate the card (and its siblings) resizing to the new height.
            self.superview?.layoutIfNeeded()
        }
    }

    private func configure() {
        backgroundColor = AppColor.surface
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = AppColor.cardBorder.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func setupHierarchy() {
        [titleLabel, inputStackView].forEach { addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.leading.equalToSuperview().offset(16)
        }

        textField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        // No fixed card height: the stack's content drives it, and the card's
        // bottom follows the stack so it grows/shrinks with the helper.
        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
