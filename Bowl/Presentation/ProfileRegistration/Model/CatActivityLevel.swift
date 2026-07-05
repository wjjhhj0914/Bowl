//
//  CatActivityLevel.swift
//  Bowl
//
//  The cat's typical activity level, chosen on profile step 4.
//

import Foundation

enum CatActivityLevel: String, CaseIterable, Codable {
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low: return "낮음"
        case .medium: return "보통"
        case .high: return "높음"
        }
    }

    var subtitle: String {
        switch self {
        case .low: return "집에서 주로 자요"
        case .medium: return "적당히 놀아요"
        case .high: return "항상 활발해요"
        }
    }
}
