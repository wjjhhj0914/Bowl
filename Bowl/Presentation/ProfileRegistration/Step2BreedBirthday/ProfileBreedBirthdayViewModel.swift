//
//  ProfileBreedBirthdayViewModel.swift
//  Bowl
//
//  View model for profile step 2 (묘종 & 생일). Tracks the chosen breed and
//  birthday, derives the display strings and age info, gates the "다음"
//  button until both are set, and carries the accumulated draft forward.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileBreedBirthdayViewModel: ViewModelType {

    struct Input {
        let breedFieldTapped: Observable<Void>
        let birthdayFieldTapped: Observable<Void>
        let breedSelected: Observable<String>
        let birthdaySelected: Observable<Date>
        let nextTapped: Observable<Void>
    }

    struct Output {
        /// Breed value (nil → placeholder).
        let breedText: Driver<String?>
        /// Formatted birthday (nil → placeholder).
        let birthdayText: Driver<String?>
        /// Age info for the chip (nil → hidden).
        let ageInfo: Driver<CatAgeInfo?>
        /// Enabled once both breed and birthday are set.
        let isNextEnabled: Driver<Bool>
        /// Present the breed sheet.
        let presentBreedPicker: Driver<Void>
        /// Present the birthday sheet, seeded with the current/default date.
        let presentBirthdayPicker: Driver<Date>
        /// Emits the accumulated draft when the user taps "다음".
        let didCompleteStep: Driver<CatProfileDraft>
    }

    private let initialDraft: CatProfileDraft
    private let breedRelay: BehaviorRelay<String?>
    private let birthdayRelay: BehaviorRelay<Date?>
    private let disposeBag = DisposeBag()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy'년' M'월' d'일'"
        return formatter
    }()

    init(draft: CatProfileDraft) {
        self.initialDraft = draft
        self.breedRelay = BehaviorRelay(value: draft.breed)
        self.birthdayRelay = BehaviorRelay(value: draft.birthday)
    }

    func transform(input: Input) -> Output {
        input.breedSelected
            .map { Optional($0) }
            .bind(to: breedRelay)
            .disposed(by: disposeBag)

        input.birthdaySelected
            .map { Optional($0) }
            .bind(to: birthdayRelay)
            .disposed(by: disposeBag)

        let breedText = breedRelay.asDriver()

        let birthdayText = birthdayRelay
            .asDriver()
            .map { date in date.map { Self.dateFormatter.string(from: $0) } }

        let ageInfo = birthdayRelay
            .asDriver()
            .map { date in date.map { CatAgeInfo(birthday: $0) } }

        let isNextEnabled = Driver
            .combineLatest(breedRelay.asDriver(), birthdayRelay.asDriver()) { breed, birthday in
                breed != nil && birthday != nil
            }

        let presentBirthdayPicker = input.birthdayFieldTapped
            .withLatestFrom(birthdayRelay)
            .map { $0 ?? Date() }
            .asDriver(onErrorDriveWith: .empty())

        let didCompleteStep = input.nextTapped
            .withLatestFrom(Observable.combineLatest(breedRelay, birthdayRelay))
            .map { [initialDraft] breed, birthday -> CatProfileDraft in
                var draft = initialDraft
                draft.breed = breed
                draft.birthday = birthday
                return draft
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            breedText: breedText,
            birthdayText: birthdayText,
            ageInfo: ageInfo,
            isNextEnabled: isNextEnabled,
            presentBreedPicker: input.breedFieldTapped.asDriver(onErrorDriveWith: .empty()),
            presentBirthdayPicker: presentBirthdayPicker,
            didCompleteStep: didCompleteStep
        )
    }
}
