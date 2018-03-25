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

	var theme: Theme {
		get {
			guard let rawValue = userDefaults.object(forKey: "selectedTheme") as? String else {
				return .light
			}

			return Theme(rawValue: rawValue) ?? .light
		}
		set {
			userDefaults.set(newValue.rawValue, forKey: "selectedTheme")
		}
	}

	var isDarkMode: Bool {
		get {
			return theme == .dark
		}
		set {
			theme = newValue ? .dark : .light
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
	
	var font: String {
		get {
			return userDefaults.string(forKey: "font") ?? "Menlo-Regular"
		}
		set {
			userDefaults.set(newValue, forKey: "font")
		}
	}

	var isFastlane: Bool {
		return userDefaults.bool(forKey: "FASTLANE_SNAPSHOT") == true
	}

}
