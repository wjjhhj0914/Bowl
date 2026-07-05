//
//  AllergyCardView.swift
//  Bowl
//
//  알러지 card: an optional yes/no toggle. When turned on, an allergen
//  multi-select grid reveals itself and the card expands downward. The
//  switch row and the grid live in a vertical stack so hiding the grid
//  collapses its space automatically.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AllergyCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아이가 알러지가 있나요?"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let badge = OptionalBadgeView()

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = AppColor.primary
        return toggle
    }()

    private let switchRow = UIView()

    // Allergen chips are reused from the health-chip component (generic
    // labeled multi-select chip).
    private let allergenChips = CatAllergen.all.map { HealthChipView(concern: $0) }
    private let allergyGrid = UIStackView()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private let selectionRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()

    /// Emits when the switch is toggled.
    var allergyChanged: Observable<Bool> {
        toggle.rx.controlEvent(.valueChanged).withLatestFrom(toggle.rx.value)
    }
    /// Emits the tapped allergen.
    var toggledAllergen: Observable<String> { selectionRelay.asObservable() }

    override init() {
        super.init()
        setupLayout()
        bindChips()
        // Hidden until the switch is turned on.
        allergyGrid.isHidden = true
        allergyGrid.alpha = 0
    }

    private func setupLayout() {
        // Switch row: title + optional badge + toggle.
        [titleLabel, badge, toggle].forEach { switchRow.addSubview($0) }
        switchRow.snp.makeConstraints { $0.height.equalTo(40) }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        badge.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        // Allergen grid: equal-width rows of four.
        allergyGrid.axis = .vertical
        allergyGrid.spacing = 10
        stride(from: 0, to: allergenChips.count, by: 4).forEach { start in
            var rowItems: [UIView] = Array(allergenChips[start..<min(start + 4, allergenChips.count)])
            while rowItems.count < 4 { rowItems.append(UIView()) }
            let row = UIStackView(arrangedSubviews: rowItems)
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 8
            allergyGrid.addArrangedSubview(row)
        }

        contentStack.addArrangedSubview(switchRow)
        contentStack.addArrangedSubview(allergyGrid)
        addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func bindChips() {
        for chip in allergenChips {
            chip.rx.controlEvent(.touchUpInside)
                .map { chip.concern }
                .bind(to: selectionRelay)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - API

    func setOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }

    /// Shows/hides the allergen grid. The caller animates layout so the card
    /// (and scroll content) expands smoothly.
    func setSelectionHidden(_ hidden: Bool) {
        allergyGrid.isHidden = hidden
        allergyGrid.alpha = hidden ? 0 : 1
    }

    func setSelectedAllergens(_ allergens: Set<String>) {
        allergenChips.forEach { $0.setSelected(allergens.contains($0.concern)) }
    }
}
