//
//  ProfileSummaryCardView.swift
//  Bowl
//
//  Home profile card: a blue gradient panel with the cat's avatar, name and
//  summary, plus two white stat sub-cards (recommended calories / water).
//

import UIKit
import SnapKit

final class ProfileSummaryCardView: UIView {

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [AppColor.profileCardGradientStart.cgColor, AppColor.profileCardGradientEnd.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 20
        return layer
    }()

    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.surface
        view.layer.cornerRadius = 30
        let emoji = UILabel()
        emoji.text = "🐱"
        emoji.font = .systemFont(ofSize: 30)
        view.addSubview(emoji)
        emoji.snp.makeConstraints { $0.center.equalToSuperview() }
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.cardValue
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitleBold
        label.textColor = AppColor.profileCardSubtitle
        return label
    }()

    private let calorieCard = StatSubCard(title: "권장 칼로리")
    private let waterCard = StatSubCard(title: "권장 음수량")

    init() {
        super.init(frame: .zero)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 1)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func setupLayout() {
        [avatarView, nameLabel, subtitleLabel, calorieCard, waterCard].forEach { addSubview($0) }

        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(60)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(31)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
        }
        calorieCard.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(96)
            make.height.equalTo(68)
        }
        waterCard.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.width.height.equalTo(calorieCard)
            make.leading.equalTo(calorieCard.snp.trailing).offset(13)
        }
    }

    func configure(name: String, subtitle: String, calorie: String, water: String) {
        nameLabel.text = name
        subtitleLabel.text = subtitle
        calorieCard.setValue(calorie)
        waterCard.setValue(water)
    }
}

// MARK: - Stat sub-card

private final class StatSubCard: UIView {

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.cardValue
        label.textColor = AppColor.primary
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = AppColor.surface
        layer.cornerRadius = 14

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.caption
        titleLabel.textColor = AppColor.textTertiary

        addSubview(titleLabel)
        addSubview(valueLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(14)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setValue(_ value: String) { valueLabel.text = value }
}
