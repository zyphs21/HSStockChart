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
    var high = UILabel()
    var low = UILabel()
    var volume = UILabel()
    var marketCapital = UILabel()
    var moreButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let redColor = UIColor(rgba: "#CC1100")
        let brownColor = UIColor(rgba: "#808080")
        
        currentPrice.text = "68.46"
        currentPrice.textColor = redColor
        currentPrice.font = UIFont.systemFontOfSize(35)
        
        change.text = "+0.27"
        change.textColor = redColor
        change.font = UIFont.systemFontOfSize(14)
        
        percentage.text = "0.20%"
        percentage.textColor = redColor
        percentage.font = UIFont.systemFontOfSize(14)
        
        time.text = "09-01 09:15:21(北京)"
        time.textColor = brownColor
        time.font = UIFont.systemFontOfSize(10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
