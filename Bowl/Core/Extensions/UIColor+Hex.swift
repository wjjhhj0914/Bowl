//
//  UIColor+Hex.swift
//  Bowl
//
//  Convenience initializer for creating colors from hex values,
//  so design tokens can be declared exactly as they appear in Figma.
//

import UIKit

extension UIColor {

    /// Creates a color from a hex string such as `"#3C82F6"` or `"3C82F6"`.
    /// Supports 6-digit (RGB) and 8-digit (RGBA) hex strings.
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }

        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let r, g, b, a: CGFloat
        switch sanitized.count {
        case 8: // RRGGBBAA
            r = CGFloat((value & 0xFF00_0000) >> 24) / 255
            g = CGFloat((value & 0x00FF_0000) >> 16) / 255
            b = CGFloat((value & 0x0000_FF00) >> 8) / 255
            a = CGFloat(value & 0x0000_00FF) / 255
        default: // RRGGBB
            r = CGFloat((value & 0xFF0000) >> 16) / 255
            g = CGFloat((value & 0x00FF00) >> 8) / 255
            b = CGFloat(value & 0x0000FF) / 255
            a = alpha
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
