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

	static let shared = DocumentManager()

	let fileManager = FileManager.default

	// All created documents are .txt
	// (might change in future)
	private var fileExtension: String {
		return "txt"
	}

	init() {

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

@objc enum FileListSortOption: Int {
	case name = 0
	case lastModificationDate = 1
}

extension DocumentManager {

	/// - Parameter fileName: Without extension
	@objc func isFileNameAvailable(_ fileName: String) -> Bool {

		let files = fileList(sortedBy: .name).map { $0.fileName().lowercased() }

		return !files.contains(fileName.lowercased())
	}

	/// - Parameter proposedName: Without extension
	@objc func availableFileName(forProposedName proposedName: String) -> String {

		let files = fileList(sortedBy: .name).map { $0.fileName().lowercased() }

		var availableFileName = proposedName

		var i = 0
		while files.contains(availableFileName.lowercased()) {

			i += 1
			availableFileName = "\(proposedName) \(i)"

		}

		return availableFileName
	}

	/// File list, including file extensions.
	@objc func fileList(sortedBy sortOption: FileListSortOption) -> [String] {

		let documentsURL = activeDocumentsFolderURL

		guard let contents = try? self.fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) else {
			return []
		}

		let sortedURLs: [URL]

		switch sortOption {
		case .name:

			sortedURLs = contents.sorted { (url1, url2) -> Bool in
				return url1.lastPathComponent < url2.lastPathComponent
			}

		case .lastModificationDate:

			var dates = [URL: Date]()

			for url in contents {

				guard let date1 = (try? fileManager.attributesOfItem(atPath: url.path)[.modificationDate]) as? Date else {
					continue
				}

				dates[url] = date1
			}

			sortedURLs = contents.sorted { (url1, url2) -> Bool in

				guard let date1 = dates[url1] else {
					return true
				}

				guard let date2 = dates[url2] else {
					return true
				}

				return date1 > date2

			}

		}

		let files = sortedURLs.map({ $0.lastPathComponent }).filter({ $0.hasSuffix(".svg") })

		return files
	}

}

extension DocumentManager {

	func lastEditedDate(for fileName: String) -> Date? {
		return fileAttribute(.modificationDate, for: fileName)
	}

	func fileCreationDate(for fileName: String) -> Date? {
		return fileAttribute(.creationDate, for: fileName)
	}

	func fileSize(for fileName: String) -> NSNumber? {
		return fileAttribute(.size, for: fileName)
	}

	private func fileAttribute<T>(_ attributeKey: FileAttributeKey, for fileName: String) -> T? {

		guard let url = url(for: fileName) else {
			return nil
		}

		guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) else {
			return nil
		}

		let attribute = attributes[attributeKey] as? T

		return attribute
	}

}
