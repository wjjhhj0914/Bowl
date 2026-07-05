//
//  ProfileGenderWeightViewController.swift
//  Bowl
//
//  "프로필 3단계 · 성별 & 몸무게 & 체형" — step 3 of the cat-profile flow.
//  A gender segmented control, a weight slider with manual entry, and a
//  body-type selector. Built 100% in code with SnapKit, bound via RxSwift.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileGenderWeightViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileGenderWeightViewModel

    /// Invoked when step 3 completes, carrying the draft collected so far.
    var onCompleteStep: ((CatProfileDraft) -> Void)?

    private let manualWeightRelay = PublishRelay<Double>()

    // MARK: - UI

    private let navigationBar = StepProgressNavigationBar(
        title: "고양이 프로필",
        currentStep: 3,
        totalSteps: 4
    )

    private let genderCard = GenderCardView()
    private let weightCard = WeightCardView()
    private let bodyTypeCard = BodyTypeCardView()
    private let nextButton = PrimaryButton(title: "다음")

    // MARK: - Init

    init(viewModel: ProfileGenderWeightViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        [navigationBar, genderCard, weightCard, bodyTypeCard, nextButton].forEach { view.addSubview($0) }
    }

    override func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        genderCard.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        weightCard.snp.makeConstraints { make in
            make.top.equalTo(genderCard.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        bodyTypeCard.snp.makeConstraints { make in
            make.top.equalTo(weightCard.snp.bottom).offset(30)
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
        let input = ProfileGenderWeightViewModel.Input(
            genderSelected: genderCard.selectedGender,
            weightChanged: weightCard.weightChanged,
            manualWeightTapped: weightCard.manualEntryTapped,
            manualWeightEntered: manualWeightRelay.asObservable(),
            bodyTypeSelected: bodyTypeCard.selectedBodyType,
            nextTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.gender
            .drive(with: self) { owner, gender in
                owner.genderCard.setSelected(gender)
            }
            .disposed(by: disposeBag)

        output.weightText
            .drive(with: self) { owner, text in
                owner.weightCard.setValueText(text)
            }
            .disposed(by: disposeBag)

        output.sliderValue
            .drive(with: self) { owner, value in
                owner.weightCard.setSliderValue(value)
            }
            .disposed(by: disposeBag)

        output.bodyType
            .drive(with: self) { owner, bodyType in
                owner.bodyTypeCard.setSelected(bodyType)
            }
            .disposed(by: disposeBag)

        output.presentManualWeight
            .drive(with: self) { owner, current in
                owner.presentManualWeightDialog(current: current)
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

    // MARK: - Manual weight entry

    private func presentManualWeightDialog(current: Double) {
        let alert = UIAlertController(title: "몸무게 입력", message: "kg 단위로 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField { field in
            field.keyboardType = .decimalPad
            field.text = String(format: "%.1f", current)
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self, weak alert] _ in
            guard let text = alert?.textFields?.first?.text,
                  let value = Double(text.replacingOccurrences(of: ",", with: ".")) else { return }
            self?.manualWeightRelay.accept(value)
        })
        present(alert, animated: true)
    }
}
