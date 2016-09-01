//
//  LandscapeViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/1.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeLeft.rawValue, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonDidClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
