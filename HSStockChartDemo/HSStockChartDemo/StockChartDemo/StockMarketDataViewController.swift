//
//  StockMarketDataViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/1.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class StockMarketDataViewController: UIViewController {

    @IBOutlet weak var backgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonDidClick(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }

}
