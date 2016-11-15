//
//  HSKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/10.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit


class HSKLineView: UIView {

    var scrollView: UIScrollView!
    
    var dataSet: KLineDataSet?
    var oldContentOffsetX: CGFloat = 0
    var candleWidth: CGFloat = 8
    var candleMaxWidth: CGFloat = 30
    var candleMinWidth: CGFloat = 5
    var gapBetweenCandle: CGFloat = 1
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxVolume: CGFloat = 0
    var maxMACD: CGFloat = CGFloat.leastNormalMagnitude
    var maxMA5: CGFloat = 0
    var minMA5: CGFloat = 0
    var maxMA10: CGFloat = 0
    var minMA10: CGFloat = 0
    var maxMA20: CGFloat = 0
    var minMA20: CGFloat = 0
    
    var xAxisHeitht: CGFloat = 20
    var uperChartHeightScale: CGFloat = 0.7
    var uperChartHeight: CGFloat {
        get {
            return uperChartHeightScale * self.frame.height
        }
    }
    var lowerChartTop: CGFloat {
        get {
            return uperChartHeight + xAxisHeitht
        }
    }
    var lowerChartHeight: CGFloat {
        get {
            return self.frame.height * (1 - uperChartHeightScale) - xAxisHeitht
        }
    }
    var showContentWidth: CGFloat = 0
    var klineMaxValueY: CGFloat = 10
    var klineMinValueY: CGFloat {
        get {
            return uperChartHeightScale * self.frame.height - 10
        }
    }
    var lowerChartMaxValueY: CGFloat {
        get {
            return lowerChartTop + 10
        }
    }
    
    var gridBackgroundColor = UIColor.white
    var borderColor = UIColor(rgba: "#e4e4e4")
    var borderWidth: CGFloat = 1
    
    var priceOnYaxisScale: CGFloat = 0
    var ma5OnYaxisScale: CGFloat = 0
    var ma10OnYaxisScale: CGFloat = 0
    var ma20OnYaxisScale: CGFloat = 0
    var lastPriceOnYaxisScale: CGFloat = 0
    var volumeOnYaxisScale: CGFloat = 0
    var macdOnYaxisScale: CGFloat = 0
    
    var yAxisLabelEdgeInset: CGFloat = 5
    
    var monthInterval = 0 //for week
    var showMacdEnable = false
    var showLongPressHighlight = false
    var highLightIndex: Int = 0
    
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x
            let leftCandleCount = abs(scrollViewOffsetX) / (candleWidth + gapBetweenCandle)
            
            if leftCandleCount == 0 {
                return Int(leftCandleCount)
            } else {
                return Int(leftCandleCount) + 1
            }
        }
    }
    
    // 当前显示区域起始横坐标 x
    var startX: CGFloat {
        get {
            let scrollViewOffsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x
            return scrollViewOffsetX
        }
    }
    
    // 当前显示区域最多显示的蜡烛图个数
    var countOfshowCandle: Int {
        get{
            return Int((scrollView.frame.width - candleWidth) / ( candleWidth + gapBetweenCandle))
        }
    }
    
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
    
    var longPressGesture: UILongPressGestureRecognizer {
        get{
            return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        }
    }
    
    var pinGesture: UIPinchGestureRecognizer {
        get{
            return UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        }
    }
    var lastPinScale: CGFloat = 0
    
    // MARK: - 初始化方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(pinGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        
        if let data  = self.dataSet?.data , data.count > 0 {
            setMaxAndMinData()
            drawChartFrame(context!)
            drawCandleLine(context!, data: data)
        } else {
            
        }
    }
    
    
    // MARK: - 当前 view 被添加到 subview 后调用
    
    override func didMoveToSuperview() {
        self.scrollView = self.superview as? UIScrollView
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        showContentWidth = self.scrollView.frame.width
        super.didMoveToSuperview()
    }
    
    
    // MARK: - 通过监听获取 scrollview 的 contentOffset 变化
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            print("in klineview scrollView?.contentOffset.x " + "\(scrollView?.contentOffset.x)")
            let diff = abs(scrollView!.contentOffset.x - self.oldContentOffsetX)
            if diff >= candleWidth + gapBetweenCandle {
                self.oldContentOffsetX = (self.scrollView?.contentOffset.x)!
                // 拖动 ScrollView 改变当前显示的 klineview
                drawCurrentKlineView()
            }
        }
    }
    

    // MARK: - 更新 View 的整体长度
    
    func updateKlineViewWidth() {
        if let data = dataSet?.data {
            let count = CGFloat(data.count)
            // 总长度
            var kLineViewWidth = count * candleWidth + (count + 1) * gapBetweenCandle
            if kLineViewWidth < ScreenWidth {
                kLineViewWidth = ScreenWidth
            }
            // 更新长度
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kLineViewWidth, height: 300)
            self.scrollView.contentSize = CGSize(width: kLineViewWidth, height: 300)
            
        } else {
            //self.showFailStatusView()
        }
    }
    
    
    // MARK: - 重绘当前的 KlineView
    
    func drawCurrentKlineView() {
        setNeedsDisplay()
    }
    
    
    // MARK: - 设置当前显示区域的最大最小值
    
    func setMaxAndMinData() {
        if let data = self.dataSet?.data , data.count > 0 {
            self.maxPrice = CGFloat.leastNormalMagnitude
            self.minPrice = CGFloat.greatestFiniteMagnitude
            self.maxVolume = CGFloat.leastNormalMagnitude
            self.maxMACD = CGFloat.leastNormalMagnitude
            self.maxMA5 = CGFloat.leastNormalMagnitude
            self.minMA5 = CGFloat.greatestFiniteMagnitude
            self.maxMA10 = CGFloat.leastNormalMagnitude
            self.minMA10 = CGFloat.greatestFiniteMagnitude
            self.maxMA20 = CGFloat.leastNormalMagnitude
            self.minMA20 = CGFloat.greatestFiniteMagnitude
            let startIndex = self.startIndex
            //let count = (startIndex + countOfshowCandle) > data.count ? data.count : (startIndex + countOfshowCandle)
            // 比计算出来的多加一个，是为了避免计算结果的取整导致少画
            let count = (startIndex + countOfshowCandle + 1) > data.count ? data.count : (startIndex + countOfshowCandle + 1)
            for i in startIndex ..< count {
                let entity = data[i]
                self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                
                let tempMAMax = max(entity.ma5, entity.ma10, entity.ma20)
                self.maxMA5 = self.maxMA5 > tempMAMax ? self.maxMA5 : tempMAMax
                
                let tempMAMin = min(entity.ma5, entity.ma10, entity.ma20)
                self.minMA5 = self.minMA5 < tempMAMin ? self.minMA5 : tempMAMin
                
//                self.maxMA5 = self.maxMA5 > entity.ma5 ? self.maxMA5 : entity.ma5
//                self.minMA5 = self.minMA5 < entity.ma5 ? self.minMA5 : entity.ma5
//                
//                self.maxMA10 = self.maxMA10 > entity.ma10 ? self.maxMA10 : entity.ma10
//                self.minMA10 = self.minMA10 < entity.ma10 ? self.minMA10 : entity.ma10
//                
//                self.maxMA20 = self.maxMA20 > entity.ma20 ? self.maxMA20 : entity.ma20
//                self.minMA20 = self.minMA20 < entity.ma20 ? self.minMA20 : entity.ma20
                
                let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
                self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD
            }
            
            self.maxPrice = self.maxPrice > self.maxMA5 ? self.maxPrice : self.maxMA5
            self.minPrice = self.minPrice < self.minMA5 ? self.minPrice : self.minMA5
            
            self.priceOnYaxisScale = (uperChartHeight - 20) / (self.maxPrice - self.minPrice)
//            self.ma5OnYaxisScale = (uperChartHeight - 20) / (self.maxMA5 - self.minMA5)
//            self.ma10OnYaxisScale = (uperChartHeight - 20) / (self.maxMA10 - self.minMA10)
//            self.ma20OnYaxisScale = (uperChartHeight - 20) / (self.maxMA20 - self.minMA20)
            self.volumeOnYaxisScale = (lowerChartHeight - 10) / self.maxVolume
        }
    }
    
    
    // MARK: - 画边线
    
    func drawChartFrame(_ context: CGContext) {
        // K线图 顶部边界线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: 0),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: 0),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 内上边线 即最高价格线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: self.klineMaxValueY),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: self.klineMaxValueY),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 内下边线 即最低价格线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: self.klineMinValueY),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: klineMinValueY),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 中间的横线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: uperChartHeight / 2.0),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: uperChartHeight / 2.0),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 底部边界线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: uperChartHeight),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: uperChartHeight),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // 交易量图 上边界线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: lowerChartTop),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: lowerChartTop),
                      color: borderColor,
                      lineWidth: borderWidth / 4.0)
        // 交易量图 内上边线 即最高交易量格线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: lowerChartMaxValueY),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: lowerChartMaxValueY),
                      color: borderColor,
                      lineWidth: borderWidth / 4.0)
    }
    
    
    // MARK: - 画 K 线
    
    func drawCandleLine(_ context: CGContext, data: [KLineEntity]) {
        context.saveGState()
        
        var lastDate: Date?
        var highLightEntity: KLineEntity?
        var highLightX: CGFloat?
        var highLightVolume: CGFloat?
        var highLightClose: CGFloat?
        
        let count = (startIndex + countOfshowCandle + 1) > data.count ? data.count : (startIndex + countOfshowCandle + 1)
        
        for i in startIndex ..< count {
            let entity = data[i]
            let open = ((self.maxPrice - entity.open) * self.priceOnYaxisScale) + self.klineMaxValueY
            let close = ((self.maxPrice - entity.close) * self.priceOnYaxisScale) + self.klineMaxValueY
            let high = ((self.maxPrice - entity.high) * self.priceOnYaxisScale) + self.klineMaxValueY
            let low = ((self.maxPrice - entity.low) * self.priceOnYaxisScale) + self.klineMaxValueY
            let left = self.startX + CGFloat(i - startIndex) * (self.candleWidth + gapBetweenCandle) //- candleWidth
            let volume = ((entity.volume - 0) * self.volumeOnYaxisScale)
            //let macd = entity.macd * self.macdOnYaxisScale
            
            let centerX = left + candleWidth / 2.0
            
            // 画表格灰色竖线，以及横坐标的标签
            if let date = entity.date.toDate("yyyy-MM-dd") {
                if lastDate == nil {
                    lastDate = date
                }
                if date.year > (lastDate?.year)! || date.month > lastDate!.month + monthInterval {
                    self.drawline(context,
                                  startPoint: CGPoint(x: centerX, y: 0),
                                  stopPoint: CGPoint(x: centerX,  y: self.uperChartHeight), color: self.borderColor, lineWidth: 0.5)
                    
                    self.drawline(context,
                                  startPoint: CGPoint(x: centerX, y: lowerChartTop),
                                  stopPoint: CGPoint(x: centerX, y: self.frame.height), color: self.borderColor, lineWidth: 0.5)
                    
                    let drawAttributes = self.xAxisLabelAttribute
                    let dateStrAtt = NSMutableAttributedString(string: date.toString("yyyy-MM"), attributes: drawAttributes)
                    let dateStrAttSize = dateStrAtt.size()
                    self.drawLabel(context,
                                   attributesText: dateStrAtt,
                                   rect: CGRect(x: centerX - dateStrAttSize.width/2, y: uperChartHeight, width: dateStrAttSize.width, height: dateStrAttSize.height))
                    lastDate = date
                }
            }
            
            // 画蜡烛图
            var color = self.dataSet?.candleRiseColor
            if open < close {
                color = self.dataSet?.candleFallColor
                self.drawColumnRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: close - open), color: color!)
                self.drawline(context, startPoint: CGPoint(x: centerX, y: high), stopPoint: CGPoint(x: centerX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else if open == close {
                if i > 1 {
                    let lastEntity = data[i-1]
                    if lastEntity.close > entity.close{
                        color = self.dataSet?.candleFallColor
                    }
                }
                self.drawColumnRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: 1.5), color: color!)
                self.drawline(context, startPoint: CGPoint(x: centerX, y: high), stopPoint: CGPoint(x: centerX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else {
                color = self.dataSet?.candleRiseColor
                self.drawColumnRect(context, rect: CGRect(x: left, y: close, width: candleWidth, height: open-close), color: color!)
                self.drawline(context, startPoint: CGPoint(x: centerX, y: high), stopPoint: CGPoint(x: centerX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
            }
            
            // 画移动均线图
            if i > startIndex {
                let lastEntity = data[i-1]
                let lastX = centerX - self.candleWidth - gapBetweenCandle
                
                // 5，10，20日均线
                let lastY5 = (self.maxPrice - lastEntity.ma5) * self.priceOnYaxisScale + self.klineMaxValueY
                let  y5 = (self.maxPrice - entity.ma5) * self.priceOnYaxisScale  + self.klineMaxValueY
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY5), stopPoint: CGPoint(x: centerX, y: y5), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY10 = (self.maxPrice - lastEntity.ma10) * self.priceOnYaxisScale  + self.klineMaxValueY
                let  y10 = (self.maxPrice - entity.ma10) * self.priceOnYaxisScale  + self.klineMaxValueY
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY10) , stopPoint: CGPoint(x: centerX, y: y10), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY20 = (self.maxPrice - lastEntity.ma20) * self.priceOnYaxisScale  + self.klineMaxValueY
                let  y20 = (self.maxPrice - entity.ma20) * self.priceOnYaxisScale  + self.klineMaxValueY
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY20), stopPoint: CGPoint(x: centerX, y: y20), color: self.dataSet!.avgMA20Color, lineWidth: self.dataSet!.avgLineWidth)
            }
            
            // 画成交量图或者MACD
            if self.showMacdEnable {
                // 显示 MACD 值
//                let macdColor = macd >= 0 ? dataSet?.candleRiseColor : dataSet?.candleFallColor
//                self.drawColumnRect(context, rect: CGRect(x: left, y: zeroBasic - macd, width: candleWidth, height: macd), color: macdColor!)
//
//                if i > startIndex {
//                    let lastEntity = data[i-1]
//                    let lastX = centerX - self.candleWidth - gapBetweenCandle
//                    let lastDiff = zeroBasic - lastEntity.diff * macdOnYaxisScale
//                    let  diff = zeroBasic - entity.diff * macdOnYaxisScale
//                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDiff), stopPoint: CGPoint(x: centerX, y: diff), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
//                    
//                    let lastDea = zeroBasic - lastEntity.dea * macdOnYaxisScale
//                    let  dea = zeroBasic - entity.dea * macdOnYaxisScale
//                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDea), stopPoint: CGPoint(x: centerX, y: dea), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
//                }
                
            } else {
                // 成交量
                self.drawColumnRect(context,rect:CGRect(x: left, y: self.scrollView.frame.height - volume , width: candleWidth, height: volume) ,color:color!)
            }
            
            if self.showLongPressHighlight {
                if i == self.highLightIndex {
                    highLightEntity = entity
                    highLightX = centerX
                    highLightVolume = volume
                    highLightClose = close
                }
            }
        }
        
        // 画长按高亮显示内容
        if self.showLongPressHighlight {
            if let entity = highLightEntity, let x = highLightX, let vol = highLightVolume, let close = highLightClose {
                self.drawLongPressHighlight(context,
                                            pricePoint: CGPoint(x: x, y: close),
                                            volumePoint: CGPoint(x: x, y: self.scrollView.frame.height - vol),
                                            value: entity,
                                            color: self.dataSet!.highlightLineColor,
                                            lineWidth: self.dataSet!.highlightLineWidth,
                                            isShowVolume: !showMacdEnable)
                //                    if showMacdEnable {
                //                        self.drawMACDLabel(context, index: i)
                //                    } else {
                //                        self.drawYAxisLabel(context, labelString: "成交量 " + "\(entity.volume)", yAxis: lowerChartTop, isLeft: true, isInLineCenter: false)
                //                    }
                //
                //                    self.drawMALabel(context, index: i)
            }
        }
        
        context.restoreGState()
    }
}


extension HSKLineView {
    
    
    // MARK: - 处理长按操作
    
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            
            self.showLongPressHighlight = true
            self.highLightIndex = Int(point.x / (candleWidth + gapBetweenCandle))
            self.setNeedsDisplay()
            
//            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
//                let lastData = highlightLineCurrentIndex > 0 ? self.dataSet?.data?[self.highlightLineCurrentIndex - 1] : self.dataSet?.data?[0]
//                let userInfo: [AnyHashable: Any]? = ["preClose" : (lastData?.close)!,
//                                                     "kLineEntity" : (self.dataSet?.data?[self.highlightLineCurrentIndex])! ]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
//            }
        }
        
        if recognizer.state == .ended {
            self.showLongPressHighlight = false
            self.setNeedsDisplay()
//            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
////                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
//            }
        }
    }
    
    
    // MARK: - 处理手指捏合扩大操作
    
    func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches < 2 {
            return
        }
        self.showLongPressHighlight = false
        
        //let point = recognizer.location(in: self)
        //let pinchIndex = Int(point.x / (candleWidth + gapBetweenCandle))
        
        if (recognizer.state == .began) {
            lastPinScale = 1.0
            //lastPoint = [sender locationInView:self]
        }
        recognizer.scale = 1 - (self.lastPinScale - recognizer.scale)
        self.candleWidth = recognizer.scale * self.candleWidth
   
        if self.candleWidth > self.candleMaxWidth {
            self.candleWidth = self.candleMaxWidth
        }
        
        if self.candleWidth < self.candleMinWidth {
            self.candleWidth = self.candleMinWidth
        }

        updateKlineViewWidth()
        self.setNeedsDisplay()
        self.lastPinScale = recognizer.scale
        
//        let interval = 2
//        let scale = recognizer.scale
//        let velocity = recognizer.velocity
//        
//        var newRangeFrom = 0
//        if fabs(velocity) > 0.1 {
//            if scale > 1 {
//                //双指张开
//                newRangeFrom = startIndex + interval
//                self.setNeedsDisplay()
//                
//            } else {
//                //双指合拢
//                newRangeFrom = startIndex - interval
//                self.setNeedsDisplay()
//            }
//        }
//        
//        recognizer.scale = 1
    }
    
    
    // MARK: - 基本绘图方法
    
    // 画线
    func drawline(_ context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, color: UIColor, lineWidth: CGFloat, isDashLine: Bool = false) {
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
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    // 画纵坐标 标签

    func drawYAxisLabel(_ context: CGContext, str: String, labelAttribute: [String : NSObject], xAxis: CGFloat, yAxis: CGFloat, isLeft: Bool) {
        
        let valueAttributedString = NSMutableAttributedString(string: str, attributes: labelAttribute)
        let valueAttributedStringSize = valueAttributedString.size()
        let labelInLineCenterSize = valueAttributedStringSize.height/2.0
        var labelX: CGFloat = 0
        if isLeft {
            labelX = xAxis + yAxisLabelEdgeInset
        } else {
            labelX = xAxis - valueAttributedStringSize.width - yAxisLabelEdgeInset
        }
        let labelY: CGFloat = yAxis - labelInLineCenterSize
        
        self.drawLabel(context, attributesText: valueAttributedString, rect: CGRect(x: labelX, y: labelY, width: valueAttributedStringSize.width, height: valueAttributedStringSize.height))
    }
    
    // 画长按显示
    func drawLongPressHighlight(_ context: CGContext, pricePoint: CGPoint, volumePoint: CGPoint, value: AnyObject, color: UIColor, lineWidth: CGFloat, isShowVolume: Bool = true) {
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerStr = ""
        var volumeMarkerString = ""
        
        if value.isKind(of: TimeLineEntity.self) {
            let entity = value as! TimeLineEntity
            rightMarkerStr = self.formatValue(entity.price)
            bottomMarkerString = entity.currtTime
            leftMarkerString = self.formatRatio(entity.rate)
            volumeMarkerString = entity.volume.toStringWithFormat("%.2f")
            
        } else if value.isKind(of: KLineEntity.self){
            let entity = value as! KLineEntity
            rightMarkerStr = self.formatValue(entity.close)
            bottomMarkerString = entity.date
            leftMarkerString = entity.rate.toStringWithFormat("%.2f") + "%"
            volumeMarkerString = entity.volume.toStringWithFormat("%.2f")
        }else{
            
            return
        }
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        
        context.beginPath()
        context.move(to: CGPoint(x: pricePoint.x, y: 0))
        context.addLine(to: CGPoint(x: pricePoint.x, y: self.frame.height))
        context.strokePath()
        
        context.beginPath()
        context.move(to: CGPoint(x: self.startX, y: pricePoint.y))
        context.addLine(to: CGPoint(x: self.startX + self.showContentWidth, y: pricePoint.y))
        context.strokePath()
        
        if isShowVolume {
            context.beginPath()
            context.move(to: CGPoint(x: self.startX, y: volumePoint.y))
            context.addLine(to: CGPoint(x: self.startX + self.showContentWidth, y: volumePoint.y))
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
        
        labelX = self.startX
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: leftMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = self.uperChartHeight
        self.drawLabel(context,
                       attributesText: bottomMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        labelX = self.startX + self.showContentWidth - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        if isShowVolume {
            labelX = self.startX + self.showContentWidth - volumeMarkerStringAttributeSize.width
            labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
            self.drawLabel(context,
                           attributesText: volumeMarkerStringAttribute,
                           rect: CGRect(x: labelX, y: labelY, width: volumeMarkerStringAttributeSize.width, height: volumeMarkerStringAttributeSize.height))
        }
    }
    
    
    // MARK: - 格式化数字输出
    
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
    
}
