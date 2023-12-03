//
//  DarkModeManager.swift
//  WUBET-LOGIN
//
//  Created by McKelvey Student on 12/2/23.
//

import Foundation

class DarkModeManager {
    static let shared = DarkModeManager()
    
    private init() {}
    
    var isDarkModeEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "darkModeEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkModeEnabled")
        }
    }
}
