//
//  DocumentManager.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

extension String {

	/// Name without extension
	func fileName() -> String {

		if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
			return fileNameWithoutExtension
		} else {
			return ""
		}
	}

}

class DocumentManager {

	static let shared = DocumentManager(fileManager: .default)

	let fileManager: FileManager

	// All created documents are .txt
	// (might change in future)
	private var fileExtension: String {
		return "txt"
	}

	private init(fileManager: FileManager) {

		self.fileManager = fileManager
		
		let documentsFolder = activeDocumentsFolderURL

		if !fileManager.fileExists(atPath: documentsFolder.path) {
			try? fileManager.createDirectory(at: documentsFolder, withIntermediateDirectories: true, attributes: nil)
		}

	}

	private let ICLOUD_IDENTIFIER = "iCloud.com.silverfox.plaintextedit"

	private var localDocumentsURL: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}

	private var cachesURL: URL {
		return URL(fileURLWithPath: NSTemporaryDirectory())
//		return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).last!
	}

	private var cloudDocumentsURL: URL? {

		guard iCloudAvailable else {
			return nil
		}

		let ubiquityContainerURL = fileManager.url(forUbiquityContainerIdentifier: ICLOUD_IDENTIFIER)

		return ubiquityContainerURL?.appendingPathComponent("Documents")
	}

	private var activeDocumentsFolderURL: URL {

		if let cloudDocumentsURL = cloudDocumentsURL {
			return cloudDocumentsURL
		} else {
			return localDocumentsURL
		}
	}

	var iCloudAvailable: Bool {
		return fileManager.ubiquityIdentityToken != nil
	}

	func cacheUrl(for fileName: String) -> URL? {

		let docURL = cachesURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)

		return docURL
	}

	func url(for fileName: String) -> URL? {

		let baseURL = activeDocumentsFolderURL

		let docURL = baseURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)

		return docURL
	}

}

extension DocumentManager {

	/// - Parameter proposedName: Without extension
	func availableFileName(forProposedName proposedName: String) -> String {

		let files = fileList().map { $0.fileName().lowercased() }

		var availableFileName = proposedName

		var i = 0
		while files.contains(availableFileName.lowercased()) {

			i += 1
			availableFileName = "\(proposedName) \(i)"

		}

		return availableFileName
	}

	/// File list, including file extensions.
	private func fileList() -> [String] {

		let documentsURL = activeDocumentsFolderURL

		guard let contents = try? self.fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) else {
			return []
		}

		let files = contents.map({ $0.lastPathComponent }).filter({ $0.hasSuffix(".\(fileExtension)") })

		return files
	}

}
