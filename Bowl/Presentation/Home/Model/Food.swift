//
//  Food.swift
//  Bowl
//
//  A cat food product. Currently used for the "현재 급여 중인 사료" card;
//  will be shared with the search / detail features later.
//

import Foundation

struct Food {
    let brand: String
    let product: String
    let type: String        // e.g. 건식
    let proteinPercent: Int  // e.g. 32

    var proteinText: String { "조단백 \(proteinPercent)%" }
}
