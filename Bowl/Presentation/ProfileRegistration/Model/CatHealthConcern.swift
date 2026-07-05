//
//  CatHealthConcern.swift
//  Bowl
//
//  Optional health-interest tags (multi-select) shown on profile step 4.
//  "없음" (none) is mutually exclusive with the actual concerns.
//

import Foundation

enum CatHealthConcern {
    static let none = "없음"

    static let all: [String] = [
        "비뇨기 건강", "소화 건강", "체중 관리",
        "피부", "모질", "헤어볼",
        "변비", "설사", "신장",
        "눈", none
    ]
}
