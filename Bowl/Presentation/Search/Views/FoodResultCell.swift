//
//  FoodResultCell.swift
//  Bowl
//
//  A single 사료 검색 result: thumbnail, brand/product, 조단백·조지방 values,
//  neutral tag chips, and a bookmark toggle. 120pt card with a 16pt gap below.
//

import UIKit
import SnapKit

final class FoodResultCell: UITableViewCell {

    static let reuseID = "FoodResultCell"

    /// Fired when the bookmark button is tapped.
    var onBookmark: (() -> Void)?

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.surface
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()

    private let thumbnail: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.inputBackground
        view.layer.cornerRadius = 10
        let emoji = UILabel()
        emoji.text = "🥣"
        emoji.font = .systemFont(ofSize: 26)
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

    private lazy var nutritionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [proteinLabel, fatLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private lazy var tagStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColor.textTertiary
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        contentView.addSubview(card)
        [thumbnail, brandLabel, productLabel, nutritionStack, tagStack, bookmarkButton].forEach { card.addSubview($0) }

        card.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.height.equalTo(120)
            // 16pt gap to the next card.
            make.bottom.equalToSuperview().offset(-16)
        }
        thumbnail.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(87)
        }
        bookmarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(13)
            make.size.equalTo(28)
        }
        brandLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnail.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
        }
        productLabel.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel)
            make.top.equalTo(brandLabel.snp.bottom).offset(3)
        }
        nutritionStack.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel)
            make.top.equalTo(productLabel.snp.bottom).offset(6)
        }
        tagStack.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel)
            make.top.equalTo(nutritionStack.snp.bottom).offset(8)
        }
    }

    func configure(with result: FoodResult) {
        let food = result.food
        brandLabel.text = food.brand
        productLabel.text = food.product
        proteinLabel.text = food.proteinText
        fatLabel.text = food.fatText

        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        food.tags.forEach { tagStack.addArrangedSubview(Self.makeTag($0)) }

        let symbol = result.isSaved ? "bookmark.fill" : "bookmark"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        bookmarkButton.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        bookmarkButton.tintColor = result.isSaved ? AppColor.primary : AppColor.textTertiary
    }

    @objc private func didTapBookmark() {
        onBookmark?()
    }

    private static func makeTag(_ text: String) -> UILabel {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        label.text = text
        label.font = AppFont.tag
        label.textColor = AppColor.textTertiary
        label.backgroundColor = AppColor.neutralTagBackground
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }
}

/// A label that reserves padding around its text — used for the pill tags.
private final class PaddedLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
