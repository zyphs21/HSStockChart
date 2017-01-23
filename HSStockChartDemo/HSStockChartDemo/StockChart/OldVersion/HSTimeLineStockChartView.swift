//
//  TimeLineStockChartView.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class HSTimeLineStockChartView: HSBaseStockChartView {
    
    var priceOnYaxisScale : CGFloat = 0
    var volumeOnYaxisScale : CGFloat = 0
    
    var enableAnimatePoint = true
    var isDrawAvgLine = true
    
    var countOfTimes = 242 // 分时线的横坐标
    var priceMaxOffset : CGFloat = 0
    var showFiveDayLabel = false
    
    var longPressGesture : UILongPressGestureRecognizer{
        return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
    }
    
    var tapGesture: UITapGestureRecognizer {
        get{
            return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        }
    }
    
    var volumeWidth: CGFloat = 0
    
    var dataT: [HSTimeLineModel]! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var theme = HSTimeLineTheme()
    
    var layerWidth: CGFloat = 4
    
    lazy var animatePoint: CALayer = {
        var animatePoint = CALayer()
        self.layer.addSublayer(animatePoint)
        animatePoint.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        animatePoint.cornerRadius = 2
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        layer.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        layer.cornerRadius = 2
        layer.add(self.breathingLightAnimate(2), forKey: nil)
        
        animatePoint.addSublayer(layer)
        
        return animatePoint
    }()

    
    //MARK: - 构造方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect, uperChartHeightScale: CGFloat, topOffSet: CGFloat, leftOffSet: CGFloat, bottomOffSet: CGFloat, rightOffSet: CGFloat) {
        
        super.init(frame: frame, uperChartHeightScale: uperChartHeightScale, topOffSet: topOffSet, leftOffSet: leftOffSet, bottomOffSet: bottomOffSet, rightOffSet: rightOffSet)
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if dataT.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            setMaxAndMinData()
            drawChartFrame(context!, rect: rect)
            drawTimeLabelInXAxis(context!)
            drawPriceLabel(context!)
            drawRatioLabel(context!)
            drawTimeLine(context!, data: dataT)
            
        } else {
            // to show error page
        }
    }
    
    
    //MARK: - Function
    
    func setMaxAndMinData() {
        if dataT.count > 0{
            self.maxPrice = dataT[0].price
            self.minPrice = dataT[0].price
            self.maxRatio = dataT[0].rate
            self.minRatio = dataT[0].rate
            self.maxVolume = dataT[0].volume
            // 分时线和五日线的比较基准
            let toComparePrice = showFiveDayLabel ? dataT.first?.price : dataT.first?.preClosePx
            
            for i in 0 ..< dataT.count {
                let entity = dataT[i]
                self.priceMaxOffset = self.priceMaxOffset > fabs(entity.price - toComparePrice!) ? self.priceMaxOffset : fabs(entity.price - toComparePrice!)
                self.maxRatio = self.maxRatio > entity.rate ? self.maxRatio : entity.rate
                self.minRatio = self.minRatio < entity.rate ? self.minRatio : entity.rate
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
            }
            
            self.maxPrice = toComparePrice! + self.priceMaxOffset
            self.minPrice = toComparePrice! - self.priceMaxOffset
            
            for i in 0 ..< dataT.count {
                let entity = dataT[i]
                entity.avgPirce = entity.avgPirce < self.minPrice ? self.minPrice : entity.avgPirce
                entity.avgPirce = entity.avgPirce > self.maxPrice ? self.maxPrice : entity.avgPirce
            }
        }
    }
    
    //画图表边框
    override func drawChartFrame(_ context: CGContext, rect: CGRect) {
        super.drawChartFrame(context, rect: rect)
        
        if showFiveDayLabel {
            //五日分时图的四条竖线
            let width = self.contentWidth / 5
            for i in 1 ..< 5 {
                let lineX = self.contentLeft + width * CGFloat(i)
                let startPoint = CGPoint(x: lineX, y: uperChartBottom)
                let stopPoint = CGPoint(x: lineX, y: contentTop)
                self.drawline(context, startPoint: startPoint, stopPoint: stopPoint, color: borderColor, lineWidth: borderWidth / 2.0)
            }
            
        } else {
            //分时线的中间竖线
            let startPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: contentTop)
            let stopPoint = CGPoint(x: contentWidth / 2.0 + contentLeft, y: uperChartHeight +  contentTop)
            self.drawline(context, startPoint: startPoint, stopPoint: stopPoint, color: borderColor, lineWidth: borderWidth / 2.0)
        }
    }
    
    //画横坐标的时间标签
    func drawTimeLabelInXAxis(_ context:CGContext) {
        
        if showFiveDayLabel {
            let width = self.contentWidth / 5
            for (index, day) in (dataT.first?.days.enumerated())! {
                let drawAttributes = self.xAxisLabelAttribute
                let startTimeAttributedString = NSMutableAttributedString(string: day, attributes: drawAttributes)
                let sizestartTimeAttributedString = startTimeAttributedString.size()
                let labelX = self.contentLeft + (width - sizestartTimeAttributedString.width) / 2 + width * CGFloat(index)
                self.drawLabel(context,
                               attributesText: startTimeAttributedString,
                               rect: CGRect(x: labelX, y: uperChartBottom, width: sizestartTimeAttributedString.width, height: sizestartTimeAttributedString.height))
            }
            
        } else {
            let drawAttributes = self.xAxisLabelAttribute
            let startTimeAttributedString = NSMutableAttributedString(string: "9:30", attributes: drawAttributes)
            let sizestartTimeAttributedString = startTimeAttributedString.size()
            self.drawLabel(context, attributesText: startTimeAttributedString, rect: CGRect(x: self.contentLeft, y: uperChartBottom, width: sizestartTimeAttributedString.width, height: sizestartTimeAttributedString.height))
            
            let midTimeAttStr = NSMutableAttributedString(string: "11:30/13:00", attributes: drawAttributes)
            let sizeMidTimeAttStr = midTimeAttStr.size()
            self.drawLabel(context, attributesText: midTimeAttStr, rect: CGRect(x: self.contentWidth / 2.0 + self.contentLeft - sizeMidTimeAttStr.width / 2.0, y: uperChartBottom, width: sizeMidTimeAttStr.width, height: sizeMidTimeAttStr.height))
            
            let stopTimeAttStr = NSMutableAttributedString(string: "15:00", attributes: drawAttributes)
            let sizeStopTimeAttStr = stopTimeAttStr.size()
            self.drawLabel(context, attributesText: stopTimeAttStr, rect: CGRect(x: self.contentRight - sizeStopTimeAttStr.width, y: uperChartBottom, width: sizeStopTimeAttStr.width, height: sizeStopTimeAttStr.height))
        }
    }
    
    // 画纵坐标的最高和最低价格标签
    func drawPriceLabel(_ context:CGContext) {        
        let maxPriceStr = self.formatValue(maxPrice)
        let minPriceStr = self.formatValue(minPrice)
        
        self.drawYAxisLabel(context, labelString: maxPriceStr, yAxis: uperChartDrawAreaTop, isLeft: false)
        self.drawYAxisLabel(context, labelString: minPriceStr, yAxis: uperChartDrawAreaBottom, isLeft: false)
    }
    
    // 画比率标签
    func drawRatioLabel(_ context:CGContext){
        let maxRatioStr = self.formatRatio(self.maxRatio)
        let minRatioStr = self.formatRatio(self.minRatio)
        
        self.drawYAxisLabel(context, labelString: maxRatioStr, yAxis: uperChartDrawAreaTop, isLeft: true)
        self.drawYAxisLabel(context, labelString: minRatioStr, yAxis: uperChartDrawAreaBottom, isLeft: true)
    }
    
    // 画分时线，均线，成交量
    func drawTimeLine(_ context: CGContext, data: [HSTimeLineModel]){
        context.saveGState()

        self.priceOnYaxisScale = uperChartDrawAreaHeight / (self.maxPrice - self.minPrice)
        self.volumeOnYaxisScale = (lowerChartHeight - lowerChartDrawAreaMargin) / (self.maxVolume - 0)
        
        let fillPath = CGMutablePath()
        
        if showFiveDayLabel {
            self.volumeWidth = self.contentWidth / CGFloat(data.count)
        } else {
            self.volumeWidth = self.contentWidth / CGFloat(self.countOfTimes)
        }
        
        //画中间的横虚线
        if let temp = data.first {
            //日分时图中间区域线代表昨日的收盘价格，五日分时图的则代表五日内的第一天9点30分的价格
            let price = showFiveDayLabel ? temp.price : temp.preClosePx
            let preClosePriceYaxis = (self.maxPrice - price) * self.priceOnYaxisScale + self.uperChartDrawAreaTop
            self.drawline(context,
                          startPoint: CGPoint(x: contentLeft, y: preClosePriceYaxis),
                          stopPoint: CGPoint(x: contentRight, y: preClosePriceYaxis),
                          color: borderColor,
                          lineWidth: borderWidth / 2.0,
                          isDashLine: true)
            self.drawYAxisLabel(context, labelString: formatValue(price), yAxis: preClosePriceYaxis, isLeft: false)
        }
        
        for i in 0 ..< data.count {
            let entity = data[i]
            // 交易量柱之间的间隙 self.volumeWidth/6.0
            let left = (self.volumeWidth * CGFloat(i) + contentLeft) + self.volumeWidth / 6.0
            let candleWidth = self.volumeWidth - self.volumeWidth / 3.0
            let startX = left + candleWidth / 2.0
            var yPrice: CGFloat = 0
            
            var color = theme.volumeRiseColor
            
            if i > 0 {
                let previousEntity = data[i - 1]
                let preX: CGFloat = startX - self.volumeWidth
                let previousPrice = (self.maxPrice - previousEntity.price) * self.priceOnYaxisScale + self.uperChartDrawAreaTop
                yPrice = (self.maxPrice - entity.price) * self.priceOnYaxisScale + self.uperChartDrawAreaTop
                //画分时线
                self.drawline(context,
                              startPoint: CGPoint(x: preX, y: previousPrice),
                              stopPoint: CGPoint(x: startX, y: yPrice),
                              color: theme.priceLineCorlor,
                              lineWidth: theme.lineWidth)
                
                if isDrawAvgLine {
                    //画均线
                    let lastYAvg = (self.maxPrice - previousEntity.avgPirce) * self.priceOnYaxisScale  + self.uperChartDrawAreaTop
                    let yAvg = (self.maxPrice - entity.avgPirce) * self.priceOnYaxisScale  + self.uperChartDrawAreaTop
                    
                    self.drawline(context, startPoint: CGPoint(x: preX, y: lastYAvg), stopPoint: CGPoint(x: startX, y: yAvg), color: theme.avgLineCorlor, lineWidth: theme.lineWidth)
                }
                
                //设置成交量的颜色
                if (entity.price > previousEntity.price) {
                    color = theme.volumeRiseColor
                }else if (entity.price < previousEntity.price){
                    color = theme.volumeFallColor
                }else{
                    color = theme.volumeTieColor
                }
                
                // 为填充渐变颜色，包围图形
                if 1 == i {
                    fillPath.move(to: CGPoint(x: self.contentLeft, y: uperChartHeight + self.contentTop))
                    fillPath.addLine(to: CGPoint(x: self.contentLeft, y: previousPrice))
                    fillPath.addLine(to: CGPoint(x: preX, y: previousPrice))
                }else{
                    fillPath.addLine(to: CGPoint(x: startX, y: yPrice))
                }
                if (data.count - 1) == i {
                    fillPath.addLine(to: CGPoint(x: startX, y: yPrice))
                    fillPath.addLine(to: CGPoint(x: startX, y: uperChartHeight + self.contentTop))
                    fillPath.closeSubpath()
                }
            }
            
            // 成交量
            let volume = entity.volume * self.volumeOnYaxisScale
            self.drawColumnRect(context, rect: CGRect(x: left, y: lowerChartBottom - volume, width: candleWidth, height: volume), color: color)
            
            // 最高成交量标签
            if entity.volume == self.maxVolume {
                let y = lowerChartBottom - volume
                self.drawline(context, startPoint: CGPoint(x: contentLeft, y: y), stopPoint: CGPoint(x: contentRight, y: y), color: borderColor, lineWidth: borderWidth / 4.0)
                let maxVolumeStr = self.formatValue(entity.volume)
                self.drawYAxisLabel(context, labelString: maxVolumeStr, yAxis: y, isLeft: false)
            }
            
            // 分时线最后一个点动画显示
            if self.enableAnimatePoint {
                if (i == data.count - 1) {
                    self.animatePoint.frame = CGRect(x: startX - layerWidth/2, y: yPrice - layerWidth/2, width: layerWidth, height: layerWidth)
                }
            }
        }
        
        //填充渐变的颜色
        if theme.drawFilledEnabled && data.count > 0 {
            self.drawLinearGradient(context, path: fillPath, alpha: theme.fillAlpha, startColor: theme.fillStartColor.cgColor, endColor: theme.fillStopColor.cgColor)
        }
        
        // 长按显示（不能放到上面的循环里，不然该高亮部分被上面的线段掩盖）
        for i in 0 ..< data.count {
            let entity = data[i]
            let left = (self.volumeWidth * CGFloat(i) + contentLeft) + self.volumeWidth / 6.0
            let candleWidth = self.volumeWidth - self.volumeWidth / 3.0
            let startX = left + candleWidth / 2.0
            var yPrice: CGFloat = 0
            let volume = entity.volume * self.volumeOnYaxisScale
            if self.longPressToHighlightEnabled {
                if (i == self.highlightLineCurrentIndex) {
                    yPrice = (self.maxPrice - entity.price) * self.priceOnYaxisScale + self.uperChartDrawAreaTop
                    self.drawLongPressHighlight(context,
                                                pricePoint: CGPoint(x: startX, y: yPrice),
                                                volumePoint: CGPoint(x: startX, y: self.contentBottom - volume),
                                                idex: i,
                                                value: entity,
                                                color: theme.highlightLineColor,
                                                lineWidth: theme.highlightLineWidth)
                }
            }
        }
        
        context.restoreGState()
        
    }
    
    func handleLongPressGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            
            if (point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y < self.contentBottom) {
                self.longPressToHighlightEnabled = true;
                self.highlightLineCurrentIndex = Int((point.x - self.contentLeft) / self.volumeWidth)
                self.setNeedsDisplay()
            }
            // TODO: count 没有解包，可以最上面的方法解决
            if self.highlightLineCurrentIndex < dataT.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineLongpress), object: self, userInfo: ["timeLineEntity": (dataT[self.highlightLineCurrentIndex])])
            }
        }
        
        if recognizer.state == .ended {
            self.longPressToHighlightEnabled = false
            self.setNeedsDisplay()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineUnLongpress), object: self)
        }
    }
    
    func handleTapGestureAction(_ recognizer: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineChartDidTap), object: recognizer.view?.tag)
    }
    
    func breathingLightAnimate(_ time:Double) -> CAAnimationGroup {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 3
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
        group.isRemovedOnCompletion = true
        group.fillMode = kCAFillModeForwards
        group.animations = [scaleAnimation,opacityAnimation]
        group.repeatCount = MAXFLOAT
        
        return group
    }

    
}
