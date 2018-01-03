//
//  Machine.swift
//  Vending Machine
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

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

    // MARK: - Methods

    init(moneyAvailable: MoneyCollection) {
        print("Status: Initialize Machine")
        self.moneyInserted = 0.0
        self.moneyAvailableTotal = moneyAvailable.total()
        self.moneyAvailable = moneyAvailable
        
        self.coinReturn = MoneyCollection(quarters: 0, dimes: 0, nickels: 0, pennies: 0)
    }

    deinit {
        print("Status: Deinitialize Machine")
    }

    // MARK: - Getters
    func totalMoneyIn(machine: Machine) -> Double {
        return self.moneyAvailableTotal
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
