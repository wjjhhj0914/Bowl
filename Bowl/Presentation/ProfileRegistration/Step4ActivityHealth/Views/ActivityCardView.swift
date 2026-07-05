//
//  ActivityCardView.swift
//  Bowl
//
//  활동량 card: a title, a hint, and three single-select activity options.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ActivityCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "활동량"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "평소 아이가 얼마나 활발하게 움직이나요?"
        label.font = AppFont.cardSubtitle
        label.textColor = AppColor.textTertiary
        return label
    }()

    private let optionCards = CatActivityLevel.allCases.map {
        SelectableOptionCard(value: $0, title: $0.title, subtitle: $0.subtitle, titleFont: AppFont.optionTitleLarge, cornerRadius: 10)
    }
    private let disposeBag = DisposeBag()

    private let selectionRelay = PublishRelay<CatActivityLevel>()
    var selectedActivity: Observable<CatActivityLevel> { selectionRelay.asObservable() }

    override init() {
        super.init()
        setupLayout()
        for card in optionCards {
            card.rx.controlEvent(.touchUpInside)
                .map { card.value }
                .bind(to: selectionRelay)
                .disposed(by: disposeBag)
        }
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: optionCards)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8

        [titleLabel, subtitleLabel, stack].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func setSelected(_ activity: CatActivityLevel) {
        optionCards.forEach { $0.setSelected($0.value == activity) }
    }
}
