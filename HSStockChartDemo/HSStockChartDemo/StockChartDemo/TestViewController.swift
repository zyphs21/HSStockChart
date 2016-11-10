//
//  TestViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/9.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    var scrollKLineView: HSScrollKLineView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.gray
        
        scrollKLineView = HSScrollKLineView(frame: CGRect(x: 0, y: 70, width: ScreenWidth, height: 300))
        self.view.addSubview(scrollKLineView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
