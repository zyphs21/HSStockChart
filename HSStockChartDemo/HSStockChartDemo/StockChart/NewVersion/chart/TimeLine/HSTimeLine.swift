//
//  HSTimeLine.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/17.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSTimeLine: HSBasicBrush {

    var theme = HSTimeLineTheme()
    var crossLine: HSCrossLine?
    var timeLine: HSTimeLineBrush?
    
    var timeLineLayer = CAShapeLayer()
    var volumeLayer = CAShapeLayer()
    var maLineLayer = CAShapeLayer()
    var frameLayer = CAShapeLayer()
    var fillColorLayer = CAShapeLayer()
    
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
            self.drawTimeLineChart()
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
        
        addGestures()
        
        drawFrameLayer()
        drawXAxisLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addGestures()
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
    
    /// 横坐标轴的标签
    func drawXAxisLabel() {
        let drawAttributes = theme.xAxisLabelAttribute
        let startTimeAttributedString = NSMutableAttributedString(string: "9:30", attributes: drawAttributes)
        let sizestartTimeAttributedString = startTimeAttributedString.size()
        let startTime = getTextLayer(text: startTimeAttributedString.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: self.contentLeft, y: contentTop + uperChartHeight, width: sizestartTimeAttributedString.width, height: sizestartTimeAttributedString.height))
        
        let midTimeAttStr = NSMutableAttributedString(string: "11:30/13:00", attributes: drawAttributes)
        let sizeMidTimeAttStr = midTimeAttStr.size()
        let midTime = getTextLayer(text: midTimeAttStr.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame:  CGRect(x: self.contentWidth / 2.0 + self.contentLeft - sizeMidTimeAttStr.width / 2.0, y: contentTop + uperChartHeight, width: sizeMidTimeAttStr.width, height: sizeMidTimeAttStr.height))
        
        let stopTimeAttStr = NSMutableAttributedString(string: "15:00", attributes: drawAttributes)
        let sizeStopTimeAttStr = stopTimeAttStr.size()
        let stopTime = getTextLayer(text: stopTimeAttStr.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: self.contentRight - sizeStopTimeAttStr.width, y: contentTop + uperChartHeight, width: sizeStopTimeAttStr.width, height: sizeStopTimeAttStr.height))
        
        self.layer.addSublayer(startTime)
        self.layer.addSublayer(midTime)
        self.layer.addSublayer(stopTime)
    }
    
    /// 纵坐标轴的标签
    func drawYAxisLabel() {
        // 画纵坐标的最高和最低价格标签
        let maxPriceStr = maxPrice.toStringWithFormat(".2")
        let minPriceStr = minPrice.toStringWithFormat(".2")
        
        self.drawYAxisLabel(str: maxPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: contentTop + theme.viewMinYGap, isLeft: false)
        self.drawYAxisLabel(str: minPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: uperChartDrawAreaBottom, isLeft: false)
        
        // 最高成交量标签
        let y = contentBottom - maxVolume * volumeUnit
//        self.drawline(startPoint: CGPoint(x: contentLeft, y: y), stopPoint: CGPoint(x: contentRight, y: y), color: theme.borderColor, lineWidth: theme.borderWidth / 4.0)
        let maxVolumeStr = maxVolume.toStringWithFormat(".2")
        self.drawYAxisLabel(str: maxVolumeStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentRight, yAxis: y, isLeft: false)
        
        let maxRatioStr = self.maxRatio.toPercentFormat()
        let minRatioStr = self.minRatio.toPercentFormat()
        
        // 画比率标签
        self.drawYAxisLabel(str: maxRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentLeft, yAxis: uperChartDrawAreaTop, isLeft: true)
        self.drawYAxisLabel(str: minRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: contentLeft, yAxis: uperChartDrawAreaBottom, isLeft: true)
    }
    
    /// 转换为坐标数据
    func convertToPoints(data: [HSTimeLineModel]) {
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
    
    
    func drawTimeLineChart() {
        setMaxAndMinData()
        convertToPoints(data: dataT)
        clearLayer()
        drawLineLayer(array: positionModels)
        drawVolumeLayer(array: positionModels)
        drawMALineLayer(array: positionModels)
        drawYAxisLabel()
    }
    
    func clearLayer() {
        timeLineLayer.removeFromSuperlayer()
        fillColorLayer.removeFromSuperlayer()
        volumeLayer.removeFromSuperlayer()
        maLineLayer.removeFromSuperlayer()
    }
    
    /// 边框
    func drawFrameLayer() {
        // 分时线区域 frame
        let framePath = UIBezierPath(rect: CGRect(x: contentLeft, y: contentTop, width: contentWidth, height: uperChartHeight))
        if showFiveDayLabel {
            //五日分时图的四条竖线
            let width = self.contentWidth / 5
            for i in 1 ..< 5 {
                let lineX = self.contentLeft + width * CGFloat(i)
                let startPoint = CGPoint(x: lineX, y: contentTop + uperChartHeight)
                let stopPoint = CGPoint(x: lineX, y: contentTop)
                framePath.move(to: startPoint)
                framePath.addLine(to: stopPoint)
            }
        } else {
            //分时线的中间竖线
            let startPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: contentTop)
            let stopPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: uperChartHeight +  contentTop)
            framePath.move(to: startPoint)
            framePath.addLine(to: stopPoint)
        }
        
        let frameLayer = CAShapeLayer()
        frameLayer.path = framePath.cgPath
        frameLayer.lineWidth = theme.borderWidth / 2.0
        frameLayer.strokeColor = theme.borderColor.cgColor
        frameLayer.fillColor = UIColor.clear.cgColor
        
        // 交易量区域 frame
        let volFramePath = UIBezierPath(rect: CGRect(x: contentLeft, y: lowerChartTop, width: contentWidth, height: lowerChartHeight))
        let y = contentBottom - maxVolume * volumeUnit
        volFramePath.move(to: CGPoint(x: contentLeft, y: y))
        volFramePath.addLine(to: CGPoint(x: contentRight, y: y))
        
        let volFrameLayer = CAShapeLayer()
        volFrameLayer.path = volFramePath.cgPath
        volFrameLayer.lineWidth = theme.borderWidth / 2.0
        volFrameLayer.strokeColor = theme.borderColor.cgColor
        volFrameLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(frameLayer)
        self.layer.addSublayer(volFrameLayer)
    }
    
    
    /// 分时线
    func drawLineLayer(array: [HSTimeLineCoordModel]) {
        let timeLinePath = UIBezierPath()
        timeLinePath.move(to: array.first!.pricePoint)
        for index in 1 ..< array.count {
            timeLinePath.addLine(to: array[index].pricePoint)
        }
        timeLineLayer.path = timeLinePath.cgPath
        timeLineLayer.lineWidth = 1.5
        timeLineLayer.strokeColor = theme.priceLineCorlor.cgColor
        timeLineLayer.fillColor = UIColor.clear.cgColor
        
        // 填充颜色
        timeLinePath.addLine(to: CGPoint(x: array.last!.pricePoint.x, y: theme.uperChartHeightScale * frame.height))
        timeLinePath.addLine(to: CGPoint(x: array[0].pricePoint.x, y: theme.uperChartHeightScale * frame.height))
        fillColorLayer.path = timeLinePath.cgPath
        fillColorLayer.fillColor = theme.fillStartColor.cgColor
        fillColorLayer.strokeColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(timeLineLayer)
        self.layer.addSublayer(fillColorLayer)
        self.animatePoint.frame = CGRect(x: array.last!.pricePoint.x - 3/2, y: array.last!.pricePoint.y - 3/2, width: 3, height: 3)
    }
    
    /// 交易量图
    func drawVolumeLayer(array: [HSTimeLineCoordModel]) {
        volumeLayer.sublayers?.removeAll()
        var strokeColor = UIColor.clear
        let preClosePx = dataT.first?.preClosePx ?? 0
        
        for index in 0 ..< array.count {
            let comparePrice = (index == 0) ? preClosePx : dataT[index - 1].price
            if dataT[index].price > comparePrice {
                strokeColor = theme.volumeRiseColor
                
            } else if dataT[index].price < comparePrice {
                strokeColor = theme.volumeFallColor
                
            } else {
                strokeColor = theme.volumeTieColor
            }
            
            let volLayer = getVolumeLayer(model: array[index], fillColor: strokeColor)
            volumeLayer.addSublayer(volLayer)
        }
        self.layer.addSublayer(volumeLayer)
    }
    
    /// 均线
    func drawMALineLayer(array: [HSTimeLineCoordModel]) {
        let maLinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preMaPoint = array[index - 1].avgPoint
            let maPoint = array[index].avgPoint
            maLinePath.move(to: preMaPoint)
            maLinePath.addLine(to: maPoint)
        }
        maLineLayer.path = maLinePath.cgPath
        maLineLayer.strokeColor = theme.avgLineCorlor.cgColor
        maLineLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(maLineLayer)
    }
    
    /// 获取单个交易量图的layer
    fileprivate func getVolumeLayer(model: HSTimeLineCoordModel, fillColor: UIColor) -> CAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: model.volumeStartPoint)
        linePath.addLine(to: model.volumeEndPoint)
        
        let vlayer = CAShapeLayer()
        vlayer.path = linePath.cgPath
        vlayer.lineWidth = theme.volumeWidth
        vlayer.strokeColor = fillColor.cgColor
        vlayer.fillColor = fillColor.cgColor
        
        return vlayer
    }
    
    lazy var animatePoint: CALayer = {
        let animatePoint = CALayer()
        self.layer.addSublayer(animatePoint)
        animatePoint.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        animatePoint.cornerRadius = 1.5
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 3, height: 3)
        layer.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        layer.cornerRadius = 1.5
        layer.add(self.breathingLightAnimate(2), forKey: nil)
        
        animatePoint.addSublayer(layer)
        
        return animatePoint
    }()
    
    func breathingLightAnimate(_ time:Double) -> CAAnimationGroup {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 3.5
        scaleAnimation.autoreverses = false
        scaleAnimation.isRemovedOnCompletion = true
        scaleAnimation.repeatCount = MAXFLOAT
        scaleAnimation.duration = time
        
        let opacityAnimation = CABasicAnimation(keyPath:"opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0
        opacityAnimation.autoreverses = false
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.repeatCount = MAXFLOAT
        opacityAnimation.duration = time
        opacityAnimation.fillMode = kCAFillModeForwards
        
        let group = CAAnimationGroup()
        group.duration = time
        group.autoreverses = false
        group.isRemovedOnCompletion = false // 设置为false 在各种走势图切换后，动画不会失效
        group.fillMode = kCAFillModeForwards
        group.animations = [scaleAnimation,opacityAnimation]
        group.repeatCount = MAXFLOAT
        
        return group
    }
    
    func getTextLayer(text: String, foregroundColor: UIColor, backgroundColor: UIColor, frame: CGRect) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = 10
        textLayer.foregroundColor = foregroundColor.cgColor // UIColor(rgba: "#8695a6")
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.truncationMode = kCATruncationEnd
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    func drawYAxisLabel(str: String, labelAttribute: [String : NSObject], xAxis: CGFloat, yAxis: CGFloat, isLeft: Bool) {
        let valueAttributedString = NSMutableAttributedString(string: str, attributes: labelAttribute)
        let valueAttributedStringSize = valueAttributedString.size()
        let labelInLineCenterSize = valueAttributedStringSize.height/2.0
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = xAxis + yAxisLabelEdgeInset
            
        } else {
            labelX = xAxis - valueAttributedStringSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = yAxis - labelInLineCenterSize
        
        let yTextLayer = getTextLayer(text: str, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: labelX, y: labelY, width: valueAttributedStringSize.width, height: valueAttributedStringSize.height))
        print(yTextLayer.frame)
        self.layer.addSublayer(yTextLayer)
    }

}
