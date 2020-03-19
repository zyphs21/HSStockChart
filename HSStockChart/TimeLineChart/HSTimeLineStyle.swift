//
//  HSTimeLineStyle.swift
//  HSStockChart
//
//  Created by Hanson on 2017/10/13.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public struct HSTimeLineStyle {
    var uperChartHeightScale: CGFloat = 0.7 // 70% 的空间是上部分的走势图
    
    var lineWidth: CGFloat = 1
    var frameWidth: CGFloat = 0.25
    
    var xAxisHeitht: CGFloat = 30
    var viewMinYGap: CGFloat = 15
    var volumeGap: CGFloat = 10
    
    var ma5Color = UIColor(red: 134/255, green: 149/255, blue: 166/255, alpha: 1)
    var ma10Color = UIColor(red: 111/255, green: 168/255, blue: 167/255, alpha: 1)
    var ma20Color = UIColor(red: 111/255, green: 168/255, blue: 167/255, alpha: 1)
    var borderColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
    var crossLineColor = UIColor(red: 84/255, green: 102/255, blue: 121/255, alpha: 1)
    var textColor = UIColor(red: 134/255, green: 149/255, blue: 166/255, alpha: 1)
    var riseColor = UIColor(red: 242/255, green: 73/255, blue: 87/255, alpha: 1) // 涨 red
    var fallColor = UIColor(red: 29/255, green: 191/255, blue: 96/255, alpha: 1) // 跌 green
    var priceLineColor = UIColor(red: 0/255, green: 149/255, blue: 252/255, alpha: 1)
    var avgLineColor = UIColor(red: 255/255, green: 192/255, blue: 4/255, alpha: 1)
    var fillColor = UIColor(red: 227/255, green: 239/255, blue: 255/255, alpha: 1)
    
    var baseFont = UIFont.systemFont(ofSize: 10)
    
    func getTextSize(text: String) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedString.Key.font: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        
        return CGSize(width: width, height: height)
    }
}
