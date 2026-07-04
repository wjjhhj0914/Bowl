//
//  ProfileBreedBirthdayViewController.swift
//  Bowl
//
//  "프로필 2단계 · 묘종 & 생일" — step 2 of the cat-profile flow. Two
//  selection cards (breed & birthday), each opening a bottom sheet, plus an
//  adaptive age chip under the birthday. Built 100% in code with SnapKit and
//  bound to its view model via RxSwift.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileBreedBirthdayViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileBreedBirthdayViewModel

    /// Invoked when step 2 completes, carrying the draft collected so far.
    var onCompleteStep: ((CatProfileDraft) -> Void)?

    private let breedSelectedRelay = PublishRelay<String>()
    private let birthdaySelectedRelay = PublishRelay<Date>()

    // MARK: - UI

    private let navigationBar = StepProgressNavigationBar(
        title: "고양이 프로필",
        currentStep: 2,
        totalSteps: 4
    )

    private let breedCard = ProfileSelectionCardView(title: "묘종", placeholder: "묘종을 등록해 주세요")
    private let birthdayCard = ProfileSelectionCardView(title: "생일", placeholder: "생일을 입력해 주세요")
    private let ageInfoView = AgeInfoView()
    private let nextButton = PrimaryButton(title: "다음")

    // MARK: - Init

    init(viewModel: ProfileBreedBirthdayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        [navigationBar, breedCard, birthdayCard, nextButton].forEach { view.addSubview($0) }
        birthdayCard.setAccessory(ageInfoView)
    }

    override func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        breedCard.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        birthdayCard.snp.makeConstraints { make in
            make.top.equalTo(breedCard.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-12)
            make.height.equalTo(52)
        }
    }

    // MARK: - Binding

    override func bind() {
        let input = ProfileBreedBirthdayViewModel.Input(
            breedFieldTapped: breedCard.fieldRow.rx.controlEvent(.touchUpInside).asObservable(),
            birthdayFieldTapped: birthdayCard.fieldRow.rx.controlEvent(.touchUpInside).asObservable(),
            breedSelected: breedSelectedRelay.asObservable(),
            birthdaySelected: birthdaySelectedRelay.asObservable(),
            nextTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.breedText
            .drive(with: self) { owner, breed in
                owner.breedCard.setValue(breed)
            }
            .disposed(by: disposeBag)

        output.birthdayText
            .drive(with: self) { owner, birthday in
                owner.birthdayCard.setValue(birthday)
            }
            .disposed(by: disposeBag)

        output.ageInfo
            .drive(with: self) { owner, info in
                if let info {
                    owner.ageInfoView.configure(with: info)
                    owner.birthdayCard.setAccessoryVisible(true)
                } else {
                    owner.birthdayCard.setAccessoryVisible(false)
                }
            }
            .disposed(by: disposeBag)

        output.isNextEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.presentBreedPicker
            .drive(with: self) { owner, _ in
                owner.presentBreedPicker()
            }
            .disposed(by: disposeBag)

        output.presentBirthdayPicker
            .drive(with: self) { owner, date in
                owner.presentBirthdayPicker(initialDate: date)
            }
            .disposed(by: disposeBag)

        output.didCompleteStep
            .drive(with: self) { owner, draft in
                owner.onCompleteStep?(draft)
            }
            .disposed(by: disposeBag)

        navigationBar.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Sheets

    private func presentBreedPicker() {
        let picker = BreedPickerViewController()
        picker.onSelect = { [weak self] breed in
            self?.breedSelectedRelay.accept(breed)
        }
        // The sheet animates its own slide-up, so present without the system animation.
        present(picker, animated: false)
    }

    private func presentBirthdayPicker(initialDate: Date) {
        let picker = BirthdayPickerViewController(initialDate: initialDate)
        picker.onSelect = { [weak self] date in
            self?.birthdaySelectedRelay.accept(date)
        }
        present(picker, animated: false)
    }
}
