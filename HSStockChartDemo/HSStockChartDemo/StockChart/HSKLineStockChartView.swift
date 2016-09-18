//
//  KLineStockChartView.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/22.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    var maxMACD: CGFloat = CGFloat.leastNormalMagnitude
    
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
    
    fileprivate func commonInit() {
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinGesture)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let data  = self.dataSet?.data , data.count > 0{
            let context = UIGraphicsGetCurrentContext()
            self.setMaxAndMinData()
            self.drawChartFrame(context!, rect: rect)
            self.drawCandleLine(context!, data: data)
            self.drawLabelPrice(context!)
        }
    }
    
    func setUpData(_ dataSet: KLineDataSet) {
        if let d = dataSet.data , self.countOfshowCandle > 0 {

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
        if let data = self.dataSet?.data , data.count > 0 {
            self.maxPrice = CGFloat.leastNormalMagnitude
            self.minPrice = CGFloat.greatestFiniteMagnitude
            self.maxRatio = CGFloat.leastNormalMagnitude
            self.minRatio = CGFloat.greatestFiniteMagnitude
            self.maxVolume = CGFloat.leastNormalMagnitude
            self.maxMACD = CGFloat.leastNormalMagnitude
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
    
    override func drawChartFrame(_ context: CGContext,rect: CGRect) {
        super.drawChartFrame(context, rect: rect)
        
        // K线图 内上边线
        self.drawline(context,
                      startPoint: CGPoint(x: self.contentLeft, y: self.uperChartDrawAreaTop),
                      stopPoint: CGPoint(x: self.contentLeft + self.contentWidth, y: self.uperChartDrawAreaTop),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        // K线图 内下边线
        self.drawline(context,
                      startPoint: CGPoint(x: self.contentLeft, y: uperChartDrawAreaBottom),
                      stopPoint: CGPoint(x: self.contentRight, y: uperChartDrawAreaBottom),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        
        // K线图 中间的横线
        self.drawline(context,
                      startPoint: CGPoint(x: self.contentLeft, y: uperChartHeight / 2.0 + self.contentTop),
                      stopPoint: CGPoint(x: self.contentRight, y: uperChartHeight /  2.0 + self.contentTop),
                      color: self.borderColor,
                      lineWidth: self.borderWidth / 4.0)
        
        self.drawYAxisLabel(context, labelString: recoverSign, yAxis: contentTop, isLeft: true, isInLineCenter: false)

        // 显示macd的坐标线及标签
        if showMacdEnable {
            let startPoint1 = CGPoint(x: contentLeft, y: lowerChartBottom - lowerChartDrawAreaMargin)
            let stopPoint1 = CGPoint(x: contentRight, y: lowerChartBottom - lowerChartDrawAreaMargin)
            self.drawline(context, startPoint: startPoint1, stopPoint: stopPoint1, color: borderColor, lineWidth: borderWidth / 2.0)
            
            let startPoint2 = CGPoint(x: contentLeft, y: lowerChartTop + lowerChartDrawAreaMargin)
            let stopPoint2 = CGPoint(x: contentRight, y: lowerChartTop + lowerChartDrawAreaMargin)
            self.drawline(context, startPoint: startPoint2, stopPoint: stopPoint2, color: borderColor, lineWidth: borderWidth / 2.0)
            
            let tempY = lowerChartRect.height / 2
            let startPoint3 = CGPoint(x: contentLeft, y: lowerChartTop + tempY)
            let stopPoint3 = CGPoint(x: contentRight, y: lowerChartTop + tempY)
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
    func drawLabelPrice(_ context: CGContext) {
        let maxPriceStr = self.formatValue(maxPrice)
        let minPriceStr = self.formatValue(minPrice)
        
        self.drawYAxisLabel(context, labelString: maxPriceStr, yAxis: uperChartDrawAreaTop, isLeft: false)
        self.drawYAxisLabel(context, labelString: minPriceStr, yAxis: uperChartDrawAreaBottom, isLeft: false)
    }
    
    // 画 K 线
    func drawCandleLine(_ context: CGContext, data: [KLineEntity]) {
        context.saveGState()
        
        var lastDate: Date?
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
                                  startPoint: CGPoint(x: startX, y: self.contentTop),
                                  stopPoint: CGPoint(x: startX,  y: self.uperChartBottom), color: self.borderColor, lineWidth: 0.5)
                    
                    self.drawline(context,
                                  startPoint: CGPoint(x: startX, y: lowerChartTop),
                                  stopPoint: CGPoint(x: startX, y: self.contentBottom), color: self.borderColor, lineWidth: 0.5)
                    
                    let drawAttributes = self.xAxisLabelAttribute
                    let dateStrAtt = NSMutableAttributedString(string: date.toString("yyyy-MM"), attributes: drawAttributes)
                    let dateStrAttSize = dateStrAtt.size()
                    self.drawLabel(context,
                                   attributesText: dateStrAtt,
                                   rect: CGRect(x: startX - dateStrAttSize.width/2, y: (uperChartHeight + self.contentTop), width: dateStrAttSize.width,height: dateStrAttSize.height))
                    lastDate = date
                }
            }
            
            var color = self.dataSet?.candleRiseColor
            if open < close {
                color = self.dataSet?.candleFallColor
                self.drawColumnRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: close - open), color: color!)
                self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else if open == close {
                if i > 1 {
                    let lastEntity = data[i-1]
                    if lastEntity.close > entity.close{
                        color = self.dataSet?.candleFallColor
                    }
                }
                self.drawColumnRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: 1.5), color: color!)
                self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
                
            } else {
                color = self.dataSet?.candleRiseColor
                self.drawColumnRect(context, rect: CGRect(x: left, y: close, width: candleWidth, height: open-close), color: color!)
                self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottmLineWidth)
            }
            
            if i > 0 {
                let lastEntity = data[i-1]
                let lastX = startX - self.candleWidth
                
                // 5，10，20日均线
                let lastY5 = (self.maxPrice - lastEntity.ma5) * self.priceOnYaxisScale + self.contentTop
                let  y5 = (self.maxPrice - entity.ma5) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY5), stopPoint: CGPoint(x: startX, y: y5), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY10 = (self.maxPrice - lastEntity.ma10) * self.priceOnYaxisScale  + self.contentTop
                let  y10 = (self.maxPrice - entity.ma10) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY10) , stopPoint: CGPoint(x: startX, y: y10), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                
                let lastY20 = (self.maxPrice - lastEntity.ma20) * self.priceOnYaxisScale  + self.contentTop
                let  y20 = (self.maxPrice - entity.ma20) * self.priceOnYaxisScale  + self.contentTop
                self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY20), stopPoint: CGPoint(x: startX, y: y20), color: self.dataSet!.avgMA20Color, lineWidth: self.dataSet!.avgLineWidth)
                
                if self.showMacdEnable {
                    // 显示 MACD 值
                    let macdColor = macd >= 0 ? dataSet?.candleRiseColor : dataSet?.candleFallColor
                    self.drawColumnRect(context, rect: CGRect(x: left, y: zeroBasic - macd, width: candleWidth, height: macd), color: macdColor!)
                    
                    let lastDiff = zeroBasic - lastEntity.diff * macdOnYaxisScale
                    let  diff = zeroBasic - entity.diff * macdOnYaxisScale
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDiff), stopPoint: CGPoint(x: startX, y: diff), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                    let lastDea = zeroBasic - lastEntity.dea * macdOnYaxisScale
                    let  dea = zeroBasic - entity.dea * macdOnYaxisScale
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastDea), stopPoint: CGPoint(x: startX, y: dea), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                } else {
                    // 成交量
                    self.drawColumnRect(context,rect:CGRect(x: left, y: self.lowerChartBottom - volume , width: candleWidth, height: volume) ,color:color!)
                    
                    // 最高成交量标签
                    if entity.volume == self.maxVolume {
                        let y = self.lowerChartBottom - volume
                        self.drawline(context, startPoint: CGPoint(x: contentLeft, y: y), stopPoint: CGPoint(x: contentRight, y: y), color: borderColor, lineWidth: borderWidth / 4.0)
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
                                                pricePoint: CGPoint(x: startX, y: close),
                                                volumePoint: CGPoint(x: startX, y: self.contentBottom - volume),
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
        
        context.restoreGState()
    }
    
    func drawMALabel(_ context: CGContext, index: Int) {
        var entity : KLineEntity?
        if index == 0{
            entity = self.dataSet?.data?.last
        }else{
            entity = self.dataSet?.data?[index]
        }
        
        if let entity = entity , self.longPressToHighlightEnabled {
            
            let space:CGFloat = 4.0
            var startPoint = CGPoint(x: self.contentLeft + space, y: self.contentTop)
            
            let recoverAttribute = NSMutableAttributedString(string: recoverSign, attributes: self.annotationLabelAttribute)
            let recoverSize = recoverAttribute.size()
            self.drawLabel(context, attributesText: recoverAttribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: recoverSize.width, height: recoverSize.height))
            
            startPoint.x += recoverSize.width + space
            let ma5 = "MA5:" + "\(formatValue(entity.ma5))"
            let ma5Attribute = NSMutableAttributedString(string: ma5 , attributes: getLabelAttribute((dataSet?.avgMA5Color)!, backgroundColor: UIColor.white, fontSize: 8))
            let ma5Size = ma5Attribute.size()
            self.drawLabel(context, attributesText: ma5Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma5Size.width, height: ma5Size.height))
            
            startPoint.x += ma5Size.width + space
            let ma10 = "MA10:" + "\(formatValue(entity.ma10))"
            let ma10Attribute = NSMutableAttributedString(string: ma10 , attributes: getLabelAttribute((dataSet?.avgMA10Color)!, backgroundColor: UIColor.white, fontSize: 8))
            let ma10Size = ma10Attribute.size()
            self.drawLabel(context, attributesText: ma10Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma10Size.width, height: ma10Size.height))
            
            startPoint.x += ma10Size.width + space
            let ma20 = "MA20:" + "\(formatValue(entity.ma20))"
            let ma20Attribute = NSMutableAttributedString(string: ma20 , attributes: getLabelAttribute((dataSet?.avgMA20Color)!, backgroundColor: UIColor.white, fontSize: 8))
            let ma20Size = ma20Attribute.size()
            self.drawLabel(context, attributesText: ma20Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma20Size.width, height: ma20Size.height))
            
        }
    }
    
    func drawMACDLabel(_ context: CGContext, index: Int) {
        var entity : KLineEntity?
        if index == 0{
            entity = self.dataSet?.data?.last
        }else{
            entity = self.dataSet?.data?[index]
        }
        
        if let entity = entity , self.longPressToHighlightEnabled {
            
            let space:CGFloat = 4.0
            var startPoint = CGPoint(x: self.contentLeft + space, y: self.lowerChartTop)
            
            let diff = "DIFF:" + "\(formatValue(entity.diff))"
            let diffAttribute = NSMutableAttributedString(string: diff , attributes: getLabelAttribute((dataSet?.avgMA5Color)!, backgroundColor: UIColor.white, fontSize: 8))
            let diffSize = diffAttribute.size()
            self.drawLabel(context, attributesText: diffAttribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: diffSize.width, height: diffSize.height))
            
            startPoint.x += diffSize.width + space
            let dea = "DEA:" + "\(formatValue(entity.dea))"
            let deaAttribute = NSMutableAttributedString(string: dea , attributes: getLabelAttribute((dataSet?.avgMA10Color)!, backgroundColor: UIColor.white, fontSize: 8))
            let deaSize = deaAttribute.size()
            self.drawLabel(context, attributesText: deaAttribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: deaSize.width, height: deaSize.height))
            
            startPoint.x += deaSize.width + space
            let macd = "MACD:" + "\(formatValue(entity.macd))"
            let macdAttribute = NSMutableAttributedString(string: macd , attributes: getLabelAttribute((dataSet?.highlightLineColor)!, backgroundColor: UIColor.white, fontSize: 8))
            let macdSize = macdAttribute.size()
            self.drawLabel(context, attributesText: macdAttribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: macdSize.width, height: macdSize.height))
            
        }
    }
    
    
    func handlePanGestureAction(_ recognizer: UIPanGestureRecognizer) {
        self.longPressToHighlightEnabled = false
        
        var isPanRight = false
        let point = recognizer.translation(in: self) //获得拖动的信息
        
        if (recognizer.state == UIGestureRecognizerState.began) {
        }
        if (recognizer.state == UIGestureRecognizerState.changed) {
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
        
        if recognizer.state == UIGestureRecognizerState.ended {
            if isPanRight {
                self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
                //print("startDrawIndex  " + "\(startDrawIndex)")
//                self.notifyDataSetChanged()
                self.setNeedsDisplay()
            }
        }
        
        self.setNeedsDisplay()
        
        // 切换回零点，不然拖动的速度变快
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {
        self.longPressToHighlightEnabled = false
        
        if recognizer.state == .began {
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
    
    func handleTapGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if self.lowerChartRect.contains(recognizer.location(in: self)) {
            self.showMacdEnable = !self.showMacdEnable
            self.setNeedsDisplay()
            
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: KLineUperChartDidTap), object: recognizer.view?.tag)
        }
    }
    
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            
            if (point.x > contentLeft && point.x < contentRight && point.y > contentTop && point.y < contentBottom) {
                self.longPressToHighlightEnabled = true
                self.highlightLineCurrentIndex = startDrawIndex + Int((point.x - contentLeft) / candleWidth)
                self.setNeedsDisplay()
            }
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
                let lastData = highlightLineCurrentIndex > 0 ? self.dataSet?.data?[self.highlightLineCurrentIndex - 1] : self.dataSet?.data?[0]
                let userInfo: [AnyHashable: Any]? = ["preClose" : (lastData?.close)!,
                              "kLineEntity" : (self.dataSet?.data?[self.highlightLineCurrentIndex])! ]
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .ended {
            self.longPressToHighlightEnabled = false
            self.setNeedsDisplay()
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
            }
        }
    }
    
}

