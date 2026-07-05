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

    /// Card section title ("묘종", "생일"). Figma: SF Pro Bold 15.
    static let cardTitle = UIFont.systemFont(ofSize: 15, weight: .bold)

    /// Selection field value / placeholder. Figma: SF Pro Bold 15.
    static let fieldValue = UIFont.systemFont(ofSize: 15, weight: .bold)

    /// Bottom-sheet title. Figma: SF Pro Bold 18.
    static let sheetTitle = UIFont.systemFont(ofSize: 18, weight: .bold)

    /// Bottom-sheet subtitle. Figma: SF Pro Bold 13.
    static let sheetSubtitle = UIFont.systemFont(ofSize: 13, weight: .bold)

    /// List row inside a bottom sheet. Figma: SF Pro Bold 16.
    static let listRow = UIFont.systemFont(ofSize: 16, weight: .bold)

    /// Date-picker column header ("년도", "월", "일"). Figma: SF Pro Medium 12.
    static let pickerHeader = UIFont.systemFont(ofSize: 12, weight: .medium)

    /// Date-picker selected value. Figma: SF Pro Bold 18.
    static let pickerValue = UIFont.systemFont(ofSize: 18, weight: .bold)

    /// Small chip label ("성묘"). Figma: SF Pro Bold 12.
    static let chipLabel = UIFont.systemFont(ofSize: 12, weight: .bold)

    /// Age-info descriptive text. Figma: SF Pro Bold 13.
    static let chipText = UIFont.systemFont(ofSize: 13, weight: .bold)

    /// Emphasized numeric value (e.g. weight "4.5 kg"). Figma: SF Pro Black 18.
    static let valueEmphasis = UIFont.systemFont(ofSize: 18, weight: .black)

    /// Segmented-control option label (e.g. 암컷/수컷). Figma: SF Pro Bold 16.
    static let segmentTitle = UIFont.systemFont(ofSize: 16, weight: .bold)

    /// Option-card title (e.g. 체형 options). Figma: SF Pro Bold 13.
    static let optionTitle = UIFont.systemFont(ofSize: 13, weight: .bold)

    /// Option-card subtitle. Figma: SF Pro Medium 10.
    static let optionSubtitle = UIFont.systemFont(ofSize: 10, weight: .medium)

    /// Card body subtitle. Figma: SF Pro Medium 13.
    static let cardSubtitle = UIFont.systemFont(ofSize: 13, weight: .medium)

    /// Small bold caption (slider bounds, inline links). Figma: SF Pro Bold 12.
    static let caption = UIFont.systemFont(ofSize: 12, weight: .bold)

    /// Larger option-card title (e.g. 활동량 options). Figma: SF Pro Bold 14.
    static let optionTitleLarge = UIFont.systemFont(ofSize: 14, weight: .bold)

    /// Screen title in a header (e.g. "홈"). Figma: SF Pro Bold 22.
    static let screenTitle = UIFont.systemFont(ofSize: 22, weight: .bold)

    /// Emphasized card value / name. Figma: SF Pro Bold 18.
    static let cardValue = UIFont.systemFont(ofSize: 18, weight: .bold)

    /// Bold body text (e.g. product name). Figma: SF Pro Bold 16.
    static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .bold)

    /// Bold 14 subtitle (e.g. profile card subtitle). Figma: SF Pro Bold 14.
    static let subtitleBold = UIFont.systemFont(ofSize: 14, weight: .bold)

    /// Medium 12 caption (e.g. brand name). Figma: SF Pro Medium 12.
    static let captionMedium = UIFont.systemFont(ofSize: 12, weight: .medium)

    /// Medium 14 inline link (e.g. "상세"). Figma: SF Pro Medium 14.
    static let linkMedium = UIFont.systemFont(ofSize: 14, weight: .medium)

    /// Tiny bold tag (e.g. "건식", "조단백 32%"). Figma: SF Pro Bold 10.
    static let tag = UIFont.systemFont(ofSize: 10, weight: .bold)
}
