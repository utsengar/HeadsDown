//
//  UserPreferences.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/8/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Foundation

public struct UserPreferences {
    
    static var isEnabled : Bool {
        get {
            UserDefaults.standard.bool(forKey: "isEnabled")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "isEnabled")
        }
    }
    
    static var timeStarted : Date {
        get {
            UserDefaults.standard.object(forKey: "startTime") as? Date ?? Date()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "startTime")
        }
    }
    
    static var apps : [String : Bool] {
        get {
            UserDefaults.standard.dictionary(forKey: "apps") as! [String : Bool]
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "apps")
        }
    }
}
