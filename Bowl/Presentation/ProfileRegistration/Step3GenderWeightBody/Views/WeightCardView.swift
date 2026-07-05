//
//  WeightCardView.swift
//  Bowl
//
//  몸무게 card: an emphasized value, a custom-styled slider (8pt rounded
//  track with a blue fill and a white thumb), min/max bounds, and a "직접
//  작성하기" button for manual entry. A native UISlider drives the thumb and
//  dragging; the rounded track is drawn behind it.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WeightCardView: ProfileCardView {

    static let minWeight: Float = 1
    static let maxWeight: Float = 10

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "몸무게"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.valueEmphasis
        label.textColor = AppColor.primary
        label.textAlignment = .right
        return label
    }()

    private let trackBackground: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.divider
        view.layer.cornerRadius = 4
        return view
    }()

    private let trackFill: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.primary
        view.layer.cornerRadius = 4
        return view
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = minWeight
        slider.maximumValue = maxWeight
        slider.setMinimumTrackImage(UIImage(), for: .normal)
        slider.setMaximumTrackImage(UIImage(), for: .normal)
        slider.setThumbImage(WeightCardView.makeThumbImage(), for: .normal)
        return slider
    }()

    private let minLabel = WeightCardView.makeBoundLabel("1 kg")
    private let maxLabel = WeightCardView.makeBoundLabel("10 kg")

    private let manualButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = AppColor.inputBackground
        config.baseForegroundColor = AppColor.textSecondary
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        var title = AttributedString("직접 작성하기")
        title.font = AppFont.caption
        config.attributedTitle = title
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private var fillWidthConstraint: Constraint?

    // MARK: - Exposed streams

    /// Emits the slider value as the user drags. `skip(1)` drops the initial
    /// ControlProperty emission so it doesn't overwrite the view model's default.
    var weightChanged: Observable<Float> { slider.rx.value.skip(1).asObservable() }
    /// Emits when the manual-entry button is tapped.
    var manualEntryTapped: Observable<Void> { manualButton.rx.tap.asObservable() }

    // MARK: - Init

    override init() {
        super.init()
        setupLayout()
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }

    private func setupLayout() {
        [titleLabel, valueLabel, trackBackground, trackFill, slider, minLabel, maxLabel, manualButton]
            .forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }

        trackBackground.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(54)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(8)
        }

        trackFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(trackBackground)
            fillWidthConstraint = make.width.equalTo(0).constraint
        }

        slider.snp.makeConstraints { make in
            make.leading.trailing.equalTo(trackBackground)
            make.centerY.equalTo(trackBackground)
        }

        minLabel.snp.makeConstraints { make in
            make.top.equalTo(trackBackground.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
        }

        maxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(minLabel)
            make.trailing.equalToSuperview().offset(-16)
        }

        manualButton.snp.makeConstraints { make in
            make.top.equalTo(minLabel.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFill()
    }

    // MARK: - API

    /// Positions the slider (e.g. after manual entry) without emitting a change.
    func setSliderValue(_ value: Float) {
        slider.value = value
        updateFill()
    }

    /// Sets the emphasized value text (e.g. "4.5 kg").
    func setValueText(_ text: String) {
        valueLabel.text = text
    }

    // MARK: - Helpers

    @objc private func sliderChanged() {
        updateFill()
    }

    private func updateFill() {
        let range = slider.maximumValue - slider.minimumValue
        let fraction = range > 0 ? (slider.value - slider.minimumValue) / range : 0
        fillWidthConstraint?.update(offset: CGFloat(fraction) * trackBackground.bounds.width)
    }

    private static func makeBoundLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFont.caption
        label.textColor = AppColor.textTertiary
        return label
    }

    private static func makeThumbImage() -> UIImage {
        let diameter: CGFloat = 20
        let padding: CGFloat = 3
        let size = CGSize(width: diameter + padding * 2, height: diameter + padding * 2)
        return UIGraphicsImageRenderer(size: size).image { context in
            let rect = CGRect(x: padding, y: padding, width: diameter, height: diameter)
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 1),
                blur: 3,
                color: UIColor.black.withAlphaComponent(0.25).cgColor
            )
            AppColor.surface.setFill()
            UIBezierPath(ovalIn: rect).fill()
        }
    }
}
