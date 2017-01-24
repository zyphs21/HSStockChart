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
    var contentRect: CGRect = CGRect.zero
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
    var uperChartDrawAreaRect: CGRect = CGRect.zero
    var uperChartDrawAreaTop: CGFloat = 0
    var uperChartDrawAreaBottom: CGFloat = 0
    var uperChartDrawAreaHeight: CGFloat = 0
    
    // 上部分图表里，画图区域间隔与边距的间隔
    var uperChartDrawingAreaMargin: CGFloat = 10
    
    // 下部分图表区域
    var lowerChartRect: CGRect = CGRect.zero
    var lowerChartTop: CGFloat = 0
    var lowerChartBottom: CGFloat = 0
    var lowerChartHeight: CGFloat = 0
    var lowerChartDrawAreaMargin: CGFloat = 10
    
    var yAxisLabelEdgeInset: CGFloat = 5
    
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
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxRatio: CGFloat = 0
    var minRatio: CGFloat = 0
    var maxVolume: CGFloat = 0
    
    var gridBackgroundColor = UIColor.white
    var borderColor = UIColor(rgba: "#e4e4e4")
    var borderWidth: CGFloat = 1
    
    var xAxisHeitht: CGFloat = 30
    
    var longPressToHighlightEnabled = false
    var highlightLineCurrentIndex: Int = 0
    var highlightLineCurrentPoint: CGPoint = CGPoint.zero
    
    
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
    
    fileprivate func commonInit() {
        
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
            
        uperChartDrawAreaRect = CGRect(x: contentRect.origin.x, y: contentRect.origin.y + uperChartDrawingAreaMargin, width: contentRect.width, height: uperChartHeight - uperChartDrawingAreaMargin * 2)
        
        lowerChartRect = CGRect(x: contentRect.origin.x, y: contentRect.origin.y + uperChartHeight + xAxisHeitht, width: contentRect.width, height: contentRect.height - uperChartHeight - xAxisHeitht)

        uperChartDrawAreaTop = uperChartDrawAreaRect.origin.y
        uperChartDrawAreaBottom = uperChartDrawAreaRect.origin.y + uperChartDrawAreaRect.size.height
        uperChartDrawAreaHeight = uperChartDrawAreaRect.size.height
        
        lowerChartTop = lowerChartRect.origin.y
        lowerChartBottom = lowerChartRect.origin.y + lowerChartRect.size.height
        lowerChartHeight = lowerChartRect.size.height
    }
    
    
    // MARK: - Common Function
    
    func drawChartFrame(_ context: CGContext, rect: CGRect) {
        context.setFillColor(gridBackgroundColor.cgColor)
        context.fill(rect)
        
        //画外面边框
        context.setLineWidth(self.borderWidth / 2.0)
        context.setStrokeColor(self.borderColor.cgColor)
        context.stroke(CGRect(x: self.contentLeft, y: self.contentTop, width: self.contentWidth, height: uperChartHeight))
        
        //画交易量边框
        context.stroke(CGRect(x: contentLeft, y: lowerChartTop, width: contentWidth, height: lowerChartHeight))
    }

    func drawYAxisLabel(_ context: CGContext, labelString: String, yAxis: CGFloat, isLeft: Bool, isInLineCenter: Bool = true) {
        
        let labelAttribute = isInLineCenter ? self.yAxisLabelAttribute : self.annotationLabelAttribute
        let valueAttributedString = NSMutableAttributedString(string: labelString, attributes: labelAttribute)
        let valueAttributedStringSize = valueAttributedString.size()
        let labelInLineCenterSize = isInLineCenter ? valueAttributedStringSize.height/2.0 : 0
        var labelX: CGFloat = 0
        if isLeft {
            labelX = self.contentLeft + yAxisLabelEdgeInset
        } else {
            labelX = self.contentRight - valueAttributedStringSize.width - yAxisLabelEdgeInset
        }
        let labelY: CGFloat = yAxis - labelInLineCenterSize
        
        self.drawLabel(context, attributesText: valueAttributedString, rect: CGRect(x: labelX, y: labelY, width: valueAttributedStringSize.width, height: valueAttributedStringSize.height))
    }
    
    
    func drawLongPressHighlight(_ context: CGContext, pricePoint: CGPoint, volumePoint: CGPoint, idex: Int, value: AnyObject, color: UIColor, lineWidth: CGFloat, isShowVolume: Bool = true) {
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerStr = ""
        var volumeMarkerString = ""
        
        if value.isKind(of: HSTimeLineModel.self) {
            let entity = value as! HSTimeLineModel
            rightMarkerStr = self.formatValue(entity.price)
            bottomMarkerString = entity.time
            leftMarkerString = self.formatRatio(entity.rate)
            volumeMarkerString = entity.volume.toStringWithFormat("%.2f")
            
        } else if value.isKind(of: HSKLineModel.self){
            let entity = value as! HSKLineModel
            rightMarkerStr = self.formatValue(entity.close)
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            leftMarkerString = entity.rate.toStringWithFormat(".2") + "%"
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
        }else{
            
            return
        }
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        
        context.beginPath()
        context.move(to: CGPoint(x: pricePoint.x, y: self.contentTop))
        context.addLine(to: CGPoint(x: pricePoint.x, y: self.contentBottom))
        context.strokePath()
        
        context.beginPath()
        context.move(to: CGPoint(x: self.contentLeft, y: pricePoint.y))
        context.addLine(to: CGPoint(x: self.contentRight, y: pricePoint.y))
        context.strokePath()
        
        if isShowVolume {
            context.beginPath()
            context.move(to: CGPoint(x: self.contentLeft, y: volumePoint.y))
            context.addLine(to: CGPoint(x: self.contentRight, y: volumePoint.y))
            context.strokePath()
        }
        
        let radius:CGFloat = 3.0
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: pricePoint.x-(radius/2.0), y: pricePoint.y-(radius/2.0), width: radius, height: radius))
        
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
                       rect: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = self.uperChartHeight + self.contentTop
        self.drawLabel(context,
                       attributesText: bottomMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        labelX = self.contentRight - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        if isShowVolume {
            labelX = self.contentRight - volumeMarkerStringAttributeSize.width
            labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
            self.drawLabel(context,
                           attributesText: volumeMarkerStringAttribute,
                           rect: CGRect(x: labelX, y: labelY, width: volumeMarkerStringAttributeSize.width, height: volumeMarkerStringAttributeSize.height))
        }
    }

    
    func getLabelAttribute(_ foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> [String: AnyObject] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: foregroundColor]
    }
    
    // MARK: - Drawing Util Function
    
    func formatValue(_ value: CGFloat) -> String {
        //return NSString(format: "%.2f", value) as String
        return String(format: "%.2f", value)
    }
    
    func formatRatio(_ value: CGFloat) -> String {
        return String(format: "%.2f", value * 100) + "%"
    }
    
    func formatWithVolume(_ argVolume: CGFloat) -> String{
        let volume = argVolume / 100.0;
        
        if (volume < 10000.0) {
            return "手 ";
        }else if (volume > 10000.0 && volume < 100000000.0){
            return "万手 ";
        }else{
            return "亿手 ";
        }
    }
    
    func formatNumWithVolume(_ argVolume: CGFloat) -> String{
        let volume = argVolume/100.0;
        if (volume < 10000.0) {
            return NSString(format: "%.0f", volume) as String
        }else if (volume > 10000.0 && volume < 100000000.0){
            return NSString(format: "%.2f", volume/10000.0) as String
        }else{
            return NSString(format: "%.2f", volume/100000000.0) as String
        }
    }
    
    // 画线
    func drawline(_ context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, color: UIColor, lineWidth: CGFloat, isDashLine: Bool = false) {
        if (startPoint.x < self.contentLeft || stopPoint.x > self.contentRight || startPoint.y < self.contentTop || stopPoint.y < self.contentTop) {
            return
        }
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.beginPath()
        context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context.addLine(to: CGPoint(x: stopPoint.x, y: stopPoint.y))
        if isDashLine {
            let arr: [CGFloat] = [6, 3]
            context.setLineDash(phase: 0, lengths: arr)
        }
        context.strokePath()
        context.restoreGState()
    }
    
    // 画标签
    func drawLabel(_ context: CGContext, attributesText: NSAttributedString, rect: CGRect) {
        context.setFillColor(UIColor.clear.cgColor)
        attributesText.draw(in: rect)
    }
    
    // 画柱形
    func drawColumnRect(_ context: CGContext, rect: CGRect, color: UIColor) {
        if ((rect.origin.x + rect.size.width) > self.contentRight) {
            return
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    // 画渐变色
    func drawLinearGradient(_ context: CGContext, path: CGPath, alpha: CGFloat, startColor: CGColor, endColor: CGColor) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [startColor, endColor]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let pathRect = path.boundingBox
        
        //具体方向可根据需求修改
        let startPoint = CGPoint(x: pathRect.midX, y: pathRect.minY)
        let endPoint = CGPoint(x: pathRect.midX, y: pathRect.maxY)
        
        context.saveGState()
        context.addPath(path)
        context.clip()
        context.setAlpha(0.5)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        context.restoreGState()
    }

}
