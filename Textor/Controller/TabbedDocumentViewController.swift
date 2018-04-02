//
//  TabbedDocumentViewController.swift
//  Textor
//
//  Created by idz on 4/1/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import IDZTabView


///
/// Container view controller that holds a set of tabbed `DocumentViewControllers`.
///
/// This contoller also implements presentation of `UIDocumentBrowserViewController`
/// as a form sheet. The Apple documentation explicitly warns *not* to do this (see:
/// [Adding a Document Browser to Your App](https://developer.apple.com/documentation/uikit/view_controllers/adding_a_document_browser_to_your_app) )
/// BUT the recommended alternative `UIDocumentPickerViewController`does not provide
/// control over the interface style, so looks awful in the dark theme. Furthermore,
/// it seems to work just fine.
/// Just in case, a user default is provided which can switch to the picker implementation
/// although no user interface for this has been added to `SwttingsViewController`
///
class TabbedDocumentViewController: TabViewController {
	/// The open view controller is created early and cached to avoid flashing when it is presented.
	private var openVC: UIViewController! = nil
	
	required init(coder aDecoder: NSCoder) {
		fatalError("Unimplemented")
	}
	
	required init(theme: TabViewTheme) {
		super.init(theme: theme)
		openVC = UserDefaultsController.shared.useDocumentPicker ? createDocumentPicker() : createDocumentBrowser()
	}
	
	init() {
		super.init(theme: UserDefaultsController.shared.isDarkMode ? TabViewThemeDark() : TabViewThemeLight())
		openVC = UserDefaultsController.shared.useDocumentPicker ? createDocumentPicker() : createDocumentBrowser()
	}
	
	/// Called when the 'add' button is touched.
	/// Prompts user to choose a file which will be added to the view in a new tab.
	@objc func add(_ sender: UIBarButtonItem) {
		openVC.modalPresentationStyle =  .formSheet
		present(openVC, animated: true, completion: nil)
	}
	
	private func createDocumentPicker() -> UIViewController {
		let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
		documentPicker.delegate = self
		return documentPicker
	}
	
	private func createDocumentBrowser() -> UIViewController {
		let documentBrowser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.item"])
		documentBrowser.browserUserInterfaceStyle = UserDefaultsController.shared.isDarkMode ? .dark : .light
		documentBrowser.delegate = self
		return documentBrowser
	}
	
	public func addTabs(forURLs urls: [URL]) {
		for url in urls {
			let document = Document(fileURL: url)
			let documentViewController = UIStoryboard.main.documentViewController(document: document)
			documentViewController.title = url.lastPathComponent
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TabbedDocumentViewController.add(_:)))
			documentViewController.navigationItem.rightBarButtonItems?.append(addButton)
			activateTab(documentViewController)
		}
	}
}


// MARK: - UIDocumentPickerDelegate
extension TabbedDocumentViewController: UIDocumentPickerDelegate {
	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
	{
		addTabs(forURLs: urls)
	}

	public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
	{
		// Nothing to do? -- Seems like the UIDocumentPicker does not need to be dismissed.
	}
}

// MARK: - UIDocumentBrowserViewControllerDelegate
extension TabbedDocumentViewController: UIDocumentBrowserViewControllerDelegate {
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
		defer { controller.dismiss(animated: true, completion: nil) }
		
		let newName = DocumentManager.shared.availableFileName(forProposedName: "Untitled")
		
		guard let url = DocumentManager.shared.cacheUrl(for: newName) else {
			importHandler(nil, .none)
			return
		}
		
		let doc = Document(fileURL: url)
		doc.text = ""
		
		doc.save(to: url, for: .forCreating) { (_) in
			
			doc.close(completionHandler: { (_) in
				
				importHandler(url, .move)
				
			})
			
		}
		
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
		defer { controller.dismiss(animated: true, completion: nil) }
		guard !documentURLs.isEmpty else {
			return
		}
		addTabs(forURLs: documentURLs)
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		defer { controller.dismiss(animated: true, completion: nil) }
		addTabs(forURLs: [destinationURL])
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
		defer { controller.dismiss(animated: true, completion: nil) }
		self.showErrorAlert()
	}
	
}

// MARK: - User Defaults
extension UserDefaultsController {
	var isTabbed: Bool {
		get {
			return userDefaults.object(forKey: "tabbed") as? Bool ??  false
		}
		set {
			userDefaults.set(newValue, forKey: "tabbed")
		}
	}
	
	var useDocumentPicker: Bool {
		get {
			return userDefaults.object(forKey: "useDocumentPicker") as? Bool ??  false
		}
		set {
			userDefaults.set(newValue, forKey: "useDocumentPicker")
		}
	}
}

