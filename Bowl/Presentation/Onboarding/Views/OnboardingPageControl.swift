//
//  OnboardingPageControl.swift
//  Bowl
//
//  Custom page indicator. The active page is a rounded pill (26×8), the
//  inactive pages are 8×8 dots, laid out horizontally with 4pt spacing —
//  matching the Figma onboarding design.
//

import UIKit
import SnapKit

final class OnboardingPageControl: UIView {

    private let dotSize: CGFloat = 8
    private let activeWidth: CGFloat = 26
    private let spacing: CGFloat = 4

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private var dots: [UIView] = []

    private let numberOfPages: Int

    /// Currently highlighted page. Updating it re-styles the dots.
    var currentPage: Int = 0 {
        didSet { updateStyles() }
    }

    init(numberOfPages: Int, currentPage: Int = 0) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
        super.init(frame: .zero)
        stackView.spacing = spacing
        setupHierarchy()
        updateStyles()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.cornerRadius = dotSize / 2
            dots.append(dot)
            stackView.addArrangedSubview(dot)
        }
    }

    private func updateStyles() {
        for (index, dot) in dots.enumerated() {
            let isActive = index == currentPage
            dot.backgroundColor = isActive ? AppColor.primary : AppColor.indicatorInactive
            dot.snp.remakeConstraints { make in
                make.height.equalTo(dotSize)
                make.width.equalTo(isActive ? activeWidth : dotSize)
            }
        }
    }
}
