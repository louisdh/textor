//
//  DocumentViewController.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

extension UIViewController {
	
	@objc func showAlert(_ title: String, message: String) {
		
		showAlert(title, message: message, callbackBtnTitle: nil, retryCallback: nil, dismissCallback: nil)
	}
	
	@objc func showAlert(_ title: String, message: String, dismissCallback: @escaping (() -> Void)) {
		
		showAlert(title, message: message, callbackBtnTitle: nil, retryCallback: nil, dismissCallback: dismissCallback)
		
	}
	
	@objc func showAlert(_ title: String, message: String? = nil, callbackBtnTitle: String? = nil, retryCallback: (() -> Void)? = nil, dismissCallback: (() -> Void)? = nil) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		if let retry = retryCallback, let callbackTitle = callbackBtnTitle {
			
			alert.addAction(UIAlertAction(title: callbackTitle, style: .default, handler: { (a) -> Void in
				retry()
			}))
			
			if let dismiss = dismissCallback {
				
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (a) -> Void in
					dismiss()
				}))
				
			}
			
		} else {
			
			if let dismiss = dismissCallback {
				
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (a) -> Void in
					dismiss()
				}))
				
			} else {
				
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				
			}
			
		}
		
//		alert.view.tintColor = .main
		
		self.present(alert, animated: true) { () -> Void in
			
//			alert.view.tintColor = .foreground()
			
		}
		
	}
	
	@objc func showErrorAlert(_ error: Error?) {
		
		showErrorAlert(error, res: nil, retryCallback: nil, dismissCallback: nil)
	}
	
	@objc func showErrorAlert(_ error: Error? = nil, res: HTTPURLResponse? = nil, retryCallback: (() -> Void)? = nil, dismissCallback: (() -> Void)? = nil) {
		
		var errorTitle = "Error"
		var errorMessage = ""
		
		
		if errorMessage == "" {
			// TODO: add error code?
			if let error = error {
				errorMessage = error.localizedDescription
			}
		}
		
		if errorMessage == "" {
			
			errorMessage = "An error occurred"
			
		}
		
		if retryCallback == nil {
			
			self.showAlert(errorTitle, message: errorMessage, callbackBtnTitle: "Retry", dismissCallback: dismissCallback)
			
		} else {
			
			self.showAlert(errorTitle, message: errorMessage, callbackBtnTitle: "Retry", retryCallback: retryCallback, dismissCallback: dismissCallback)
			
		}
		
	}
	
	
}

class DocumentViewController: UIViewController {
	
	@IBOutlet weak var textView: UITextView!
	var document: Document?
	
	let keyboardObserver = KeyboardObserver()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		self.navigationController?.view.tintColor = .appTintColor
		view.tintColor = .appTintColor

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
