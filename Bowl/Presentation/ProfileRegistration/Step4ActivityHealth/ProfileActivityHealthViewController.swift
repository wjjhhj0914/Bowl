//
//  ProfileActivityHealthViewController.swift
//  Bowl
//
//  "프로필 4단계 · 활동량 & 건강 & 알러지" — the final profile step. Activity
//  selector, an optional health-interest chip grid, and an allergy toggle,
//  inside a scroll view (the content is taller than the shorter devices).
//  Built 100% in code with SnapKit, bound via RxSwift.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileActivityHealthViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileActivityHealthViewModel

    /// Invoked when the whole profile registration completes.
    var onComplete: ((CatProfileDraft) -> Void)?

    private var didApplyAllergyState = false

    // MARK: - UI

    private let navigationBar = StepProgressNavigationBar(
        title: "고양이 프로필",
        currentStep: 4,
        totalSteps: 4
    )

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let contentView = UIView()

    private let activityCard = ActivityCardView()
    private let healthCard = HealthInterestCardView()
    private let allergyCard = AllergyCardView()
    private let doneButton = PrimaryButton(title: "완료")

    // MARK: - Init

    init(viewModel: ProfileActivityHealthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        view.addSubview(doneButton)
        scrollView.addSubview(contentView)
        [activityCard, healthCard, allergyCard].forEach { contentView.addSubview($0) }
    }

    override func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        doneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-12)
            make.height.equalTo(52)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-12)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        activityCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        healthCard.snp.makeConstraints { make in
            make.top.equalTo(activityCard.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        allergyCard.snp.makeConstraints { make in
            make.top.equalTo(healthCard.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    // MARK: - Binding

    override func bind() {
        let input = ProfileActivityHealthViewModel.Input(
            activitySelected: activityCard.selectedActivity,
            healthConcernToggled: healthCard.toggledConcern,
            allergyToggled: allergyCard.allergyChanged,
            allergenToggled: allergyCard.toggledAllergen,
            doneTapped: doneButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.activity
            .drive(with: self) { owner, activity in
                owner.activityCard.setSelected(activity)
            }
            .disposed(by: disposeBag)

        output.healthConcerns
            .drive(with: self) { owner, concerns in
                owner.healthCard.setSelected(concerns)
            }
            .disposed(by: disposeBag)

        output.hasAllergy
            .drive(with: self) { owner, isOn in
                owner.allergyCard.setOn(isOn)
                owner.updateAllergySelection(visible: isOn)
            }
            .disposed(by: disposeBag)

        output.allergens
            .drive(with: self) { owner, allergens in
                owner.allergyCard.setSelectedAllergens(allergens)
            }
            .disposed(by: disposeBag)

        output.didComplete
            .drive(with: self) { owner, draft in
                owner.onComplete?(draft)
            }
            .disposed(by: disposeBag)

        navigationBar.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    /// Reveals/hides the allergen grid, animating the card and scroll content.
    /// The first application (initial state) is instant so nothing animates on load.
    private func updateAllergySelection(visible: Bool) {
        guard didApplyAllergyState else {
            didApplyAllergyState = true
            allergyCard.setSelectionHidden(!visible)
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.allergyCard.setSelectionHidden(!visible)
            // Lay out the whole hierarchy so the card + scroll content grow smoothly.
            self.view.layoutIfNeeded()
        }
    }
}
