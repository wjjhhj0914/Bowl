//
//  OnboardingViewModel.swift
//  Bowl
//
//  View model for the 3-page onboarding flow. It owns the current-page
//  state: the view feeds in swipe-driven page changes and button taps, and
//  the view model emits the page to display, the button title, and a signal
//  when onboarding is complete.
//
//  Button behavior: on pages 1–2 it reads "다음" and advances one page; on
//  the last page it reads "시작하기" and finishes onboarding.
//

import Foundation
import RxSwift
import RxCocoa

final class OnboardingViewModel: ViewModelType {

    struct Input {
        /// Page index the user swiped to (from the collection view).
        let pageChangedByScroll: Observable<Int>
        /// Taps on the primary button.
        let primaryButtonTapped: Observable<Void>
    }

    struct Output {
        /// Static page content, in display order.
        let pages: [OnboardingPage]
        /// The page that should currently be shown/highlighted.
        let currentPage: Driver<Int>
        /// Title for the primary button, derived from the current page.
        let primaryButtonTitle: Driver<String>
        /// Emits when the user finishes onboarding.
        let didFinishOnboarding: Driver<Void>
    }

    private let pages = OnboardingPage.all
    private let currentPageRelay = BehaviorRelay<Int>(value: 0)
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let lastIndex = pages.count - 1
        let finishRelay = PublishRelay<Void>()

        // Swipe updates the current page.
        input.pageChangedByScroll
            .distinctUntilChanged()
            .bind(to: currentPageRelay)
            .disposed(by: disposeBag)

        // Button advances through the pages, then finishes on the last one.
        input.primaryButtonTapped
            .withLatestFrom(currentPageRelay)
            .subscribe(onNext: { [weak self] page in
                guard let self else { return }
                if page >= lastIndex {
                    finishRelay.accept(())
                } else {
                    self.currentPageRelay.accept(page + 1)
                }
            })
            .disposed(by: disposeBag)

        let currentPage = currentPageRelay
            .asDriver()
            .distinctUntilChanged()

        let primaryButtonTitle = currentPage
            .map { $0 >= lastIndex ? "시작하기" : "다음" }

        return Output(
            pages: pages,
            currentPage: currentPage,
            primaryButtonTitle: primaryButtonTitle,
            didFinishOnboarding: finishRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
