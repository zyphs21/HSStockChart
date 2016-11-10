//
//  HSKLineAreaView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/10.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit


class HSKLineAreaView: UIView {

    var scrollView: UIScrollView!
    
    var dataSet: KLineDataSet?
    var oldContentOffsetX: CGFloat = 0
    var candleWidth: CGFloat = 8
    var gapBetweenCandle: CGFloat = 1
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxVolume: CGFloat = 0
    var maxMACD: CGFloat = CGFloat.leastNormalMagnitude
    
    var xAxisHeitht: CGFloat = 30
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
    var lastPriceOnYaxisScale: CGFloat = 0
    var volumeOnYaxisScale: CGFloat = 0
    var macdOnYaxisScale: CGFloat = 0
    
    var monthInterval = 0 //for week
    var showMacdEnable = false
    
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x
            let leftCandleCount = abs(scrollViewOffsetX) / ( candleWidth + gapBetweenCandle)
//            let leftCandleCount = abs(scrollViewOffsetX - gapBetweenCandle) / ( candleWidth + gapBetweenCandle)
            print("leftCandleCount " + "\(Int(leftCandleCount))")
            print("data count")
            return Int(leftCandleCount)
        }
    }
    
    // 当前显示区域起始横坐标 x
    var startX: CGFloat {
        get {
//            let start = CGFloat(startIndex)
//            let temp = start * candleWidth + gapBetweenCandle / 2
//            return (start + 1) * gapBetweenCandle + temp
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
    
    // MARK: - 初始化方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("draw " + "\(rect)")
        print("startIndex " + "\(startIndex)")
        
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
                print("oldContentOffsetX " + "\(oldContentOffsetX)")
                self.oldContentOffsetX = (self.scrollView?.contentOffset.x)!
                
                // 拖动 ScrollView 改变当前显示的 klineview
                drawCurrentKlineView()
            }
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
            let startIndex = self.startIndex
            let count = (startIndex + countOfshowCandle) > data.count ? data.count : (startIndex + countOfshowCandle)
            for i in startIndex ..< count {
                let entity = data[i]
                self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
                self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD
            }
            
            self.priceOnYaxisScale = (uperChartHeight - 20) / (self.maxPrice - self.minPrice)
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
        // K线图 内上边线
        self.drawline(context,
                      startPoint: CGPoint(x: self.startX, y: self.klineMaxValueY),
                      stopPoint: CGPoint(x: self.startX + self.showContentWidth, y: self.klineMaxValueY),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 内下边线
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
    }
    
    
    // MARK: - 画 K 线
    
    func drawCandleLine(_ context: CGContext, data: [KLineEntity]) {
        var lastDate: Date?
        let count = (startIndex + countOfshowCandle) > data.count ? data.count : (startIndex + countOfshowCandle)
        
        for i in startIndex + 1 ..< count {
            print("startIndex " + "\(startIndex)")
            print("i " + "\(i)")
            print("count " + "\(count)")
            let entity = data[i]
            let open = ((self.maxPrice - entity.open) * self.priceOnYaxisScale) + self.klineMaxValueY
            let close = ((self.maxPrice - entity.close) * self.priceOnYaxisScale) + self.klineMaxValueY
            let high = ((self.maxPrice - entity.high) * self.priceOnYaxisScale) + self.klineMaxValueY
            let low = ((self.maxPrice - entity.low) * self.priceOnYaxisScale) + self.klineMaxValueY
            let left = self.startX + CGFloat(i - startIndex) * (self.candleWidth + gapBetweenCandle)
            let volume = ((entity.volume - 0) * self.volumeOnYaxisScale)
            let macd = entity.macd * self.macdOnYaxisScale
            
            //let candleWidth = self.candleWidth - self.candleWidth / 6.0
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
            
            // 画移动均线图，成交量/ macd图
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
                
                if self.showMacdEnable {
                    // 显示 MACD 值
//                    let macdColor = macd >= 0 ? dataSet?.candleRiseColor : dataSet?.candleFallColor
//                    self.drawColumnRect(context, rect: CGRect(x: left, y: zeroBasic - macd, width: candleWidth, height: macd), color: macdColor!)
//                    
//                    let lastDiff = zeroBasic - lastEntity.diff * macdOnYaxisScale
//                    let  diff = zeroBasic - entity.diff * macdOnYaxisScale
//                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDiff), stopPoint: CGPoint(x: centerX, y: diff), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
//                    
//                    let lastDea = zeroBasic - lastEntity.dea * macdOnYaxisScale
//                    let  dea = zeroBasic - entity.dea * macdOnYaxisScale
//                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDea), stopPoint: CGPoint(x: centerX, y: dea), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                } else {
                    // 成交量
                    self.drawColumnRect(context,rect:CGRect(x: left, y: self.scrollView.frame.height - volume , width: candleWidth, height: volume) ,color:color!)
                    
                    // 最高成交量标签
//                    if entity.volume == self.maxVolume {
//                        let y = self.lowerChartBottom - volume
//                        self.drawline(context, startPoint: CGPoint(x: contentLeft, y: y), stopPoint: CGPoint(x: contentRight, y: y), color: borderColor, lineWidth: borderWidth / 4.0)
//                        let maxVolumeStr = self.formatValue(entity.volume)
//                        self.drawYAxisLabel(context, labelString: maxVolumeStr, yAxis: y, isLeft: false)
//                    }
                }
            }
        }
    }
}


extension HSKLineAreaView {
    
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
}
