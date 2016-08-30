//
//  BaseStockChartView.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSBaseStockChartView: UIView {
    
    
    //MARK: - Properties
    
    var statusView = UIView()
    var statusLabel = UILabel()
    var act = UIActivityIndicatorView()
    
    // 图表距边缘距离
    var offsetLeft: CGFloat = 0
    var offsetTop: CGFloat = 10
    var offsetRight: CGFloat = 0
    var offsetBottom: CGFloat = 10
    
    // 整个图表的区域
    var contentRect: CGRect = CGRectZero
    var contentTop: CGFloat = 0
    var contentLeft: CGFloat = 0
    var contentRight: CGFloat = 0
    var contentBottom: CGFloat = 0
    var contentWidth: CGFloat = 0
    var contentHeight: CGFloat = 0
    
    var chartHeight: CGFloat = 0
    var chartWidth: CGFloat = 0
    
    var uperChartHeightScale: CGFloat = 0.7 //60%的空间是上部分的走势图
    var uperChartHeight: CGFloat = 0
    var uperChartBottom: CGFloat = 0
    
    // 上部分图表的内部画图区域
    var uperChartDrawAreaRect: CGRect = CGRectZero
    var uperChartDrawAreaTop: CGFloat = 0
    var uperChartDrawAreaBottom: CGFloat = 0
    var uperChartDrawAreaHeight: CGFloat = 0
    
    // 上部分图表里，画图区域间隔与边距的间隔
    var uperChartDrawingAreaMargin: CGFloat = 10
    
    // 下部分图表区域
    var lowerChartRect: CGRect = CGRectZero
    var lowerChartTop: CGFloat = 0
    var lowerChartBottom: CGFloat = 0
    var lowerChartHeight: CGFloat = 0
    var lowerChartDrawAreaMargin: CGFloat = 5
    
    var yAxisLabelEdgeInset: CGFloat = 5
    
    var yAxisLabelAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(9),
                                  NSBackgroundColorAttributeName: UIColor.clearColor(),
                                  NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var xAxisLabelAttribute = [NSFontAttributeName:UIFont.systemFontOfSize(10),
                              NSBackgroundColorAttributeName: UIColor.clearColor(),
                              NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var highlightAttribute = [NSFontAttributeName:UIFont.systemFontOfSize(10),
                                  NSBackgroundColorAttributeName: UIColor(rgba: "#8695a6"),
                                  NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    var maxPrice = CGFloat.min
    var minPrice = CGFloat.max
    var maxRatio = CGFloat.min
    var minRatio = CGFloat.max
    var maxVolume = CGFloat.min
    
    var gridBackgroundColor = UIColor.whiteColor()
    var borderColor = UIColor(rgba: "#e4e4e4")
    var borderWidth: CGFloat = 1
    
    var xAxisHeitht: CGFloat = 30
    
    var longPressToHighlightEnabled = false
    var highlightLineCurrentIndex: Int = 0
    var highlightLineCurrentPoint: CGPoint = CGPointZero
    
    
    //MARK: - Life Circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(frame: CGRect, uperChartHeightScale: CGFloat, topOffSet: CGFloat, leftOffSet: CGFloat, bottomOffSet: CGFloat, rightOffSet: CGFloat) {
        super.init(frame: frame)
        
        self.uperChartHeightScale = uperChartHeightScale
        self.offsetLeft = leftOffSet
        self.offsetRight = rightOffSet
        self.offsetTop = topOffSet
        self.offsetBottom = bottomOffSet

        commonInit()
    }
    
    deinit {
        print("-----HSBaseStockChartView Deinit-------")
    }
    
    private func commonInit() {
        chartHeight = frame.height
        chartWidth = frame.width
    
        contentRect.origin.x = offsetLeft
        contentRect.origin.y = offsetTop
        contentRect.size.width = self.chartWidth - offsetLeft - offsetRight
        contentRect.size.height = self.chartHeight - offsetBottom - offsetTop
        
        contentTop = contentRect.origin.y
        contentLeft = contentRect.origin.x
        contentBottom = contentRect.origin.y + contentRect.size.height
        contentRight = contentRect.origin.x + contentRect.size.width
        contentWidth = contentRect.size.width
        contentHeight = contentRect.size.height
        
        uperChartHeight = (chartHeight - xAxisHeitht) * uperChartHeightScale
        uperChartBottom = uperChartHeight + contentTop
            
        uperChartDrawAreaRect = CGRectMake(contentRect.origin.x, contentRect.origin.y + uperChartDrawingAreaMargin, contentRect.width, uperChartHeight - uperChartDrawingAreaMargin * 2)
        
        lowerChartRect = CGRectMake(contentRect.origin.x, contentRect.origin.y + uperChartHeight + xAxisHeitht, contentRect.width, contentRect.height - uperChartHeight - xAxisHeitht)

        uperChartDrawAreaTop = uperChartDrawAreaRect.origin.y
        uperChartDrawAreaBottom = uperChartDrawAreaRect.origin.y + uperChartDrawAreaRect.size.height
        uperChartDrawAreaHeight = uperChartDrawAreaRect.size.height
        
        lowerChartTop = lowerChartRect.origin.y
        lowerChartBottom = lowerChartRect.origin.y + lowerChartRect.size.height
        lowerChartHeight = lowerChartRect.size.height
    }
    
    
    // MARK: - Common Function
    
    func drawGridBackground(context: CGContextRef, rect: CGRect) {
        CGContextSetFillColorWithColor(context, gridBackgroundColor.CGColor)
        CGContextFillRect(context, rect)
        
        //画外面边框
        CGContextSetLineWidth(context, self.borderWidth / 2)
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
        CGContextStrokeRect(context, CGRectMake(self.contentLeft, self.contentTop, self.contentWidth, uperChartHeight))
        
        //画交易量边框
        CGContextStrokeRect(context, CGRectMake(contentLeft, lowerChartTop, contentWidth, lowerChartHeight))
    }

    func drawYAxisLabel(context: CGContextRef, labelString: String, yAxis: CGFloat, isLeft: Bool) {
        
        let valueAttributedString = NSMutableAttributedString(string: labelString, attributes: self.yAxisLabelAttribute)
        let valueAttributedStringSize = valueAttributedString.size()
        var labelX: CGFloat = 0
        if isLeft {
            labelX = self.contentLeft + yAxisLabelEdgeInset
        } else {
            labelX = self.contentRight - valueAttributedStringSize.width - yAxisLabelEdgeInset
        }
        let labelY: CGFloat = yAxis - valueAttributedStringSize.height / 2.0
        
        self.drawLabel(context, attributesText: valueAttributedString, rect: CGRectMake(labelX, labelY, valueAttributedStringSize.width, valueAttributedStringSize.height))
    }
    
    
    func drawLongPressHighlight(context: CGContextRef, pricePoint: CGPoint, volumePoint: CGPoint, idex: Int, value: AnyObject, color: UIColor, lineWidth: CGFloat) {
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerStr = ""
        var volumeMarkerString = ""
        
        if value.isKindOfClass(TimeLineEntity.self) {
            let entity = value as! TimeLineEntity
            rightMarkerStr = self.formatValue(entity.price)
            bottomMarkerString = entity.currtTime
            leftMarkerString = entity.rate.toStringWithFormat("%.2f")
            volumeMarkerString = entity.volume.toStringWithFormat("%.2f")
            
        } else if value.isKindOfClass(KLineEntity.self){
            let entity = value as! KLineEntity
            rightMarkerStr = self.formatValue(entity.close)
            bottomMarkerString = entity.date
            leftMarkerString = entity.rate.toStringWithFormat("%.2f")
            volumeMarkerString = entity.volume.toStringWithFormat("%.2f")
        }else{
            
            return
        }
        
        CGContextSetStrokeColorWithColor(context,color.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, pricePoint.x, self.contentTop)
        CGContextAddLineToPoint(context, pricePoint.x, self.contentBottom)
        CGContextStrokePath(context)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, self.contentLeft, pricePoint.y)
        CGContextAddLineToPoint(context, self.contentRight, pricePoint.y)
        CGContextStrokePath(context)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, self.contentLeft, volumePoint.y)
        CGContextAddLineToPoint(context, self.contentRight, volumePoint.y)
        CGContextStrokePath(context)
        
        let radius:CGFloat = 3.0
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(pricePoint.x-(radius/2.0), pricePoint.y-(radius/2.0), radius, radius))
        
        let leftMarkerStringAttribute = NSMutableAttributedString(string: leftMarkerString, attributes: highlightAttribute)
        let bottomMarkerStringAttribute = NSMutableAttributedString(string: bottomMarkerString, attributes: highlightAttribute)
        let rightMarkerStringAttribute = NSMutableAttributedString(string: rightMarkerStr, attributes: highlightAttribute)
        let volumeMarkerStringAttribute = NSMutableAttributedString(string: volumeMarkerString, attributes: highlightAttribute)
        
        let leftMarkerStringAttributeSize = leftMarkerStringAttribute.size()
        let bottomMarkerStringAttributeSize = bottomMarkerStringAttribute.size()
        let rightMarkerStringAttributeSize = rightMarkerStringAttribute.size()
        let volumeMarkerStringAttributeSize = volumeMarkerStringAttribute.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        labelX = self.contentLeft
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: leftMarkerStringAttribute,
                       rect: CGRectMake(labelX, labelY, leftMarkerStringAttributeSize.width, leftMarkerStringAttributeSize.height))
        
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = self.uperChartHeight + self.contentTop
        self.drawLabel(context,
                       attributesText: bottomMarkerStringAttribute,
                       rect: CGRectMake(labelX, labelY, bottomMarkerStringAttributeSize.width, bottomMarkerStringAttributeSize.height))
        
        labelX = self.contentRight - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStringAttribute,
                       rect: CGRectMake(labelX, labelY, rightMarkerStringAttributeSize.width, rightMarkerStringAttributeSize.height))
        
        labelX = self.contentRight - volumeMarkerStringAttributeSize.width
        labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: volumeMarkerStringAttribute,
                       rect: CGRectMake(labelX, labelY, volumeMarkerStringAttributeSize.width, volumeMarkerStringAttributeSize.height))
    }
    
    
    // MARK: - Drawing Util Function
    
    func formatValue(value: CGFloat) -> String {
        return NSString(format: "%.2f", value) as String
    }
    
    func formatWithVolume(argVolume: CGFloat) -> String{
        let volume = argVolume / 100.0;
        
        if (volume < 10000.0) {
            return "手 ";
        }else if (volume > 10000.0 && volume < 100000000.0){
            return "万手 ";
        }else{
            return "亿手 ";
        }
    }
    
    func formatNumWithVolume(argVolume: CGFloat) -> String{
        let volume = argVolume/100.0;
        if (volume < 10000.0) {
            return NSString(format: "%.0f", volume) as String
        }else if (volume > 10000.0 && volume < 100000000.0){
            return NSString(format: "%.2f", volume/10000.0) as String
        }else{
            return NSString(format: "%.2f", volume/100000000.0) as String
        }
    }
    
    func drawline(context: CGContextRef, startPoint: CGPoint, stopPoint: CGPoint, color: UIColor, lineWidth: CGFloat, isDashLine: Bool = false) {
        if (startPoint.x < self.contentLeft || stopPoint.x > self.contentRight || startPoint.y < self.contentTop || stopPoint.y < self.contentTop) {
            return
        }
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, startPoint.x, startPoint.y)
        CGContextAddLineToPoint(context, stopPoint.x, stopPoint.y)
        if isDashLine {
            let arr: [CGFloat] = [6, 3]
            CGContextSetLineDash(context, 0, arr, arr.count)
        }
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
    func drawLabel(context: CGContextRef,attributesText: NSAttributedString, rect: CGRect) {
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        attributesText.drawInRect(rect)
    }
    
    func drawColumnRect(context: CGContextRef, rect: CGRect, color: UIColor) {
        if ((rect.origin.x + rect.size.width) > self.contentRight) {
            return
        }
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
    }
    
    func drawLinearGradient(context: CGContextRef, path: CGPathRef, alpha: CGFloat, startColor: CGColorRef, endColor: CGColorRef) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [startColor, endColor]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        let pathRect = CGPathGetBoundingBox(path)
        
        //具体方向可根据需求修改
        let startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect))
        let endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect))
        
        CGContextSaveGState(context)
        CGContextAddPath(context, path)
        CGContextClip(context)
        CGContextSetAlpha(context, 0.5)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
        CGContextRestoreGState(context)
    }

}
