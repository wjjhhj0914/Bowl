//
//  ProfilePhotoNameViewModel.swift
//  Bowl
//
//  View model for profile step 1 (사진 & 이름). Validates the name against
//  the "한글/영문/숫자 1~8자" rule to gate the "다음" button, tracks the
//  chosen photo, and emits the accumulated draft when the user advances.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfilePhotoNameViewModel: ViewModelType {

    struct Input {
        let name: Observable<String>
        let photoTapped: Observable<Void>
        let photoSelected: Observable<UIImage>
        let photoDeleted: Observable<Void>
        let nextTapped: Observable<Void>
    }

    struct Output {
        /// Current photo to display in the picker (nil → camera placeholder).
        let photo: Driver<UIImage?>
        /// Whether the name is valid and the user may proceed.
        let isNextEnabled: Driver<Bool>
        /// Whether to show the red validation rule — only once the user has
        /// typed something that fails the rule (never while empty/untouched).
        let showNameError: Driver<Bool>
        /// Request to present the photo options sheet. The payload is whether a
        /// photo already exists (so the sheet can offer a "delete" action).
        let presentPhotoOptions: Driver<Bool>
        /// Emits the accumulated draft when the user taps "다음".
        let didCompleteStep: Driver<CatProfileDraft>
    }

    /// Names must be 1–8 characters of Korean syllables, letters, or digits.
    private static let namePattern = "^[가-힣a-zA-Z0-9]{1,8}$"

    func transform(input: Input) -> Output {
        let name = input.name
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .startWith("")

        // Photo is set by picking an image and cleared by the delete action.
        let photo = Observable
            .merge(
                input.photoSelected.map { UIImage?.some($0) },
                input.photoDeleted.map { UIImage?.none }
            )
            .startWith(nil)
            .share(replay: 1)

        let isNextEnabled = name
            .map { Self.isValidName($0) }
            .distinctUntilChanged()

        // Show the rule only when there is input that fails validation.
        let showNameError = name
            .map { !$0.isEmpty && !Self.isValidName($0) }
            .distinctUntilChanged()

        let presentPhotoOptions = input.photoTapped
            .withLatestFrom(photo)
            .map { $0 != nil }

        let didCompleteStep = input.nextTapped
            .withLatestFrom(Observable.combineLatest(name, photo))
            .map { name, photo in CatProfileDraft(photo: photo, name: name) }

        return Output(
            photo: photo.asDriver(onErrorJustReturn: nil),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            showNameError: showNameError.asDriver(onErrorJustReturn: false),
            presentPhotoOptions: presentPhotoOptions.asDriver(onErrorDriveWith: .empty()),
            didCompleteStep: didCompleteStep.asDriver(onErrorDriveWith: .empty())
        )
    }

    private static func isValidName(_ name: String) -> Bool {
        name.range(of: namePattern, options: .regularExpression) != nil
    }
}
