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

    // Populated by later steps:
    // var gender: Gender?
    // var weight: Double?
    // ...

    init(photo: UIImage? = nil,
         name: String = "",
         breed: String? = nil,
         birthday: Date? = nil) {
        self.photo = photo
        self.name = name
        self.breed = breed
        self.birthday = birthday
    }
}
