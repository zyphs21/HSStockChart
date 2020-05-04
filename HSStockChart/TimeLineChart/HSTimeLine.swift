//
//  HSTimeLineTest.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

public class HSTimeLine: UIView, HSDrawLayerProtocol {
    
    var timeLineLayer = CAShapeLayer()
    var volumeLayer = CAShapeLayer()
    var maLineLayer = CAShapeLayer()
    var frameLayer = CAShapeLayer()
    var fillColorLayer = CAShapeLayer()
    var yAxisLayer = CAShapeLayer()
    var crossLineLayer = CAShapeLayer()
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxRatio: CGFloat = 0
    var minRatio: CGFloat = 0
    var maxVolume: CGFloat = 0
    var priceMaxOffset : CGFloat = 0
    var priceUnit: CGFloat = 0
    var volumeUnit: CGFloat = 0
    
    var highLightIndex: Int = 0
    
    
    /// Number of Dot in TimeLine 分时线的横坐标个数
    public var countOfTimes = 240
    
    /// Number of Dot in Five Day TimeLine 五日分时线总横坐标
    public var fiveDayCount = 120
    
    public var openTime: String = "9:30"
    public var middleTime: String = "11:30/13:00"
    public var closeTime: String = "15:00"
    
    public var isFiveDayTime = false
    public var isLandscapeMode = false
    
    var volumeStep: CGFloat = 0
    var volumeWidth: CGFloat = 0
    
    var positionModels: [HSTimeLineCoordModel] = []
    
    public var dataT: [HSTimeLineModel] = [] {
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
            return frame.height * (1 - theme.uperChartHeightScale) - theme.xAxisHeitht
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
    
    public init(frame: CGRect, isFiveDay: Bool = false) {
        super.init(frame: frame)
        
        self.isFiveDayTime = isFiveDay
        addGestures()
        drawFrameLayer()
        drawXAxisLabel()
    }
    
    public init(frame: CGRect, isFiveDay: Bool = false, countOfTime: Int, openTime: String, middleTime: String, closeTime: String) {
        super.init(frame: frame)
        
        self.countOfTimes = countOfTime
        
        self.openTime = openTime
        self.middleTime = middleTime
        self.closeTime = closeTime
        
        self.isFiveDayTime = isFiveDay
        addGestures()
        drawFrameLayer()
        drawXAxisLabel()
    }
     
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    
    func addGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    //Getter Setter for customization
    public func setCountOfTimes(times: Int)
    {
        self.countOfTimes = times
    }
    
    public func setfiveDayCount(counts: Int)
    {
        self.fiveDayCount = counts
    }
    
    public func setDailyOpenTime(openTime: String, middleTime: String, closeTime: String)
    {
        self.openTime = openTime
        self.middleTime = middleTime
        self.closeTime = closeTime
    }
    
    
    // 绘图
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
                    self.priceMaxOffset = self.priceMaxOffset > abs(entity.price - toComparePrice) ? self.priceMaxOffset : abs(entity.price - toComparePrice)
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
            let startTimeSize = theme.getTextSize(text: openTime)
            
            let startTime = drawTextLayer(frame: CGRect(x: 0, y: uperChartHeight, width: startTimeSize.width, height: startTimeSize.height),
                                          text: openTime,
                                          foregroundColor: theme.textColor)
            
            let midTimeSize = theme.getTextSize(text: middleTime)
            let midTime = drawTextLayer(frame: CGRect(x: frame.width / 2.0 - midTimeSize.width / 2.0, y: uperChartHeight, width: midTimeSize.width, height: midTimeSize.height),
                                        text: middleTime,
                                        foregroundColor: theme.textColor)
            
            let stopTimeSize = theme.getTextSize(text: closeTime)
            let stopTime = drawTextLayer(frame: CGRect(x: frame.width - stopTimeSize.width, y: uperChartHeight, width: stopTimeSize.width, height: stopTimeSize.height),
                                         text: closeTime,
                                         foregroundColor: theme.textColor)
            
            self.layer.addSublayer(startTime)
            self.layer.addSublayer(midTime)
            self.layer.addSublayer(stopTime)
        }
    }
    
    /// 纵坐标轴的标签
    func drawYAxisLabel() {
        yAxisLayer.sublayers?.removeAll()
        
        // 画纵坐标的最高和最低价格标签
        let maxPriceStr = maxPrice.hschart.toStringWithFormat(".2")
        let minPriceStr = minPrice.hschart.toStringWithFormat(".2")
        yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: maxPriceStr, y: theme.viewMinYGap, isLeft: false))
        yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: minPriceStr, y: uperChartDrawAreaBottom, isLeft: false))
        
        // 最高成交量标签及其横线
        let y = frame.height - maxVolume * volumeUnit
        let maxVolumeStr = maxVolume.hschart.toStringWithFormat(".2")
        yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: maxVolumeStr, y: y, isLeft: false))
        
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
        let maxRatioStr = (self.maxRatio * 100).hschart.toPercentFormat()
        let minRatioStr = (self.minRatio * 100).hschart.toPercentFormat()
        yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: maxRatioStr, y: uperChartDrawAreaTop, isLeft: true))
        yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: minRatioStr, y: uperChartDrawAreaBottom, isLeft: true))
        
        // 中间横虚线及其标签
        if let temp = dataT.first {
            // 日分时图中间区域线代表昨日的收盘价格，五日分时图的则代表五日内的第一天9点30分的价格
            let price = isFiveDayTime ? temp.price : temp.preClosePx
            let preClosePriceYaxis = (self.maxPrice - price) * self.priceUnit + uperChartDrawAreaTop
            
            let dashLinePath = UIBezierPath()
            dashLinePath.move(to: CGPoint(x: 0, y: preClosePriceYaxis))
            dashLinePath.addLine(to: CGPoint(x: frame.width, y: preClosePriceYaxis))
            
            let dashLineLayer = CAShapeLayer()
            dashLineLayer.path = dashLinePath.cgPath
            dashLineLayer.strokeColor = theme.borderColor.cgColor
            dashLineLayer.lineWidth = theme.lineWidth / 2
            dashLineLayer.fillColor = UIColor.clear.cgColor
            dashLineLayer.lineDashPattern = [6, 3]
            yAxisLayer.addSublayer(dashLineLayer)
            
            yAxisLayer.addSublayer(getYAxisMarkLayer(frame: frame, text: price.hschart.toStringWithFormat(".2"), y: preClosePriceYaxis, isLeft: false))
        }
        
        self.layer.addSublayer(yAxisLayer)
    }
    
    /// 转换为坐标数据
    func convertToPoints(data: [HSTimeLineModel]) {
        let maxDiff = self.maxPrice - self.minPrice
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (uperChartHeight - 2 * theme.viewMinYGap) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeGap) / self.maxVolume
        }
        
        if isFiveDayTime {
            volumeStep = self.frame.width / CGFloat(fiveDayCount)
        } else {
            volumeStep = self.frame.width / CGFloat(countOfTimes)
        }
        
        volumeWidth = volumeStep - volumeStep / 3.0
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
            
            var positionModel = HSTimeLineCoordModel()
            positionModel.pricePoint = pricePoint
            positionModel.avgPoint = avgPoint
            positionModel.volumeHeight = volumeHeight
            positionModel.volumeStartPoint = volumeStartPoint
            positionModel.volumeEndPoint = volumeEndPoint
            
            self.positionModels.append(positionModel)
        }
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
        frameLayer.lineWidth = theme.frameWidth
        frameLayer.strokeColor = theme.borderColor.cgColor
        frameLayer.fillColor = UIColor.clear.cgColor
        
        // 交易量区域 frame
        let volFramePath = UIBezierPath(rect: CGRect(x: 0, y: lowerChartTop, width: frame.width, height: lowerChartHeight))
        let y = frame.height - maxVolume * volumeUnit
        volFramePath.move(to: CGPoint(x: 0, y: y))
        volFramePath.addLine(to: CGPoint(x: frame.width, y: y))
        
        let volFrameLayer = CAShapeLayer()
        volFrameLayer.path = volFramePath.cgPath
        volFrameLayer.lineWidth = theme.frameWidth
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
        timeLineLayer.lineWidth = 1
        timeLineLayer.strokeColor = theme.priceLineColor.cgColor
        timeLineLayer.fillColor = UIColor.clear.cgColor
        
        // 填充颜色
        timeLinePath.addLine(to: CGPoint(x: array.last!.pricePoint.x, y: theme.uperChartHeightScale * frame.height))
        timeLinePath.addLine(to: CGPoint(x: array[0].pricePoint.x, y: theme.uperChartHeightScale * frame.height))
        fillColorLayer.path = timeLinePath.cgPath
        fillColorLayer.fillColor = theme.fillColor.cgColor
        fillColorLayer.strokeColor = UIColor.clear.cgColor
        fillColorLayer.zPosition -= 1 // 将图层置于下一级，让底部的标记线显示出来
        
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
            if dataT[index].price < comparePrice {
                strokeColor = theme.fallColor
                
            } else {
                strokeColor = theme.riseColor
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
        maLineLayer.strokeColor = theme.avgLineColor.cgColor
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
        vlayer.lineWidth = volumeWidth
        vlayer.strokeColor = fillColor.cgColor
        vlayer.fillColor = fillColor.cgColor
        
        return vlayer
    }
    
    // 分时图实时动态点（呼吸灯动画）
    lazy var animatePoint: CALayer = {
        let animatePoint = CALayer()
        self.layer.addSublayer(animatePoint)
        animatePoint.backgroundColor = UIColor.hschart.color(rgba: "#0095e1").cgColor
        animatePoint.cornerRadius = 1.5
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 3, height: 3)
        layer.backgroundColor = UIColor.hschart.color(rgba: "#0095e1").cgColor
        layer.cornerRadius = 1.5
        layer.add(self.getBreathingLightAnimate(2), forKey: nil)
        
        animatePoint.addSublayer(layer)
        
        return animatePoint
    }()
    
    /// 处理长按事件
    @objc func handleLongPressGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            if (point.x > 0 && point.x < self.frame.width && point.y > 0 && point.y < self.frame.height) {
                let index = Int(point.x / volumeStep)
                
                if index > dataT.count - 1 {
                    self.highLightIndex = dataT.count - 1
                } else {
                    self.highLightIndex = index
                }
                
                crossLineLayer.removeFromSuperlayer()
                crossLineLayer = getCrossLineLayer(frame: frame, pricePoint: positionModels[highLightIndex].pricePoint, volumePoint: positionModels[highLightIndex].volumeStartPoint, model: dataT[highLightIndex] as AnyObject, chartType:(isFiveDayTime ? HSChartType.timeLineForFiveday: HSChartType.timeLineForDay))
                self.layer.addSublayer(crossLineLayer)
            }
            if self.highLightIndex < dataT.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineLongpress"), object: self, userInfo: ["timeLineEntity": dataT[self.highLightIndex]])
            }
        }
        
        if recognizer.state == .ended {
            crossLineLayer.removeFromSuperlayer()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineUnLongpress"), object: self)
        }
    }
    
    
    /// 处理点击事件
    @objc func handleTapGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if !isLandscapeMode {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLineChartDidTap"), object: recognizer.view?.tag)
        }
    }

}


extension HSTimeLine {
    
    /// 获取呼吸灯动画
    private func getBreathingLightAnimate(_ time:Double) -> CAAnimationGroup {
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
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let group = CAAnimationGroup()
        group.duration = time
        group.autoreverses = false
        group.isRemovedOnCompletion = false // 设置为false 在各种走势图切换后，动画不会失效
        group.fillMode = CAMediaTimingFillMode.forwards
        group.animations = [scaleAnimation, opacityAnimation]
        group.repeatCount = MAXFLOAT
        
        return group
    }
}
