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
	
	let fonts: [Character: [String]] = Dictionary(grouping: UIFont.familyNames.flatMap(UIFont.fontNames(forFamilyName:)).sorted()) { font  in
		if let character = font.uppercased().first,
			let characterScalar = "\(character)".unicodeScalars.first,
			CharacterSet.letters.contains(characterScalar) {
			return character
		} else {
			// Fallback case, in case some installs a font that doesn't start
			// with an alphabetical character
			return "*" as Character
		}
	}
	var filteredFonts = [Character: [String]]()
	// Cache for getting a character for a given index, since ordinarily this
	// would be O(n) on a String
	var charactersForIndex: [Int: Character] = [:]
	
	var defaultSeparatorColor: UIColor!
	var invertedSeparatorColor: UIColor!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateTheme()
		title = "Fonts"
		
		self.searchController.searchResultsUpdater = self
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = true
		
		defaultSeparatorColor = tableView.separatorColor
		let components = defaultSeparatorColor.cgColor.components!
		invertedSeparatorColor = UIColor(red: 1 - components[0], green: 1 - components[1], blue: 1 - components[2], alpha: components[3])
		
		// Do an initial pass to get the table view to populate
		searchFonts(searchText: "")
    }
	
	func updateTheme() {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			tableView.backgroundColor = .white
			navigationController?.navigationBar.barStyle = .default
			tableView.separatorColor = defaultSeparatorColor
			
		case .dark:
			tableView.backgroundColor = UIColor(white: 0.07, alpha: 1)
			navigationController?.navigationBar.barStyle = .black
			tableView.separatorColor = invertedSeparatorColor
			
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
		
		filteredFonts = fonts
		defer {
			charactersForIndex = Dictionary(zip(0..., filteredFonts.keys.filter { character in
					!filteredFonts[character]!.isEmpty
				}.sorted())) { index, _ in
				return index
			}
			tableView.reloadData()
		}
		
		guard !searchText.isEmpty else {
			return
		}
		
		for letter in filteredFonts.keys {
			filteredFonts[letter] = filteredFonts[letter]!.filter { font in
				font.lowercased().contains(searchText.lowercased())
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
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return filteredFonts.values.reduce(into: 0) { sections, fonts in
			sections += (fonts.isEmpty ? 0 : 1)
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredFonts[charactersForIndex[section]!]!.count
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return filteredFonts.keys.filter { character in
			!filteredFonts[character]!.isEmpty
			}.sorted().map(String.init)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		var fontName: String
		fontName = filteredFonts[charactersForIndex[indexPath.section]!]![indexPath.row]
		
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
