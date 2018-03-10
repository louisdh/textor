//
//  DocumentBrowserViewController.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Makes sure everything is initialized
		let _ = DocumentManager.shared
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
//		browserUserInterfaceStyle = .light
		
//		UIApplication.shared.keyWindow?.tintColor = .purple
		view.tintColor = .appTintColor
		
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
		
		self.additionalLeadingNavigationBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .done, target: self, action: #selector(showSettings))]
	}
	
	var snapshotDocumentIndex = 0
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") == true {
			
			var snapshotDocuments = ["The Crazy Ones.txt", "Planets.txt", "Circle.svg"]
			
			if self.view.bounds.width > 600 {
				snapshotDocuments.append("Pharaoh.txt")
			} else {
				snapshotDocuments.append("Mouse.txt")
			}
			
			let url = Bundle.main.url(forResource: snapshotDocuments[snapshotDocumentIndex], withExtension: nil)!
			
			presentDocument(at: url)
			
			snapshotDocumentIndex += 1
			
		}
	
	}
	
	@objc
	func showSettings() {
		
		let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController")
		
		let navCon = UINavigationController(rootViewController: settingsVC)
		navCon.modalPresentationStyle = .formSheet
		
		self.present(navCon, animated: true, completion: nil)
	}
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
		
//		let url = URL(fileURLWithPath: "Untitled.txt")
		
		let newName = DocumentManager.shared.availableFileName(forProposedName: "Untitled")

		guard let url = DocumentManager.shared.cacheUrl(for: newName) else {
			importHandler(nil, .none)
			return
		}
		
		let doc = Document(fileURL: url)
		doc.text = ""
		
		doc.save(to: url, for: .forCreating) { (c) in
			
			doc.close(completionHandler: { (c1) in
				
				importHandler(url, .move)

			})
			
		}
		

        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
//        if newDocumentURL != nil {
//            importHandler(newDocumentURL, .move)
//        } else {
//            importHandler(nil, .none)
//        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
	
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        documentViewController.document = Document(fileURL: documentURL)
		documentViewController.title = documentURL.lastPathComponent
		
		let navCon = UINavigationController(rootViewController: documentViewController)
		
        present(navCon, animated: true, completion: nil)
    }
}

