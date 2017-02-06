//
//  TimeLineStockChartView.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSTimeLineView: HSBasicBrush {
    
    var theme = HSTimeLineTheme()
    var crossLine: HSCrossLine?
    var timeLine: HSTimeLineBrush?
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxRatio: CGFloat = 0
    var minRatio: CGFloat = 0
    var maxVolume: CGFloat = 0
    var priceMaxOffset : CGFloat = 0
    var priceUnit: CGFloat = 0
    var volumeUnit: CGFloat = 0

    var contentTop: CGFloat = 0
    var contentLeft: CGFloat = 0
    var contentRight: CGFloat = 0
    var contentBottom: CGFloat = 0
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat = 0
    
    var highLightIndex: Int = 0
    
    let countOfTimes = 240 // 分时线的横坐标
    let fiveDayCount = 1200 // 五日线总横坐标
    
    var showLongPressHighlight = false
    var showFiveDayLabel = false
    
    var volumeStep: CGFloat = 0
    
    var positionModels: [HSTimeLineCoordModel] = []
    var dataT: [HSTimeLineModel] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var uperChartHeight: CGFloat {
        get {
            return contentHeight * theme.uperChartHeightScale
        }
    }
    var lowerChartHeight: CGFloat {
        get {
            return contentHeight * (1 - theme.kLineChartHeightScale) - theme.xAxisHeitht
        }
    }
    var uperChartDrawAreaTop: CGFloat {
        get {
            return contentTop + theme.viewMinYGap
        }
    }
    var uperChartDrawAreaBottom: CGFloat {
        get {
            return contentTop + uperChartHeight - theme.viewMinYGap
        }
    }
    var lowerChartTop: CGFloat {
        get {
            return contentTop + uperChartHeight + theme.xAxisHeitht
        }
    }
    
    
    //MARK: - 构造方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestures()
    }
    
    init(frame: CGRect, topOffSet: CGFloat, leftOffSet: CGFloat, bottomOffSet: CGFloat, rightOffSet: CGFloat) {
        super.init(frame: frame)
        
        contentTop = topOffSet
        contentLeft = leftOffSet
        contentBottom = frame.height - bottomOffSet
        contentRight = frame.width - rightOffSet
        contentWidth = frame.width - rightOffSet - leftOffSet
        contentHeight = frame.height - topOffSet - bottomOffSet
        
        // 分时线的 frame 是固定 ，所以不需要在 drawRect 方法中调用
        timeLine = HSTimeLineBrush(frame: frame)
        crossLine = HSCrossLine(frame: frame)
        addGestures()
        
        self.addSubview(timeLine!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addGestures()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        
        if dataT.count > 0 {
            setMaxAndMinData()
            convertToPoints(context!, data: dataT)
            drawChartFrame(context!, rect: rect)
            drawChartLabel(context!)
            timeLine?.draw(context: context!, timeLineModels: dataT, positionModels: positionModels, theme: theme)
            if showLongPressHighlight {
                drawCrossLine(context!)
            }
            
        } else {
            // to show error page
        }
    }
    
    
    // MARK: - 
    
    func addGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    
    /// 求极限值
    func setMaxAndMinData() {
        if dataT.count > 0 {
            self.maxPrice = dataT[0].price
            self.minPrice = dataT[0].price
            self.maxRatio = dataT[0].rate
            self.minRatio = dataT[0].rate
            self.maxVolume = dataT[0].volume
            // 分时线和五日线的比较基准
            let toComparePrice = showFiveDayLabel ? dataT[0].price : dataT[0].preClosePx
            
            for i in 0 ..< dataT.count {
                let entity = dataT[i]
                self.priceMaxOffset = self.priceMaxOffset > fabs(entity.price - toComparePrice) ? self.priceMaxOffset : fabs(entity.price - toComparePrice)
                self.maxRatio = self.maxRatio > entity.rate ? self.maxRatio : entity.rate
                self.minRatio = self.minRatio < entity.rate ? self.minRatio : entity.rate
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
            }
            
            self.maxPrice = toComparePrice + self.priceMaxOffset
            self.minPrice = toComparePrice - self.priceMaxOffset
            
            for i in 0 ..< dataT.count {
                let entity = dataT[i]
                entity.avgPirce = entity.avgPirce < self.minPrice ? self.minPrice : entity.avgPirce
                entity.avgPirce = entity.avgPirce > self.maxPrice ? self.maxPrice : entity.avgPirce
            }
        }
    }
    
    
    /// 画图表边框
    ///
    /// - Parameters:
    ///   - context:
    ///   - rect:
    func drawChartFrame(_ context: CGContext, rect: CGRect) {
        
        context.setFillColor(theme.gridBackgroundColor.cgColor)
        context.fill(rect)
        
        //画外面边框
        context.setLineWidth(theme.borderWidth / 2.0)
        context.setStrokeColor(theme.borderColor.cgColor)
        context.stroke(CGRect(x: contentLeft, y: contentTop, width: contentWidth, height: uperChartHeight))
        
        //画交易量边框
        context.stroke(CGRect(x: contentLeft, y: lowerChartTop, width: contentWidth, height: lowerChartHeight))
        
        if showFiveDayLabel {
            //五日分时图的四条竖线
            let width = self.contentWidth / 5
            for i in 1 ..< 5 {
                let lineX = self.contentLeft + width * CGFloat(i)
                let startPoint = CGPoint(x: lineX, y: contentTop + uperChartHeight)
                let stopPoint = CGPoint(x: lineX, y: contentTop)
                self.drawline(context, startPoint: startPoint, stopPoint: stopPoint, color: theme.borderColor, lineWidth: theme.borderWidth / 2.0)
            }
            
        } else {
            //分时线的中间竖线
            let startPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: contentTop)
            let stopPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: uperChartHeight +  contentTop)
            self.drawline(context, startPoint: startPoint, stopPoint: stopPoint, color: theme.borderColor, lineWidth: theme.borderWidth / 2.0)
        }
        
        
        //画中间的横虚线
        if let temp = dataT.first {
            //日分时图中间区域线代表昨日的收盘价格，五日分时图的则代表五日内的第一天9点30分的价格
            let price = showFiveDayLabel ? temp.price : temp.preClosePx
            let preClosePriceYaxis = (self.maxPrice - price) * self.priceUnit + uperChartDrawAreaTop
            self.drawline(context,
                          startPoint: CGPoint(x: contentLeft, y: preClosePriceYaxis),
                          stopPoint: CGPoint(x: contentRight, y: preClosePriceYaxis),
                          color: theme.borderColor,
                          lineWidth: theme.borderWidth / 2.0,
                          isDashLine: true)
            self.drawYAxisLabel(context, str: price.toStringWithFormat(".2"), labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight,  yAxis: preClosePriceYaxis, isLeft: false)
        }
    }
    
    
    /// 画图表标签
    ///
    /// - Parameter context:
    func drawChartLabel(_ context:CGContext) {
        
        if showFiveDayLabel {
            
        } else {
            let drawAttributes = theme.xAxisLabelAttribute
            let startTimeAttributedString = NSMutableAttributedString(string: "9:30", attributes: drawAttributes)
            let sizestartTimeAttributedString = startTimeAttributedString.size()
            self.drawLabel(context, attributesText: startTimeAttributedString, rect: CGRect(x: self.contentLeft, y: contentTop + uperChartHeight, width: sizestartTimeAttributedString.width, height: sizestartTimeAttributedString.height))
            
            let midTimeAttStr = NSMutableAttributedString(string: "11:30/13:00", attributes: drawAttributes)
            let sizeMidTimeAttStr = midTimeAttStr.size()
            self.drawLabel(context, attributesText: midTimeAttStr, rect: CGRect(x: self.contentWidth / 2.0 + self.contentLeft - sizeMidTimeAttStr.width / 2.0, y: contentTop + uperChartHeight, width: sizeMidTimeAttStr.width, height: sizeMidTimeAttStr.height))
            
            let stopTimeAttStr = NSMutableAttributedString(string: "15:00", attributes: drawAttributes)
            let sizeStopTimeAttStr = stopTimeAttStr.size()
            self.drawLabel(context, attributesText: stopTimeAttStr, rect: CGRect(x: self.contentRight - sizeStopTimeAttStr.width, y: contentTop + uperChartHeight, width: sizeStopTimeAttStr.width, height: sizeStopTimeAttStr.height))
        }
        
        // 画纵坐标的最高和最低价格标签
        let maxPriceStr = maxPrice.toStringWithFormat(".2")
        let minPriceStr = minPrice.toStringWithFormat(".2")
        
        self.drawYAxisLabel(context, str: maxPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: contentTop + theme.viewMinYGap, isLeft: false)
        self.drawYAxisLabel(context, str: minPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: uperChartDrawAreaBottom, isLeft: false)
        
        // 最高成交量标签
        let y = contentBottom - maxVolume * volumeUnit
        self.drawline(context, startPoint: CGPoint(x: contentLeft, y: y), stopPoint: CGPoint(x: contentRight, y: y), color: theme.borderColor, lineWidth: theme.borderWidth / 4.0)
        let maxVolumeStr = maxVolume.toStringWithFormat(".2")
        self.drawYAxisLabel(context, str: maxVolumeStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: y, isLeft: false)
        
        let maxRatioStr = self.maxRatio.toPercentFormat()
        let minRatioStr = self.minRatio.toPercentFormat()
        
        // 画比率标签
        self.drawYAxisLabel(context, str: maxRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentLeft, yAxis: uperChartDrawAreaTop, isLeft: true)
        self.drawYAxisLabel(context, str: minRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentLeft, yAxis: uperChartDrawAreaBottom, isLeft: true)
    }
    
    
    /// 转换为坐标数据
    ///
    /// - Parameters:
    ///   - context:
    ///   - data: HSTimeLineModel 数组
    func convertToPoints(_ context: CGContext, data: [HSTimeLineModel]) {
        let maxDiff = self.maxPrice - self.minPrice
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (uperChartHeight - 2 * theme.viewMinYGap) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeMinGap) / self.maxVolume
        }
        
        if showFiveDayLabel {
            volumeStep = self.contentWidth / CGFloat(fiveDayCount)
        } else {
            volumeStep = self.contentWidth / CGFloat(countOfTimes)
        }

        let volumeWidth = volumeStep - volumeStep / 3.0
        self.theme.volumeWidth = volumeWidth
        self.positionModels.removeAll()
        for index in 0 ..< data.count {
            let centerX = contentLeft + volumeStep * CGFloat(index) + volumeStep / 2
            
            let xPosition = centerX
            let yPosition = (self.maxPrice - data[index].price) * priceUnit + self.uperChartDrawAreaTop
            let pricePoint = CGPoint(x: xPosition, y: yPosition)
            
            let avgYPosition = (self.maxPrice - data[index].avgPirce) * priceUnit + self.uperChartDrawAreaTop
            let avgPoint = CGPoint(x: xPosition, y: avgYPosition)
            
            let volumeHeight = data[index].volume * volumeUnit
            let volumeStartPoint = CGPoint(x: centerX, y: contentBottom - volumeHeight)
            let volumeEndPoint = CGPoint(x: centerX, y: contentBottom)
            
            let positionModel = HSTimeLineCoordModel()
            positionModel.pricePoint = pricePoint
            positionModel.avgPoint = avgPoint
            positionModel.volumeHeight = volumeHeight
            positionModel.volumeStartPoint = volumeStartPoint
            positionModel.volumeEndPoint = volumeEndPoint
            
            self.positionModels.append(positionModel)
        }
    }
    
    
    // MARK: - 画十字标记线
    
    func drawCrossLine(_ context: CGContext) {
        if highLightIndex < dataT.count {
            let entity = dataT[highLightIndex]
            let centerX = contentLeft + volumeStep * CGFloat(highLightIndex) + volumeStep / 2
            let highLightVolume = entity.volume * self.volumeUnit
            let highLightClose = ((self.maxPrice - entity.price) * self.priceUnit) + self.uperChartDrawAreaTop
            
            crossLine?.draw(context: context, theme: theme, contentRect: CGRect(x: contentLeft, y: contentTop, width: contentWidth, height: contentHeight), pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: contentBottom - highLightVolume), model: entity)
        }
    }
    
    
    // MARK: - 处理长按事件
    
    func handleLongPressGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            if (point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y < self.contentBottom) {
                self.showLongPressHighlight = true
                let index = Int((point.x - self.contentLeft) / volumeStep)
                
                if index > dataT.count {
                    self.highLightIndex = dataT.count - 1
                    
                } else {
                    self.highLightIndex = index
                }
                self.setNeedsDisplay()
            }
            if self.highLightIndex < dataT.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineLongpress"),
                                                object: self,
                                                userInfo: ["timeLineEntity": dataT[self.highLightIndex]])
            }
        }
        
        if recognizer.state == .ended {
            self.showLongPressHighlight = false
            self.setNeedsDisplay()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineUnLongpress"), object: self)
        }
    }
    
    
    // MARK: - 处理点击事件
    
    func handleTapGestureAction(_ recognizer: UIPanGestureRecognizer) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineChartDidTap"), object: recognizer.view?.tag)
    }
}




