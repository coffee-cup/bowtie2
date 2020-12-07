//
//  UserSettings.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import Foundation
import Combine

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

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("showGraph", defaultValue: true)
    var showGraph: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @PListUserDefault("theme", defaultValue: themes[0])
    var theme: Theme {
        willSet {
            objectWillChange.send()
        }
    }
}
