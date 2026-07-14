//
//  HomeViewController.swift
//  Bowl
//
//  "03 · 홈 대시보드" — the home tab. A fixed header over a scroll view with
//  the profile summary card, the current-food card, and a 2×2 quick-actions
//  grid. Built 100% in code with SnapKit, bound via RxSwift.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: HomeViewModel

    /// Routes header / quick-action taps to the coordinator.
    var onRoute: ((HomeRoute) -> Void)?

    private let profileTapRelay = PublishRelay<Void>()

    // MARK: - UI

    private let headerView = HomeHeaderView()
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    private let contentView = UIView()

    private let profileCard = ProfileSummaryCardView()

    private let foodSectionTitle = HomeViewController.makeSectionTitle("현재 급여 중인 사료")
    private let foodCard = CurrentFoodCardView()
    private let emptyFoodView = EmptyFoodStateView()

    /// Holds the food card and the empty state; only one is visible at a time,
    /// so the stack sizes to whichever is shown.
    private lazy var foodContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [foodCard, emptyFoodView])
        stack.axis = .vertical
        return stack
    }()

    private let quickSectionTitle = HomeViewController.makeSectionTitle("빠른 실행")
    private let quickActionCards = HomeQuickAction.allCases.map { QuickActionCardView(action: $0) }

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(headerView)
        scrollView.addSubview(contentView)
        [profileCard, foodSectionTitle, foodContainer, quickSectionTitle, quickActionGrid()].forEach { contentView.addSubview($0) }

        // Tapping the profile card opens profile editing.
        profileCard.isUserInteractionEnabled = true
        profileCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileCard)))
    }

    @objc private func didTapProfileCard() {
        profileTapRelay.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Home uses its own custom header, so keep the system nav bar hidden.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private lazy var grid: UIStackView = {
        let rows = stride(from: 0, to: quickActionCards.count, by: 2).map { start -> UIStackView in
            let row = UIStackView(arrangedSubviews: Array(quickActionCards[start..<min(start + 2, quickActionCards.count)]))
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 13
            return row
        }
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private func quickActionGrid() -> UIStackView { grid }

    override func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        profileCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(180)
        }
        foodSectionTitle.snp.makeConstraints { make in
            make.top.equalTo(profileCard.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        foodContainer.snp.makeConstraints { make in
            make.top.equalTo(foodSectionTitle.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        quickSectionTitle.snp.makeConstraints { make in
            make.top.equalTo(foodContainer.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        grid.snp.makeConstraints { make in
            make.top.equalTo(quickSectionTitle.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    // MARK: - Binding

    override func bind() {
        let quickActionTapped = Observable.merge(
            quickActionCards.map { card in
                card.rx.controlEvent(.touchUpInside).map { card.action }
            }
        )

        let input = HomeViewModel.Input(
            settingsTapped: headerView.settingsButton.rx.tap.asObservable(),
            profileTapped: profileTapRelay.asObservable(),
            foodDetailTapped: foodCard.detailButton.rx.tap.asObservable(),
            registerFoodTapped: emptyFoodView.rx.controlEvent(.touchUpInside).map { () }.asObservable(),
            quickActionTapped: quickActionTapped
        )
        let output = viewModel.transform(input: input)

        output.display
            .drive(with: self) { owner, display in
                owner.profileCard.configure(
                    name: display.name,
                    subtitle: display.subtitle,
                    calorie: display.calorie,
                    water: display.water
                )
            }
            .disposed(by: disposeBag)

        // Swap between the food card and the empty state.
        output.currentFood
            .drive(with: self) { owner, food in
                owner.foodCard.isHidden = food == nil
                owner.emptyFoodView.isHidden = food != nil
                if let food {
                    owner.foodCard.configure(
                        brand: food.brand,
                        product: food.product,
                        type: food.type,
                        protein: food.proteinText
                    )
                }
            }
            .disposed(by: disposeBag)

        output.route
            .drive(with: self) { owner, route in
                switch route {
                case .editProfile:
                    // Home is embedded in a navigation controller — push cleanly.
                    owner.navigationController?.pushViewController(ProfileEditViewController(), animated: true)
                case .registerFood:
                    // Guide the user to the search tab to register their first food.
                    owner.tabBarController?.selectedIndex = 1
                default:
                    owner.onRoute?(route)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Helpers

    private static func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFont.navTitle
        label.textColor = AppColor.textSecondary
        return label
    }
}
