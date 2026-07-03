//
//  BaseViewController.swift
//  Bowl
//
//  Base class for all code-based view controllers. It fixes a consistent
//  setup order (hierarchy → layout → binding) and provides a shared
//  `DisposeBag` for Rx subscriptions.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupHierarchy()
        setupLayout()
        bind()
    }

    /// Configure the root view (background color, etc.).
    func configureView() {
        view.backgroundColor = AppColor.background
    }

    /// Add subviews to the hierarchy. Override in subclasses.
    func setupHierarchy() {}

    /// Install SnapKit constraints. Override in subclasses.
    func setupLayout() {}

    /// Wire up Rx bindings between the view and its view model. Override in subclasses.
    func bind() {}
}
