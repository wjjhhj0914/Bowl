//
//  RecommendationCell.swift
//  Bowl
//
//  A compact food card for the "우리 아이 맞춤 사료" horizontal rail shown in the
//  search empty state. A 52pt thumbnail beside a tidy brand / product / nutrient
//  stack, on a softly bordered white card with generous 16pt padding.
//

import UIKit
import SnapKit

final class RecommendationCell: UICollectionViewCell {

    static let reuseID = "RecommendationCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.surface
        view.layer.cornerRadius = 16
        // Extremely light border + a soft shadow for a premium, non-flat look.
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.cardBorder.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()

    private let thumbnail: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.inputBackground
        view.layer.cornerRadius = 10
        let emoji = UILabel()
        emoji.text = "🥣"
        emoji.font = .systemFont(ofSize: 22)
        view.addSubview(emoji)
        emoji.snp.makeConstraints { $0.center.equalToSuperview() }
        return view
    }()

    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.captionMedium
        label.textColor = AppColor.textTertiary
        return label
    }()

    private let productLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 1
        return label
    }()

    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.tag
        label.textColor = AppColor.primary
        return label
    }()

    private let fatLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.tag
        label.textColor = AppColor.accentOrange
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        contentView.addSubview(card)
        card.snp.makeConstraints { $0.edges.equalToSuperview() }

        let nutritionStack = UIStackView(arrangedSubviews: [proteinLabel, fatLabel])
        nutritionStack.axis = .horizontal
        nutritionStack.spacing = 8

        // Brand / title / nutrients, evenly spaced and left-aligned.
        let textStack = UIStackView(arrangedSubviews: [brandLabel, productLabel, nutritionStack])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        let rowStack = UIStackView(arrangedSubviews: [thumbnail, textStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center

        card.addSubview(rowStack)
        thumbnail.snp.makeConstraints { $0.size.equalTo(52) }
        rowStack.snp.makeConstraints { make in
            // 16pt breathing room on every side.
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(with food: Food) {
        brandLabel.text = food.brand
        productLabel.text = food.product
        proteinLabel.text = food.proteinText
        fatLabel.text = food.fatText
    }
}
