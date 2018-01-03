//
//  MachineTests.swift
//  Vending MachineTests
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import XCTest

class MachineTests: XCTestCase {

    var machine: Machine!
    var totalMoney: Double = 0.0

    var display: UILabel = UILabel()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let coinsInMachine: Machine.MoneyCollection = Machine.MoneyCollection(quarters: 10,
                                                                              dimes: 10,
                                                                              nickels: 10,
                                                                              pennies: 0)
        totalMoney = 0.25 * 10.0 + 0.10 * 10.0 + 0.05 * 10.0 + 0.01 * 0.0

        machine = Machine(coinsInMachine: coinsInMachine, display: display)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /* Test if display is initialized with "INSERT COINS"
     * Check: display.text == "INSERT COINS"
     */
    func testMachineInitialization() {
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS' when initialized.")
    }

    /* Test if the provided money collection adds up to the correct total of money available
     * Check: totalMoneyIn = 4.0
     */
    func testMachineMoneyAvailableTotal() {
        XCTAssert(machine.totalMoneyIn() == totalMoney,
                  "Total value of money in machine does not equal \(totalMoney)")

        // display should still be 'INSERT COINS'
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS'.")
    }

    /* Test if the machine will accept the correct coin types
     * Check: total + 0.25 = 0.25
     * Check: total + 0.10 = 0.35
     * Check: total + 0.05 = 0.40
     * Check: total + 0.01 = 0.40 (pennies not allowed)
     * Check: coinReturn = 1 penny, 0 quarters, 0 dimes, 0 nickels
     * Check: display for each total
     */
    func testMachineValidCoinTypes() {
        var totalInserted = 0.0
        var totalInsertedInMachine = 0.0

        machine.insertMoney(type: Coins.CoinTypes.quarter)
        totalInserted += Coins.CoinTypes.quarter.rawValue
        totalInsertedInMachine = machine.totalMoneyInsertedIn()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a quarter, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "Inserted: $0.25", "Display text is \(display.text!)," +
            " should read 'Inserted: $0.25'.")

        machine.insertMoney(type: Coins.CoinTypes.dime)
        totalInserted += Coins.CoinTypes.dime.rawValue
        totalInsertedInMachine = machine.totalMoneyInsertedIn()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a dime, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "Inserted: $0.35", "Display text is \(display.text!)," +
            "  should read 'Inserted: $0.35'.")

        machine.insertMoney(type: Coins.CoinTypes.nickel)
        totalInserted += Coins.CoinTypes.nickel.rawValue
        totalInsertedInMachine = machine.totalMoneyInsertedIn()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a nickel, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "Inserted: $0.40", "Display text is \(display.text!)," +
            "  should read 'Inserted: $0.40'.")

        machine.insertMoney(type: Coins.CoinTypes.penny)
        // totalInserted should not change, we are returning pennies
        totalInsertedInMachine = machine.totalMoneyInsertedIn()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a penny, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "Inserted: $0.40", "Display text is \(display.text!)," +
            "  should read 'Inserted: $0.40'.")

        XCTAssert(machine.moneyInCoinReturn().pennies == 1,
                  "Inserted a penny, coin return should only contain a single penny.")
        XCTAssert(machine.moneyInCoinReturn().quarters == 0,
                  "Inserted a penny, coin return should only contain a single penny. Contained quarters.")
        XCTAssert(machine.moneyInCoinReturn().dimes == 0,
                  "Inserted a penny, coin return should only contain a single penny. Contained dimes.")
        XCTAssert(machine.moneyInCoinReturn().nickels == 0,
                  "Inserted a penny, coin return should only contain a single penny. Contained nickels.")
    }

    /* Test that machine returns correct change
     * Check: insert 1.00, buy item of 1.00 -> return 0
     */
    func testMachineMakeChangeInsertedEqualsPrice() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }

        let cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)

        machine.makeChange(product: cola)
        let emptyCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
        XCTAssert(machine.moneyInCoinReturn().total() == emptyCoinReturn.total(),
                  "Inserted \(machine.totalMoneyInsertedIn()) and purchased cola for " +
                  "\(cola.getPrice()). CoinReturn should be empty.")
    }
    
    /* Test that machine returns correct change
     * Check: insert 2.00, buy item of 1.00 -> return 4 quarters
     */
    func testMachineMakeChangeInsertedMoreThanPriceQuarters() {
        for _ in 1...8 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }

        let cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)

        machine.makeChange(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 4, dimes: 0, nickels: 0, pennies: 0)

        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        XCTAssert(machine.moneyInCoinReturn().quarters == 4)
        XCTAssert(machine.moneyInCoinReturn().dimes == 0)
        XCTAssert(machine.moneyInCoinReturn().nickels == 0)

        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.totalMoneyInsertedIn()) and purchased cola for " +
                  "\(cola.getPrice()). CoinReturn should be $1.00.")
    }
    
    /* Test that machine returns correct change
     * Check: insert 1.20, buy item of 1.00 -> return 2 dimes
     */
    func testMachineMakeChangeInsertedMoreThanPriceDimes() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        for _ in 1...2 {
            machine.insertMoney(type: Coins.CoinTypes.dime)
        }
        
        let cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)
        
        machine.makeChange(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 2, nickels: 0, pennies: 0)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 0)
        XCTAssert(machine.moneyInCoinReturn().dimes == 2)
        XCTAssert(machine.moneyInCoinReturn().nickels == 0)
        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.totalMoneyInsertedIn()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.20.")
    }
    
    /* Test that machine returns correct change
     * Check: insert 1.05, buy item of 1.00 -> return 1 nickel
     */
    func testMachineMakeChangeInsertedMoreThanPriceNickel() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        for _ in 1...1 {
            machine.insertMoney(type: Coins.CoinTypes.nickel)
        }
        
        let cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)
        
        machine.makeChange(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 0, nickels: 1, pennies: 0)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 0)
        XCTAssert(machine.moneyInCoinReturn().dimes == 0)
        XCTAssert(machine.moneyInCoinReturn().nickels == 1)
        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.totalMoneyInsertedIn()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.05.")
    }
    
    /* Test that machine returns correct change
     * Check: insert 1.66, buy item of 1.00 -> return 2 quarters, 1 dime, 1 nickel, 1 penny
     */
    func testMachineMakeChangeInsertedMoreThanPriceMixed() {
        for _ in 1...6 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        
        machine.insertMoney(type: Coins.CoinTypes.penny)
        machine.insertMoney(type: Coins.CoinTypes.dime)
        machine.insertMoney(type: Coins.CoinTypes.nickel)
        
        let cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)
        
        machine.makeChange(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 2, dimes: 1, nickels: 1, pennies: 1)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 2)
        XCTAssert(machine.moneyInCoinReturn().dimes == 1)
        XCTAssert(machine.moneyInCoinReturn().nickels == 1)
        XCTAssert(machine.moneyInCoinReturn().pennies == 1)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.totalMoneyInsertedIn()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.66.")
    }
}
