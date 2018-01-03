//
//  Products.swift
//  Vending Machine
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import Foundation

class Products {
    
    private var price:Double = 0.0
    
    private var inventory:Int = 0
    
    private var type:VendingItemType
    
    /**
     Initializes the product with a provided type, price, and inventory.
     
     - Parameters:
        - type: The VendingItem to be associated with product.
        - price: The cost of the item as a float value.
        - inventory: The number of items currently in the machine.
     */
    init(type:VendingItemType, price:Double, inventory:Int ) {
        self.type = type
        self.price = price
        self.inventory = inventory
    }
    
    // MARK: - Methods
    // MARK: Getters
    
    /**
     Returns the current inventory of the item.
     */
    func getInventory() -> Int {
        return self.inventory
    }
    
    /**
     Returns the current price of the item.
     */
    func getPrice() -> Double {
        return self.price
    }
    
    // MARK: Setters
    
    /**
     Updates the current inventory of the item.
     
     - Parameters:
     - count: New count of item in inventory
     */
    func updateInventory(count:Int) {
        self.inventory = count
    }
    
    /**
     Updates the current price of the item.
     
     - Parameters:
     - price: New price of item
     */
    func updatePrice(with price:Double) {
        self.price = price
    }
    
    /**
     Available item types for the vending machine.
     */
    enum VendingItemType {
        case Cola
        
        case Chips
        
        case Candy
    }
}
