//
//  HomeViewModel.swift
//  Bowl
//
//  View model for the home dashboard. Derives the display data from the cat
//  profile (name, life stage, recommended calories/water computed from
//  weight) and routes header / quick-action taps.
//

import Foundation
import RxSwift
import RxCocoa

struct HomeDisplay {
    let name: String
    let subtitle: String
    let calorie: String
    let water: String
    let foodBrand: String
    let foodProduct: String
    let foodType: String
    let foodProtein: String
}

enum HomeRoute {
    case settings
    case foodDetail
    case editProfile
    case quickAction(HomeQuickAction)
}

final class HomeViewModel: ViewModelType {

    struct Input {
        let settingsTapped: Observable<Void>
        let profileTapped: Observable<Void>
        let foodDetailTapped: Observable<Void>
        let quickActionTapped: Observable<HomeQuickAction>
    }

    struct Output {
        let display: Driver<HomeDisplay>
        let route: Driver<HomeRoute>
    }

    private let storage: ProfileStoring

    init(storage: ProfileStoring = UserDefaultsProfileStorage.shared) {
        self.storage = storage
    }

    func transform(input: Input) -> Output {
        let display = Driver.just(makeDisplay())

        let route = Observable
            .merge(
                input.settingsTapped.map { HomeRoute.settings },
                input.profileTapped.map { HomeRoute.editProfile },
                input.foodDetailTapped.map { HomeRoute.foodDetail },
                input.quickActionTapped.map { HomeRoute.quickAction($0) }
            )
            .asDriver(onErrorDriveWith: .empty())

        return Output(display: display, route: route)
    }

    // MARK: - Derivation

    private func makeDisplay() -> HomeDisplay {
        // Fetch the profile saved during onboarding/registration.
        let profile = storage.load()

        let weight = profile?.weight ?? 4.5
        let stage = profile?.birthday.map { CatAgeInfo(birthday: $0).stage } ?? "성묘"
        let name = (profile?.name).flatMap { $0.isEmpty ? nil : $0 } ?? "우리 아이"

        return HomeDisplay(
            name: name,
            subtitle: "\(stage) · \(Self.formatWeight(weight))kg",
            calorie: "\(Self.recommendedCalorie(weight))kcal",
            water: "\(Self.recommendedWater(weight))ml",
            // Demo data until food records are implemented.
            foodBrand: "로얄캐닌",
            foodProduct: "인도어 어덜트",
            foodType: "건식",
            foodProtein: "조단백 32%"
        )
    }

    /// Maintenance energy: RER (70·kg^0.75) × 1.15 (neutered indoor factor).
    private static func recommendedCalorie(_ weight: Double) -> Int {
        Int((70 * pow(weight, 0.75) * 1.15).rounded())
    }

    /// Daily water need ≈ 44.4 ml per kg.
    private static func recommendedWater(_ weight: Double) -> Int {
        Int((weight * 44.4).rounded())
    }

    private static func formatWeight(_ weight: Double) -> String {
        weight == weight.rounded() ? String(Int(weight)) : String(format: "%.1f", weight)
    }
}
