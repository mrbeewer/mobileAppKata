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
    private var displayTimer: Timer!

    // MARK: - Methods

    init(coinsInMachine: MoneyCollection, display: UILabel) {
        print("Status: Initialize Machine")
        self.coinsInserted = 0.0
        self.coinsInMachine = coinsInMachine

        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)

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
    }

    /**
     Method to make change based on the selected product and inserted money.
     
     - Parameters:
     - product: The product being purchased.
     */
    func makeChange(product: Products) {
        var change = self.coinsInserted - product.getPrice()
        change = Double(round(100*change)/100)

        if change > 0 {
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

            // pennies are rejected when inserted
            
            displayDefault()
        }
        
        self.coinsInserted = 0.0
    }
    
    // MARK: - Product
    /**
     Method to allow the user to purchase a product, if enough money is available.
     
     - Parameters:
     - product: The product being purchased.
     */
    func purchase(product: Products) -> Bool {
        if self.coinsInserted - product.getPrice() >= 0 {
            makeChange(product: product)
            displayDone()
            return true
        } else if self.coinsInserted - product.getPrice() < 0 {
            displayPriceOfProduct(product: product)
        }
        
        return false
    }
    
    // MARK: - Display Adjustments
    /// Sets the display to the default text - "INSERT COIN"
    @objc func displayDefault() {
        self.display.text = "INSERT COINS"
        self.coinsInserted = 0.0
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
    func displayMoneyInserted() {
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
