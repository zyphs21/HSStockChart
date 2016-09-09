//
//  KLineStockChartView.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/22.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSKLineStockChartView: HSBaseStockChartView {

    var dataSet: KLineDataSet?
    var priceOnYaxisScale: CGFloat = 0
    var volumeOnYaxisScale: CGFloat = 0
    var macdOnYaxisScale: CGFloat = 0
    
    var candleWidth: CGFloat = 8
    var monthInterval = 0
    var candleMaxWidth: CGFloat = 30
    var candleMinWidth: CGFloat = 5
    
    var recoverSign: String = "不复权"
    
    var maxMACD: CGFloat = CGFloat.min
    
    var showMacdEnable: Bool = false
    
    var countOfshowCandle: Int {
        get{
            return Int(contentWidth / candleWidth)
        }
    }
    var _startDrawIndex: Int = 0
    var startDrawIndex : Int {
        get{
            return _startDrawIndex
        }
        set(value){
            var temp = 0
            if (value < 0) {
                temp = 0
            }else{
                temp = value
            }
            if (temp + self.countOfshowCandle > self.dataSet!.data!.count) {
                //temp = self.dataSet!.data!.count - self.countOfshowCandle
            }
            _startDrawIndex = temp
        }
    }
    
    var panGesture: UIPanGestureRecognizer {
        get{
            return UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureAction(_:)))
        }
    }
    
    var pinGesture: UIPinchGestureRecognizer {
        get{
            return UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        }
    }
    
    var longPressGesture: UILongPressGestureRecognizer {
        get{
            return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        }
    }
    
    var tapGesture: UITapGestureRecognizer {
        get{
            return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        }
    }
    
    var lastPinScale: CGFloat = 0
    
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    override init(frame: CGRect, uperChartHeightScale: CGFloat, topOffSet: CGFloat, leftOffSet: CGFloat, bottomOffSet: CGFloat, rightOffSet: CGFloat) {
        
        super.init(frame: frame, uperChartHeightScale: uperChartHeightScale, topOffSet: topOffSet, leftOffSet: leftOffSet, bottomOffSet: bottomOffSet, rightOffSet: rightOffSet)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinGesture)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if let data  = self.dataSet?.data where data.count > 0{
            let context = UIGraphicsGetCurrentContext()
            self.setMaxAndMinData()
            self.drawChartFrame(context!, rect: rect)
            self.drawCandleLine(context!, data: data)
            self.drawLabelPrice(context!)
        }
    }
    
    func setUpData(dataSet: KLineDataSet) {
        if let d = dataSet.data where self.countOfshowCandle > 0 {

            self.dataSet = dataSet
            //dataSet.data = [KLineEntity](d)
            
            if d.count > self.countOfshowCandle {
                self.startDrawIndex = d.count - self.countOfshowCandle
            }
            self.self.setNeedsDisplay()
            
        } else {
            //self.showFailStatusView()
        }
    }

    
    // MARK: - Function
    
    func setMaxAndMinData() {
        if let data = self.dataSet?.data where data.count > 0 {
            self.maxPrice = CGFloat.min
            self.minPrice = CGFloat.max
            self.maxRatio = CGFloat.min
            self.minRatio = CGFloat.max
            self.maxVolume = CGFloat.min
            self.maxMACD = CGFloat.min
            let startIndex = self.startDrawIndex
            //data.count
            let count = (startIndex + countOfshowCandle) > data.count ? data.count : (startIndex + countOfshowCandle)
            for i in startIndex ..< count {
                let entity = data[i]
                self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
                self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD
            }
            print("max macd  " + "\(maxMACD)")
        }
    }
    
    override func drawChartFrame(context: CGContextRef,rect: CGRect) {
        super.drawChartFrame(context, rect: rect)
        
        // K线图 内上边线
        self.drawline(context,
                      startPoint: CGPointMake(self.contentLeft, self.uperChartDrawAreaTop),
                      stopPoint: CGPointMake(self.contentLeft + self.contentWidth, self.uperChartDrawAreaTop),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 内下边线
        self.drawline(context,
                      startPoint: CGPointMake(self.contentLeft, uperChartDrawAreaBottom),
                      stopPoint: CGPointMake(self.contentRight, uperChartDrawAreaBottom),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        
        // K线图 中间的横线
        self.drawline(context,
                      startPoint: CGPointMake(self.contentLeft, uperChartHeight / 2.0 + self.contentTop),
                      stopPoint: CGPointMake(self.contentRight, uperChartHeight /  2.0 + self.contentTop),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        
        self.drawYAxisLabel(context, labelString: recoverSign, yAxis: contentTop, isLeft: true, isInLineCenter: false)

        // 显示macd的坐标线及标签
        if showMacdEnable {
            let startPoint1 = CGPointMake(contentLeft, lowerChartBottom - lowerChartDrawAreaMargin)
            let stopPoint1 = CGPointMake(contentRight, lowerChartBottom - lowerChartDrawAreaMargin)
            self.drawline(context, startPoint: startPoint1, stopPoint: stopPoint1, color: borderColor, lineWidth: borderWidth / 2.0)
            
            let startPoint2 = CGPointMake(contentLeft, lowerChartTop + lowerChartDrawAreaMargin)
            let stopPoint2 = CGPointMake(contentRight, lowerChartTop + lowerChartDrawAreaMargin)
            self.drawline(context, startPoint: startPoint2, stopPoint: stopPoint2, color: borderColor, lineWidth: borderWidth / 2.0)
            
            let tempY = lowerChartRect.height / 2
            let startPoint3 = CGPointMake(contentLeft, lowerChartTop + tempY)
            let stopPoint3 = CGPointMake(contentRight, lowerChartTop + tempY)
            self.drawline(context, startPoint: startPoint3, stopPoint: stopPoint3, color: borderColor, lineWidth: borderWidth / 2.0, isDashLine: true)
            
            self.drawYAxisLabel(context, labelString: formatValue(self.maxMACD), yAxis: lowerChartTop + lowerChartDrawAreaMargin, isLeft: false)
            self.drawYAxisLabel(context, labelString: formatValue(-self.maxMACD), yAxis: lowerChartBottom - lowerChartDrawAreaMargin, isLeft: false)
            self.drawYAxisLabel(context, labelString: formatValue(0), yAxis: lowerChartTop + tempY, isLeft: false)
            
            self.drawYAxisLabel(context, labelString: "MACD", yAxis: lowerChartTop, isLeft: true, isInLineCenter: false)
            
        } else {
            self.drawYAxisLabel(context, labelString: "成交量", yAxis: lowerChartTop, isLeft: true, isInLineCenter: false)
        }
    }
    
    // 画纵坐标标签
    func drawLabelPrice(context: CGContextRef) {
        let maxPriceStr = self.formatValue(maxPrice)
        let minPriceStr = self.formatValue(minPrice)
        
        self.drawYAxisLabel(context, labelString: maxPriceStr, yAxis: uperChartDrawAreaTop, isLeft: false)
        self.drawYAxisLabel(context, labelString: minPriceStr, yAxis: uperChartDrawAreaBottom, isLeft: false)
    }
    
    // 画 K 线
    func drawCandleLine(context: CGContextRef, data: [KLineEntity]) {
        CGContextSaveGState(context)
        
        var lastDate: NSDate?
        let idex = self.startDrawIndex
        
        self.priceOnYaxisScale = uperChartDrawAreaHeight / (self.maxPrice - self.minPrice)
        self.volumeOnYaxisScale = (lowerChartHeight - lowerChartDrawAreaMargin) / self.maxVolume
        
        let zeroBasic = lowerChartTop + lowerChartRect.height / 2
        let macdDrawingHeight = lowerChartHeight - lowerChartDrawAreaMargin * 2
        self.macdOnYaxisScale = macdDrawingHeight / (self.maxMACD * 2)
        
        for i in idex ..< data.count {
            let entity = data[i]
            let open = ((self.maxPrice - entity.open) * self.priceOnYaxisScale) + self.uperChartDrawAreaTop
            let close = ((self.maxPrice - entity.close) * self.priceOnYaxisScale) + self.uperChartDrawAreaTop
            let high = ((self.maxPrice - entity.high) * self.priceOnYaxisScale) + self.uperChartDrawAreaTop
            let low = ((self.maxPrice - entity.low) * self.priceOnYaxisScale) + self.uperChartDrawAreaTop
            let left = (self.candleWidth * CGFloat(i - idex) + self.contentLeft) + self.candleWidth / 6.0
            let volume = ((entity.volume - 0) * self.volumeOnYaxisScale)
            let macd = entity.macd * self.macdOnYaxisScale
            
            let candleWidth = self.candleWidth - self.candleWidth / 6.0
            let startX = left + candleWidth / 2.0
            
            //画表格灰色竖线，以及横坐标的标签
            if let date = entity.date.toDate("yyyy-MM-dd") {
                if lastDate == nil {
                    lastDate = date
                }
                if date.year > lastDate?.year || date.month > lastDate!.month + monthInterval {
                    self.drawline(context,
                                  startPoint: CGPointMake(startX, self.contentTop),
                                  stopPoint: CGPointMake(startX,  self.uperChartBottom), color: self.borderColor, lineWidth: 0.5)
                    
                    self.drawline(context,
                                  startPoint: CGPointMake(startX, lowerChartTop),
                                  stopPoint: CGPointMake(startX, self.contentBottom), color: self.borderColor, lineWidth: 0.5)
                    
                    let drawAttributes = self.xAxisLabelAttribute
                    let dateStrAtt = NSMutableAttributedString(string: date.toString("yyyy-MM"), attributes: drawAttributes)
                    let dateStrAttSize = dateStrAtt.size()
                    self.drawLabel(context,
                                   attributesText: dateStrAtt,
                                   rect: CGRectMake(startX - dateStrAttSize.width/2, (uperChartHeight + self.contentTop), dateStrAttSize.width,dateStrAttSize.height))
                    lastDate = date
                }
            }
            
            var color = self.dataSet?.candleRiseColor
            if open < close {
                color = self.dataSet?.candleFallColor
                self.drawColumnRect(context, rect: CGRectMake(left, open, candleWidth, close - open), color: color!)
                self.drawline(context, startPoint: CGPointMake(startX, high), stopPoint: CGPointMake(startX, low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else if open == close {
                if i > 1 {
                    let lastEntity = data[i-1]
                    if lastEntity.close > entity.close{
                        color = self.dataSet?.candleFallColor
                    }
                }
                self.drawColumnRect(context, rect: CGRectMake(left, open, candleWidth, 1.5), color: color!)
                self.drawline(context, startPoint: CGPointMake(startX, high), stopPoint: CGPointMake(startX, low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else {
                color = self.dataSet?.candleRiseColor
                self.drawColumnRect(context, rect: CGRectMake(left, close, candleWidth, open-close), color: color!)
                self.drawline(context, startPoint: CGPointMake(startX, high), stopPoint: CGPointMake(startX, low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
            }
            
            if i > 0 {
                let lastEntity = data[i-1]
                let lastX = startX - self.candleWidth
                
                // 5，10，20日均线
                let lastY5 = (self.maxPrice - lastEntity.ma5) * self.priceOnYaxisScale + self.contentTop
                let  y5 = (self.maxPrice - entity.ma5) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPointMake(lastX, lastY5), stopPoint: CGPointMake(startX, y5), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY10 = (self.maxPrice - lastEntity.ma10) * self.priceOnYaxisScale  + self.contentTop
                let  y10 = (self.maxPrice - entity.ma10) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPointMake(lastX, lastY10) , stopPoint: CGPointMake(startX, y10), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY20 = (self.maxPrice - lastEntity.ma20) * self.priceOnYaxisScale  + self.contentTop
                let  y20 = (self.maxPrice - entity.ma20) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPointMake(lastX, lastY20), stopPoint: CGPointMake(startX, y20), color: self.dataSet!.avgMA20Color, lineWidth: self.dataSet!.avgLineWidth)
                
                if self.showMacdEnable {
                    // 显示 MACD 值
                    let macdColor = macd >= 0 ? dataSet?.candleRiseColor : dataSet?.candleFallColor
                    self.drawColumnRect(context, rect: CGRectMake(left, zeroBasic - macd, candleWidth, macd), color: macdColor!)
                    
                    let lastDiff = zeroBasic - lastEntity.diff * macdOnYaxisScale
                    let  diff = zeroBasic - entity.diff * macdOnYaxisScale
                    self.drawline(context, startPoint: CGPointMake(lastX, lastDiff), stopPoint: CGPointMake(startX, diff), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                    let lastDea = zeroBasic - lastEntity.dea * macdOnYaxisScale
                    let  dea = zeroBasic - entity.dea * macdOnYaxisScale
                    self.drawline(context, startPoint: CGPointMake(lastX, lastDea), stopPoint: CGPointMake(startX, dea), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                } else {
                    // 成交量
                    self.drawColumnRect(context,rect:CGRectMake(left, self.lowerChartBottom - volume , candleWidth, volume) ,color:color!)
                    
                    // 最高成交量标签
                    if entity.volume == self.maxVolume {
                        let y = self.lowerChartBottom - volume
                        self.drawline(context, startPoint: CGPointMake(contentLeft, y), stopPoint: CGPointMake(contentRight, y), color: borderColor, lineWidth: borderWidth / 4.0)
                        let maxVolumeStr = self.formatValue(entity.volume)
                        self.drawYAxisLabel(context, labelString: maxVolumeStr, yAxis: y, isLeft: false)
                    }
                }
            }
        }
        
        // 长按显示
        for i in idex ..< data.count {
            let entity = data[i]
            let close = ((self.maxPrice - entity.close) * self.priceOnYaxisScale) + self.uperChartDrawAreaTop
            let left = (self.candleWidth * CGFloat(i - idex) + self.contentLeft) + self.candleWidth / 6.0
            let volume = entity.volume * self.volumeOnYaxisScale
            //let macd = entity.macd * self.macdOnYaxisScale
            
            let candleWidth = self.candleWidth - self.candleWidth / 6.0
            let startX = left + candleWidth / 2.0
            
            if self.longPressToHighlightEnabled {
                if i == self.highlightLineCurrentIndex {
                    self.drawLongPressHighlight(context,
                                                pricePoint: CGPointMake(startX, close),
                                                volumePoint: CGPointMake(startX, self.contentBottom - volume),
                                                idex: idex,
                                                value: entity,
                                                color: self.dataSet!.highlightLineColor,
                                                lineWidth: self.dataSet!.highlightLineWidth,
                                                isShowVolume: !showMacdEnable)
                    if showMacdEnable {
                        self.drawMACDLabel(context, index: i)
                    } else {
                        self.drawYAxisLabel(context, labelString: "成交量 " + "\(entity.volume)", yAxis: lowerChartTop, isLeft: true, isInLineCenter: false)
                    }
                    
                    self.drawMALabel(context, index: i)
                }
            }
        }
        
        if !self.longPressToHighlightEnabled{
//            self.drawAvgMarker(context, idex: 0)
        }
        
        CGContextRestoreGState(context)
    }
    
    func drawMALabel(context: CGContextRef, index: Int) {
        var entity : KLineEntity?
        if index == 0{
            entity = self.dataSet?.data?.last
        }else{
            entity = self.dataSet?.data?[index]
        }
        
        if let entity = entity where self.longPressToHighlightEnabled {
            
            let space:CGFloat = 4.0
            var startPoint = CGPointMake(self.contentLeft + space, self.contentTop)
            
            let recoverAttribute = NSMutableAttributedString(string: recoverSign, attributes: self.annotationLabelAttribute)
            let recoverSize = recoverAttribute.size()
            self.drawLabel(context, attributesText: recoverAttribute, rect: CGRectMake(startPoint.x, startPoint.y, recoverSize.width, recoverSize.height))
            
            startPoint.x += recoverSize.width + space
            let ma5 = "MA5:" + "\(formatValue(entity.ma5))"
            let ma5Attribute = NSMutableAttributedString(string: ma5 , attributes: getLabelAttribute((dataSet?.avgMA5Color)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let ma5Size = ma5Attribute.size()
            self.drawLabel(context, attributesText: ma5Attribute, rect: CGRectMake(startPoint.x, startPoint.y, ma5Size.width, ma5Size.height))
            
            startPoint.x += ma5Size.width + space
            let ma10 = "MA10:" + "\(formatValue(entity.ma10))"
            let ma10Attribute = NSMutableAttributedString(string: ma10 , attributes: getLabelAttribute((dataSet?.avgMA10Color)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let ma10Size = ma10Attribute.size()
            self.drawLabel(context, attributesText: ma10Attribute, rect: CGRectMake(startPoint.x, startPoint.y, ma10Size.width, ma10Size.height))
            
            startPoint.x += ma10Size.width + space
            let ma20 = "MA20:" + "\(formatValue(entity.ma20))"
            let ma20Attribute = NSMutableAttributedString(string: ma20 , attributes: getLabelAttribute((dataSet?.avgMA20Color)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let ma20Size = ma20Attribute.size()
            self.drawLabel(context, attributesText: ma20Attribute, rect: CGRectMake(startPoint.x, startPoint.y, ma20Size.width, ma20Size.height))
            
        }
    }
    
    func drawMACDLabel(context: CGContextRef, index: Int) {
        var entity : KLineEntity?
        if index == 0{
            entity = self.dataSet?.data?.last
        }else{
            entity = self.dataSet?.data?[index]
        }
        
        if let entity = entity where self.longPressToHighlightEnabled {
            
            let space:CGFloat = 4.0
            var startPoint = CGPointMake(self.contentLeft + space, self.lowerChartTop)
            
            let diff = "DIFF:" + "\(formatValue(entity.diff))"
            let diffAttribute = NSMutableAttributedString(string: diff , attributes: getLabelAttribute((dataSet?.avgMA5Color)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let diffSize = diffAttribute.size()
            self.drawLabel(context, attributesText: diffAttribute, rect: CGRectMake(startPoint.x, startPoint.y, diffSize.width, diffSize.height))
            
            startPoint.x += diffSize.width + space
            let dea = "DEA:" + "\(formatValue(entity.dea))"
            let deaAttribute = NSMutableAttributedString(string: dea , attributes: getLabelAttribute((dataSet?.avgMA10Color)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let deaSize = deaAttribute.size()
            self.drawLabel(context, attributesText: deaAttribute, rect: CGRectMake(startPoint.x, startPoint.y, deaSize.width, deaSize.height))
            
            startPoint.x += deaSize.width + space
            let macd = "MACD:" + "\(formatValue(entity.macd))"
            let macdAttribute = NSMutableAttributedString(string: macd , attributes: getLabelAttribute((dataSet?.highlightLineColor)!, backgroundColor: UIColor.whiteColor(), fontSize: 8))
            let macdSize = macdAttribute.size()
            self.drawLabel(context, attributesText: macdAttribute, rect: CGRectMake(startPoint.x, startPoint.y, macdSize.width, macdSize.height))
            
        }
    }
    
    
    func handlePanGestureAction(recognizer: UIPanGestureRecognizer) {
        self.longPressToHighlightEnabled = false
        
        var isPanRight = false
        let point = recognizer.translationInView(self) //获得拖动的信息
        
        if (recognizer.state == UIGestureRecognizerState.Began) {
        }
        if (recognizer.state == UIGestureRecognizerState.Changed) {
        }
        
        let offset = point.x
        if point.x > 0 {
            
            let temp = offset / self.candleWidth
            var moveCount = 0
            if temp <= 1 {
                moveCount = 1
                
            }else {
                moveCount = Int(temp)
            }
            
            self.startDrawIndex = self.startDrawIndex - moveCount
            if self.startDrawIndex < 10 {
//                if self.delegate != nil {
//                    self.delegate?.chartKlineScrollLeft!(self)
//                }
            }
            
        } else {
            // 判断是否拖动到右边缘尽头
            let count = Int(CGFloat(self.startDrawIndex + self.countOfshowCandle) + (-offset/self.candleWidth))
            if count > self.dataSet?.data?.count {
                isPanRight = true
                print("isPanRight  " + "\(isPanRight)")
            }
            
            let temp = (-offset) / self.candleWidth
            var moveCount = 0
            if temp <= 1 {
                moveCount = 1
                
            } else {
                moveCount = Int(temp)
            }
            
            self.startDrawIndex += moveCount

            if startDrawIndex > self.dataSet?.data?.count {
                self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
            }
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            if isPanRight {
                self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
                //print("startDrawIndex  " + "\(startDrawIndex)")
//                self.notifyDataSetChanged()
                self.setNeedsDisplay()
            }
        }
        
        self.setNeedsDisplay()
        
        // 切换回零点，不然拖动的速度变快
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    
    func handlePinGestureAction(recognizer: UIPinchGestureRecognizer) {
        self.longPressToHighlightEnabled = false
        
        if recognizer.state == .Began {
            self.lastPinScale = 1.0
        }
        
        recognizer.scale = 1 - (self.lastPinScale - recognizer.scale)
        
        self.candleWidth = recognizer.scale * self.candleWidth
        
        if self.candleWidth > self.candleMaxWidth {
            self.candleWidth = self.candleMaxWidth
        }
        
        if self.candleWidth < self.candleMinWidth {
            self.candleWidth = self.candleMinWidth
        }
        
//        self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
        self.setNeedsDisplay()
        self.lastPinScale = recognizer.scale
    }
    
    func handleTapGestureAction(recognizer: UIPanGestureRecognizer) {
        if CGRectContainsPoint(self.lowerChartRect, recognizer.locationInView(self)) {
            self.showMacdEnable = !self.showMacdEnable
            self.setNeedsDisplay()
            
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(KLineUperChartDidTap, object: recognizer.view?.tag)
        }
    }
    
    func handleLongPressGestureAction(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let  point = recognizer.locationInView(self)
            
            if (point.x > contentLeft && point.x < contentRight && point.y > contentTop && point.y < contentBottom) {
                self.longPressToHighlightEnabled = true
                self.highlightLineCurrentIndex = startDrawIndex + Int((point.x - contentLeft) / candleWidth)
                self.setNeedsDisplay()
            }
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
                let lastData = highlightLineCurrentIndex > 0 ? self.dataSet?.data?[self.highlightLineCurrentIndex - 1] : self.dataSet?.data?[0]
                let userInfo: [NSObject: AnyObject]? = ["preClose" : (lastData?.close)!,
                              "kLineEntity" : (self.dataSet?.data?[self.highlightLineCurrentIndex])! ]
                NSNotificationCenter.defaultCenter().postNotificationName(KLineChartLongPress, object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .Ended {
            self.longPressToHighlightEnabled = false
            self.setNeedsDisplay()
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
                NSNotificationCenter.defaultCenter().postNotificationName(KLineChartUnLongPress, object: self)
            }
        }
    }
    
}

