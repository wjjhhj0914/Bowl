//
//  GenderCardView.swift
//  Bowl
//
//  성별 card: a two-option segmented selector (암컷 / 수컷). The selected
//  option is filled blue with white text; the other is a light gray pill.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GenderCardView: ProfileCardView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let femaleButton = GenderCardView.makeOptionButton(title: CatGender.female.title)
    private let maleButton = GenderCardView.makeOptionButton(title: CatGender.male.title)

    private let selectionRelay = PublishRelay<CatGender>()
    /// Emits when the user taps a gender option.
    var selectedGender: Observable<CatGender> { selectionRelay.asObservable() }

    private var hasStyledOnce = false

    override init() {
        super.init()
        setupLayout()
        femaleButton.addTarget(self, action: #selector(didTapFemale), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(didTapMale), for: .touchUpInside)

        // Tactile press feedback on both options.
        [femaleButton, maleButton].forEach { button in
            button.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }

    @objc private func pressDown(_ sender: UIView) { sender.animatePressDown() }
    @objc private func pressUp(_ sender: UIView) { sender.animatePressUp() }

    private static func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.segmentTitle
        button.layer.cornerRadius = 12
        return button
    }

    private func setupLayout() {
        [titleLabel, femaleButton, maleButton].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        femaleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }

        maleButton.snp.makeConstraints { make in
            make.top.height.equalTo(femaleButton)
            make.leading.equalTo(femaleButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(femaleButton)
        }
    }

    /// Updates the visual selection state, gliding the colors between choices.
    func setSelected(_ gender: CatGender) {
        // First paint (on load) is instant; later changes animate.
        let animated = hasStyledOnce
        hasStyledOnce = true
        style(femaleButton, isSelected: gender == .female, animated: animated)
        style(maleButton, isSelected: gender == .male, animated: animated)
    }

    private func style(_ button: UIButton, isSelected: Bool, animated: Bool) {
        // Cross-dissolve so both the background and the (otherwise
        // non-animatable) title color fade smoothly.
        let apply = {
            button.backgroundColor = isSelected ? AppColor.primary : AppColor.inputBackground
            button.setTitleColor(isSelected ? AppColor.onPrimary : AppColor.textSecondary, for: .normal)
        }
        if animated {
            UIView.transition(with: button, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
    }

    @objc private func didTapFemale() { selectionRelay.accept(.female) }
    @objc private func didTapMale() { selectionRelay.accept(.male) }
}
