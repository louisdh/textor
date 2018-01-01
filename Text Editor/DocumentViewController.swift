//
//  DocumentViewController.swift
//  Text Editor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
	
	@IBOutlet weak var textView: UITextView!
	var document: Document?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		self.navigationController?.view.tintColor = .appTintColor
		view.tintColor = .appTintColor

		textView.text = ""
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
				
				self.textView.text = self.document?.text

                // Display the content of the document, e.g.:
//                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
		self.document?.text = self.textView.text
		
		self.document?.updateChangeCount(.done)
		
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
