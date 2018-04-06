//
//  UITableViewCell+Labels.swift
//  Textor
//
//  Created by Louis D'hauwe on 15/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {

	func subviewLabels() -> [UILabel] {
		return deepSubviews().compactMap({ $0 as? UILabel })
	}
	
}

extension UIView {
	
	func deepSubviews() -> [UIView] {
		
		var views = [UIView]()
		
		for subview in subviews {
			views.append(subview)
			views.append(contentsOf: subview.deepSubviews())
		}
		
		return views
	}
	
	
}
