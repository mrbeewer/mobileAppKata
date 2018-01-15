//
//  Machine.swift
//  Vending Machine
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import UIKit
import Foundation

/// Contains the logic that that vending machine uses
class Machine {

    // MARK: - Variables

    private var coinsInserted: Double = 0.0
    private var coinsInMachine: MoneyCollection
    private var coinReturn: MoneyCollection
    private var displayTimer: Timer!
    private var display: UILabel
    var coinReturnDisplay: UITextView
    var diagnosticsDisplay: UITextView
    var productArray: [Products]
    
    var stateExactChangeOnly: Bool = false

    // MARK: - Methods

    init(coinsInMachine: MoneyCollection, display: UILabel) {
        print("Status: Initialize Machine")
        self.coinsInserted = 0.0
        self.coinsInMachine = coinsInMachine
        self.stateExactChangeOnly = coinsInMachine.total() >= 1.0 ? false : true
        self.coinReturn = MoneyCollection()
        self.coinReturnDisplay = UITextView()
        self.diagnosticsDisplay = UITextView()
        self.productArray = []
        self.display = display
        
        if self.stateExactChangeOnly {
            self.display.text = "EXACT CHANGE ONLY"
        } else {
            self.display.text = "INSERT COINS"
        }
    }

    deinit {
        print("Status: Deinitialize Machine")
    }

    // MARK: - Getters
    
    /// Gets the total money that has been inserted
    func getCoinsInsertedTotal() -> Double {
        return self.coinsInserted
    }
    
    /// Gets the toal money in the machine (internal money)
    func getCoinsInMachineTotal() -> Double {
        return self.coinsInMachine.total()
    }
    
    /// Gets the money in the coin return as a MoneyCollection type.
    func moneyInCoinReturn() -> MoneyCollection {
        return self.coinReturn
    }

    // MARK: - Money Adjustments
    
    /**
     Method called when the user inserts money. Will validate and increment the inserted total.
     
     - Parameters:
     - type: The type of coin that was inserted.
     */
    func insertMoney(type: Coins.CoinTypes) {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        
        switch type {
        case .penny:
            sendToCoinReturn(type: type)
        default:
            addToInternalCoinStore(type: type)
            self.coinsInserted += type.rawValue
            displayMoneyInserted()
        }
        
        updateDiagnosticsText()
    }
    
    /**
     Method to add to the internal coin store.
     
     - Parameters:
     - type: The type of coin being received.
     */
    func addToInternalCoinStore(type: Coins.CoinTypes) {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        
        switch type {
        case .quarter:
            self.coinsInMachine.quarters += 1
        case .dime:
            self.coinsInMachine.dimes += 1
        case .nickel:
            self.coinsInMachine.nickels += 1
        case .penny:
            sendToCoinReturn(type: type)
        }
        
        updateDiagnosticsText()
    }
    
    /**
     Method to remove the internal coin store.
     
     - Parameters:
     - type: The type of coin being received.
     */
    func removeFromInternalCoinStore(type: Coins.CoinTypes, multiple: Int = 1) {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        
        switch type {
        case .quarter:
            self.coinsInMachine.quarters -= 1 * multiple
        case .dime:
            self.coinsInMachine.dimes -= 1 * multiple
        case .nickel:
            self.coinsInMachine.nickels -= 1 * multiple
        case .penny:
            sendToCoinReturn(type: type)
        }
        
        updateDiagnosticsText()
    }

    /**
     Method to send the coin type to the coin return
     
     - Parameters:
     - type: The type of coin being sent.
     - multiple: Defaults to 1, but can be used to send multiple of the same coin.
     */
    func sendToCoinReturn(type: Coins.CoinTypes, multiple: Int = 1) {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        
        switch type {
        case .quarter:
            self.coinReturn.quarters += (1 * multiple)
        case .dime:
            self.coinReturn.dimes += (1 * multiple)
        case .nickel:
            self.coinReturn.nickels += (1 * multiple)
        case .penny:
            self.coinReturn.pennies += (1 * multiple)
        }
        
        updateCoinReturnText()
        updateDiagnosticsText()
    }

    /**
     Method to make change based on the selected product and inserted money.
     
     - Parameters:
     - product: The product being purchased.
     */
    func makeChangeFrom(product: Products) {
        var change = self.coinsInserted - product.getPrice()
        change = Double(round(100*change)/100)

        if change > 0 {
            makeChange(coins: change)

            // pennies are rejected when inserted
            
            displayDefault()
        }
        
        self.coinsInserted = 0.0
        updateDiagnosticsText()
    }
    
    /// Method to collect all coins from coin return
    func emptyCoinReturn() {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
        updateCoinReturnText()
        updateDiagnosticsText()
    }
    
    /// Method to return all coins
    func returnCoins() {
        if self.displayTimer != nil {
            self.displayTimer.invalidate()
        }
        
        makeChange(coins: self.coinsInserted)
        updateCoinReturnText()
        updateDiagnosticsText()
        displayDefault()
    }
    
    /**
     Method to determine the correct quantities of coin types to make change
     
     - Parameters:
     - coins: The coins to change out.
     */
    func makeChange(coins: Double) {
        canMakeChange()
        
        var change = coins
        var numQuarters = Int(floor(change / Coins.CoinTypes.quarter.rawValue))
        if numQuarters >= self.coinsInMachine.quarters {
            numQuarters = 0
        }
        sendToCoinReturn(type: Coins.CoinTypes.quarter, multiple: numQuarters)
        removeFromInternalCoinStore(type: Coins.CoinTypes.quarter, multiple: numQuarters)
        
        change -= 0.25 * Double(numQuarters)
        change = Double(round(100*change)/100)
        var numDimes = Int(floor(change / Coins.CoinTypes.dime.rawValue))
        if numDimes >= self.coinsInMachine.dimes {
            numDimes = 0
        }
        sendToCoinReturn(type: Coins.CoinTypes.dime, multiple: numDimes)
        removeFromInternalCoinStore(type: Coins.CoinTypes.dime, multiple: numDimes)
        
        change -= 0.10 * Double(numDimes)
        change = Double(round(100*change)/100)
        var numNickels = Int(floor(change / Coins.CoinTypes.nickel.rawValue))
        if numNickels >= self.coinsInMachine.nickels {
            numNickels = 0
        }
        sendToCoinReturn(type: Coins.CoinTypes.nickel, multiple: numNickels)
        removeFromInternalCoinStore(type: Coins.CoinTypes.nickel, multiple: numNickels)
    }
    
    // MARK: - Product
    
    /**
     Method to allow the user to purchase a product, if enough money is available.
     
     - Parameters:
     - product: The product being purchased.
     */
    func purchase(product: Products) -> Bool {
        if inStock(product: product) {
            if (self.coinsInserted - product.getPrice() > 0 && !self.stateExactChangeOnly) ||
                (self.coinsInserted - product.getPrice() == 0) {
                product.itemSold()
                makeChangeFrom(product: product)
                displayDone()
                updateDiagnosticsText()
                return true
            } else {
                displayPriceOfProduct(product: product)
                updateDiagnosticsText()
                return false
            }
        } else {
            displaySoldOut()
            updateDiagnosticsText()
            return false
        }
    }
    
    // MARK: - System State
    
    /**
     Method to check stock of product
     
     - Parameters:
     - product: The product being purchased.
     */
    func inStock(product: Products) -> Bool {
        if product.getInventory() >= 1 {
            return true
        }
        
        return false
    }
    
    /// Method to check for 'Exact Change Only' state
    func canMakeChange() {
        if self.getCoinsInMachineTotal() >= 1.0 {
            self.stateExactChangeOnly = false
        } else {
            self.stateExactChangeOnly = false
        }
    }
    
    /// Method to update the coin return text
    func updateCoinReturnText() {
        self.coinReturnDisplay.text = "CoinReturn\n\n\(self.coinReturn.quarters)x Quarters\n" +
            "\(self.coinReturn.dimes)x Dimes\n" +
            "\(self.coinReturn.nickels)x Nickels\n" +
            "\(self.coinReturn.pennies)x Pennies"
    }
    
    /// Method to update the diagnostics text
    func updateDiagnosticsText() {
        self.diagnosticsDisplay.text = "Diagnostics\n\n\(self.coinsInMachine.quarters)x Quarters\n" +
            "\(self.coinsInMachine.dimes)x Dimes\n" +
            "\(self.coinsInMachine.nickels)x Nickels\n" +
            "\(self.coinsInMachine.pennies)x Pennies\n\n" +
            "\(self.stateExactChangeOnly) - ExactChange"
        
        if productArray.count > 0 {
            // this only works because I know the order I am adding the products...needs a better method
            self.diagnosticsDisplay.text = self.diagnosticsDisplay.text! +
                "\n\n\(productArray[0].getInventory())x cola\n" +
                "\(productArray[1].getInventory())x chips\n" +
                "\(productArray[2].getInventory())x candy"
        }
    }
    
    // MARK: - Display Adjustments
    
    /// Sets the display to the default text - "INSERT COIN"
    @objc func displayDefault() {
        self.display.text = "INSERT COINS"
        self.coinsInserted = 0.0
    }
    
    /// Sets the display to the default text - "INSERT COIN"
    func displaySoldOut() {
        self.display.text = "SOLD OUT"
        displayDelayShow()
    }
    
    /// Sets the display to the default text - "INSERT COIN"
    @objc func displayExactChangeOnly() {
        self.display.text = "EXACT CHANGE ONLY"
        displayDelayShow()
    }

    /// Sets the display to the done state - "THANK YOU"
    func displayDone() {
        self.display.text = "THANK YOU"
        
        // put the display back to default after 1 seconds
        self.displayTimer = Timer.scheduledTimer(timeInterval: 1,
                                                 target: self,
                                                 selector: #selector(displayDefault),
                                                 userInfo: nil,
                                                 repeats: false)
    }

    /// Sets the display to show the money inserted - "INSERTED: $#.##"
    @objc func displayMoneyInserted() {
        self.display.text = String(format: "INSERTED: $%.02f", self.coinsInserted)
    }
    
    /// Sets the display to show the price of the selected product - "PRICE: $#.##"
    func displayPriceOfProduct(product: Products) {
        self.display.text = String(format: "PRICE: $%.02f", product.getPrice())
        displayDelayShow()
    }
    
    /// Sets the display back to default or money inserted with delay
    func displayDelayShow() {
        if self.coinsInserted > 0 {
            // put the display back to default after 1 seconds
            self.displayTimer = Timer.scheduledTimer(timeInterval: 1,
                                                     target: self,
                                                     selector: #selector(displayMoneyInserted),
                                                     userInfo: nil,
                                                     repeats: false)
        } else if self.stateExactChangeOnly {
            // put the display back to default after 1 seconds
            self.displayTimer = Timer.scheduledTimer(timeInterval: 1,
                                                     target: self,
                                                     selector: #selector(displayExactChangeOnly),
                                                     userInfo: nil,
                                                     repeats: false)
        } else {
            // put the display back to default after 1 seconds
            self.displayTimer = Timer.scheduledTimer(timeInterval: 1,
                                                     target: self,
                                                     selector: #selector(displayDefault),
                                                     userInfo: nil,
                                                     repeats: false)
        }
    }

    /// Struct to hold the quantities of the coin options
    struct MoneyCollection {
        var quarters: Int = 0
        var dimes: Int = 0
        var nickels: Int = 0
        var pennies: Int = 0

        func total() -> Double {
            let total: Double = Double(quarters) * 0.25 + Double(dimes) * 0.10 +
                Double(nickels) * 0.05 + Double(pennies) * 0.01
            return total
        }
    }

}
