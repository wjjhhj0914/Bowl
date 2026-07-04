//
//  PrimaryButton.swift
//  Bowl
//
//  The app's primary call-to-action button: full-width blue pill with a
//  white bold label (e.g. "다음", "완료", "시작하기"). Dims itself when
//  disabled. Height (52) is applied by the owning layout.
//

import UIKit

final class PrimaryButton: UIButton {

    override var isEnabled: Bool {
        didSet { updateBackground() }
    }

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(AppColor.onPrimary, for: .normal)
        setTitleColor(AppColor.buttonDisabledText, for: .disabled)
        titleLabel?.font = AppFont.buttonTitle
        layer.cornerRadius = 14
        updateBackground()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func updateBackground() {
        backgroundColor = isEnabled ? AppColor.primary : AppColor.buttonDisabledBackground
    }
}
