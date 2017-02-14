//
//  HSChartFrame.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/14.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSChartFrame: HSBasicBrush {

    var theme: HSKLineTheme = HSKLineTheme()
    var uperChartHeight: CGFloat {
        get {
            return theme.kLineChartHeightScale * self.frame.height
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    init(frame: CGRect, theme: HSKLineTheme) {
        super.init(frame: frame)
        
        self.theme = theme
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // K线图 顶部边界线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: 0),
                      stopPoint: CGPoint(x: rect.maxX, y: 0),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // K线图 内上边线 即最高价格线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: theme.viewMinYGap),
                      stopPoint: CGPoint(x: rect.maxX, y: theme.viewMinYGap),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // K线图 内下边线 即最低价格线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: uperChartHeight - theme.viewMinYGap),
                      stopPoint: CGPoint(x: rect.maxX, y: uperChartHeight - theme.viewMinYGap),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // K线图 中间的横线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: uperChartHeight / 2.0),
                      stopPoint: CGPoint(x: rect.maxX, y: uperChartHeight / 2.0),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // K线图 底部边界线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: uperChartHeight),
                      stopPoint: CGPoint(x: rect.maxX, y: uperChartHeight),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // 交易量图 上边界线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: uperChartHeight + theme.xAxisHeitht),
                      stopPoint: CGPoint(x: rect.maxX, y: uperChartHeight + theme.xAxisHeitht),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
        // 交易量图 内上边线 即最高交易量格线
        self.drawline(context,
                      startPoint: CGPoint(x: 0, y: uperChartHeight + theme.xAxisHeitht + theme.volumeMaxGap),
                      stopPoint: CGPoint(x: rect.maxX, y: uperChartHeight + theme.xAxisHeitht + theme.volumeMaxGap),
                      color: theme.borderColor,
                      lineWidth: theme.frameWidth)
    }
}
