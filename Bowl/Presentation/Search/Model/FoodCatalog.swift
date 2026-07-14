//
//  FoodCatalog.swift
//  Bowl
//
//  Sample cat-food catalog backing the 사료 검색 screen. Stands in for a
//  remote/product database until the data layer lands.
//

import Foundation

enum FoodCatalog {
    static let all: [Food] = [
        Food(brand: "로얄캐닌", product: "인도어 어덜트", type: "건식",
             proteinPercent: 32, fatPercent: 18, tags: ["그레인프리", "고단백"]),
        Food(brand: "로얄캐닌", product: "헤어볼 케어", type: "건식",
             proteinPercent: 30, fatPercent: 16, tags: ["헤어볼", "실내묘"]),
        Food(brand: "힐스", product: "사이언스 다이어트 어덜트", type: "건식",
             proteinPercent: 33, fatPercent: 20, tags: ["소화건강", "고단백"]),
        Food(brand: "오리젠", product: "캣 앤 키튼", type: "건식",
             proteinPercent: 40, fatPercent: 20, tags: ["그레인프리", "고단백"]),
        Food(brand: "아카나", product: "와일드 프레리 캣", type: "건식",
             proteinPercent: 37, fatPercent: 18, tags: ["그레인프리", "고단백"]),
        Food(brand: "지위픽", product: "에어드라이 매커럴 & 램", type: "건식",
             proteinPercent: 38, fatPercent: 24, tags: ["그레인프리", "고단백"]),
        Food(brand: "퓨리나", product: "프로플랜 인도어 케어", type: "건식",
             proteinPercent: 34, fatPercent: 15, tags: ["실내묘", "헤어볼"]),
        Food(brand: "네추럴발란스", product: "울트라 프리미엄 치킨", type: "건식",
             proteinPercent: 30, fatPercent: 14, tags: ["체중관리"]),
        Food(brand: "웰니스", product: "코어 오리지널 무곡물", type: "건식",
             proteinPercent: 38, fatPercent: 18, tags: ["그레인프리", "고단백"]),
        Food(brand: "고", product: "센시티비티 연어", type: "건식",
             proteinPercent: 32, fatPercent: 16, tags: ["소화건강", "그레인프리"]),
        Food(brand: "블루버팔로", product: "윌더니스 치킨", type: "건식",
             proteinPercent: 40, fatPercent: 18, tags: ["그레인프리", "고단백"]),
        Food(brand: "뉴트로", product: "와일드 프론티어 인도어", type: "건식",
             proteinPercent: 36, fatPercent: 16, tags: ["실내묘", "그레인프리"]),
        Food(brand: "테라캣", product: "헤어볼 컨트롤", type: "습식",
             proteinPercent: 11, fatPercent: 5, tags: ["헤어볼", "습식"]),
        Food(brand: "시바", product: "프리미엄 참치", type: "습식",
             proteinPercent: 16, fatPercent: 3, tags: ["습식", "기호성"]),
        Food(brand: "앙팡", product: "그레인프리 키튼", type: "건식",
             proteinPercent: 36, fatPercent: 20, tags: ["그레인프리", "자묘"])
    ]
}
