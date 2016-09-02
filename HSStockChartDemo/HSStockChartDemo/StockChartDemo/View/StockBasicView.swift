//
//  StockBasicView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/1.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class StockBasicView: UIView {

    var currentPrice = UILabel()
    var change = UILabel()
    var percentage = UILabel()
    var time = UILabel()
    var openPrice = UILabel()
    var lastClosePrice = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
