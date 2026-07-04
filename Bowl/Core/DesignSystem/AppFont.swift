//
//  AppFont.swift
//  Bowl
//
//  Typography tokens. The design uses "SF Pro", which is the iOS system
//  font, so we map directly onto `UIFont.systemFont(ofSize:weight:)`.
//

import UIKit

enum AppFont {

    /// Brand wordmark ("Bowl"). Figma: SF Pro Bold 36.
    static let brandTitle = UIFont.systemFont(ofSize: 36, weight: .bold)

    /// Screen headline. Figma: SF Pro Bold 24.
    static let title = UIFont.systemFont(ofSize: 24, weight: .bold)

    /// Supporting subtitle. Figma: SF Pro Medium 16.
    static let subtitle = UIFont.systemFont(ofSize: 16, weight: .medium)

    /// Primary button label. Figma: SF Pro Bold 17.
    static let buttonTitle = UIFont.systemFont(ofSize: 17, weight: .bold)

    /// Navigation-bar title. Figma: SF Pro Bold 17.
    static let navTitle = UIFont.systemFont(ofSize: 17, weight: .bold)

    /// Step indicator ("1 / 4"). Figma: SF Pro Bold 13.
    static let stepIndicator = UIFont.systemFont(ofSize: 13, weight: .bold)

    /// Field / section label. Figma: SF Pro Medium 14.
    static let fieldLabel = UIFont.systemFont(ofSize: 14, weight: .medium)

    /// Text-field input & placeholder. Figma: SF Pro Regular 14.
    static let input = UIFont.systemFont(ofSize: 14, weight: .regular)

    /// Helper / validation-rule caption. Figma: SF Pro Medium 11.
    static let helper = UIFont.systemFont(ofSize: 11, weight: .medium)
}
