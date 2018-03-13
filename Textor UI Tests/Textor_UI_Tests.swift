//
//  Textor_UI_Tests.swift
//  Textor UI Tests
//
//  Created by Louis D'hauwe on 10/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest

class Textor_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
		
        continueAfterFailure = false

		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			XCUIDevice.shared.orientation = .landscapeLeft
		}
		
		let app = XCUIApplication()

		snapshot("screenshot1")
		
		app.navigationBars["Think different.txt"].buttons["Done"].tap()

		let textView = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element

		textView.tap()
		
		sleep(1)
		snapshot("screenshot2")

		app.navigationBars["Planets.txt"].buttons["Done"].tap()
		
		textView.tap()

		sleep(1)
		snapshot("screenshot3")
		
		app.navigationBars["Circle.svg"].buttons["Done"].tap()

		snapshot("screenshot4")

    }
    
}
