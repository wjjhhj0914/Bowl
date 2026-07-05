//
//  HomeQuickAction.swift
//  Bowl
//
//  The four "빠른 실행" shortcuts on the home dashboard.
//

import UIKit

enum HomeQuickAction: CaseIterable {
    case search
    case scan
    case compare
    case record

    var title: String {
        switch self {
        case .search: return "사료 검색"
        case .scan: return "바코드 스캔"
        case .compare: return "성분 비교"
        case .record: return "급여 기록"
        }
    }

    var symbolName: String {
        switch self {
        case .search: return "magnifyingglass"
        case .scan: return "barcode.viewfinder"
        case .compare: return "chart.bar.fill"
        case .record: return "square.and.pencil"
        }
    }

    /// Pastel background of the icon circle.
    var circleColor: UIColor {
        switch self {
        case .search: return UIColor(hex: "#EDE9FB")
        case .scan: return UIColor(hex: "#DCEFE3")
        case .compare: return UIColor(hex: "#FBE6DC")
        case .record: return UIColor(hex: "#ECE7FB")
        }
    }

    /// Muted icon tint.
    var iconColor: UIColor {
        switch self {
        case .search: return UIColor(hex: "#7B7989")
        case .scan: return UIColor(hex: "#74837B")
        case .compare: return UIColor(hex: "#8B7B75")
        case .record: return UIColor(hex: "#7C7789")
        }
    }
}
