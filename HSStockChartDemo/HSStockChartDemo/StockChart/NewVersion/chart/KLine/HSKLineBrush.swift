//
//  HSKLineBrush.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSKLineBrush: HSBasicBrush {

    var context: CGContext?
    var klineModels: [HSKLineModel] = [] // K线的数据模型
    var positionModels: [HSKLineCoordModel] = [] // K线的坐标模型
    var theme: HSKLineTheme = HSKLineTheme()
    var kLineType: HSChartType = .kLineForDay
    
    init(frame: CGRect,
         context: CGContext,
         klineModels: [HSKLineModel],
         positionModels: [HSKLineCoordModel],
         theme: HSKLineTheme,
         kLineType: HSChartType) {
        
        super.init(frame: frame)
        
        self.context = context
        self.klineModels = klineModels
        self.positionModels = positionModels
        self.theme = theme
        self.kLineType = kLineType
        
        self.drawKLine()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 画出 K 线图
    func drawKLine() {
        guard let context = self.context else {
            return
        }
        // var lastDate: Date?
        for (index, position) in positionModels.enumerated() {
            let open = positionModels[index].openPoint.y
            let close = positionModels[index].closePoint.y
            var strokeColor = UIColor.clear
            // 注意是坐标的比较
            if open < close {
                strokeColor = theme.candleFallColor
                
            } else if open > close {
                strokeColor = theme.candleRiseColor
                
            } else {
                if index > 1 {
                    let prePosition = positionModels[index-1]
                    if open >= prePosition.closePoint.y {
                        strokeColor = theme.candleFallColor
                    } else {
                        strokeColor = theme.candleRiseColor
                    }
                } else {
                    //strokeColor = VYCommon.mainGreenColor
                }
            }
            
            // K线
            self.drawline(context,
                          startPoint: position.openPoint,
                          stopPoint: position.closePoint,
                          color: strokeColor,
                          lineWidth: theme.candleWidth)
            // 影线
            self.drawline(context,
                          startPoint: position.lowPoint,
                          stopPoint: position.highPoint,
                          color: strokeColor,
                          lineWidth: theme.lineWidth)
            // MA 线
            if index > 0 {
                self.drawline(context, startPoint: positionModels[index - 1].ma5Point, stopPoint: position.ma5Point, color: theme.ma5Color, lineWidth: theme.lineWidth)
                self.drawline(context, startPoint: positionModels[index - 1].ma10Point, stopPoint: position.ma10Point, color: theme.ma10Color, lineWidth: theme.lineWidth)
                self.drawline(context, startPoint: positionModels[index - 1].ma20Point, stopPoint: position.ma20Point, color: theme.ma20Color, lineWidth: theme.lineWidth)
            }
            
            // 交易量
            self.drawline(context,
                          startPoint: position.volumeStartPoint,
                          stopPoint: position.volumeEndPoint,
                          color: strokeColor,
                          lineWidth: theme.candleWidth)
            
        }
    }
    
    // 画时间和竖线标记
    func drawTimeLineMark(_ context: CGContext, xPosition: CGFloat, dateString: String) {
        self.drawline(context,
                      startPoint: CGPoint(x: xPosition, y: 0),
                      stopPoint: CGPoint(x: xPosition,  y: self.frame.height * theme.kLineChartHeightScale), color: theme.borderColor, lineWidth: 0.5)
        
        self.drawline(context,
                      startPoint: CGPoint(x: xPosition, y: self.frame.height * theme.kLineChartHeightScale + theme.xAxisHeitht),
                      stopPoint: CGPoint(x: xPosition, y: self.frame.height), color: theme.borderColor, lineWidth: 0.5)
        
        let dateStrAtt = NSMutableAttributedString(string: dateString, attributes: theme.xAxisLabelAttribute)
        let dateStrAttSize = dateStrAtt.size()
        self.drawLabel(context,
                       attributesText: dateStrAtt,
                       rect: CGRect(x: xPosition - dateStrAttSize.width/2, y: self.frame.height * theme.kLineChartHeightScale, width: dateStrAttSize.width, height: dateStrAttSize.height))
    }
}
