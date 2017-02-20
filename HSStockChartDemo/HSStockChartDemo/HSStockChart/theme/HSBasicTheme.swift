//
//  HSBasicTheme.swift
//  dingdong
//
//  Created by Hanson on 2017/1/23.
//  Copyright © 2017年 vanyun. All rights reserved.
//

import UIKit

class HSBasicTheme: NSObject {

    var lineWidth: CGFloat = 1
    var frameWidth: CGFloat = 0.25
    var borderColor = UIColor(rgba: "#e4e4e4")
    var crossLineColor = UIColor(rgba: "#546679")
    
    var yAxisLabelAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 10),
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
    
    var ma5Color = UIColor(netHex: 0xe8de85, alpha: 1)
    var ma10Color = UIColor(netHex: 0x6fa8bb, alpha: 1)
    var ma20Color = UIColor(netHex: 0xdf8fc6, alpha: 1)
    
    var candleRiseColor = UIColor(rgba: "#f24957") // red
    var candleFallColor = UIColor(rgba: "#1dbf60") // green
    
    var kLineChartHeightScale: CGFloat = 0.7
    var uperChartHeightScale: CGFloat = 0.7 //70%的空间是上部分的走势图
}
