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

    // current state of the system
    // current amount of money in the system (reserves)
    // inventory
    // current amount of money inserted into the system
    //
    private var coinsInserted: Double = 0.0
    private var coinsInMachine: MoneyCollection
    private var coinReturn: MoneyCollection

    private var display: UILabel
    var coinReturnDisplay: UITextView
    var diagnosticsDisplay: UITextView
    private var displayTimer: Timer!
    
    var stateExactChangeOnly: Bool = false

    // MARK: - Methods

    init(coinsInMachine: MoneyCollection, display: UILabel) {
        print("Status: Initialize Machine")
        self.coinsInserted = 0.0
        self.coinsInMachine = coinsInMachine

        self.stateExactChangeOnly = coinsInMachine.total() >= 1.0 ? true : false

        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
        
        self.coinReturnDisplay = UITextView()
        self.diagnosticsDisplay = UITextView()

        self.display = display
        self.display.text = "INSERT COINS"
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
        switch type {
        case .penny:
            sendToCoinReturn(type: type)
        default:
            self.coinsInserted += type.rawValue
        }

        displayMoneyInserted()
        updateDiagnosticsText()
    }

    /**
     Method to send the coin type to the coin return
     
     - Parameters:
     - type: The type of coin being sent.
     - multiple: Defaults to 1, but can be used to send multiple of the same coin.
     */
    func sendToCoinReturn(type: Coins.CoinTypes, multiple: Int = 1) {
        switch type {
        case .quarter:
            self.coinReturn.quarters += 1 * multiple
        case .dime:
            self.coinReturn.dimes += 1 * multiple
        case .nickel:
            self.coinReturn.nickels += 1 * multiple
        case .penny:
            self.coinReturn.pennies += 1 * multiple
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
        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
        updateCoinReturnText()
        updateDiagnosticsText()
    }
    
    /// Method to return all coins
    func returnCoins() {
        makeChange(coins: self.coinsInserted)
        updateCoinReturnText()
        updateDiagnosticsText()
        displayDefault()
    }
    
    /**
     Method to determine the correct quantities of coin types to make change
     
     - Parameters:
     - product: The product being purchased.
     */
    func makeChange(coins: Double) {
        var change = coins
        let numQuarters = Int(floor(change / Coins.CoinTypes.quarter.rawValue))
        sendToCoinReturn(type: Coins.CoinTypes.quarter, multiple: numQuarters)
        
        change -= 0.25 * Double(numQuarters)
        change = Double(round(100*change)/100)
        let numDime = Int(floor(change / Coins.CoinTypes.dime.rawValue))
        sendToCoinReturn(type: Coins.CoinTypes.dime, multiple: numDime)
        
        change -= 0.10 * Double(numDime)
        change = Double(round(100*change)/100)
        let numNickel = Int(floor(change / Coins.CoinTypes.nickel.rawValue))
        sendToCoinReturn(type: Coins.CoinTypes.nickel, multiple: numNickel)
    }
    
    // MARK: - Product
    /**
     Method to allow the user to purchase a product, if enough money is available.
     
     - Parameters:
     - product: The product being purchased.
     */
    func purchase(product: Products) -> Bool {
        if inStock(product: product) {
            if self.coinsInserted - product.getPrice() >= 0 {
                makeChangeFrom(product: product)
                displayDone()
                updateDiagnosticsText()
                return true
            } else if self.coinsInserted - product.getPrice() < 0 {
                displayPriceOfProduct(product: product)
                updateDiagnosticsText()
            }
            
            return false
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
            "\(self.stateExactChangeOnly) - ExactChangeOnly"
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
        
        if self.coinsInserted > 0 {
            // put the display back to default after 3 seconds
            self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
                                                     target: self,
                                                     selector: #selector(displayMoneyInserted),
                                                     userInfo: nil,
                                                     repeats: false)
        } else {
            // put the display back to default after 3 seconds
            self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
                                                     target: self,
                                                     selector: #selector(displayDefault),
                                                     userInfo: nil,
                                                     repeats: false)
        }
    }
    
    /// Sets the display to the default text - "INSERT COIN"
    func displayExactChangeOnly() {
        self.display.text = "EXACT CHANGE ONLY"
        
//        if self.coinsInserted > 0 {
//            // put the display back to default after 3 seconds
//            self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
//                                                     target: self,
//                                                     selector: #selector(displayMoneyInserted),
//                                                     userInfo: nil,
//                                                     repeats: false)
//        } else {
//            // put the display back to default after 3 seconds
//            self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
//                                                     target: self,
//                                                     selector: #selector(displayDefault),
//                                                     userInfo: nil,
//                                                     repeats: false)
//        }
    }

    /// Sets the display to the done state - "THANK YOU"
    func displayDone() {
        self.display.text = "THANK YOU"
        
        // put the display back to default after 3 seconds
        self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
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
        
        // put the display back to default after 3 seconds
        self.displayTimer = Timer.scheduledTimer(timeInterval: 3,
                                                 target: self,
                                                 selector: #selector(displayDefault),
                                                 userInfo: nil,
                                                 repeats: false)
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
