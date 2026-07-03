//
//  OnboardingViewController.swift
//  Bowl
//
//  "01 · 온보딩" — a 3-page horizontally-paged onboarding flow. The brand
//  wordmark (top), page control, and primary button stay fixed while the
//  illustration + headline + subtitle swipe inside a paged collection view.
//  Built 100% in code with SnapKit and bound to its view model via RxSwift.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: OnboardingViewModel

    /// Invoked when the user finishes onboarding. The parent/coordinator
    /// decides where to navigate next (e.g. the profile-registration flow).
    var onFinishOnboarding: (() -> Void)?

    // MARK: - State

    private var pages: [OnboardingPage] = []

    // MARK: - UI

    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Bowl"
        label.font = AppFont.brandTitle
        label.textColor = AppColor.primary
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let pageControl = OnboardingPageControl(numberOfPages: OnboardingPage.all.count)

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColor.onPrimary, for: .normal)
        button.titleLabel?.font = AppFont.buttonTitle
        button.backgroundColor = AppColor.primary
        button.layer.cornerRadius = 14
        return button
    }()

    // MARK: - Init

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep each page the exact size of the collection view for clean paging.
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Setup

    override func setupHierarchy() {
        [brandLabel, collectionView, pageControl, primaryButton].forEach { view.addSubview($0) }
    }

    override func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(67)
            make.centerX.equalToSuperview()
        }

        // Holds the swipeable illustration + title + subtitle. Height matches
        // the Figma content block (brand.bottom → subtitle.bottom).
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(369)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
            make.height.equalTo(8)
        }

        primaryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-12)
            make.height.equalTo(52)
        }
    }

    // MARK: - Binding

    override func bind() {
        let scrolledPage = collectionView.rx.didEndDecelerating
            .compactMap { [weak self] in self?.currentPageIndex() }

        let input = OnboardingViewModel.Input(
            pageChangedByScroll: scrolledPage,
            primaryButtonTapped: primaryButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        pages = output.pages
        collectionView.reloadData()

        output.currentPage
            .drive(with: self) { owner, page in
                owner.pageControl.currentPage = page
                owner.scrollToPageIfNeeded(page)
            }
            .disposed(by: disposeBag)

        output.primaryButtonTitle
            .drive(primaryButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        output.didFinishOnboarding
            .drive(with: self) { owner, _ in
                owner.onFinishOnboarding?()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Helpers

    private func currentPageIndex() -> Int {
        let width = collectionView.bounds.width
        guard width > 0 else { return 0 }
        return Int((collectionView.contentOffset.x + width / 2) / width)
    }

    /// Programmatically scrolls to `page` when the collection view isn't
    /// already there (e.g. the button advanced the page).
    private func scrollToPageIfNeeded(_ page: Int) {
        let width = collectionView.bounds.width
        guard width > 0 else { return }
        let targetX = CGFloat(page) * width
        guard abs(collectionView.contentOffset.x - targetX) > 1 else { return }
        collectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension OnboardingViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingPageCell.reuseID,
            for: indexPath
        )
        (cell as? OnboardingPageCell)?.configure(with: pages[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}
