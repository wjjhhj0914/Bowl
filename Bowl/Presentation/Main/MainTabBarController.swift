//
//  MainTabBarController.swift
//  Bowl
//
//  The app shell after profile registration: 홈 / 검색 / 스캔 / 기록 / 마이.
//  Only 홈 is implemented; the rest are placeholders for now.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let profile: CatProfileDraft

    init(profile: CatProfileDraft) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureTabs()
    }

    private func configureTabs() {
        let home = HomeViewController(viewModel: HomeViewModel(profile: profile))
        home.onRoute = { route in
            // TODO: Route to search / scan / compare / record / settings.
            print("Home route → \(route)")
        }

        viewControllers = [
            tab(home, title: "홈", symbol: "house.fill"),
            tab(PlaceholderViewController(name: "검색"), title: "검색", symbol: "magnifyingglass"),
            tab(PlaceholderViewController(name: "스캔"), title: "스캔", symbol: "barcode.viewfinder"),
            tab(PlaceholderViewController(name: "기록"), title: "기록", symbol: "list.bullet.clipboard.fill"),
            tab(PlaceholderViewController(name: "마이"), title: "마이", symbol: "person.fill")
        ]
    }

    private func tab(_ controller: UIViewController, title: String, symbol: String) -> UIViewController {
        controller.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: symbol),
            selectedImage: UIImage(systemName: symbol)
        )
        return controller
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.surface
        appearance.shadowColor = AppColor.headerDivider

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppColor.primary
        tabBar.unselectedItemTintColor = AppColor.textTertiary
    }
}
