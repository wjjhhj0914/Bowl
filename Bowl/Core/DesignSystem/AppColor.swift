//
//  AppColor.swift
//  Bowl
//
//  Centralized color tokens extracted from the Figma design system.
//  Reference these instead of hardcoding hex values in views.
//

import UIKit

enum AppColor {

    /// Screen background. Figma: `#F8F9FA`
    static let background = UIColor(hex: "#F8F9FA")

    /// Primary brand blue — buttons, accents, active indicators. Figma: `#3C82F6`
    static let primary = UIColor(hex: "#3C82F6")

    /// Primary/title text. Figma: `#1C1C1E`
    static let textPrimary = UIColor(hex: "#1C1C1E")

    /// Secondary/subtitle text. Figma: `#555D69`
    static let textSecondary = UIColor(hex: "#555D69")

    /// Text/foreground on top of the primary color (e.g. button label).
    static let onPrimary = UIColor.white

    /// Inactive page-indicator dot. Figma: light gray `#D9DCE1`
    static let indicatorInactive = UIColor(hex: "#D9DCE1")

    /// Soft periwinkle backdrop behind the onboarding illustration. Figma: `#DCE6FB`
    static let illustrationCircle = UIColor(hex: "#DCE6FB")

    /// Surface color for the floating icon chips (white with a soft shadow).
    static let chipSurface = UIColor.white
}
