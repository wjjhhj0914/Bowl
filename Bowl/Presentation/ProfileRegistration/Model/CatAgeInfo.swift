//
//  CatAgeInfo.swift
//  Bowl
//
//  Derives a cat's life stage and a friendly age description from its
//  birthday. Shown in the age chip on the birthday card once a date is set.
//

import Foundation

struct CatAgeInfo {
    /// Life-stage label shown in the pill (자묘 / 성묘 / 노묘).
    let stage: String
    /// Friendly description, e.g. "아이의 나이는 만 4세예요".
    let description: String

    init(birthday: Date, now: Date = Date(), calendar: Calendar = .current) {
        let years = max(0, calendar.dateComponents([.year], from: birthday, to: now).year ?? 0)

        switch years {
        case ..<1:
            stage = "자묘"
        case 1...6:
            stage = "성묘"
        default:
            stage = "노묘"
        }
        description = "아이의 나이는 만 \(years)세예요"
    }
}
