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

        if change > 0 {
            let numQuarters = Int(floor(change / Coins.CoinTypes.quarter.rawValue))
            sendToCoinReturn(type: Coins.CoinTypes.quarter, multiple: numQuarters)
            
            change -= 0.25 * Double(numQuarters)
            let numDime = Int(floor(change / Coins.CoinTypes.dime.rawValue))
            sendToCoinReturn(type: Coins.CoinTypes.dime, multiple: numDime)
            
            change -= 0.10 * Double(numDime)
            let numNickel = Int(floor(change / Coins.CoinTypes.nickel.rawValue))
            sendToCoinReturn(type: Coins.CoinTypes.nickel, multiple: numNickel)
            
            // pennies are rejected when inserted
        }
    }

    // MARK: - Display Adjustments
    /// Sets the display to the default text - "INSERT COIN"
    func displayDefault() {
        self.display.text = "INSERT COIN"
    }

    /// Sets the display to the done state - "THANK YOU"
    func displayDone() {
        self.display.text = "THANK YOU"
    }

    /// Sets the display to show the money inserted - "Inserted: $#.##"
    func displayMoneyInserted() {
        self.display.text = String(format: "Inserted: $%.02f", self.coinsInserted)
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
