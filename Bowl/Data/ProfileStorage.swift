//
//  ProfileStorage.swift
//  Bowl
//
//  Persistence for the cat profile. Uses UserDefaults (JSON-encoded) — a
//  single profile is small and non-relational, so this is sufficient for now.
//

import Foundation

protocol ProfileStoring {
    func save(_ profile: CatProfile)
    func load() -> CatProfile?
}

final class UserDefaultsProfileStorage: ProfileStoring {

    static let shared = UserDefaultsProfileStorage()

    private let key = "com.bowl.catProfile"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ profile: CatProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: key)
    }

    func load() -> CatProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CatProfile.self, from: data)
    }
}
