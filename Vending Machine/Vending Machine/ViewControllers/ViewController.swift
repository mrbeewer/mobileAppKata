//
//  ViewController.swift
//  Vending Machine
//
//  Created by David Beeler on 1/2/18.
//  Copyright © 2018 David Beeler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Variables
    var vmachine: Machine!
    var cola: Products!
    var chips: Products!
    var candy: Products!
    
    // MARK: - UI
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var coinReturnText: UITextView!
    @IBOutlet weak var diagnosticsText: UITextView!
    
    // MARK: - Button Interaction
    
    @IBAction func colaTouchUp(_ sender: Any) {
        var success = vmachine.purchase(product: cola)
    }
    @IBAction func chipsTouchUp(_ sender: Any) {
        vmachine.purchase(product: chips)
    }
    @IBAction func candyTouchUp(_ sender: Any) {
        vmachine.purchase(product: candy)
    }
    
    @IBAction func quarterTouchUp(_ sender: Any) {
        vmachine.insertMoney(type: Coins.CoinTypes.quarter)
    }
    @IBAction func dimeTouchUp(_ sender: Any) {
        vmachine.insertMoney(type: Coins.CoinTypes.dime)
    }
    @IBAction func nickelTouchUp(_ sender: Any) {
        vmachine.insertMoney(type: Coins.CoinTypes.nickel)
    }
    @IBAction func pennyTouchUp(_ sender: Any) {
        vmachine.insertMoney(type: Coins.CoinTypes.penny)
    }
    @IBAction func collectCoinsFromReturnTouchUp(_ sender: Any) {
        vmachine.emptyCoinReturn()
    }
    @IBAction func returnCoinsTouchUp(_ sender: Any) {
        vmachine.returnCoins()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // give the machine coins
        let coinsInMachine = Machine.MoneyCollection(quarters: 10, dimes: 10, nickels: 10, pennies: 0)
        // initialize the machine
        vmachine = Machine(coinsInMachine: coinsInMachine, display: self.displayLabel)
        // create the products
        cola = Products(type: Products.VendingItemType.cola, price: 1.00, inventory: 3)
        chips = Products(type: Products.VendingItemType.chips, price: 0.50, inventory: 10)
        candy = Products(type: Products.VendingItemType.candy, price: 0.65, inventory: 10)
        // connect the extra displays
        vmachine.coinReturnDisplay = self.coinReturnText
        vmachine.diagnosticsDisplay = self.diagnosticsText
        vmachine.productArray.append(cola)
        vmachine.productArray.append(chips)
        vmachine.productArray.append(candy)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
