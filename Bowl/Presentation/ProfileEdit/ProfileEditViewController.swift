//
//  ProfileEditViewController.swift
//  Bowl
//
//  Placeholder for the profile-editing screen (to be built next). Pushed
//  from the home profile card. Shows the native navigation bar with a back
//  button while the home screen keeps its own custom header.
//

import UIKit
import SnapKit

final class ProfileEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        title = "프로필 수정"

        let label = UILabel()
        label.text = "프로필 수정 화면은 준비 중이에요"
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textTertiary
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Home hides the nav bar; show it here for a native back button.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
