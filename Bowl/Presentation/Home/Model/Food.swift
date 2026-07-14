//
//  Food.swift
//  Bowl
//
//  A cat food product. Shared across the home "현재 급여 중인 사료" card and
//  the 사료 검색 result list; will feed the 사료 상세 분석 screen later.
//

import Foundation

struct Food {
    let brand: String
    let product: String
    let type: String         // e.g. 건식
    let proteinPercent: Int   // 조단백, e.g. 32
    let fatPercent: Int       // 조지방, e.g. 18
    let tags: [String]        // e.g. ["그레인프리", "고단백"]

    /// Stable identity for bookmark tracking (no backing store yet).
    var id: String { "\(brand)/\(product)" }

    var proteinText: String { "조단백 \(proteinPercent)%" }
    var fatText: String { "조지방 \(fatPercent)%" }

    /// Lower-cased haystack for search / filter matching (brand, product, tags).
    var searchableText: String {
        ([brand, product] + tags).joined(separator: " ").lowercased()
    }
}
