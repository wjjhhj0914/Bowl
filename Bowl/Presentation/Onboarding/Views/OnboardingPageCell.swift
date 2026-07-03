//
//  OnboardingPageCell.swift
//  Bowl
//
//  A single swipeable onboarding page: the center illustration with a
//  headline and subtitle beneath it. Vertical spacing mirrors the Figma
//  design (illustration → 86 → title → 14 → subtitle).
//

import UIKit
import SnapKit

final class OnboardingPageCell: UICollectionViewCell {

    static let reuseID = "OnboardingPageCell"

    private let illustrationView = OnboardingIllustrationView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.title
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        [illustrationView, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        illustrationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(61)
            // The illustration sits ~6pt left of the horizontal center in the design.
            make.centerX.equalToSuperview().offset(-6)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationView.snp.bottom).offset(86)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
    }

    func configure(with page: OnboardingPage) {
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
    }
}
