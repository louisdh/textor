//
//  FontPickerViewController.swift
//  Textor
//
//  Created by Simon Andersson on 25/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class FontPickerViewController: UITableViewController {

	let searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Fonts"
		return searchController
	}()
	
	let fonts: [String] = {
		var allFonts = [String]()
		let fontFamilys = UIFont.familyNames
		for fontFamily in fontFamilys {
			allFonts += UIFont.fontNames(forFamilyName: fontFamily)
		}
		
		return allFonts.sorted()
	}()
	var filteredFonts = [String]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateTheme()
		title = "Fonts"
		
		self.searchController.searchResultsUpdater = self
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = true
    }
	
	func updateTheme() {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			tableView.backgroundColor = .white
			navigationController?.navigationBar.barStyle = .default
			tableView.separatorColor = .gray
			
		case .dark:
			tableView.backgroundColor = UIColor(white: 0.07, alpha: 1)
			navigationController?.navigationBar.barStyle = .black
			tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
			
		}
		
	}
	
	func updateTheme(for cell: UITableViewCell) {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			cell.backgroundColor = .clear
			
			for label in cell.subviewLabels() {
				label.textColor = .black
				label.highlightedTextColor = .white
			}
			
		case .dark:
			cell.backgroundColor = .clear
			
			for label in cell.subviewLabels() {
				label.textColor = .white
				label.highlightedTextColor = .black
			}
			
		}
		
	}
	
	func searchFonts(searchText: String) {
		
		filteredFonts = fonts.filter({ $0.lowercased().contains(searchText.lowercased()) })
		
		tableView.reloadData()
	}
	
	func isSearching() -> Bool {
		let isSearchBarEmpty = searchController.searchBar.text?.isEmpty ?? true
		return searchController.isActive && !isSearchBarEmpty
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
		if isSearching() {
			return filteredFonts.count
		}
		
		return fonts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		var fontName: String
		if isSearching() {
			fontName = filteredFonts[indexPath.row]
		} else {
			fontName = fonts[indexPath.row]
		}
		
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

extension FontPickerViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text {
			searchFonts(searchText: searchText)
		}
	}
}
