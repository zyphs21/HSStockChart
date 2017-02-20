//
//  HSChartFrame.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/14.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSChartFrame: UIView {

    var theme: HSKLineTheme = HSKLineTheme()
    var uperChartHeight: CGFloat {
        get {
            return theme.kLineChartHeightScale * self.frame.height
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawLine()
    }
    
    init(frame: CGRect, theme: HSKLineTheme) {
        super.init(frame: frame)
        
        self.theme = theme
        drawLine()
    }
    
    func drawLine() {
        let linePath = UIBezierPath()
        
        // K线图 顶部边界线
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: 0))
        
        // K线图 内上边线 即最高价格线
        linePath.move(to: CGPoint(x: 0, y: theme.viewMinYGap))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: theme.viewMinYGap))
        
         // K线图 内下边线 即最低价格线
        linePath.move(to: CGPoint(x: 0, y: uperChartHeight - theme.viewMinYGap))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight - theme.viewMinYGap))
        
        // K线图 中间的横线
        linePath.move(to: CGPoint(x: 0, y: uperChartHeight / 2.0))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight / 2.0))
        
        // K线图 底部边界线
        linePath.move(to: CGPoint(x: 0, y: uperChartHeight))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight))
        
        // 交易量图 上边界线
        linePath.move(to: CGPoint(x: 0, y: uperChartHeight + theme.xAxisHeitht))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight + theme.xAxisHeitht))
        
        // 交易量图 内上边线 即最高交易量格线
        linePath.move(to: CGPoint(x: 0, y: uperChartHeight + theme.xAxisHeitht + theme.volumeMaxGap))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight + theme.xAxisHeitht + theme.volumeMaxGap))
        
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = theme.frameWidth
        lineLayer.strokeColor = theme.borderColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.path = linePath.cgPath
        
        self.layer.addSublayer(lineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
