//
//  HomeHeaderView.swift
//  Bowl
//
//  Home screen header: a white bar (extending behind the status bar) with
//  the "홈" title and a settings button, plus a bottom hairline.
//

import UIKit
import SnapKit

final class HomeHeaderView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "홈"
        label.font = AppFont.screenTitle
        label.textColor = AppColor.textPrimary
        return label
    }()

    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "gearshape", withConfiguration: config), for: .normal)
        // Matches the header title color (navigation theme).
        button.tintColor = AppColor.textPrimary
        return button
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.headerDivider
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.surface
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        [titleLabel, settingsButton, divider].forEach { addSubview($0) }

        // Content sits below the status bar (this view spans behind it).
        let contentTop = safeAreaLayoutGuide.snp.top

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(contentTop).offset(6)
            make.height.equalTo(40)
        }

        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(44)
        }

        divider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview()
        }
    }
}
