//
//  BreedPickerViewController.swift
//  Bowl
//
//  묘종 bottom sheet: a grabber, title, search field, and a searchable list
//  of breeds. Presented as a native sheet (dimmed backdrop, rounded top,
//  grabber). Selecting a breed reports it back and dismisses.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BreedPickerViewController: BottomSheetViewController {

    /// Called with the chosen breed.
    var onSelect: ((String) -> Void)?

    private let allBreeds = CatBreed.all
    private let filteredBreeds = BehaviorRelay<[String]>(value: CatBreed.all)
    private let disposeBag = DisposeBag()

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "묘종을 선택해 주세요"
        label.font = AppFont.sheetTitle
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let searchField: UITextField = {
        let field = UITextField()
        field.font = AppFont.fieldValue
        field.textColor = AppColor.textPrimary
        field.backgroundColor = AppColor.searchFieldBackground
        field.layer.cornerRadius = 12
        field.attributedPlaceholder = NSAttributedString(
            string: "묘종 검색",
            attributes: [.foregroundColor: AppColor.placeholder, .font: AppFont.fieldValue]
        )
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        icon.tintColor = AppColor.placeholder
        icon.contentMode = .center
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 44))
        icon.frame = CGRect(x: 14, y: 15, width: 14, height: 14)
        leftView.addSubview(icon)
        field.leftView = leftView
        field.leftViewMode = .always
        return field
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        table.rowHeight = 55
        table.backgroundColor = .clear
        table.keyboardDismissMode = .onDrag
        // Removes the separator below the final row (and any empty-cell separators).
        table.tableFooterView = UIView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "BreedCell")
        return table
    }()

    // MARK: - Init

    init() {
        super.init(sheetHeight: 520)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }

    private func setupLayout() {
        [titleLabel, searchField, tableView].forEach { sheetView.addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(sheetView.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }

        searchField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(sheetView).offset(24)
            make.trailing.equalTo(sheetView).offset(-24)
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalTo(sheetView)
        }
    }

    // MARK: - Binding

    private func bind() {
        // Filter breeds by search text (case-insensitive substring).
        searchField.rx.text.orEmpty
            .map { [allBreeds] query in
                let trimmed = query.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return allBreeds }
                return allBreeds.filter { $0.localizedCaseInsensitiveContains(trimmed) }
            }
            .bind(to: filteredBreeds)
            .disposed(by: disposeBag)

        filteredBreeds
            .bind(to: tableView.rx.items(cellIdentifier: "BreedCell")) { _, breed, cell in
                var content = cell.defaultContentConfiguration()
                content.text = breed
                content.textProperties.font = AppFont.listRow
                content.textProperties.color = AppColor.textSecondary
                cell.contentConfiguration = content
                cell.backgroundColor = .clear
                cell.selectionStyle = .default
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(String.self)
            .bind(with: self) { owner, breed in
                owner.onSelect?(breed)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
