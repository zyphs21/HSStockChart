//
//  HSKLineStyle.swift
//  HSStockChart
//
//  Created by Hanson on 2017/10/20.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public struct HSKLineStyle {
    
    public init()
    {
        
    }
    
    public var uperChartHeightScale: CGFloat = 0.7 // 70% 的空间是上部分的走势图
    
    public var lineWidth: CGFloat = 1
    public var frameWidth: CGFloat = 0.25
    
    public var xAxisHeitht: CGFloat = 30
    public var viewMinYGap: CGFloat = 15
    public var volumeGap: CGFloat = 10
    
    public var candleWidth: CGFloat = 5
    public var candleGap: CGFloat = 2
    public var candleMinHeight: CGFloat = 0.5
    public var candleMaxWidth: CGFloat = 30
    public var candleMinWidth: CGFloat = 2
    
    public var ma5Color = UIColor.hschart.color(rgba: "#e8de85")
    public var ma10Color = UIColor.hschart.color(rgba: "#6fa8bb")
    public var ma20Color = UIColor.hschart.color(rgba: "#df8fc6")
    public var borderColor = UIColor.hschart.color(rgba: "#e4e4e4")
    public var crossLineColor = UIColor.hschart.color(rgba: "#546679")
    public var textColor = UIColor.hschart.color(rgba: "#8695a6")
    public var riseColor = UIColor.hschart.color(rgba: "#f24957") // 涨 red
    public var fallColor = UIColor.hschart.color(rgba: "#1dbf60") // 跌 green
    public var priceLineCorlor = UIColor.hschart.color(rgba: "#0095ff")
    public var avgLineCorlor = UIColor.hschart.color(rgba: "#ffc004") // 均线颜色
    public var fillColor = UIColor.hschart.color(rgba: "#e3efff")
    
    public var baseFont = UIFont.systemFont(ofSize: 10)
    
    func getTextSize(text: String) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedString.Key.font: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        
        return CGSize(width: width, height: height)
    }
}
