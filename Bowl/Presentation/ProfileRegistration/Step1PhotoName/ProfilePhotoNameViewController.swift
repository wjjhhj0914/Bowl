//
//  ProfilePhotoNameViewController.swift
//  Bowl
//
//  "02 프로필 등록 1단계 · 사진 & 이름" — step 1 of the cat-profile flow.
//  A custom step nav bar, a circular photo picker, a name card with inline
//  validation, and a primary "다음" button. Built 100% in code with SnapKit
//  and bound to its view model via RxSwift.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

final class ProfilePhotoNameViewController: BaseViewController {

    // MARK: - Dependencies

    private let viewModel: ProfilePhotoNameViewModel

    /// Invoked when step 1 completes, carrying the draft collected so far.
    var onCompleteStep: ((CatProfileDraft) -> Void)?

    /// Feeds photos picked from the system picker back into the view model.
    private let photoSelectedRelay = PublishRelay<UIImage>()

    /// Emits when the photo circle is tapped.
    private let photoTappedRelay = PublishRelay<Void>()

    /// Emits when the user chooses to delete the current photo.
    private let photoDeletedRelay = PublishRelay<Void>()

    // MARK: - UI

    private let navigationBar = StepProgressNavigationBar(
        title: "고양이 프로필",
        currentStep: 1,
        totalSteps: 4
    )

    private let photoPickerView = ProfilePhotoPickerView()
    private let nameCardView = NameInputCardView()
    private let nextButton = PrimaryButton(title: "다음")

    // MARK: - Init

    init(viewModel: ProfilePhotoNameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    override func setupHierarchy() {
        [navigationBar, photoPickerView, nameCardView, nextButton].forEach { view.addSubview($0) }
        setupGestures()
    }

    private func setupGestures() {
        photoPickerView.isUserInteractionEnabled = true
        photoPickerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        )

        // Dismiss the keyboard when tapping the background. Its delegate makes
        // it ignore touches that land on controls (e.g. the back / next
        // buttons), so those taps are never swallowed.
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        backgroundTap.cancelsTouchesInView = false
        backgroundTap.delegate = self
        view.addGestureRecognizer(backgroundTap)
    }

    @objc private func didTapPhoto() {
        photoTappedRelay.accept(())
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        navigationBar.snp.makeConstraints { make in
            // Extends behind the status bar; its content self-insets below the safe area.
            make.top.leading.trailing.equalToSuperview()
        }

        photoPickerView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }

        nameCardView.snp.makeConstraints { make in
            make.top.equalTo(photoPickerView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            // No height constraint: the card sizes itself to its content and
            // grows/shrinks as the validation message shows/hides.
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
        let input = ProfilePhotoNameViewModel.Input(
            name: nameCardView.textField.rx.text.orEmpty.asObservable(),
            photoTapped: photoTappedRelay.asObservable(),
            photoSelected: photoSelectedRelay.asObservable(),
            photoDeleted: photoDeletedRelay.asObservable(),
            nextTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.photo
            .drive(with: self) { owner, image in
                owner.photoPickerView.setPhoto(image)
            }
            .disposed(by: disposeBag)

        output.isNextEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.showNameError
            .drive(with: self) { owner, show in
                owner.nameCardView.setValidationMessage(visible: show)
            }
            .disposed(by: disposeBag)

        output.presentPhotoOptions
            .drive(with: self) { owner, hasPhoto in
                owner.presentPhotoOptions(canDelete: hasPhoto)
            }
            .disposed(by: disposeBag)

        output.didCompleteStep
            .drive(with: self) { owner, draft in
                owner.onCompleteStep?(draft)
            }
            .disposed(by: disposeBag)

        // Back button pops the flow.
        navigationBar.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Photo picking

    /// Presents the photo-source action sheet. A "delete" action is offered
    /// only when a photo already exists.
    private func presentPhotoOptions(canDelete: Bool) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "카메라로 촬영", style: .default) { [weak self] _ in
            self?.presentCamera()
        })
        sheet.addAction(UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in
            self?.presentAlbumPicker()
        })
        if canDelete {
            sheet.addAction(UIAlertAction(title: "기존 사진 삭제", style: .destructive) { [weak self] _ in
                self?.photoDeletedRelay.accept(())
            })
        }
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))

        // Anchor for iPad, where action sheets are presented as popovers.
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = photoPickerView
            popover.sourceRect = photoPickerView.bounds
        }

        present(sheet, animated: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(
                title: "카메라를 사용할 수 없어요",
                message: "이 기기에서는 카메라를 사용할 수 없습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentAlbumPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate (album)

extension ProfilePhotoNameViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.photoSelectedRelay.accept(image)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate (camera)

extension ProfilePhotoNameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            photoSelectedRelay.accept(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ProfilePhotoNameViewController: UIGestureRecognizerDelegate {

    /// Let the keyboard-dismiss tap ignore touches on controls, so buttons
    /// (like the back button) always receive their taps.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}
