//
//  ProfileActivityHealthViewModel.swift
//  Bowl
//
//  View model for profile step 4 (활동량 & 건강 & 알러지) — the final step.
//  Tracks activity level (required, defaulted), the optional multi-select
//  health concerns, and the allergy toggle, then emits the completed profile.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileActivityHealthViewModel: ViewModelType {

    struct Input {
        let activitySelected: Observable<CatActivityLevel>
        let healthConcernToggled: Observable<String>
        let allergyToggled: Observable<Bool>
        let allergenToggled: Observable<String>
        let doneTapped: Observable<Void>
    }

    struct Output {
        let activity: Driver<CatActivityLevel>
        let healthConcerns: Driver<Set<String>>
        let hasAllergy: Driver<Bool>
        let allergens: Driver<Set<String>>
        /// Emits the finished profile when the user taps "완료".
        let didComplete: Driver<CatProfileDraft>
    }

    private let initialDraft: CatProfileDraft
    private let activityRelay: BehaviorRelay<CatActivityLevel>
    private let healthRelay: BehaviorRelay<Set<String>>
    private let allergyRelay: BehaviorRelay<Bool>
    private let allergensRelay: BehaviorRelay<Set<String>>
    private let disposeBag = DisposeBag()

    init(draft: CatProfileDraft) {
        self.initialDraft = draft
        activityRelay = BehaviorRelay(value: draft.activityLevel ?? .medium)
        healthRelay = BehaviorRelay(value: draft.healthConcerns)
        allergyRelay = BehaviorRelay(value: draft.hasAllergy)
        allergensRelay = BehaviorRelay(value: draft.allergens)
    }

    func transform(input: Input) -> Output {
        input.activitySelected
            .bind(to: activityRelay)
            .disposed(by: disposeBag)

        input.allergyToggled
            .bind(to: allergyRelay)
            .disposed(by: disposeBag)

        // Turning the allergy switch off clears any chosen allergens.
        input.allergyToggled
            .filter { !$0 }
            .map { _ in Set<String>() }
            .bind(to: allergensRelay)
            .disposed(by: disposeBag)

        // Toggle an allergen in/out of the set.
        input.allergenToggled
            .withLatestFrom(allergensRelay) { allergen, current in
                var set = current
                if set.contains(allergen) { set.remove(allergen) } else { set.insert(allergen) }
                return set
            }
            .bind(to: allergensRelay)
            .disposed(by: disposeBag)

        // Toggle a concern in/out of the set. "없음" is mutually exclusive with
        // the real concerns.
        input.healthConcernToggled
            .withLatestFrom(healthRelay) { concern, current in
                Self.toggle(concern, in: current)
            }
            .bind(to: healthRelay)
            .disposed(by: disposeBag)

        let didComplete = input.doneTapped
            .withLatestFrom(Observable.combineLatest(activityRelay, healthRelay, allergyRelay, allergensRelay))
            .map { [initialDraft] activity, concerns, hasAllergy, allergens -> CatProfileDraft in
                var draft = initialDraft
                draft.activityLevel = activity
                draft.healthConcerns = concerns
                draft.hasAllergy = hasAllergy
                draft.allergens = allergens
                return draft
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            activity: activityRelay.asDriver(),
            healthConcerns: healthRelay.asDriver(),
            hasAllergy: allergyRelay.asDriver(),
            allergens: allergensRelay.asDriver(),
            didComplete: didComplete
        )
    }

    private static func toggle(_ concern: String, in current: Set<String>) -> Set<String> {
        var set = current
        if concern == CatHealthConcern.none {
            return set.contains(concern) ? [] : [concern]
        }
        set.remove(CatHealthConcern.none)
        if set.contains(concern) {
            set.remove(concern)
        } else {
            set.insert(concern)
        }
        return set
    }
}
