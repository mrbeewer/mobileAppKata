//
//  Vending_MachineTests.swift
//  Vending MachineTests
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import XCTest
@testable import Vending_Machine

class VendingMachineTests: XCTestCase {

    var machine: Machine!
    var totalMoney: Double = 0.0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let moneyAvailable: Machine.MoneyCollection = Machine.MoneyCollection(quarters: 10,
                                                                              dimes: 10,
                                                                              nickels: 10,
                                                                              pennies: 0)
        totalMoney = 0.25 * 10.0 + 0.10 * 10.0 + 0.05 * 10.0 + 0.01 * 0.0

        machine = Machine(moneyAvailable: moneyAvailable)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Test if the provided money collection adds up to the correct total of money available
    func testMachineMoneyAvailableTotal() {
        XCTAssert(machine.totalMoneyIn(machine: machine) == totalMoney,
                  "Total value of money in machine does not equal \(totalMoney)")
    }

    /// Test if the machine will accept the correct coin types
    func testMachineValidCoinTypes() {
        
    }

}
