//
//  MachineTests.swift
//  Vending MachineTests
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import XCTest
@testable import VendingMachine

class MachineTests: XCTestCase {

    var machine: Machine!
    var totalMoney: Double = 0.0
    
    var cola: Products!
    var chips: Products!
    var candy: Products!

    var display: UILabel = UILabel()
    var diagnosticsDisplay: UITextView = UITextView()
    var coinReturnDisplay: UITextView = UITextView()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let coinsInMachine: Machine.MoneyCollection = Machine.MoneyCollection(quarters: 10,
                                                                              dimes: 10,
                                                                              nickels: 10,
                                                                              pennies: 0)
        totalMoney = 0.25 * 10.0 + 0.10 * 10.0 + 0.05 * 10.0 + 0.01 * 0.0

        machine = Machine(coinsInMachine: coinsInMachine, display: display)
        
        machine.diagnosticsDisplay = diagnosticsDisplay
        machine.coinReturnDisplay = coinReturnDisplay
        
        // create products
        cola = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 10)
        chips = Products(type: Products.VendingItemType.chips, price: 0.50, inventory: 10)
        candy = Products(type: Products.VendingItemType.candy, price: 0.65, inventory: 10)
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
        XCTAssert(machine.getCoinsInMachineTotal() == totalMoney,
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
        totalInsertedInMachine = machine.getCoinsInsertedTotal()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a quarter, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "INSERTED: $0.25", "Display text is \(display.text!)," +
            " should read 'INSERTED: $0.25'.")

        machine.insertMoney(type: Coins.CoinTypes.dime)
        totalInserted += Coins.CoinTypes.dime.rawValue
        totalInsertedInMachine = machine.getCoinsInsertedTotal()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a dime, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "INSERTED: $0.35", "Display text is \(display.text!)," +
            "  should read 'INSERTED: $0.35'.")

        machine.insertMoney(type: Coins.CoinTypes.nickel)
        totalInserted += Coins.CoinTypes.nickel.rawValue
        totalInsertedInMachine = machine.getCoinsInsertedTotal()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a nickel, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "INSERTED: $0.40", "Display text is \(display.text!)," +
            "  should read 'INSERTED: $0.40'.")

        machine.insertMoney(type: Coins.CoinTypes.penny)
        // totalInserted should not change, we are returning pennies
        totalInsertedInMachine = machine.getCoinsInsertedTotal()
        XCTAssert(totalInsertedInMachine == totalInserted,
                  "Inserted a penny, total (\(totalInsertedInMachine)) should be \(totalInserted).")
        XCTAssert(display.text! == "INSERTED: $0.40", "Display text is \(display.text!)," +
            "  should read 'INSERTED: $0.40'.")

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

        machine.makeChangeFrom(product: cola)
        let emptyCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
        XCTAssert(machine.moneyInCoinReturn().total() == emptyCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased cola for " +
                  "\(cola.getPrice()). CoinReturn should be empty.")
    }
    
    /* Test that machine returns correct change
     * Check: insert 2.00, buy item of 1.00 -> return 4 quarters
     */
    func testMachineMakeChangeInsertedMoreThanPriceQuarters() {
        for _ in 1...8 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }

        machine.makeChangeFrom(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 4, dimes: 0, nickels: 0, pennies: 0)

        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        XCTAssert(machine.moneyInCoinReturn().quarters == 4)
        XCTAssert(machine.moneyInCoinReturn().dimes == 0)
        XCTAssert(machine.moneyInCoinReturn().nickels == 0)

        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased cola for " +
                  "\(cola.getPrice()). CoinReturn should be $1.00.")
        
        // display should be 'INSERT COINS'
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS'.")
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
        
        machine.makeChangeFrom(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 2, nickels: 0, pennies: 0)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 0)
        XCTAssert(machine.moneyInCoinReturn().dimes == 2)
        XCTAssert(machine.moneyInCoinReturn().nickels == 0)
        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.20.")
        
        // display should be 'INSERT COINS'
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS'.")
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

        machine.makeChangeFrom(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 0, dimes: 0, nickels: 1, pennies: 0)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 0)
        XCTAssert(machine.moneyInCoinReturn().dimes == 0)
        XCTAssert(machine.moneyInCoinReturn().nickels == 1)
        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.05.")
        
        // display should be 'INSERT COINS'
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS'.")
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
        
        machine.makeChangeFrom(product: cola)
        let correctCoinReturn = Machine.MoneyCollection(quarters: 2, dimes: 1, nickels: 1, pennies: 1)
        
        XCTAssert(machine.moneyInCoinReturn().quarters == 2)
        XCTAssert(machine.moneyInCoinReturn().dimes == 1)
        XCTAssert(machine.moneyInCoinReturn().nickels == 1)
        XCTAssert(machine.moneyInCoinReturn().pennies == 1)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased cola for " +
            "\(cola.getPrice()). CoinReturn should be $0.66.")
        
        // display should be 'INSERT COINS'
        XCTAssert(display.text! == "INSERT COINS", "Display text should read 'INSERT COINS'.")
    }
    
    /* Test that machine empties the coin return
     * Check: insert 2.0 and emptyCoinReturn -> coinReturn == 0
     */
    func testMachineEmptyCoinReturn() {
        for _ in 1...8 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        machine.makeChangeFrom(product: cola)
        machine.emptyCoinReturn()
        XCTAssert(machine.moneyInCoinReturn().total() == 0, "Empty coin return should result in 0")
    }
    
    /* Test that machine returns coins
     * Check: insert 2.0 and returnCoins -> coinReturn == 4 quarters
     */
    func testMachineReturnCoins() {
        for _ in 1...8 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        machine.returnCoins()
        XCTAssert(machine.moneyInCoinReturn().total() == 2.0, "Empty coin return should result in 2.0")
    }
    
    /* Test purchasing an item with insufficient money inserted
     * Check: insert $0.50, buy a cola -> no cola
     */
    func testMachinePurchaseWithInsufficientMoneyInsertedCola() {
        for _ in 1...2 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        
        let success = machine.purchase(product: cola)
        XCTAssert(!success, "Should not be able to purchase cola (\(cola.getPrice())" +
            " with \(machine.getCoinsInsertedTotal())")
        
        // display should be 'PRICE: $1.00'
        XCTAssert(display.text! == "PRICE: $1.00", "Display text should read 'PRICE: $1.00'.")
    }
    
    /* Test purchasing an item with insufficient money inserted
     * Check: insert $0.10, buy chips -> no chips
     */
    func testMachinePurchaseWithInsufficientMoneyInsertedChips() {
        for _ in 1...1 {
            machine.insertMoney(type: Coins.CoinTypes.dime)
        }
        
        let success = machine.purchase(product: chips)
        XCTAssert(!success, "Should not be able to purchase chips (\(chips.getPrice())" +
            " with \(machine.getCoinsInsertedTotal())")
        
        // display should be 'PRICE: $0.50'
        XCTAssert(display.text! == "PRICE: $0.50", "Display text should read 'PRICE: $0.50'.")
    }
    
    /* Test purchasing an item with insufficient money inserted
     * Check: insert $0.10, buy a candy -> no candy
     */
    func testMachinePurchaseWithInsufficientMoneyInsertedCandy() {
        for _ in 1...1 {
            machine.insertMoney(type: Coins.CoinTypes.dime)
        }
        
        let success = machine.purchase(product: candy)
        XCTAssert(!success, "Should not be able to purchase candy (\(candy.getPrice())" +
            " with \(machine.getCoinsInsertedTotal())")
        
        // display should be 'PRICE: $0.65'
        XCTAssert(display.text! == "PRICE: $0.65", "Display text should read 'PRICE: $0.65'.")
    }
    
    /* Test purchasing an item with sufficient money inserted
     * Check: insert $1.00, buy a cola -> dispense cola
     */
    func testMachinePurchaseWithSufficientMoneyInsertedCola() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }

        let success = machine.purchase(product: cola)
        XCTAssert(success, "Failed purchasing cola (\(cola.getPrice()) with \(machine.getCoinsInsertedTotal())")
    }
    
    /* Test purchasing an item with sufficient money inserted
     * Check: insert $1.00, buy chips -> dispense chips
     */
    func testMachinePurchaseWithSufficientMoneyInsertedChips() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        
        let success = machine.purchase(product: chips)
        XCTAssert(success, "Failed purchasing chips (\(chips.getPrice()) with \(machine.getCoinsInsertedTotal())")
        
        let correctCoinReturn = Machine.MoneyCollection(quarters: 2, dimes: 0, nickels: 0, pennies: 0)
        XCTAssert(machine.moneyInCoinReturn().quarters == 2)
        XCTAssert(machine.moneyInCoinReturn().dimes == 0)
        XCTAssert(machine.moneyInCoinReturn().nickels == 0)
        XCTAssert(machine.moneyInCoinReturn().pennies == 0)
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased chips for " +
            "\(chips.getPrice()). CoinReturn should be $0.50.")
    }
    
    /* Test purchasing an item with sufficient money inserted
     * Check: insert $1.00, buy candy -> dispense candy
     */
    func testMachinePurchaseWithSufficientMoneyInsertedCandy() {
        for _ in 1...4 {
            machine.insertMoney(type: Coins.CoinTypes.quarter)
        }
        
        let success = machine.purchase(product: candy)
        XCTAssert(success, "Failed purchasing candy (\(candy.getPrice()) with \(machine.getCoinsInsertedTotal())")
        
        let correctCoinReturn = Machine.MoneyCollection(quarters: 1, dimes: 1, nickels: 0, pennies: 0)
        XCTAssert(machine.moneyInCoinReturn().quarters == 1, "returned \(machine.moneyInCoinReturn().quarters)")
        XCTAssert(machine.moneyInCoinReturn().dimes == 1, "returned \(machine.moneyInCoinReturn().dimes)")
        XCTAssert(machine.moneyInCoinReturn().nickels == 0, "returned \(machine.moneyInCoinReturn().nickels)")
        XCTAssert(machine.moneyInCoinReturn().pennies == 0, "returned \(machine.moneyInCoinReturn().pennies)")
        
        XCTAssert(machine.moneyInCoinReturn().total() == correctCoinReturn.total(),
                  "Inserted \(machine.getCoinsInsertedTotal()) and purchased candy for " +
            "\(candy.getPrice()). CoinReturn should be $0.35.")
        
        XCTAssert(display.text! == "THANK YOU", "Display text should read 'THANK YOU'.")
        
        XCTAssert(machine.getCoinsInsertedTotal() == 0.0,
                  "All money should be returned, so CoinsInsertedTotal should be 0")
    }
    
    /* Test in stock status
     * Check: cola has inventory of 10, should be in stock
     */
    func testMachineInStockStatus() {
        let inStock = machine.inStock(product: cola)
        XCTAssert(inStock, "Machine should have cola in stock")
    }
    
    /* Test not in stock status
     * Check: create new product with no inventory, should not be in stock
     */
    func testMachineNotInStockStatus() {
        let mtDew = Products(type: Products.VendingItemType.cola, price: 1.0, inventory: 0)
        let inStock = machine.inStock(product: mtDew)
        XCTAssert(!inStock, "Machine should not have MtDew in stock")
    }
    
    /* Test if machine can make change
     * Check: machine has $4.00 of change, should be able to make change
     */
    func testMachineCanMakeChange() {
        XCTAssert(!machine.stateExactChangeOnly, "Machine should be able to make change")
    }
    
    /* Test if machine can not make change
     * Check: machine has $0.50 of change, should be NOT able to make change
     */
    func testMachineCanNotMakeChange() {
        let coinsInMachine: Machine.MoneyCollection = Machine.MoneyCollection(quarters: 2,
                                                                              dimes: 0,
                                                                              nickels: 0,
                                                                              pennies: 0)

        machine = Machine(coinsInMachine: coinsInMachine, display: display)
        XCTAssert(machine.stateExactChangeOnly, "Machine should not be able to make change")
        XCTAssert(self.display.text == "EXACT CHANGE ONLY", "Display should show 'EXACT CHANGE ONLY'")
    }
    
    /* Test if display Sold Out sets displayView
     * Check: display.text == "SOLD OUT"
     */
    func testMachineDisplaySoldOut() {
        machine.displaySoldOut()
        XCTAssert(self.display.text == "SOLD OUT", "Display should show 'SOLD OUT'")
    }
    
    /* Test if display Exact Change Only sets displayView
     * Check: display.text == "EXACT CHANGE ONLY"
     */
    func testMachineDisplayExactChangeOnly() {
        machine.displayExactChangeOnly()
        XCTAssert(self.display.text == "EXACT CHANGE ONLY", "Display should show 'EXACT CHANGE ONLY'")
    }

}
