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
    
    //图表距边缘距离
    var offsetLeft: CGFloat = 0
    var offsetTop: CGFloat = 10
    var offsetRight: CGFloat = 0
    var offsetBottom: CGFloat = 10
    
    var chartHeight: CGFloat = 0
    var chartWidth: CGFloat = 0
    
    var contentRect: CGRect = CGRectZero // 整个图表的区域
    var contentTop: CGFloat = 0
    var contentLeft: CGFloat = 0
    var contentRight: CGFloat = 0
    var contentBottom: CGFloat = 0
    var contentWidth: CGFloat = 0
    var contentHeight: CGFloat = 0
    
    var uperChartHeightScale: CGFloat = 0.6 //60%的空间是上部分的走势图
    var uperChartHeight: CGFloat = 0
    
    var uperChartDrawAreaRect: CGRect = CGRectZero // 上部分图表的内部画图区域
    var uperChartDrawAreaTop: CGFloat = 0
    var uperChartDrawAreaBottom: CGFloat = 0
    var uperChartDrawAreaHeight: CGFloat = 0
    
    var gapBetweenInnerAndOuterRect: CGFloat = 0
    
    var leftYAxisAttributedDic = [NSFontAttributeName: UIFont.systemFontOfSize(9),
                                  NSBackgroundColorAttributeName: UIColor.clearColor(),
                                  NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var xAxisAttributedDic = [NSFontAttributeName:UIFont.systemFontOfSize(10),
                              NSBackgroundColorAttributeName: UIColor.clearColor(),
                              NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    var highlightAttributedDic = [NSFontAttributeName:UIFont.systemFontOfSize(10),
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
    
    init(frame: CGRect, topOffSet: CGFloat, leftOffSet: CGFloat, bottomOffSet: CGFloat, rightOffSet: CGFloat) {
        super.init(frame: frame)
        
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
        
        uperChartHeight = (chartHeight - xAxisHeitht) * uperChartHeightScale
        
        contentRect.origin.x = offsetLeft
        contentRect.origin.y = offsetTop
        contentRect.size.width = self.chartWidth - offsetLeft - offsetRight
        contentRect.size.height = self.chartHeight - offsetBottom - offsetTop
        
        uperChartDrawAreaRect = CGRectMake(contentRect.origin.x, contentRect.origin.y + 10, contentRect.width, uperChartHeight - 20)
        
        contentTop = contentRect.origin.y
        contentLeft = contentRect.origin.x
        contentBottom = contentRect.origin.y + contentRect.size.height
        contentRight = contentRect.origin.x + contentRect.size.width
        contentWidth = contentRect.size.width
        contentHeight = contentRect.size.height
        
        uperChartDrawAreaTop = uperChartDrawAreaRect.origin.y
        uperChartDrawAreaBottom = uperChartDrawAreaRect.origin.y + uperChartDrawAreaRect.size.height
        uperChartDrawAreaHeight = uperChartDrawAreaRect.size.height
        
        gapBetweenInnerAndOuterRect = uperChartDrawAreaTop - contentTop
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
        CGContextStrokeRect(context, CGRectMake(contentLeft, uperChartHeight + xAxisHeitht, contentWidth, (contentBottom - uperChartHeight - xAxisHeitht)))
    }
    
    func drawYAxisLabel(context: CGContextRef, max: CGFloat, mid: CGFloat, min: CGFloat) {
        let maxPriceStr = self.formatPrice(max)
//        let midPriceStr = self.formatPrice(mid)
        let minPriceStr = self.formatPrice(min)
        
        let maxPriceAttStr = NSMutableAttributedString(string: maxPriceStr, attributes: self.leftYAxisAttributedDic)
//        let midPriceAttStr = NSMutableAttributedString(string: midPriceStr, attributes: self.leftYAxisAttributedDic)
        let minPriceAttStr = NSMutableAttributedString(string: minPriceStr, attributes: self.leftYAxisAttributedDic)
        
        let sizeMaxPriceAttStr = maxPriceAttStr.size()
//        let sizeMidPriceAttStr = midPriceAttStr.size()
        let sizeMinPriceAttStr = minPriceAttStr.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        let edgeInset: CGFloat = 5
        
        labelX = self.contentRight - sizeMaxPriceAttStr.width - edgeInset
        labelY = self.uperChartDrawAreaTop - sizeMaxPriceAttStr.height / 2.0
        self.drawLabel(context, attributesText: maxPriceAttStr, rect: CGRectMake(labelX, labelY, sizeMaxPriceAttStr.width, sizeMaxPriceAttStr.height))
        
//        labelX = self.contentRight - sizeMidPriceAttStr.width - edgeInset
//        labelY = (uperChartHeight / 2.0 + self.contentTop) - sizeMidPriceAttStr.height / 2.0
//        self.drawLabel(context, attributesText: midPriceAttStr, rect: CGRectMake(labelX, labelY, sizeMidPriceAttStr.width, sizeMidPriceAttStr.height))
        
        labelX = self.contentRight - sizeMinPriceAttStr.width - edgeInset
        labelY = (uperChartHeight + self.contentTop - gapBetweenInnerAndOuterRect - sizeMinPriceAttStr.height / 2.0)
        self.drawLabel(context, attributesText: minPriceAttStr, rect: CGRectMake(labelX, labelY, sizeMinPriceAttStr.width, sizeMinPriceAttStr.height))
    }
    
    func drawYAxisLabel(context: CGContextRef, value: CGFloat, y: CGFloat) {
        let valueString = self.formatPrice(value)
        let valueAttributedString = NSMutableAttributedString(string: valueString, attributes: self.leftYAxisAttributedDic)
        let valueAttributedStringSize = valueAttributedString.size()
        let edgeInset: CGFloat = 5
        let labelX: CGFloat = self.contentRight - valueAttributedStringSize.width - edgeInset
        let labelY: CGFloat = y - valueAttributedStringSize.height / 2.0
        self.drawLabel(context, attributesText: valueAttributedString, rect: CGRectMake(labelX, labelY, valueAttributedStringSize.width, valueAttributedStringSize.height))
    }
    
    
    func drawLongPressHighlight(context: CGContextRef, pricePoint: CGPoint, volumePoint: CGPoint, idex: Int, value: AnyObject, color: UIColor, lineWidth: CGFloat) {
        var leftMarkerStr = ""
        var bottomMarkerStr = ""
        var rightMarkerStr = ""
        var volumeMarkerStr = ""
        
        if value.isKindOfClass(TimeLineEntity.self) {
            let entity = value as! TimeLineEntity
            rightMarkerStr = self.formatPrice(entity.lastPirce)
            bottomMarkerStr = entity.currtTime
            leftMarkerStr = entity.rate.toStringWithFormat("%.2f")
            volumeMarkerStr = entity.volume.toStringWithFormat("%.2f")
            
        } else if value.isKindOfClass(KLineEntity.self){
            let entity = value as! KLineEntity
            rightMarkerStr = self.formatPrice(entity.close)
            bottomMarkerStr = entity.date
            leftMarkerStr = entity.rate.toStringWithFormat("%.2f")
            volumeMarkerStr = entity.volume.toStringWithFormat("%.2f")
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
        
        let leftMarkerStrAtt = NSMutableAttributedString(string: leftMarkerStr, attributes: highlightAttributedDic)
        let bottomMarkerStrAtt = NSMutableAttributedString(string: bottomMarkerStr, attributes: highlightAttributedDic)
        let rightMarkerStrAtt = NSMutableAttributedString(string: rightMarkerStr, attributes: highlightAttributedDic)
        let volumeMarkerStrAtt = NSMutableAttributedString(string: volumeMarkerStr, attributes: highlightAttributedDic)
        
        let leftMarkerStrAttSize = leftMarkerStrAtt.size()
        let bottomMarkerStrAttSize = bottomMarkerStrAtt.size()
        let rightMarkerStrAttSize = rightMarkerStrAtt.size()
        let volumeMarkerStrAttSize = volumeMarkerStrAtt.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        labelX = self.contentLeft
        labelY = pricePoint.y - leftMarkerStrAttSize.height / 2.0
        self.drawLabel(context,
                       attributesText: leftMarkerStrAtt,
                       rect: CGRectMake(labelX, labelY, leftMarkerStrAttSize.width, leftMarkerStrAttSize.height))
        
        labelX = pricePoint.x - bottomMarkerStrAttSize.width / 2.0
        labelY = self.uperChartHeight + self.contentTop
        self.drawLabel(context,
                       attributesText: bottomMarkerStrAtt,
                       rect: CGRectMake(labelX, labelY, bottomMarkerStrAttSize.width, bottomMarkerStrAttSize.height))
        
        labelX = self.contentRight - rightMarkerStrAttSize.width
        labelY = pricePoint.y - rightMarkerStrAttSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStrAtt,
                       rect: CGRectMake(labelX, labelY, rightMarkerStrAttSize.width, rightMarkerStrAttSize.height))
        
        labelX = self.contentRight - volumeMarkerStrAttSize.width
        labelY = volumePoint.y - volumeMarkerStrAttSize.height / 2.0
        self.drawLabel(context,
                       attributesText: volumeMarkerStrAtt,
                       rect: CGRectMake(labelX, labelY, volumeMarkerStrAttSize.width, volumeMarkerStrAttSize.height))
    }
    
    
    // MARK: - Drawing Util Function
    
    func formatPrice(price: CGFloat) -> String {
        return NSString(format: "%.2f", price) as String
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
