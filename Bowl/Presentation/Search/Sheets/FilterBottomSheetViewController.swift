//
//  FilterBottomSheetViewController.swift
//  Bowl
//
//  사료 검색 filter sheet. Built on the app's edge-to-edge BottomSheetViewController
//  (grabber, drag-to-dismiss with rubber-banding, dimmed backdrop). Presents four
//  multi-select tag sections in a scroll view and, on 적용하기, emits the selected
//  filter keywords. Reuses the 건강 관심사 pill styling and the global press-scale
//  feedback for a consistent, tactile feel.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

// MARK: - Filter data

struct FilterTag {
    /// Descriptive label shown in the sheet (e.g. "키튼 (1세 미만)").
    let title: String
    /// Canonical keyword emitted and matched against a food (e.g. "키튼").
    let keyword: String
}

struct FilterSection {
    let title: String
    let tags: [FilterTag]
}

enum FilterCatalog {
    static let sections: [FilterSection] = [
        FilterSection(title: "성장 단계", tags: [
            FilterTag(title: "키튼 (1세 미만)", keyword: "키튼"),
            FilterTag(title: "어덜트 (1-7세)", keyword: "어덜트"),
            FilterTag(title: "시니어 (7세 이상)", keyword: "시니어"),
            FilterTag(title: "전연령", keyword: "전연령")
        ]),
        FilterSection(title: "주원료 단백질", tags: [
            FilterTag(title: "닭고기", keyword: "닭고기"),
            FilterTag(title: "연어", keyword: "연어"),
            FilterTag(title: "오리고기", keyword: "오리고기"),
            FilterTag(title: "칠면조", keyword: "칠면조"),
            FilterTag(title: "소/양고기", keyword: "소/양고기"),
            FilterTag(title: "가수분해", keyword: "가수분해")
        ]),
        FilterSection(title: "원료 특징", tags: [
            FilterTag(title: "그레인프리", keyword: "그레인프리"),
            FilterTag(title: "LID (단일원료)", keyword: "LID"),
            FilterTag(title: "인도어 (실내묘용)", keyword: "인도어"),
            FilterTag(title: "글루텐프리", keyword: "글루텐프리")
        ]),
        FilterSection(title: "기능/고민별", tags: [
            FilterTag(title: "체중조절", keyword: "체중조절"),
            FilterTag(title: "장/소화", keyword: "소화"),
            FilterTag(title: "헤어볼 관리", keyword: "헤어볼"),
            FilterTag(title: "요로/비뇨기", keyword: "비뇨기"),
            FilterTag(title: "피부/피모", keyword: "피부"),
            FilterTag(title: "관절/뼈", keyword: "관절")
        ])
    ]
}

// MARK: - View controller

final class FilterBottomSheetViewController: BottomSheetViewController {

    private let applyRelay = PublishRelay<[String]>()
    /// Emits the selected filter keywords, in section order, when 적용하기 is tapped.
    var didApplyFilters: Observable<[String]> { applyRelay.asObservable() }

    let disposeBag = DisposeBag()

    private let initiallySelected: Set<String>
    private var tagButtons: [FilterTagButton] = []

    /// Called when the sheet finishes disappearing (applied or dismissed).
    var onDismiss: (() -> Void)?

    // MARK: UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "필터 설정"
        label.font = AppFont.sheetTitle
        label.textColor = AppColor.textPrimary
        return label
    }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(AppColor.textTertiary, for: .normal)
        button.titleLabel?.font = AppFont.buttonTitle
        button.backgroundColor = AppColor.inputBackground
        button.layer.cornerRadius = 14
        return button
    }()

    private let applyButton = PrimaryButton(title: "적용하기")

    // MARK: Init

    init(selected: Set<String> = []) {
        self.initiallySelected = selected
        super.init(sheetHeight: 660)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Mask the pinned button row so it can't peek below the card while the
        // sheet slides up as one cohesive unit.
        sheetView.clipsToBounds = true
        setupLayout()
        resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }

    private func setupLayout() {
        let buttonRow = UIStackView(arrangedSubviews: [resetButton, applyButton])
        buttonRow.axis = .horizontal
        buttonRow.spacing = 10
        buttonRow.distribution = .fill

        [titleLabel, scrollView, buttonRow].forEach { sheetView.addSubview($0) }
        scrollView.addSubview(contentStack)
        FilterCatalog.sections.forEach { contentStack.addArrangedSubview(makeSectionView($0)) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(sheetView.snp.top).offset(30)
            make.leading.equalTo(sheetView).offset(24)
        }

        resetButton.snp.makeConstraints { $0.width.equalTo(96) }
        buttonRow.snp.makeConstraints { make in
            make.leading.equalTo(sheetView).offset(24)
            make.trailing.equalTo(sheetView).offset(-24)
            // Pin to the card's own safe area (not the main view) so the row
            // slides up with the card instead of flashing at the screen bottom.
            make.bottom.equalTo(sheetView.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(52)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(buttonRow.snp.top).offset(-16)
        }
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView.contentLayoutGuide)
            // Pin the width to the visible frame so the tag-flow rows can wrap.
            make.leading.equalTo(scrollView.frameLayoutGuide).offset(24)
            make.trailing.equalTo(scrollView.frameLayoutGuide).offset(-24)
        }
    }

    /// A section header plus its wrapping row of multi-select tags.
    private func makeSectionView(_ section: FilterSection) -> UIView {
        let header = UILabel()
        header.text = section.title
        header.font = AppFont.cardTitle
        header.textColor = AppColor.textSecondary

        let buttons = section.tags.map { tag -> FilterTagButton in
            let button = FilterTagButton(tag: tag)
            button.setSelected(initiallySelected.contains(tag.keyword), animated: false)
            button.addTarget(self, action: #selector(didTapTag(_:)), for: .touchUpInside)
            return button
        }
        tagButtons.append(contentsOf: buttons)

        let container = UIStackView(arrangedSubviews: [header, TagFlowView(buttons: buttons)])
        container.axis = .vertical
        container.spacing = 14
        return container
    }

    // MARK: Actions

    @objc private func didTapTag(_ sender: FilterTagButton) {
        sender.setSelected(!sender.isOn, animated: true)
    }

    @objc private func didTapReset() {
        tagButtons.forEach { $0.setSelected(false, animated: true) }
    }

    @objc private func didTapApply() {
        // Preserve section/tag order for stable chip ordering.
        let selected = tagButtons.filter(\.isOn).map(\.keyword)
        applyRelay.accept(selected)
        dismiss(animated: true)
    }
}

// MARK: - Tag button

/// A pill-shaped multi-select tag. Light gray with dark text when off, solid
/// blue with white text when on. Reuses the global press-scale feedback and a
/// cross-dissolve between states, matching the 건강 관심사 chips.
final class FilterTagButton: UIControl {

    let keyword: String
    private(set) var isOn = false

    private let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.optionTitle
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()

    private var hasStyledOnce = false

    init(tag: FilterTag) {
        self.keyword = tag.keyword
        super.init(frame: .zero)
        label.text = tag.title
        layer.cornerRadius = 18
        layer.masksToBounds = true

        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 32, height: 36)
    }

    @objc private func pressDown() { animatePressDown() }
    @objc private func pressUp() { animatePressUp() }

    func setSelected(_ selected: Bool, animated: Bool) {
        isOn = selected
        let apply = {
            self.backgroundColor = selected ? AppColor.primary : AppColor.inputBackground
            self.label.textColor = selected ? AppColor.onPrimary : AppColor.textSecondary
        }
        if animated && hasStyledOnce {
            UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
        hasStyledOnce = true
    }
}

// MARK: - Wrapping flow layout

/// Lays out tag buttons left-to-right, wrapping to the next line when they
/// exceed the available width, and self-sizes its height for a vertical stack.
final class TagFlowView: UIView {

    private let hSpacing: CGFloat = 8
    private let vSpacing: CGFloat = 10
    private let buttons: [FilterTagButton]
    private var computedHeight: CGFloat = 0

    init(buttons: [FilterTagButton]) {
        self.buttons = buttons
        super.init(frame: .zero)
        buttons.forEach { addSubview($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxWidth = bounds.width
        guard maxWidth > 0 else { return }

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for button in buttons {
            let size = button.intrinsicContentSize
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + vSpacing
                rowHeight = 0
            }
            button.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }

        let height = y + rowHeight
        if abs(height - computedHeight) > 0.5 {
            computedHeight = height
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: computedHeight)
    }
}
