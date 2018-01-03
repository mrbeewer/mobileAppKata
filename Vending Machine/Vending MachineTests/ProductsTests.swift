//
//  ProductsTests.swift
//  Vending MachineTests
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import XCTest

class ProductsTests: XCTestCase {

    var product: Products!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Tests the product initialization method
    func testProductInitialization() {
        let price = 1.0
        let inventory = 10

        product = Products(type: Products.VendingItemType.Cola, price: price, inventory: inventory)

        XCTAssert(product.getPrice() == price, "testCola - price was not set to \(price)")
        XCTAssert(product.getInventory() == inventory, "testCola - inventory was not set to \(inventory)")
    }

    /// Tests the product update (inventory and price) methods
    func testProductUpdate() {
        let price = 1.0
        let inventory = 10

        product = Products(type: Products.VendingItemType.Cola, price: price, inventory: inventory)

        let newInventory = 5
        product.updateInventory(count: newInventory)
        XCTAssert(product.getInventory() == newInventory, "testCola - inventory was not updated to \(newInventory)")

        let newPrice = 0.50
        product.updatePrice(price: newPrice)
        XCTAssert(product.getPrice() == newPrice, "testCola - price was not updated to \(newPrice)")
    }

    /// Test the product inventory decrease when item is sold
    func testProductInventoryDecrease() {
        let price = 1.0
        let inventory = 10

        product = Products(type: Products.VendingItemType.Cola, price: price, inventory: inventory)

        product.itemSold()
        XCTAssert(product.getInventory() == (inventory - 1), "testCola - inventory was not decreased by 1")
    }

    /// Test the product availability
    func testProductAvailability() {
        let price = 1.0
        let inventory = 10

        product = Products(type: Products.VendingItemType.Cola, price: price, inventory: inventory)

        XCTAssert(product.available(), "ProductTest - Item availability should be true")

        product.updateInventory(count: 0)
        XCTAssert(!product.available(), "ProductTest - Item availability should be false")
    }

}
