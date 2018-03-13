//
//  DocumentViewController.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import StoreKit

var hasAskedForReview = false

var documentsClosed = 0

class DocumentViewController: UIViewController {
	
	@IBOutlet weak var textView: UITextView!
	var document: Document?
	
	let keyboardObserver = KeyboardObserver()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		self.navigationController?.view.tintColor = .appTintColor
		view.tintColor = .appTintColor
        
        let fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize"))
        textView.font = UIFont(name: "Menlo-Regular", size: fontSize)
        
        let darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        if darkMode {
            textView.textColor = .white
            textView.backgroundColor = UIColor(white: 0.1, alpha: 1)
			textView.keyboardAppearance = .dark
			textView.indicatorStyle = .white
			navigationController?.navigationBar.barStyle = .blackTranslucent
        } else {
            textView.textColor = .black
            textView.backgroundColor = .white
			textView.keyboardAppearance = .default
        }
        
		keyboardObserver.observe { [weak self] (state) in
			
			guard let textView = self?.textView else {
				return
			}
			
			let rect = textView.convert(state.keyboardFrameEnd, from: nil).intersection(textView.bounds)
			
			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
				
				textView.contentInset.bottom = rect.height
				textView.scrollIndicatorInsets.bottom = rect.height
				
			}, completion: nil)
			
		}
		
		textView.text = ""
		
		
		
		document?.open(completionHandler: { [weak self] (success) in
			
			guard let `self` = self else {
				return
			}
			
            if success {
				
				self.textView.text = self.document?.text
				
				// Calculate layout for full document, so scrolling is smooth.
				self.textView.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: self.textView.text.count))

            } else {
				
				self.showAlert("Error", message: "Document could not be opened.", dismissCallback: {
					self.dismiss(animated: true, completion: nil)
				})
				
            }
			
        })
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	
		documentsClosed += 1
		
		if !hasAskedForReview && documentsClosed >= 4 {
			hasAskedForReview = true
			SKStoreReviewController.requestReview()
		}
		
	}
	
	@IBAction func shareDocument(_ sender: UIBarButtonItem) {
		
		guard let url = document?.fileURL else {
			return
		}
	
		let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		
		activityVC.popoverPresentationController?.barButtonItem = sender
		
		self.present(activityVC, animated: true, completion: nil)
	}
	
    @IBAction func dismissDocumentViewController() {
		
		let currentText = self.document?.text ?? ""
		
		self.document?.text = self.textView.text
		
		if currentText != self.textView.text {
			self.document?.updateChangeCount(.done)
		}
		
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
	
}
