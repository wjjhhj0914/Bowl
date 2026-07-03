//
//  IconChipView.swift
//  Bowl
//
//  A circular white "chip" that floats over the onboarding illustration,
//  holding a single icon (the chart / cat graphics). Matches the 64×64
//  white circles with a soft shadow seen in the Figma design.
//
//  NOTE: The chip's white circle + shadow are drawn here in code. The
//  provided asset (`Analyze` / `Cat`) is treated as the inner glyph only.
//  If your SVG already includes the white circle, set `iconInset` to 0.
//

import UIKit
import SnapKit

final class IconChipView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// - Parameters:
    ///   - image: the icon glyph to display.
    ///   - diameter: chip diameter (Figma: 64).
    ///   - iconInset: inset of the glyph inside the chip (Figma glyph ≈ 32 → inset 16).
    init(image: UIImage?, diameter: CGFloat = 64, iconInset: CGFloat = 16) {
        super.init(frame: .zero)
        imageView.image = image
        configure(diameter: diameter)
        layout(diameter: diameter, iconInset: iconInset)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure(diameter: CGFloat) {
        backgroundColor = AppColor.chipSurface
        layer.cornerRadius = diameter / 2
        // Soft floating shadow.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func layout(diameter: CGFloat, iconInset: CGFloat) {
        snp.makeConstraints { $0.size.equalTo(diameter) }

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(diameter - iconInset * 2)
        }
    }
}
