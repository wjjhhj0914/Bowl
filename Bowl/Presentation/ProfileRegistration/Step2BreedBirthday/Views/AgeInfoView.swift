//
//  AgeInfoView.swift
//  Bowl
//
//  The light-blue age chip shown under the birthday field once a date is
//  chosen: a life-stage pill (성묘 etc.) followed by a friendly age line.
//

import UIKit
import SnapKit

final class AgeInfoView: UIView {

    private let stagePill: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.primary
        view.layer.cornerRadius = 12
        return view
    }()

    private let stageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.chipLabel
        label.textColor = AppColor.onPrimary
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.chipText
        label.textColor = AppColor.ageChipText
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.ageChipBackground
        layer.cornerRadius = 10
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    private func setupLayout() {
        stagePill.addSubview(stageLabel)
        addSubview(stagePill)
        addSubview(descriptionLabel)

        stagePill.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
        }

        stageLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(stagePill.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    func configure(with info: CatAgeInfo) {
        stageLabel.text = info.stage
        descriptionLabel.text = info.description
    }
}
