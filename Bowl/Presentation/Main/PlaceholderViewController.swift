//
//  PlaceholderViewController.swift
//  Bowl
//
//  Temporary placeholder for tabs that aren't implemented yet.
//

import UIKit
import SnapKit

final class PlaceholderViewController: UIViewController {

    private let name: String

    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background

        let label = UILabel()
        label.text = "\(name) 화면은 준비 중이에요"
        label.font = AppFont.bodyBold
        label.textColor = AppColor.textTertiary
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
