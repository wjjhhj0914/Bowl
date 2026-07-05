//
//  CatProfile.swift
//  Bowl
//
//  Persisted cat profile (Codable). Mirrors `CatProfileDraft` but stores the
//  photo as raw Data so the whole profile can be serialized to UserDefaults.
//

import UIKit

struct CatProfile: Codable {
    var name: String
    var breed: String?
    var birthday: Date?
    var gender: CatGender?
    var weight: Double?
    var bodyType: CatBodyType?
    var activityLevel: CatActivityLevel?
    var healthConcerns: Set<String>
    var hasAllergy: Bool
    var allergens: Set<String>
    var photoData: Data?

    /// The stored photo, decoded on demand.
    var photo: UIImage? { photoData.flatMap(UIImage.init(data:)) }

    init(draft: CatProfileDraft) {
        name = draft.name
        breed = draft.breed
        birthday = draft.birthday
        gender = draft.gender
        weight = draft.weight
        bodyType = draft.bodyType
        activityLevel = draft.activityLevel
        healthConcerns = draft.healthConcerns
        hasAllergy = draft.hasAllergy
        allergens = draft.allergens
        photoData = draft.photo?.jpegData(compressionQuality: 0.8)
    }
}
