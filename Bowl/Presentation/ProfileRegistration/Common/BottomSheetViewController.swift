//
//  BottomSheetViewController.swift
//  Bowl
//
//  Base class for custom bottom sheets that sit perfectly flush with the
//  screen's left, right, and bottom edges (only the top corners are
//  rounded). Uses an over-full-screen presentation with a dimmed backdrop
//  and a slide-up/-down animation — avoiding the inset "floating" look of
//  the system sheet on modern iOS.
//
//  Subclasses add their content to `sheetView` and lay it out against
//  `sheetView` (top/leading/trailing) and `view.safeAreaLayoutGuide`
//  (bottom, to clear the home indicator).
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {

    private let sheetHeight: CGFloat

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.dimmingBackground
        view.alpha = 0
        return view
    }()

    /// The white sheet surface. Subclasses add their content here.
    let sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.surface
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let grabber: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.sheetGrabber
        view.layer.cornerRadius = 2
        return view
    }()

    private var sheetTopConstraint: Constraint?
    private var didAnimateIn = false

    init(sheetHeight: CGFloat) {
        self.sheetHeight = sheetHeight
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        view.addSubview(dimmingView)
        view.addSubview(sheetView)
        sheetView.addSubview(grabber)

        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Flush to left/right/bottom; starts just below the bottom edge.
        sheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(sheetHeight)
            sheetTopConstraint = make.top.equalTo(view.snp.bottom).constraint
        }

        grabber.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(37)
            make.height.equalTo(4)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDimTap))
        dimmingView.addGestureRecognizer(tap)

        // Interactive drag-to-dismiss (grabber / non-scrolling areas).
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        sheetView.addGestureRecognizer(pan)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAnimateIn else { return }
        didAnimateIn = true

        sheetTopConstraint?.update(offset: -sheetHeight)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmingView.alpha = 0.4
            self.view.layoutIfNeeded()
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard flag else {
            super.dismiss(animated: false, completion: completion)
            return
        }
        sheetTopConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmingView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            super.dismiss(animated: false, completion: completion)
        })
    }

    @objc private func handleDimTap() {
        dismiss(animated: true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: view).y

        switch gesture.state {
        case .changed:
            // Follow the finger downward; rubber-band a little upward.
            let drag = translationY > 0 ? translationY : translationY / 6
            sheetTopConstraint?.update(offset: -sheetHeight + drag)
            let progress = max(0, translationY) / sheetHeight
            dimmingView.alpha = 0.4 * (1 - progress)

        case .ended, .cancelled:
            let velocityY = gesture.velocity(in: view).y
            // Dismiss on a long-enough or fast-enough downward drag.
            if translationY > sheetHeight * 0.3 || velocityY > 900 {
                dismiss(animated: true)
            } else {
                sheetTopConstraint?.update(offset: -sheetHeight)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                    self.dimmingView.alpha = 0.4
                    self.view.layoutIfNeeded()
                }
            }

        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BottomSheetViewController: UIGestureRecognizerDelegate {

    /// Only start a drag from non-scrolling, non-interactive areas (grabber,
    /// titles, empty space) so tables, pickers, and buttons keep working.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldReceive touch: UITouch) -> Bool {
        var candidate = touch.view
        while let current = candidate, current != sheetView {
            if current is UIScrollView || current is UIPickerView || current is UIControl {
                return false
            }
            candidate = current.superview
        }
        return true
    }
}
