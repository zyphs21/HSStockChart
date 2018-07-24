//
//  HSKLineStyle.swift
//  HSStockChart
//
//  Created by Hanson on 2017/10/20.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import Foundation

public struct HSKLineStyle {
    
    let uperChartHeightScale: CGFloat = 0.7 // 70% 的空间是上部分的走势图
    
    let lineWidth: CGFloat = 1
    let frameWidth: CGFloat = 0.25
    
    let xAxisHeitht: CGFloat = 30
    let viewMinYGap: CGFloat = 15
    let volumeGap: CGFloat = 10
    
    var candleWidth: CGFloat = 5
    let candleGap: CGFloat = 2
    let candleMinHeight: CGFloat = 0.5
    let candleMaxWidth: CGFloat = 30
    let candleMinWidth: CGFloat = 2
    
    let ma5Color = UIColor.hschart.color(rgba: "#e8de85")
    let ma10Color = UIColor.hschart.color(rgba: "#6fa8bb")
    let ma20Color = UIColor.hschart.color(rgba: "#df8fc6")
    let borderColor = UIColor.hschart.color(rgba: "#e4e4e4")
    let crossLineColor = UIColor.hschart.color(rgba: "#546679")
    let textColor = UIColor.hschart.color(rgba: "#8695a6")
    let riseColor = UIColor.hschart.color(rgba: "#f24957") // 涨 red
    let fallColor = UIColor.hschart.color(rgba: "#1dbf60") // 跌 green
    let priceLineCorlor = UIColor.hschart.color(rgba: "#0095ff")
    let avgLineCorlor = UIColor.hschart.color(rgba: "#ffc004") // 均线颜色
    let fillColor = UIColor.hschart.color(rgba: "#e3efff")
    
    let baseFont = UIFont.systemFont(ofSize: 10)
    
    func getTextSize(text: String) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedStringKey.font: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        
        return CGSize(width: width, height: height)
    }
}
