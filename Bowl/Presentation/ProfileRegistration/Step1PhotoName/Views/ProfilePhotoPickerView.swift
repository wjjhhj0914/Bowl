//
//  ProfilePhotoPickerView.swift
//  Bowl
//
//  Circular photo picker used on profile step 1: a 110×110 light-blue
//  circle with a centered camera icon. Once a photo is chosen it fills the
//  circle and the camera icon is hidden.
//

import UIKit
import SnapKit

final class ProfilePhotoPickerView: UIView {

    static let diameter: CGFloat = 110

    private let cameraIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let iv = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: config))
        iv.tintColor = AppColor.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.photoPlaceholderBackground
        layer.cornerRadius = Self.diameter / 2
        clipsToBounds = true
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        addSubview(photoImageView)
        addSubview(cameraIconView)
    }

    private func setupLayout() {
        snp.makeConstraints { $0.size.equalTo(Self.diameter) }
        photoImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        cameraIconView.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    /// Displays the selected photo (or reverts to the camera placeholder when nil).
    func setPhoto(_ image: UIImage?) {
        photoImageView.image = image
        photoImageView.isHidden = image == nil
        cameraIconView.isHidden = image != nil
    }
}
