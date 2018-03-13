//
//  UserDefaultsController.swift
//  Textor
//
//  Created by Louis D'hauwe on 13/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

class UserDefaultsController {
	
	static let shared = UserDefaultsController(userDefaults: .standard)
	
	private var userDefaults: UserDefaults
	
	private init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}

	var isDarkMode: Bool {
		get {
			return userDefaults.object(forKey: "darkMode") as? Bool ?? false
		}
		set {
			userDefaults.set(newValue, forKey: "darkMode")
		}
	}
	
	var fontSize: CGFloat {
		get {
			return userDefaults.object(forKey: "fontSize") as? CGFloat ?? 17.0
		}
		set {
			userDefaults.set(newValue, forKey: "fontSize")
		}
	}
	
	var isFastlane: Bool {
		return userDefaults.bool(forKey: "FASTLANE_SNAPSHOT") == true
	}
	
}
