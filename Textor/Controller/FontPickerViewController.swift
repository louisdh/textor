//
//  FontPickerViewController.swift
//  Textor
//
//  Created by Simon Andersson on 2018-03-25.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class FontPickerViewController: UITableViewController {

	let fonts: [String] = {
		var allFonts = [String]()
		let fontFamilys = UIFont.familyNames
		for fontFamily in fontFamilys {
			allFonts += UIFont.fontNames(forFamilyName: fontFamily)
		}
		
		return allFonts.sorted()
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateTheme()
		title = "Fonts"
    }
	
	func updateTheme() {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			tableView.backgroundColor = .groupTableViewBackground
			navigationController?.navigationBar.barStyle = .default
			tableView.separatorColor = .gray
			
		case .dark:
			tableView.backgroundColor = .darkBackgroundColor
			navigationController?.navigationBar.barStyle = .black
			tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
			
		}
		
	}
	
	func updateTheme(for cell: UITableViewCell) {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			cell.backgroundColor = .white
			
			for label in cell.subviewLabels() {
				label.textColor = .black
				label.highlightedTextColor = .white
			}
			
		case .dark:
			cell.backgroundColor = UIColor(white: 0.07, alpha: 1)
			
			for label in cell.subviewLabels() {
				label.textColor = .white
				label.highlightedTextColor = .black
			}
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let currentFont = UserDefaultsController.shared.font
		if cell.textLabel?.text == currentFont {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		tableView.reloadRows(at: [indexPath], with: .automatic)
		
		updateTheme(for: cell)
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fonts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let fontName = fonts[indexPath.row]
		cell.textLabel?.text = fontName
		cell.textLabel?.font = UIFont(name: fontName, size: 16)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		if let fontName = cell?.textLabel?.text {
			UserDefaultsController.shared.font = fontName
		}
		
		self.navigationController?.popViewController(animated: true)
	}
}
