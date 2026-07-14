//
//  FoodRecommender.swift
//  Bowl
//
//  Picks a few foods that suit the registered cat by matching the profile's
//  life stage and health concerns against each food's filter keywords. Falls
//  back to the highest-protein foods when there's no profile to personalize from.
//

import Foundation

enum FoodRecommender {

    static func recommendations(for profile: CatProfile?,
                                from foods: [Food] = FoodCatalog.all,
                                limit: Int = 3) -> [Food] {
        let wanted = desiredKeywords(for: profile)
        guard !wanted.isEmpty else {
            return Array(foods.sorted { $0.proteinPercent > $1.proteinPercent }.prefix(limit))
        }

        // Score by how many wanted keywords each food matches; give 전연령
        // recipes a small nudge so all-life-stage foods surface for any cat.
        let ranked = foods
            .map { food -> (food: Food, score: Int) in
                let matches = food.filterKeywords.filter { wanted.contains($0) }.count
                let bonus = food.filterKeywords.contains("전연령") ? 1 : 0
                return (food, matches * 2 + bonus)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .map(\.food)

        guard ranked.count < limit else { return Array(ranked.prefix(limit)) }

        // Top up with high-protein foods if too few matched.
        let filler = foods
            .sorted { $0.proteinPercent > $1.proteinPercent }
            .filter { food in !ranked.contains { $0.id == food.id } }
        return Array((ranked + filler).prefix(limit))
    }

    // MARK: - Profile → keywords

    private static func desiredKeywords(for profile: CatProfile?) -> Set<String> {
        guard let profile else { return [] }
        var keywords: Set<String> = []
        if let stage = lifeStageKeyword(birthday: profile.birthday) {
            keywords.insert(stage)
        }
        for concern in profile.healthConcerns {
            if let mapped = healthKeyword(concern) { keywords.insert(mapped) }
        }
        return keywords
    }

    /// Maps the derived life stage (키튼/성묘/노묘) onto a filter keyword.
    private static func lifeStageKeyword(birthday: Date?) -> String? {
        guard let birthday else { return nil }
        switch CatAgeInfo(birthday: birthday).stage {
        case "키튼": return "키튼"
        case "성묘": return "어덜트"
        case "노묘": return "시니어"
        default:   return nil
        }
    }

    /// Maps an onboarding health concern onto a matching recipe keyword.
    private static func healthKeyword(_ concern: String) -> String? {
        switch concern {
        case "비뇨기 건강", "신장":        return "비뇨기"
        case "소화 건강", "변비", "설사":   return "소화"
        case "체중 관리":                  return "체중조절"
        case "피부", "모질":               return "피부"
        case "헤어볼":                     return "헤어볼"
        default:                           return nil // 눈, 없음 … no recipe keyword
        }
    }
}
