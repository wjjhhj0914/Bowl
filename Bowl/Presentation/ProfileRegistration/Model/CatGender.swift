//
//  CatGender.swift
//  Bowl
//
//  The cat's gender, chosen on profile step 3.
//

import Foundation

enum CatGender: String, CaseIterable, Codable {
    case female
    case male

    var title: String {
        switch self {
        case .female: return "암컷"
        case .male: return "수컷"
        }
    }
}
