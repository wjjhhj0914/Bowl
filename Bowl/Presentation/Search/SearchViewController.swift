//
//  SearchViewController.swift
//  Bowl
//
//  04 · 사료 검색 — search cat foods by brand / product (초성 supported),
//  narrow with filter chips, browse results, and bookmark. A fixed white
//  header (title, search field, filter row) sits above a scrolling result list.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {

    private let viewModel: SearchViewModel

    private let removeFilterRelay = PublishRelay<String>()
    private let applyFiltersRelay = PublishRelay<[String]>()
    private let bookmarkRelay = PublishRelay<Food>()

    /// The filters currently applied, mirrored so the sheet can pre-select them.
    private var currentFilters: [String] = []

    // MARK: - Header

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.surface
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "사료 검색"
        label.font = AppFont.navTitle
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let searchField: UITextField = {
        let field = UITextField()
        field.font = AppFont.fieldValue
        field.textColor = AppColor.textPrimary
        field.backgroundColor = AppColor.inputBackground
        field.layer.cornerRadius = 12
        field.attributedPlaceholder = NSAttributedString(
            string: "브랜드, 제품명으로 검색",
            attributes: [.foregroundColor: AppColor.placeholder, .font: AppFont.fieldValue]
        )
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        icon.tintColor = AppColor.placeholder
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 48))
        icon.frame = CGRect(x: 18, y: 16, width: 16, height: 16)
        leftView.addSubview(icon)
        field.leftView = leftView
        field.leftViewMode = .always
        return field
    }()

    private let filterScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        return scroll
    }()

    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let filterButton = FilterButton()

    private let headerDivider: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.divider
        return view
    }()

    // MARK: - Results

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.rowHeight = 136
        table.keyboardDismissMode = .onDrag
        table.showsVerticalScrollIndicator = false
        table.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
        table.register(FoodResultCell.self, forCellReuseIdentifier: FoodResultCell.reuseID)
        return table
    }()

    // MARK: - Empty state

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없어요"
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textTertiary
        label.textAlignment = .center
        return label
    }()

    private let resetFiltersButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "필터 초기화"
        config.image = UIImage(systemName: "arrow.counterclockwise",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        config.imagePadding = 6
        config.baseForegroundColor = AppColor.textSecondary
        config.cornerStyle = .capsule
        config.background.backgroundColor = AppColor.inputBackground
        config.background.strokeColor = AppColor.divider
        config.background.strokeWidth = 1
        config.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 18, bottom: 9, trailing: 18)
        var title = AttributeContainer()
        title.font = AppFont.subtitleBold
        config.attributedTitle = AttributedString("필터 초기화", attributes: title)

        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
    }()

    private let recommendationTitle: UILabel = {
        let label = UILabel()
        label.text = "우리 아이 맞춤 사료는 어때요?"
        label.font = AppFont.cardTitle
        label.textColor = AppColor.textSecondary
        return label
    }()

    private lazy var recommendationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 260, height: 96)
        layout.minimumLineSpacing = 12
        // First card lines up with the section title; scrolled cards glide to
        // the screen edges.
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.clipsToBounds = false // let card shadows breathe
        collection.register(RecommendationCell.self, forCellWithReuseIdentifier: RecommendationCell.reuseID)
        return collection
    }()

    // MARK: - Init

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    /// Empty-state title + reset button, stacked and centered so the reset
    /// button collapses cleanly when there are no filters to clear.
    private lazy var emptyTopStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyLabel, resetFiltersButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    override func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(countLabel)
        view.addSubview(emptyStateView)
        [emptyTopStack, recommendationTitle, recommendationCollectionView].forEach { emptyStateView.addSubview($0) }
        view.addSubview(headerView)
        [titleLabel, searchField, filterScrollView, headerDivider].forEach { headerView.addSubview($0) }
        filterScrollView.addSubview(filterStack)
        filterStack.addArrangedSubview(filterButton)
    }

    override func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(11)
            make.centerX.equalToSuperview()
        }
        searchField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        filterScrollView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
        filterStack.snp.makeConstraints { make in
            make.top.bottom.height.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        headerDivider.snp.makeConstraints { make in
            make.top.equalTo(filterScrollView.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerDivider)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(24)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyTopStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
            make.centerX.equalToSuperview()
        }
        recommendationTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyTopStack.snp.bottom).offset(40)
            // Aligns with the first card's left edge (sectionInset.left).
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        recommendationCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recommendationTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            // A touch over the 96pt card so the soft shadow isn't clipped.
            make.height.equalTo(104)
        }
    }

    // MARK: - Binding

    override func bind() {
        let input = SearchViewModel.Input(
            searchText: searchField.rx.text.orEmpty.asObservable(),
            removeFilter: removeFilterRelay.asObservable(),
            applyFilters: applyFiltersRelay.asObservable(),
            filterTapped: filterButton.rx.controlEvent(.touchUpInside).map { () }.asObservable(),
            bookmarkTapped: bookmarkRelay.asObservable(),
            foodSelected: Observable.merge(
                tableView.rx.modelSelected(FoodResult.self).map { $0.food },
                recommendationCollectionView.rx.modelSelected(Food.self).asObservable()
            )
        )
        let output = viewModel.transform(input: input)

        output.results
            .drive(tableView.rx.items(cellIdentifier: FoodResultCell.reuseID, cellType: FoodResultCell.self)) { [weak self] _, result, cell in
                cell.configure(with: result)
                cell.onBookmark = { self?.bookmarkRelay.accept(result.food) }
            }
            .disposed(by: disposeBag)

        // Swap the list for the recovery empty state when there are no results.
        output.results
            .map { !$0.isEmpty }
            .drive(emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)

        output.results
            .map { $0.isEmpty }
            .drive(tableView.rx.isHidden)
            .disposed(by: disposeBag)

        output.recommendations
            .drive(recommendationCollectionView.rx.items(
                cellIdentifier: RecommendationCell.reuseID,
                cellType: RecommendationCell.self
            )) { _, food, cell in
                cell.configure(with: food)
            }
            .disposed(by: disposeBag)

        // "필터 초기화" clears every active filter and reloads the full list.
        resetFiltersButton.rx.tap
            .map { [] }
            .bind(to: applyFiltersRelay)
            .disposed(by: disposeBag)

        output.resultCount
            .map { "\($0)개의 검색 결과" }
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)

        output.activeFilters
            .drive(with: self) { owner, filters in
                owner.currentFilters = filters
                owner.rebuildFilterChips(filters)
                owner.filterButton.isActive = !filters.isEmpty
                // Only offer "필터 초기화" when there's actually a filter to clear.
                owner.resetFiltersButton.isHidden = filters.isEmpty
            }
            .disposed(by: disposeBag)

        output.route
            .drive(with: self) { owner, route in
                owner.handle(route)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Helpers

    /// Rebuilds the active-filter chips, keeping the trailing 필터 button last.
    private func rebuildFilterChips(_ filters: [String]) {
        filterStack.arrangedSubviews
            .filter { $0 is ActiveFilterChipView }
            .forEach { $0.removeFromSuperview() }

        for (index, filter) in filters.enumerated() {
            let chip = ActiveFilterChipView(title: filter)
            chip.onRemove = { [weak self] in self?.removeFilterRelay.accept(filter) }
            filterStack.insertArrangedSubview(chip, at: index)
        }
    }

    private func handle(_ route: SearchRoute) {
        switch route {
        case .detail(let food):
            // 05 · 사료 상세 분석 isn't built yet — push a placeholder for now.
            navigationController?.pushViewController(
                PlaceholderViewController(name: food.product), animated: true
            )
        case .filter:
            presentFilterSheet()
        }
    }

    private func presentFilterSheet() {
        let sheet = FilterBottomSheetViewController(selected: Set(currentFilters))
        sheet.didApplyFilters
            .take(1) // one apply per presentation; ties off with the sheet
            .bind(to: applyFiltersRelay)
            .disposed(by: sheet.disposeBag)
        // Keep the pill highlighted while the sheet is open, then reflect the
        // applied-filter state once it closes.
        filterButton.isActive = true
        sheet.onDismiss = { [weak self] in
            guard let self else { return }
            self.filterButton.isActive = !self.currentFilters.isEmpty
        }
        present(sheet, animated: true)
    }
}
