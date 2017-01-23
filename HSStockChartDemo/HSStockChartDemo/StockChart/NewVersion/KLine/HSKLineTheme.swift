//
//  HSKLineTheme.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSKLineTheme: NSObject {

    var borderColor = UIColor(rgba: "#e4e4e4")
    var borderWidth: CGFloat = 1
    
    var xAxisHeitht: CGFloat = 20
    
    var candleWidth: CGFloat = 5
    var candleGap: CGFloat = 2
    var candleMinHeight: CGFloat = 0.5
    var candleMaxWidth: CGFloat = 30
    var candleMinWidth: CGFloat = 2
    
    var viewMinYGap: CGFloat = 15
    var volumeMaxGap: CGFloat = 10
    
    var lineWidth: CGFloat = 1
    
    var yAxisLabelAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 9),
                               NSBackgroundColorAttributeName: UIColor.clear,
                               NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var xAxisLabelAttribute = [NSFontAttributeName:UIFont.systemFont(ofSize: 10),
                               NSBackgroundColorAttributeName: UIColor.clear,
                               NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var highlightAttribute = [NSFontAttributeName:UIFont.systemFont(ofSize: 10),
                              NSBackgroundColorAttributeName: UIColor(rgba: "#8695a6"),
                              NSForegroundColorAttributeName: UIColor.white]
    var annotationLabelAttribute = [NSFontAttributeName:UIFont.systemFont(ofSize: 8),
                                    NSBackgroundColorAttributeName:UIColor.white,
                                    NSForegroundColorAttributeName:UIColor(rgba: "#8695a6")]
    
    var crossLineColor = UIColor(rgba: "#546679")
    var ma5Color = UIColor(netHex: 0xe8de85, alpha: 1)
    var ma10Color = UIColor(netHex: 0x6fa8bb, alpha: 1)
    var ma20Color = UIColor(netHex: 0xdf8fc6, alpha: 1)
    
    var candleRiseColor = UIColor(rgba: "#f24957") // red
    var candleFallColor = UIColor(rgba: "#1dbf60") // green
    
    var kLineChartHeightScale: CGFloat = 0.7
}
