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
    var yAxisLayer = CAShapeLayer()
    var highlightLayer = CAShapeLayer()
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxRatio: CGFloat = 0
    var minRatio: CGFloat = 0
    var maxVolume: CGFloat = 0
    var priceMaxOffset : CGFloat = 0
    var priceUnit: CGFloat = 0
    var volumeUnit: CGFloat = 0
    
    var highLightIndex: Int = 0
    
    let countOfTimes = 240 // 分时线的横坐标
    let fiveDayCount = 120 // 五日线总横坐标
    
    var showLongPressHighlight = false
    var isFiveDayTime = false
    
    var volumeStep: CGFloat = 0
    
    var positionModels: [HSTimeLineCoordModel] = []
    var dataT: [HSTimeLineModel] = [] {
        didSet {
            self.drawTimeLineChart()
        }
    }
    
    var uperChartHeight: CGFloat {
        get {
            return frame.height * theme.uperChartHeightScale
        }
    }
    var lowerChartHeight: CGFloat {
        get {
            return frame.height * (1 - theme.kLineChartHeightScale) - theme.xAxisHeitht
        }
    }
    var uperChartDrawAreaTop: CGFloat {
        get {
            return theme.viewMinYGap
        }
    }
    var uperChartDrawAreaBottom: CGFloat {
        get {
            return uperChartHeight - theme.viewMinYGap
        }
    }
    var lowerChartTop: CGFloat {
        get {
            return uperChartHeight + theme.xAxisHeitht
        }
    }
    
    
    //MARK: - 构造方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestures()
        drawFrameLayer()
        drawXAxisLabel()
    }
    
    init(frame: CGRect, isFiveDay: Bool) {
        super.init(frame: frame)
        self.isFiveDayTime = isFiveDay
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
            let toComparePrice = isFiveDayTime ? dataT[0].price : dataT[0].preClosePx

            if isFiveDayTime {
                for i in 0 ..< dataT.count {
                    let entity = dataT[i]
                    self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                    self.maxPrice = maxPrice > entity.price ? maxPrice : entity.price
                    self.minPrice = minPrice < entity.price ? minPrice : entity.price
                }
                self.maxRatio = (maxPrice - toComparePrice) / toComparePrice
                self.minRatio = (minPrice - toComparePrice) / toComparePrice
                
            } else {
                for i in 0 ..< dataT.count {
                    let entity = dataT[i]
                    self.priceMaxOffset = self.priceMaxOffset > fabs(entity.price - toComparePrice) ? self.priceMaxOffset : fabs(entity.price - toComparePrice)
                    self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                    self.maxPrice = maxPrice > entity.price ? maxPrice : entity.price
                    self.minPrice = minPrice < entity.price ? minPrice : entity.price
                }
                self.maxPrice = toComparePrice + self.priceMaxOffset
                self.minPrice = toComparePrice - self.priceMaxOffset
                self.maxRatio = self.priceMaxOffset / toComparePrice
                self.minRatio = -self.maxRatio
            }
            
            for i in 0 ..< dataT.count {
                let entity = dataT[i]
                entity.avgPirce = entity.avgPirce < self.minPrice ? self.minPrice : entity.avgPirce
                entity.avgPirce = entity.avgPirce > self.maxPrice ? self.maxPrice : entity.avgPirce
            }
        }
    }
    
    /// 横坐标轴的标签
    func drawXAxisLabel() {
        if isFiveDayTime {
            
        } else {
            let drawAttributes = theme.xAxisLabelAttribute
            let startTimeAttributedString = NSMutableAttributedString(string: "9:30", attributes: drawAttributes)
            let sizestartTimeAttributedString = startTimeAttributedString.size()
            let startTime = getTextLayer(text: startTimeAttributedString.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: 0, y: uperChartHeight, width: sizestartTimeAttributedString.width, height: sizestartTimeAttributedString.height))
            
            let midTimeAttStr = NSMutableAttributedString(string: "11:30/13:00", attributes: drawAttributes)
            let sizeMidTimeAttStr = midTimeAttStr.size()
            let midTime = getTextLayer(text: midTimeAttStr.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame:  CGRect(x: self.frame.width / 2.0 - sizeMidTimeAttStr.width / 2.0, y: uperChartHeight, width: sizeMidTimeAttStr.width, height: sizeMidTimeAttStr.height))
            
            let stopTimeAttStr = NSMutableAttributedString(string: "15:00", attributes: drawAttributes)
            let sizeStopTimeAttStr = stopTimeAttStr.size()
            let stopTime = getTextLayer(text: stopTimeAttStr.string, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: self.frame.width - sizeStopTimeAttStr.width, y: uperChartHeight, width: sizeStopTimeAttStr.width, height: sizeStopTimeAttStr.height))
            
            self.layer.addSublayer(startTime)
            self.layer.addSublayer(midTime)
            self.layer.addSublayer(stopTime)
        }
    }
    
    /// 纵坐标轴的标签
    func drawYAxisLabel() {
        yAxisLayer.sublayers?.removeAll()
        // 画纵坐标的最高和最低价格标签
        let maxPriceStr = maxPrice.toStringWithFormat(".2")
        let minPriceStr = minPrice.toStringWithFormat(".2")
        
        yAxisLayer.addSublayer(drawYAxisLabel(str: maxPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: frame.width, yAxis: theme.viewMinYGap, isLeft: false))
        yAxisLayer.addSublayer(drawYAxisLabel(str: minPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: frame.width, yAxis: uperChartDrawAreaBottom, isLeft: false))
        
        // 最高成交量标签及其横线
        let y = frame.height - maxVolume * volumeUnit
        let maxVolumeStr = maxVolume.toStringWithFormat(".2")
        yAxisLayer.addSublayer(drawYAxisLabel(str: maxVolumeStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: frame.width, yAxis: y, isLeft: false))
        
        let maxVolLine = UIBezierPath()
        maxVolLine.move(to: CGPoint(x: 0, y: y))
        maxVolLine.addLine(to: CGPoint(x: frame.width, y: y))
        let maxVolLineLayer = CAShapeLayer()
        maxVolLineLayer.path = maxVolLine.cgPath
        maxVolLineLayer.lineWidth = 0.25
        maxVolLineLayer.strokeColor = theme.borderColor.cgColor
        maxVolLineLayer.fillColor = UIColor.clear.cgColor
        yAxisLayer.addSublayer(maxVolLineLayer)
        
        // 画比率标签
        let maxRatioStr = (self.maxRatio * 100).toPercentFormat()
        let minRatioStr = (self.minRatio * 100).toPercentFormat()
        yAxisLayer.addSublayer(drawYAxisLabel(str: maxRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: 0, yAxis: uperChartDrawAreaTop, isLeft: true))
        yAxisLayer.addSublayer(drawYAxisLabel(str: minRatioStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: 0, yAxis: uperChartDrawAreaBottom, isLeft: true))
        
        // 中间横虚线及其标签
        if let temp = dataT.first {
            //日分时图中间区域线代表昨日的收盘价格，五日分时图的则代表五日内的第一天9点30分的价格
            let price = isFiveDayTime ? temp.price : temp.preClosePx
            let preClosePriceYaxis = (self.maxPrice - price) * self.priceUnit + uperChartDrawAreaTop
            
            let dashLinePath = UIBezierPath()
            dashLinePath.move(to: CGPoint(x: 0, y: preClosePriceYaxis))
            dashLinePath.addLine(to: CGPoint(x: frame.width, y: preClosePriceYaxis))
            
            let dashLineLayer = CAShapeLayer()
            dashLineLayer.path = dashLinePath.cgPath
            dashLineLayer.strokeColor = theme.borderColor.cgColor
            dashLineLayer.lineWidth = theme.borderWidth / 2
            dashLineLayer.fillColor = UIColor.clear.cgColor
            dashLineLayer.lineDashPattern = [6, 3]
            yAxisLayer.addSublayer(dashLineLayer)
            
            yAxisLayer.addSublayer(drawYAxisLabel(str: price.toStringWithFormat(".2"), labelAttribute: theme.yAxisLabelAttribute, xAxis: frame.width,  yAxis: preClosePriceYaxis, isLeft: false))
        }
        
        self.layer.addSublayer(yAxisLayer)
    }
    
    /// 转换为坐标数据
    func convertToPoints(data: [HSTimeLineModel]) {
        let maxDiff = self.maxPrice - self.minPrice
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (uperChartHeight - 2 * theme.viewMinYGap) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeMinGap) / self.maxVolume
        }
        
        if isFiveDayTime {
            volumeStep = self.frame.width / CGFloat(fiveDayCount)
        } else {
            volumeStep = self.frame.width / CGFloat(countOfTimes)
        }
        
        let volumeWidth = volumeStep - volumeStep / 3.0
        self.theme.volumeWidth = volumeWidth
        self.positionModels.removeAll()
        for index in 0 ..< data.count {
            let centerX = volumeStep * CGFloat(index) + volumeStep / 2
            
            let xPosition = centerX
            let yPosition = (self.maxPrice - data[index].price) * priceUnit + self.uperChartDrawAreaTop
            let pricePoint = CGPoint(x: xPosition, y: yPosition)
            
            let avgYPosition = (self.maxPrice - data[index].avgPirce) * priceUnit + self.uperChartDrawAreaTop
            let avgPoint = CGPoint(x: xPosition, y: avgYPosition)
            
            let volumeHeight = data[index].volume * volumeUnit
            let volumeStartPoint = CGPoint(x: centerX, y: frame.height - volumeHeight)
            let volumeEndPoint = CGPoint(x: centerX, y: frame.height)
            
            let positionModel = HSTimeLineCoordModel()
            positionModel.pricePoint = pricePoint
            positionModel.avgPoint = avgPoint
            positionModel.volumeHeight = volumeHeight
            positionModel.volumeStartPoint = volumeStartPoint
            positionModel.volumeEndPoint = volumeEndPoint
            
            self.positionModels.append(positionModel)
        }
    }
    
    /// 处理长按事件
    func handleLongPressGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            if (point.x > 0 && point.x < self.frame.width && point.y > 0 && point.y < self.frame.height) {
                self.showLongPressHighlight = true
                let index = Int(point.x / volumeStep)
                
                if index > dataT.count - 1 {
                    self.highLightIndex = dataT.count - 1
                    
                } else {
                    self.highLightIndex = index
                }
                
                drawCrossLine(pricePoint: positionModels[highLightIndex].pricePoint, volumePoint: positionModels[highLightIndex].volumeStartPoint, model: dataT[highLightIndex])
            }
            if self.highLightIndex < dataT.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineLongpress"), object: self, userInfo: ["timeLineEntity": dataT[self.highLightIndex]])
            }
        }
        
        if recognizer.state == .ended {
            highlightLayer.removeFromSuperlayer()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineUnLongpress"), object: self)
        }
    }
    
    
    /// 处理点击事件
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
        yAxisLayer.removeFromSuperlayer()
    }
    
    /// 边框
    func drawFrameLayer() {
        // 分时线区域 frame
        let framePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: uperChartHeight))
        if isFiveDayTime {
            //五日分时图的四条竖线
            let width = self.frame.width / 5
            for i in 1 ..< 5 {
                let lineX = width * CGFloat(i)
                let startPoint = CGPoint(x: lineX, y: uperChartHeight)
                let stopPoint = CGPoint(x: lineX, y: 0)
                framePath.move(to: startPoint)
                framePath.addLine(to: stopPoint)
            }
        } else {
            //分时线的中间竖线
            let startPoint = CGPoint(x: frame.width / 2.0, y: 0)
            let stopPoint = CGPoint(x: frame.width / 2.0, y: uperChartHeight)
            framePath.move(to: startPoint)
            framePath.addLine(to: stopPoint)
        }
        
        let frameLayer = CAShapeLayer()
        frameLayer.path = framePath.cgPath
        frameLayer.lineWidth = theme.borderWidth / 2.0
        frameLayer.strokeColor = theme.borderColor.cgColor
        frameLayer.fillColor = UIColor.clear.cgColor
        
        // 交易量区域 frame
        let volFramePath = UIBezierPath(rect: CGRect(x: 0, y: lowerChartTop, width: frame.width, height: lowerChartHeight))
        let y = frame.height - maxVolume * volumeUnit
        volFramePath.move(to: CGPoint(x: 0, y: y))
        volFramePath.addLine(to: CGPoint(x: frame.width, y: y))
        
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
    
    func drawYAxisLabel(str: String, labelAttribute: [String : NSObject], xAxis: CGFloat, yAxis: CGFloat, isLeft: Bool) -> CATextLayer {
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
        
        let yTextLayer = getTextLayer(text: str, foregroundColor: UIColor(rgba: "#8695a6"), backgroundColor: UIColor.clear, frame: CGRect(x: labelX, y: labelY, width: valueAttributedStringSize.width+10, height: valueAttributedStringSize.height))
        print(yTextLayer.frame)
        
        return yTextLayer
    }
    
    func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?, isShowVolume: Bool = true) {
        highlightLayer.removeFromSuperlayer()
        highlightLayer.sublayers?.removeAll()
        let corssLineLayer = CAShapeLayer()
        var volMarkLayer = CATextLayer()
        var leftMarkLayer = CATextLayer()
        var rightMarkLayer = CATextLayer()
        var bottomMarkLayer = CATextLayer()
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerString = ""
        var volumeMarkerString = ""
        
        guard let model = model else { return }
        
        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
            rightMarkerString = entity.close.toStringWithFormat(".2")
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            leftMarkerString = entity.rate.toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
            rightMarkerString = entity.price.toStringWithFormat(".2")
            bottomMarkerString = entity.time
            leftMarkerString = (entity.rate * 100).toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else{
            return
        }
        
        let linePath = UIBezierPath()
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.maxY))
        
        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))
        
        if isShowVolume {
            // 标记交易量的横线
            linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
            linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))
        }
        
        // 交叉点
        //linePath.addArc(withCenter: pricePoint, radius: 3, startAngle: 0, endAngle: 180, clockwise: true)
        
        corssLineLayer.lineWidth = theme.lineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath
        
        // 标记标签
        
        let leftMarkerStringAttribute = NSMutableAttributedString(string: leftMarkerString, attributes: theme.highlightAttribute)
        let bottomMarkerStringAttribute = NSMutableAttributedString(string: bottomMarkerString, attributes: theme.highlightAttribute)
        let rightMarkerStringAttribute = NSMutableAttributedString(string: rightMarkerString, attributes: theme.highlightAttribute)
        let volumeMarkerStringAttribute = NSMutableAttributedString(string: volumeMarkerString, attributes: theme.highlightAttribute)
        
        let leftMarkerStringAttributeSize = leftMarkerStringAttribute.size()
        let bottomMarkerStringAttributeSize = bottomMarkerStringAttribute.size()
        let rightMarkerStringAttributeSize = rightMarkerStringAttribute.size()
        let volumeMarkerStringAttributeSize = volumeMarkerStringAttribute.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        // 左标签
        labelX = frame.minX
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        leftMarkLayer = getTextLayer(text: leftMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        // 右标签
        labelX = frame.maxX - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        rightMarkLayer = getTextLayer(text: rightMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        // 底部时间标签
        let maxX = frame.maxX - bottomMarkerStringAttributeSize.width
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkerStringAttributeSize.width
            
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        bottomMarkLayer = getTextLayer(text: bottomMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        
        if isShowVolume {
            // 交易量右标签
            let maxY = frame.maxY - volumeMarkerStringAttributeSize.height
            labelX = frame.maxX - volumeMarkerStringAttributeSize.width
            labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
            labelY = labelY > maxY ? maxY : labelY
            volMarkLayer = getTextLayer(text: volumeMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: volumeMarkerStringAttributeSize.width, height: volumeMarkerStringAttributeSize.height))
        }
        
        highlightLayer.addSublayer(corssLineLayer)
        highlightLayer.addSublayer(leftMarkLayer)
        highlightLayer.addSublayer(rightMarkLayer)
        highlightLayer.addSublayer(bottomMarkLayer)
        highlightLayer.addSublayer(volMarkLayer)
        self.layer.addSublayer(highlightLayer)
    }

}
