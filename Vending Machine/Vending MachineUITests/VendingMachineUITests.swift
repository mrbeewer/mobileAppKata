//
//  Vending_MachineUITests.swift
//  Vending MachineUITests
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import XCTest

class VendingMachineUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens
        // for each test method.
        
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for
        // your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInsertQuarter() {
        app.buttons["Quarter"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.25"].exists)
    }
    
    func testReturnQuarter() {
        app.buttons["Quarter"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.25"].exists)
        app.buttons["Return Coins"].tap()

        let coinReturnText = "CoinReturn\n\n\(1)x Quarters\n" +
            "\(0)x Dimes\n" + "\(0)x Nickels\n" + "\(0)x Pennies"
        
        XCTAssert(app.staticTexts[coinReturnText].exists)
    }

    func testInsertDime() {
        app.buttons["Dime"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.10"].exists)
    }
    
    func testReturnDime() {
        app.buttons["Dime"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.10"].exists)
        app.buttons["Return Coins"].tap()
        
        let coinReturnText = "CoinReturn\n\n\(0)x Quarters\n" +
            "\(1)x Dimes\n" + "\(0)x Nickels\n" + "\(0)x Pennies"
        
        XCTAssert(app.staticTexts[coinReturnText].exists)
    }
    
    func testInsertNickel() {
        app.buttons["Nickel"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.05"].exists)
    }
    
    func testReturnNickel() {
        app.buttons["Nickel"].tap()
        XCTAssert(app.staticTexts["INSERTED: $0.05"].exists)
        app.buttons["Return Coins"].tap()
        
        let coinReturnText = "CoinReturn\n\n\(0)x Quarters\n" +
            "\(0)x Dimes\n" + "\(1)x Nickels\n" + "\(0)x Pennies"
        
        XCTAssert(app.staticTexts[coinReturnText].exists)
    }
}
