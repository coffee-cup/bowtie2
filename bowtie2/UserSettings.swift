//
//  UserSettings.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import Foundation
import Combine
import SwiftUI

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct PListUserDefault<T> where T:Codable {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
                return defaultValue
            }
            
            return try! PropertyListDecoder().decode(T.self, from: data)
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: key)
        }
    }
}

enum PlayerSortOrder: String, CaseIterable {
    case recentlyUsed = "recentlyUsed"
    case alphabetical = "alphabetical"

    var displayName: String {
        switch self {
        case .alphabetical: return "Alphabetical"
        case .recentlyUsed: return "Recently Used"
        }
    }
}

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    var appIcon: String {
        willSet { objectWillChange.send() }
    }
    
    init() {
        self.appIcon = "primary"
    }
    
    init(appIcon: String) {
        self.appIcon = appIcon
    }
    
    @AppStorage("showWelcome") var showWelcome = true {
        willSet { objectWillChange.send() }
    }

    @AppStorage("showGraph") var showGraph = true {
        willSet { objectWillChange.send() }
    }
    
    @AppStorage(BowtieProducts.Premium) var hasPremium = false {
        willSet { objectWillChange.send() }
    }
    
    @PListUserDefault("theme", defaultValue: themes[0])
    var theme: Theme {
        willSet { objectWillChange.send() }
    }

    @AppStorage("playerSortOrder") var playerSortOrder: String = PlayerSortOrder.recentlyUsed.rawValue {
        willSet { objectWillChange.send() }
    }

    @AppStorage("liveActivitiesEnabled") var liveActivitiesEnabled = true {
        willSet { objectWillChange.send() }
    }
}
