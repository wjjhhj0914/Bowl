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
}

enum HomeRoute {
    case settings
    case foodDetail
    case editProfile
    case registerFood
    case quickAction(HomeQuickAction)
}

final class HomeViewModel: ViewModelType {

    struct Input {
        let settingsTapped: Observable<Void>
        let profileTapped: Observable<Void>
        let foodDetailTapped: Observable<Void>
        let registerFoodTapped: Observable<Void>
        let quickActionTapped: Observable<HomeQuickAction>
    }

    struct Output {
        let display: Driver<HomeDisplay>
        /// nil → show the empty state; non-nil → show the food card.
        let currentFood: Driver<Food?>
        let route: Driver<HomeRoute>
    }

    private let storage: ProfileStoring
    /// The food the cat is currently being fed (nil until one is registered).
    private let currentFood: BehaviorRelay<Food?>

    init(storage: ProfileStoring = UserDefaultsProfileStorage.shared, currentFood: Food? = nil) {
        self.storage = storage
        self.currentFood = BehaviorRelay(value: currentFood)
    }

    func transform(input: Input) -> Output {
        let display = Driver.just(makeDisplay())

        let route = Observable
            .merge(
                input.settingsTapped.map { HomeRoute.settings },
                input.profileTapped.map { HomeRoute.editProfile },
                input.foodDetailTapped.map { HomeRoute.foodDetail },
                input.registerFoodTapped.map { HomeRoute.registerFood },
                input.quickActionTapped.map { HomeRoute.quickAction($0) }
            )
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            display: display,
            currentFood: currentFood.asDriver(),
            route: route
        )
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
            calorie: "\(Self.recommendedCalorie(weight: weight, birthday: profile?.birthday))kcal",
            water: "\(Self.recommendedWater(weight))ml"
        )
    }

    /// Daily Energy Requirement (DER) = RER × life-stage factor.
    /// RER = 70 · kg^0.75.
    private static func recommendedCalorie(weight: Double, birthday: Date?) -> Int {
        let rer = 70.0 * pow(weight, 0.75)
        return Int(rer * energyFactor(birthday: birthday))
    }

    /// Multiplying factor by life stage:
    ///   자묘 < 4개월 → 3.0, 자묘 4~12개월 → 2.0,
    ///   성묘 중성화 → 1.2, 성묘 미중성화 → 1.4.
    private static func energyFactor(birthday: Date?) -> Double {
        // Neutered status isn't collected in the profile yet — assume neutered
        // (the common case) for adults. Add a profile field to refine this.
        let isNeutered = true

        guard let birthday else { return isNeutered ? 1.2 : 1.4 }
        let months = Calendar.current.dateComponents([.month], from: birthday, to: Date()).month ?? 12

        switch months {
        case ..<4:
            return 3.0
        case 4..<12:
            return 2.0
        default:
            return isNeutered ? 1.2 : 1.4
        }
    }

    /// Daily water target ≈ 55 ml per kg.
    private static func recommendedWater(_ weight: Double) -> Int {
        Int(weight * 55.0)
    }

    private static func formatWeight(_ weight: Double) -> String {
        weight == weight.rounded() ? String(Int(weight)) : String(format: "%.1f", weight)
    }
}
