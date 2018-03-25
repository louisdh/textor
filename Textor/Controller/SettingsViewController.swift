//
//  SettingsViewController.swift
//  Textor
//
//  Created by Louis D'hauwe on 10/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController {

    @IBOutlet weak var fontSizeStepper: UIStepper!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var darkThemeSwitch: UISwitch!

    override func viewDidLoad() {
		super.viewDidLoad()
		
		fontSizeStepper.value = Double(UserDefaultsController.shared.fontSize)
        fontSizeLabel.text = "\(Int(fontSizeStepper.value))"

        darkThemeSwitch.isOn = UserDefaultsController.shared.isDarkMode
		
		NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme), name: .themeChanged, object: nil)
		
		updateTheme()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let indexPathForFontRow = IndexPath(item: 5, section: 0)
		let fontCell = tableView.cellForRow(at: indexPathForFontRow)
		fontCell?.detailTextLabel?.text = UserDefaultsController.shared.font
	}

	@IBAction func close(_ sender: UIBarButtonItem) {
		
		self.dismiss(animated: true, completion: nil)

	}

    @IBAction func fontSizeChanged(_ sender: UIStepper) {
		UserDefaultsController.shared.fontSize = CGFloat(sender.value)
        fontSizeLabel.text = "\(Int(sender.value))"
    }

    @IBAction func themeChanged(_ sender: UISwitch) {
		UserDefaultsController.shared.isDarkMode = sender.isOn
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }

	@objc
	func didChangeTheme() {

		UIView.animate(withDuration: 0.3) {
			self.updateTheme()
		}
		
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
		
		for cell in tableView.visibleCells {
			updateTheme(for: cell)
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
		
		updateTheme(for: cell)
		
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textAlignment = .center

		if section == 0 {

			let version = Bundle.main.version
			let build = Bundle.main.build

			let calendar = Calendar.current
			let components = (calendar as NSCalendar).components([.day, .month, .year], from: Date())

			if let year = components.year {

				let startYear = 2018

				let copyrightText: String

				if year == startYear {

					copyrightText = "© \(startYear) Silver Fox. Textor v\(version) (build \(build))"

				} else {

					copyrightText = "© \(startYear)-\(year) Silver Fox. Textor v\(version) (build \(build))"

				}

				footer?.textLabel?.text = copyrightText

			}

		}

	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		switch indexPath.section {
		case 0:
			// Section 3: Links
			let url: String?
			switch indexPath.row {
			case 0:
				// Review on App Store
				let appId = "1330406995"
				url = "itms-apps://itunes.apple.com/us/app/textor/id\(appId)?action=write-review"
			case 1:
				// GitHub
				url = "https://github.com/louisdh/textor"
			case 2:
				// Twitter
				url = "https://twitter.com/LouisDhauwe"
			case 3:
				// Contact Us
				url = nil

				if MFMailComposeViewController.canSendMail() {

					let mailComposeViewController = configuredMailComposeViewController()
					self.present(mailComposeViewController, animated: true, completion: nil)

				} else {

					self.showSendMailErrorAlert()

				}
			case 5:
				// Font picker
				url = nil
				
				let fontVC = self.storyboard!.instantiateViewController(withIdentifier: "FontViewController")
				
				self.show(fontVC, sender: nil)
			default: return
			}

			if let urlString = url, let url = URL(string: urlString) {
				UIApplication.shared.open((url), options: [:], completionHandler: nil)
			}
		default: return
		}

	}

	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self

		mailComposerVC.setToRecipients(["support@silverfox.be"])

		let version = Bundle.main.version
		let build = Bundle.main.build

		mailComposerVC.setSubject("Textor \(version)")

		let deviceModel = UIDevice.current.modelName
		let systemName = UIDevice.current.systemName
		let systemVersion = UIDevice.current.systemVersion

		let body = """


		----------
		App: Textor \(version) (build \(build))
		Device: \(deviceModel) (\(systemName) \(systemVersion))

		"""
		mailComposerVC.setMessageBody(body, isHTML: false)

		return mailComposerVC
	}

	func showSendMailErrorAlert(_ error: NSError? = nil) {

		let errorMsg: String

		if let e = error?.localizedDescription {
			errorMsg = e
		} else {
			errorMsg = "Email could not be sent. Please check your email configuration and try again."
		}

		let alert = UIAlertController(title: "Could not send email", message: errorMsg, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

		self.present(alert, animated: true) { () -> Void in

			alert.view.tintColor = .appTintColor

		}

	}

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)

		if result == .sent {

			let alert = UIAlertController(title: "Thanks for your feedback!", message: "We usually reply within a couple of days.", preferredStyle: .alert)

			alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

			self.present(alert, animated: true) { () -> Void in

				alert.view.tintColor = .appTintColor

			}

		}

	}

}
