//
//  HealthInterestCardView.swift
//  Bowl
//
//  건강 관심사 card: an optional multi-select grid of health-interest chips
//  laid out in equal-width rows of three.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HealthInterestCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "건강 관심사"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심 있는 건강 항목을 모두 선택해 주세요"
        label.font = AppFont.cardSubtitle
        label.textColor = AppColor.textTertiary
        return label
    }()

    private let badge = OptionalBadgeView()
    private let chips = CatHealthConcern.all.map { HealthChipView(concern: $0) }
    private let disposeBag = DisposeBag()

    private let selectionRelay = PublishRelay<String>()
    /// Emits the tapped concern (the view model resolves selection state).
    var toggledConcern: Observable<String> { selectionRelay.asObservable() }

    override init() {
        super.init()
        setupLayout()
        for chip in chips {
            chip.rx.controlEvent(.touchUpInside)
                .map { chip.concern }
                .bind(to: selectionRelay)
                .disposed(by: disposeBag)
        }
    }

    private func setupLayout() {
        let chipGrid = makeChipGrid()
        [titleLabel, badge, subtitleLabel, chipGrid].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        badge.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        chipGrid.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func makeChipGrid() -> UIStackView {
        // Chunk chips into equal-width rows of three (padding the last row).
        var rows: [UIView] = []
        stride(from: 0, to: chips.count, by: 3).forEach { start in
            var rowItems: [UIView] = Array(chips[start..<min(start + 3, chips.count)])
            while rowItems.count < 3 { rowItems.append(UIView()) }
            let rowStack = UIStackView(arrangedSubviews: rowItems)
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 8
            rows.append(rowStack)
        }

        let gridStack = UIStackView(arrangedSubviews: rows)
        gridStack.axis = .vertical
        gridStack.spacing = 10
        return gridStack
    }

    func setSelected(_ concerns: Set<String>) {
        chips.forEach { $0.setSelected(concerns.contains($0.concern)) }
    }
}
