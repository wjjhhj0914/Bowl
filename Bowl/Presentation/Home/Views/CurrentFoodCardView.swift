//
//  CurrentFoodCardView.swift
//  Bowl
//
//  "현재 급여 중인 사료" card: the food thumbnail, brand/product, a type tag
//  with protein, and a "상세" link.
//

import UIKit
import SnapKit

final class CurrentFoodCardView: ProfileCardView {

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

    private let typeTag: UILabel = {
        let label = UILabel()
        label.font = AppFont.tag
        label.textColor = AppColor.primary
        label.backgroundColor = AppColor.chipSelectedBackground
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()

    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.tag
        label.textColor = AppColor.textSecondary
        return label
    }()

    let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상세", for: .normal)
        button.setTitleColor(AppColor.primary, for: .normal)
        button.titleLabel?.font = AppFont.linkMedium
        return button
    }()

    override init() {
        super.init()
        setupLayout()
    }

    private func setupLayout() {
        [thumbnail, brandLabel, productLabel, typeTag, proteinLabel, detailButton].forEach { addSubview($0) }

        thumbnail.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(72)
        }
        brandLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnail.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(16)
        }
        productLabel.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel)
            make.top.equalTo(brandLabel.snp.bottom).offset(5)
        }
        typeTag.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel)
            make.top.equalTo(productLabel.snp.bottom).offset(6)
            make.width.equalTo(36)
            make.height.equalTo(20)
        }
        proteinLabel.snp.makeConstraints { make in
            make.leading.equalTo(typeTag.snp.trailing).offset(6)
            make.centerY.equalTo(typeTag)
        }
        detailButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 104)
    }

    func configure(brand: String, product: String, type: String, protein: String) {
        brandLabel.text = brand
        productLabel.text = product
        typeTag.text = type
        proteinLabel.text = protein
    }
}
