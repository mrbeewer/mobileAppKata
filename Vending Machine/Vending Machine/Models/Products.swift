//
//  Products.swift
//  Vending Machine
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import Foundation

class Products {

    // MARK: - Variables
    
    private var price: Double = 0.0
    private var inventory: Int = 0
    private var type: VendingItemType

    // MARK: - Init
    
    /**
     Initializes the product with a provided type, price, and inventory.
     
     - Parameters:
        - type: The VendingItem to be associated with product.
        - price: The cost of the item as a float value.
        - inventory: The number of items currently in the machine.
     */
    init(type: VendingItemType, price: Double, inventory: Int ) {
        self.type = type
        self.price = price
        self.inventory = inventory
    }

    // MARK: - Getters

    /// Returns the current inventory of the item.
    func getInventory() -> Int {
        return self.inventory
    }

    /// Returns the current price of the item.
    func getPrice() -> Double {
        return self.price
    }

    // MARK: Setters
    
    /**
     Updates the current inventory of the item.
     
     - Parameters:
     - count: New count of item in inventory
     */
    func updateInventory(count: Int) {
        self.inventory = count
    }

    /**
     Updates the current price of the item.
     
     - Parameters:
     - price: New price of item
     */
    func updatePrice(price: Double) {
        self.price = price
    }

    // MARK: State Changers
    
    /// Decrease inventory count by 1.
    func available() -> Bool {
        if self.inventory >= 1 {
            return true
        }

        return false
    }

    /// Decrease inventory count by 1.
    func itemSold() {
        self.inventory -= 1
    }

    // MARK: - Enum Types
    
    /// Available item types for the vending machine.
    enum VendingItemType {
        case cola
        case chips
        case candy
    }
}
