//
//  BodyTypeCardView.swift
//  Bowl
//
//  체형 card: a title, a hint, and three selectable body-type options laid
//  out in an equal-width row.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BodyTypeCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "체형"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "눈으로 봤을 때 아이의 체형을 선택해 주세요"
        label.font = AppFont.cardSubtitle
        label.textColor = AppColor.textTertiary
        return label
    }()

    private let optionCards = CatBodyType.allCases.map { BodyTypeOptionCard(bodyType: $0) }
    private let disposeBag = DisposeBag()

    private let selectionRelay = PublishRelay<CatBodyType>()
    /// Emits when the user taps a body-type option.
    var selectedBodyType: Observable<CatBodyType> { selectionRelay.asObservable() }

    override init() {
        super.init()
        setupLayout()
        bindTaps()
    }

    private func setupLayout() {
        let optionStack = UIStackView(arrangedSubviews: optionCards)
        optionStack.axis = .horizontal
        optionStack.distribution = .fillEqually
        optionStack.spacing = 8

        [titleLabel, subtitleLabel, optionStack].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
        }

        optionStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func bindTaps() {
        for card in optionCards {
            card.rx.controlEvent(.touchUpInside)
                .map { card.bodyType }
                .bind(to: selectionRelay)
                .disposed(by: disposeBag)
        }
    }

    /// Updates the visual selection state.
    func setSelected(_ bodyType: CatBodyType) {
        optionCards.forEach { $0.setSelected($0.bodyType == bodyType) }
    }
}
