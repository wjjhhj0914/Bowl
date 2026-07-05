//
//  StepProgressNavigationBar.swift
//  Bowl
//
//  Shared navigation bar for the multi-step cat-profile flow: a back
//  button, a centered title, an "n / total" step indicator, and a progress
//  bar whose fill reflects the current step. White surface that extends
//  behind the status bar; its content is pinned below the safe area.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class StepProgressNavigationBar: UIView {

    private let contentHeight: CGFloat = 52
    private let progressHeight: CGFloat = 4

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.textPrimary
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.navTitle
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.stepIndicator
        label.textColor = AppColor.textTertiary
        return label
    }()

    private let progressTrack: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.divider
        return view
    }()

    private let progressFill: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.primary
        return view
    }()

    /// - Parameters:
    ///   - title: centered navigation title.
    ///   - currentStep: 1-based step number.
    ///   - totalSteps: total number of steps.
    init(title: String, currentStep: Int, totalSteps: Int) {
        super.init(frame: .zero)
        titleLabel.text = title
        stepLabel.text = "\(currentStep) / \(totalSteps)"
        // Highlight the step counter blue on the final step.
        stepLabel.textColor = currentStep == totalSteps ? AppColor.primary : AppColor.textTertiary
        backgroundColor = AppColor.surface
        setupHierarchy()
        setupLayout(fraction: CGFloat(currentStep) / CGFloat(totalSteps))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        [backButton, titleLabel, stepLabel, progressTrack].forEach { addSubview($0) }
        progressTrack.addSubview(progressFill)
    }

    private func setupLayout(fraction: CGFloat) {
        // Content sits below the status bar (this view spans behind it).
        let contentTop = safeAreaLayoutGuide.snp.top

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(contentTop)
            make.height.equalTo(contentHeight)
            make.width.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        stepLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalTo(backButton)
        }

        progressTrack.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(progressHeight)
            make.bottom.equalToSuperview()
        }

        progressFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(progressTrack).multipliedBy(fraction)
        }
    }
}
