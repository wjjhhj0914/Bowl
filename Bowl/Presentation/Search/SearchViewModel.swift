//
//  SearchViewModel.swift
//  Bowl
//
//  View model for the 사료 검색 screen. Filters the food catalog by the search
//  query (with 초성 support) and the active filter chips, tracks bookmarked
//  foods, and routes taps to detail / the filter sheet.
//

import Foundation
import RxSwift
import RxCocoa

/// A catalog food paired with its current bookmark state, for the result list.
struct FoodResult {
    let food: Food
    let isSaved: Bool
}

enum SearchRoute {
    case detail(Food)
    case filter
}

final class SearchViewModel: ViewModelType {

    struct Input {
        let searchText: Observable<String>
        let removeFilter: Observable<String>
        let applyFilters: Observable<[String]>
        let filterTapped: Observable<Void>
        let bookmarkTapped: Observable<Food>
        let foodSelected: Observable<Food>
    }

    struct Output {
        let results: Driver<[FoodResult]>
        let resultCount: Driver<Int>
        let activeFilters: Driver<[String]>
        let route: Driver<SearchRoute>
    }

    private let allFoods: [Food]
    private let activeFilters: BehaviorRelay<[String]>
    private let savedIDs = BehaviorRelay<Set<String>>(value: [])

    init(foods: [Food] = FoodCatalog.all, activeFilters: [String] = []) {
        self.allFoods = foods
        self.activeFilters = BehaviorRelay(value: activeFilters)
    }

    func transform(input: Input) -> Output {
        let query = input.searchText.startWith("")

        // Replace the active filters wholesale when the sheet applies.
        input.applyFilters
            .bind(to: activeFilters)
            .disposed(by: disposeBag)

        // Remove a filter chip when its ✕ is tapped.
        input.removeFilter
            .withLatestFrom(activeFilters) { removed, current in
                current.filter { $0 != removed }
            }
            .bind(to: activeFilters)
            .disposed(by: disposeBag)

        // Toggle a food's bookmark state.
        input.bookmarkTapped
            .withLatestFrom(savedIDs) { food, saved in
                var updated = saved
                if updated.contains(food.id) {
                    updated.remove(food.id)
                } else {
                    updated.insert(food.id)
                }
                return updated
            }
            .bind(to: savedIDs)
            .disposed(by: disposeBag)

        let filtered = Observable
            .combineLatest(query, activeFilters) { [allFoods] query, filters in
                Self.filter(allFoods, query: query, filters: filters)
            }
            .share(replay: 1)

        let results = Observable
            .combineLatest(filtered, savedIDs) { foods, saved in
                foods.map { FoodResult(food: $0, isSaved: saved.contains($0.id)) }
            }
            .asDriver(onErrorJustReturn: [])

        let resultCount = filtered
            .map(\.count)
            .asDriver(onErrorJustReturn: 0)

        let route = Observable
            .merge(
                input.foodSelected.map { SearchRoute.detail($0) },
                input.filterTapped.map { SearchRoute.filter }
            )
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            results: results,
            resultCount: resultCount,
            activeFilters: activeFilters.asDriver(),
            route: route
        )
    }

    // MARK: - Filtering

    private let disposeBag = DisposeBag()

    private static func filter(_ foods: [Food], query: String, filters: [String]) -> [Food] {
        foods.filter { food in
            matchesQuery(food, query: query) && matchesFilters(food, filters: filters)
        }
    }

    /// Substring match on brand/product, with 초성-only queries (e.g. "ㄹㅋ")
    /// matched against the initials of the food's brand and product.
    private static func matchesQuery(_ food: Food, query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }

        if trimmed.isChosungOnly {
            let initials = (food.brand + food.product).toChosung()
            return initials.contains(trimmed)
        }
        return food.searchableText.contains(trimmed.lowercased())
    }

    /// A food passes when it carries every active filter keyword (AND).
    private static func matchesFilters(_ food: Food, filters: [String]) -> Bool {
        filters.allSatisfy { filter in
            food.filterKeywords.contains { $0.caseInsensitiveCompare(filter) == .orderedSame }
        }
    }
}
