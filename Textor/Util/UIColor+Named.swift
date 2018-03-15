//
//  UIColor+Named.swift
//  Textor
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

	static var appTintColor: UIColor {
		return UIColor(named: "Tint Color")!
	}

	static var darkBackgroundColor: UIColor {
		return UIColor(white: 0.1, alpha: 1)
	}
	
}
