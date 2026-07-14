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

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없어요"
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textTertiary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Init

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(countLabel)
        view.addSubview(emptyLabel)
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
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView).offset(80)
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
            foodSelected: tableView.rx.modelSelected(FoodResult.self).map { $0.food }.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.results
            .drive(tableView.rx.items(cellIdentifier: FoodResultCell.reuseID, cellType: FoodResultCell.self)) { [weak self] _, result, cell in
                cell.configure(with: result)
                cell.onBookmark = { self?.bookmarkRelay.accept(result.food) }
            }
            .disposed(by: disposeBag)

        output.results
            .map { !$0.isEmpty }
            .drive(emptyLabel.rx.isHidden)
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
