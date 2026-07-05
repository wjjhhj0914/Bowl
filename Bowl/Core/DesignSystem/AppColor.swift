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

    /// Card / navigation-bar surface. Figma: white.
    static let surface = UIColor.white

    /// Tertiary text — step indicators, muted captions. Figma: `#8E8E93`
    static let textTertiary = UIColor(hex: "#8E8E93")

    /// Text-field placeholder text. Figma: `#9EA3AE`
    static let placeholder = UIColor(hex: "#9EA3AE")

    /// Warning / validation-rule text (coral). Figma: `#EB7D70`
    static let warning = UIColor(hex: "#EB7D70")

    /// Hairline dividers and progress-bar track. Figma: `#E0E2E6`
    static let divider = UIColor(hex: "#E0E2E6")

    /// Filled text-field background. Figma: `#F8F9FA`
    static let inputBackground = UIColor(hex: "#F8F9FA")

    /// Card border. Figma: `#F5F5F5`
    static let cardBorder = UIColor(hex: "#F5F5F5")

    /// Placeholder backdrop for the profile photo circle. Figma: `#DCE6FB`
    static let photoPlaceholderBackground = UIColor(hex: "#DCE6FB")

    /// Disabled primary-button background. Figma: `#E0E2E6`
    static let buttonDisabledBackground = UIColor(hex: "#E0E2E6")

    /// Disabled primary-button title. Figma: `#999CA1`
    static let buttonDisabledText = UIColor(hex: "#999CA1")

    /// Background of the age-info chip on the birthday card. Figma: `#E0EFFF`
    static let ageChipBackground = UIColor(hex: "#E0EFFF")

    /// Text color inside the age-info chip. Figma: `#1E40AF`
    static let ageChipText = UIColor(hex: "#1E40AF")

    /// Search-field background in bottom sheets. Figma: `#F1F2F4`
    static let searchFieldBackground = UIColor(hex: "#F1F2F4")

    /// Highlighted row band in the date picker. Figma: `#EFF1F6`
    static let pickerSelectionBackground = UIColor(hex: "#EFF1F6")

    /// Pale-blue circle behind the selection checkmark. Figma: `#E6EEFC`
    static let checkBadgeBackground = UIColor(hex: "#E6EEFC")

    /// Bottom-sheet grabber handle. Figma: `#CCCCD4`
    static let sheetGrabber = UIColor(hex: "#CCCCD4")

    /// Bottom-sheet dimmed backdrop (used at 40% alpha).
    static let dimmingBackground = UIColor.black

    /// Subtitle text on a selected (blue) body-type card. Figma: `#CCE5FF`
    static let onPrimarySubtext = UIColor(hex: "#CCE5FF")

    /// Selected multi-select chip background (soft blue). Figma: `#EAF1FE`
    static let chipSelectedBackground = UIColor(hex: "#EAF1FE")

    /// "선택사항" optional badge background. Figma: `#EAEAEF`
    static let badgeBackground = UIColor(hex: "#EAEAEF")
}
