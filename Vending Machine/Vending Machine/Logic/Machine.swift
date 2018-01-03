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

    // TODO:
    // current state of the system
    // current amount of money in the system (reserves)
    // inventory
    // current amount of money inserted into the system
    //
    private var moneyInserted: Double = 0.0
    private var moneyAvailableTotal: Double = 0.0
    private var moneyAvailable: MoneyCollection
    private var coinReturn: MoneyCollection

    private var display: UILabel

    // MARK: - Methods

    init(moneyAvailable: MoneyCollection, display: UILabel) {
        print("Status: Initialize Machine")
        self.moneyInserted = 0.0
        self.moneyAvailableTotal = moneyAvailable.total()
        self.moneyAvailable = moneyAvailable

        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)

        self.display = display
        self.display.text = "INSERT COINS"
    }

    deinit {
        print("Status: Deinitialize Machine")
    }

    // MARK: - Getters
    func totalMoneyIn() -> Double {
        return self.moneyAvailableTotal
    }

    func totalMoneyInsertedIn() -> Double {
        return self.moneyInserted
    }

    func moneyInCoinReturn() -> MoneyCollection {
        return self.coinReturn
    }

    // MARK: - Money Adjustments
    /// Called when the user inserts money. Will validate and increment the inserted total.
    func insertMoney(type: Coins.CoinTypes) {
        switch type {
        case .penny:
            sendToCoinReturn(type: type)
        default:
            self.moneyInserted += type.rawValue
        }

        displayMoneyInserted()
    }

    func sendToCoinReturn(type: Coins.CoinTypes) {
        switch type {
        case .quarter:
            self.coinReturn.quarters += 1
        case .dime:
            self.coinReturn.dimes += 1
        case .nickel:
            self.coinReturn.nickels += 1
        case .penny:
            self.coinReturn.pennies += 1
        }
    }

    // MARK: - Display Adjustments
    func displayDefault() {
        self.display.text = "INSERT COIN"
    }

    func displayDone() {
        self.display.text = "THANK YOU"
    }

    func displayMoneyInserted() {
        self.display.text = String(format: "Inserted: $%.02f", self.moneyInserted)
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
