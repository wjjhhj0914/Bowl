//
//  ProfileGenderWeightViewModel.swift
//  Bowl
//
//  View model for profile step 3 (성별 & 몸무게 & 체형). Holds the selected
//  gender, weight, and body type — seeded with sensible defaults so the
//  "다음" button is enabled from the start — and carries the draft forward.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileGenderWeightViewModel: ViewModelType {

    struct Input {
        let genderSelected: Observable<CatGender>
        let weightChanged: Observable<Float>
        let manualWeightTapped: Observable<Void>
        let manualWeightEntered: Observable<Double>
        let bodyTypeSelected: Observable<CatBodyType>
        let nextTapped: Observable<Void>
    }

    struct Output {
        let gender: Driver<CatGender>
        /// Formatted weight, e.g. "4.5 kg".
        let weightText: Driver<String>
        /// Weight to push into the slider (e.g. after manual entry).
        let sliderValue: Driver<Float>
        let bodyType: Driver<CatBodyType>
        /// Present the manual-entry dialog, seeded with the current weight.
        let presentManualWeight: Driver<Double>
        let didCompleteStep: Driver<CatProfileDraft>
    }

    private let initialDraft: CatProfileDraft
    private let genderRelay: BehaviorRelay<CatGender>
    private let weightRelay: BehaviorRelay<Double>
    private let bodyTypeRelay: BehaviorRelay<CatBodyType>
    private let disposeBag = DisposeBag()

    private static let defaultWeight = 4.5

    init(draft: CatProfileDraft) {
        self.initialDraft = draft
        genderRelay = BehaviorRelay(value: draft.gender ?? .female)
        weightRelay = BehaviorRelay(value: draft.weight ?? Self.defaultWeight)
        bodyTypeRelay = BehaviorRelay(value: draft.bodyType ?? .normal)
    }

    func transform(input: Input) -> Output {
        input.genderSelected
            .bind(to: genderRelay)
            .disposed(by: disposeBag)

        input.bodyTypeSelected
            .bind(to: bodyTypeRelay)
            .disposed(by: disposeBag)

        // Slider drags and manual entries both update the weight (clamped).
        Observable
            .merge(
                input.weightChanged.map { Double($0) },
                input.manualWeightEntered
            )
            .map { Self.clampWeight($0) }
            .bind(to: weightRelay)
            .disposed(by: disposeBag)

        // Position the slider at the initial weight, and again on manual entry.
        // Slider drags already reflect their own position, so they're excluded.
        let sliderValue = Observable
            .merge(
                Observable.just(Float(weightRelay.value)),
                input.manualWeightEntered.map { Float(Self.clampWeight($0)) }
            )
            .asDriver(onErrorDriveWith: .empty())

        let weightText = weightRelay
            .asDriver()
            .map { String(format: "%.1f kg", $0) }

        let presentManualWeight = input.manualWeightTapped
            .withLatestFrom(weightRelay)
            .asDriver(onErrorDriveWith: .empty())

        let didCompleteStep = input.nextTapped
            .withLatestFrom(Observable.combineLatest(genderRelay, weightRelay, bodyTypeRelay))
            .map { [initialDraft] gender, weight, bodyType -> CatProfileDraft in
                var draft = initialDraft
                draft.gender = gender
                draft.weight = weight
                draft.bodyType = bodyType
                return draft
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            gender: genderRelay.asDriver(),
            weightText: weightText,
            sliderValue: sliderValue,
            bodyType: bodyTypeRelay.asDriver(),
            presentManualWeight: presentManualWeight,
            didCompleteStep: didCompleteStep
        )
    }

    private static func clampWeight(_ value: Double) -> Double {
        min(max(value, Double(WeightCardView.minWeight)), Double(WeightCardView.maxWeight))
    }
}
