//
//  CatBodyType.swift
//  Bowl
//
//  The cat's body condition, chosen on profile step 3.
//

import Foundation

enum CatBodyType: String, CaseIterable, Codable {
    case slim
    case normal
    case chubby

    var title: String {
        switch self {
        case .slim: return "날씬해요"
        case .normal: return "적당해요"
        case .chubby: return "통통해요"
        }
    }

    var subtitle: String {
        switch self {
        case .slim: return "갈비뼈가 잘 보여요"
        case .normal: return "건강한 체형이에요"
        case .chubby: return "갈비뼈가 안 보여요"
        }
    }
}
