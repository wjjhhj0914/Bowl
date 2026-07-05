//
//  CatProfileDraft.swift
//  Bowl
//
//  Mutable draft that accumulates the cat's profile across the 4-step
//  registration flow. Step 1 fills in the photo and name; later steps add
//  breed, birthday, gender/weight/body type, activity, health, and allergy.
//

import UIKit

struct CatProfileDraft {
    var photo: UIImage?
    var name: String

    // Step 2 — 묘종 & 생일:
    var breed: String?
    var birthday: Date?

    // Step 3 — 성별 & 몸무게 & 체형:
    var gender: CatGender?
    var weight: Double?
    var bodyType: CatBodyType?

    // Step 4 — 활동량 & 건강 & 알러지:
    var activityLevel: CatActivityLevel?
    var healthConcerns: Set<String>
    var hasAllergy: Bool

    init(photo: UIImage? = nil,
         name: String = "",
         breed: String? = nil,
         birthday: Date? = nil,
         gender: CatGender? = nil,
         weight: Double? = nil,
         bodyType: CatBodyType? = nil,
         activityLevel: CatActivityLevel? = nil,
         healthConcerns: Set<String> = [],
         hasAllergy: Bool = false) {
        self.photo = photo
        self.name = name
        self.breed = breed
        self.birthday = birthday
        self.gender = gender
        self.weight = weight
        self.bodyType = bodyType
        self.activityLevel = activityLevel
        self.healthConcerns = healthConcerns
        self.hasAllergy = hasAllergy
    }
}
