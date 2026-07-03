//
//  OnboardingIllustrationView.swift
//  Bowl
//
//  The center graphic of the onboarding screen: a soft periwinkle circle
//  holding a bowl emoji, with two floating icon chips (chart at the
//  bottom-left, cat at the top-right).
//
//  Coordinate reference from Figma (frame-local, origin at the graphic's
//  top-left 109,230 → normalized to 0,0):
//    • circle   : (18, 21)  size 125
//    • bowl 🥣  : centered on the circle, 50pt
//    • chart chip: (0, 96)  size 64   → asset "Analyze"
//    • cat chip  : (99, 0)  size 64   → asset "Cat"
//  Total bounding box: 163 × 160.
//

import UIKit
import SnapKit

final class OnboardingIllustrationView: UIView {

    static let designSize = CGSize(width: 163, height: 160)

    private let circleView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.illustrationCircle
        v.layer.cornerRadius = 125 / 2
        return v
    }()

    private let bowlLabel: UILabel = {
        let label = UILabel()
        label.text = "🥣"
        label.font = .systemFont(ofSize: 50, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var chartChip = IconChipView(image: UIImage(named: "Analyze"))
    private lazy var catChip = IconChipView(image: UIImage(named: "Cat"))

    init() {
        super.init(frame: .zero)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        addSubview(circleView)
        circleView.addSubview(bowlLabel)
        addSubview(chartChip)
        addSubview(catChip)
    }

    private func setupLayout() {
        snp.makeConstraints { $0.size.equalTo(Self.designSize) }

        circleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(21)
            make.leading.equalToSuperview().offset(18)
            make.size.equalTo(125)
        }

        bowlLabel.snp.makeConstraints { $0.center.equalTo(circleView) }

        chartChip.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(96)
        }

        catChip.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}
