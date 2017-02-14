//
//  HSKLine.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSKLine: HSBasicBrush {
    
    var crossLine: HSCrossLine?
    
    var kLineType: HSChartType!
    var theme: HSKLineTheme = HSKLineTheme()
    
    var dataK: [HSKLineModel] = []
    var positionModels: [HSKLineCoordModel] = []
    var klineModels: [HSKLineModel] = []
    
    var kLineViewTotalWidth: CGFloat = 0
    var showContentWidth: CGFloat = 0
    var oldContentOffsetX: CGFloat = 0
    var highLightIndex: Int = 0
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxVolume: CGFloat = 0
    var maxMA: CGFloat = 0
    var minMA: CGFloat = 0
    var maxMACD: CGFloat = 0
    
    var priceUnit: CGFloat = 0.1
    var volumeUnit: CGFloat = 0
    
    var showMacdEnable = false
    var showMA = false
    var showLongPressHighlight = false

    var renderRect: CGRect = CGRect.zero
    
    var uperChartHeight: CGFloat {
        get {
            return theme.kLineChartHeightScale * self.frame.height
        }
    }
    var lowerChartHeight: CGFloat {
        get {
            return self.frame.height * (1 - theme.kLineChartHeightScale) - theme.xAxisHeitht
        }
    }
    
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = renderRect.minX < 0 ? 0 : renderRect.minX
            var leftCandleCount = Int(abs(scrollViewOffsetX) / (theme.candleWidth + theme.candleGap))
            
            if leftCandleCount > dataK.count {
                leftCandleCount = dataK.count - 1
                return leftCandleCount
            } else if leftCandleCount == 0 {
                return leftCandleCount
            } else {
                return leftCandleCount + 1
            }
        }
    }
    
    // 当前显示区域起始横坐标 x
    var startX: CGFloat {
        get {
            let scrollViewOffsetX = renderRect.minX < 0 ? 0 : renderRect.minX
            return scrollViewOffsetX
        }
    }
    
    // 当前显示区域最多显示的蜡烛图个数
    var countOfshowCandle: Int {
        get{
            return Int((renderRect.width - theme.candleWidth) / ( theme.candleWidth + theme.candleGap))
        }
    }
    
    
    // MARK: - 初始化方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        
        self.addGestureRecognizer(longPressGesture)
        self.addGestureRecognizer(pinGesture)
        self.contentMode = .right  // MARK: WHY
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        renderRect = rect
        print("renderRect " + "\(renderRect)")
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        if dataK.count > 0 {
            setMaxAndMinData()
            convertToPositionModel(data: dataK, context: context)
            _ = HSKLineBrush(frame: rect, context: context, klineModels: klineModels, positionModels: positionModels, theme: theme, kLineType: kLineType)
            if showLongPressHighlight {
                crossLine = HSCrossLine(frame: rect)
                drawCrossLine(context)
            }
            drawLabelPrice(context)
            
        } else {
            
        }
    }

    
    // MARK: - 设置当前显示区域的最大最小值
    
    func setMaxAndMinData() {
        if dataK.count > 0 {
            self.maxPrice = CGFloat.leastNormalMagnitude
            self.minPrice = CGFloat.greatestFiniteMagnitude
            self.maxVolume = CGFloat.leastNormalMagnitude
            self.maxMA = CGFloat.leastNormalMagnitude
            self.minMA = CGFloat.greatestFiniteMagnitude
            self.maxMACD = CGFloat.leastNormalMagnitude
            let startIndex = self.startIndex
            //let count = (startIndex + countOfshowCandle) > dataK.count ? dataK.count : (startIndex + countOfshowCandle)
            // 比计算出来的多加一个，是为了避免计算结果的取整导致少画
            let count = (startIndex + countOfshowCandle + 1) > dataK.count ? dataK.count : (startIndex + countOfshowCandle + 1)
            if startIndex < count {
                for i in startIndex ..< count {
                    let entity = dataK[i]
                    self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                    self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                    
                    self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                    
                    let tempMAMax = max(entity.ma5, entity.ma10, entity.ma20)
                    self.maxMA = self.maxMA > tempMAMax ? self.maxMA : tempMAMax
                    
                    let tempMAMin = min(entity.ma5, entity.ma10, entity.ma20)
                    self.minMA = self.minMA < tempMAMin ? self.minMA : tempMAMin
                    
                    let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
                    self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD
                }
            }
            
            self.maxPrice = self.maxPrice > self.maxMA ? self.maxPrice : self.maxMA
            self.minPrice = self.minPrice < self.minMA ? self.minPrice : self.minMA
        }
    }
    
    
    // MARK: - 转换为坐标model
    
    func convertToPositionModel(data: [HSKLineModel], context: CGContext) {
        
        self.positionModels.removeAll()
        self.klineModels.removeAll()
        
        let gap = theme.viewMinYGap
        let minY = gap
        let maxDiff = self.maxPrice - self.minPrice
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (uperChartHeight - 2 * minY) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeMaxGap) / self.maxVolume
        }
        let count = (startIndex + countOfshowCandle + 1) > data.count ? data.count : (startIndex + countOfshowCandle + 1)
        if startIndex < count {
            for index in startIndex ..< count {
                
                let model = data[index]
                let xPosition = startX + CGFloat(index - startIndex) * (theme.candleWidth + theme.candleGap) + theme.candleWidth / 2.0
                let highPoint = CGPoint(x: xPosition, y: (maxPrice - model.high) * priceUnit + minY)
                let lowPoint = CGPoint(x: xPosition, y: (maxPrice - model.low) * priceUnit + minY)
                var openPoint = CGPoint(x: xPosition, y: (maxPrice - model.open) * priceUnit + minY)
                let ma5Point = CGPoint(x: xPosition, y: (maxPrice - model.ma5) * priceUnit + minY)
                let ma10Point = CGPoint(x: xPosition, y: (maxPrice - model.ma10) * priceUnit + minY)
                let ma20Point = CGPoint(x: xPosition, y: (maxPrice - model.ma20) * priceUnit + minY)
                var closePointY = (maxPrice - model.close) * priceUnit + minY
                
                let volume = (model.volume - 0) * volumeUnit
                let volumeStartPoint = CGPoint(x: xPosition, y: self.frame.height - volume)
                let volumeEndPoint = CGPoint(x: xPosition, y: self.frame.height)
                
                let minCandleH = theme.candleMinHeight
                
                if(abs(closePointY - openPoint.y) < minCandleH) {
                    if(openPoint.y > closePointY) {
                        openPoint.y = closePointY + minCandleH
                        
                    } else if(openPoint.y < closePointY) {
                        closePointY = openPoint.y + minCandleH
                        
                    } else {
                        if(index > 0) {
                            let preKLineModel = data[index - 1]
                            if(model.open > preKLineModel.close) {
                                openPoint.y = closePointY + minCandleH
                            } else {
                                closePointY = openPoint.y + minCandleH
                            }
                        } else {
                            openPoint.y = closePointY - minCandleH
                        }
                    }
                }
                let closePoint = CGPoint(x: xPosition, y: closePointY)
                
                let positionModel = HSKLineCoordModel()
                positionModel.openPoint = openPoint
                positionModel.closePoint = closePoint
                positionModel.highPoint = highPoint
                positionModel.lowPoint = lowPoint
                positionModel.ma5Point = ma5Point
                positionModel.ma10Point = ma10Point
                positionModel.ma20Point = ma20Point
                positionModel.volumeStartPoint = volumeStartPoint
                positionModel.volumeEndPoint = volumeEndPoint
                self.positionModels.append(positionModel)
                self.klineModels.append(model)
            }
        }
    }
    
    
    // MARK: - 画十字标记线
    
    func drawCrossLine(_ context: CGContext) {
        if highLightIndex < dataK.count {
            let entity = dataK[highLightIndex]
            let left = self.startX + CGFloat(highLightIndex - startIndex) * (self.theme.candleWidth + theme.candleGap)
            let centerX = left + theme.candleWidth / 2.0
            let highLightVolume = entity.volume * self.volumeUnit
            let highLightClose = ((self.maxPrice - entity.close) * self.priceUnit) + theme.viewMinYGap
            
            crossLine?.draw(context: context,
                            theme: self.theme,
                            contentRect: CGRect(x: startX, y: 0, width: showContentWidth, height: frame.height),
                            pricePoint: CGPoint(x: centerX, y: highLightClose),
                            volumePoint: CGPoint(x: centerX, y: self.frame.height - highLightVolume),
                            model: entity)
        }
    }
    
    
    // MARK: - 画纵坐标标签
    
    func drawLabelPrice(_ context: CGContext) {
        let maxPriceStr = maxPrice.toStringWithFormat(".2")
        let minPriceStr = minPrice.toStringWithFormat(".2")
        
        self.drawYAxisLabel(context, str: maxPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: self.startX + self.showContentWidth, yAxis: theme.viewMinYGap, isLeft: false)
        self.drawYAxisLabel(context, str: minPriceStr, labelAttribute: theme.yAxisLabelAttribute, xAxis: self.startX + self.showContentWidth, yAxis: uperChartHeight - theme.viewMinYGap, isLeft: false)
    }
}


extension HSKLine {
    
    
    // MARK: - 处理长按操作
    
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: self)
            
            self.showLongPressHighlight = true
            self.highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            
            if self.highLightIndex < dataK.count {
                self.setNeedsDisplay()
                
                let lastData = highLightIndex > 0 ? dataK[self.highLightIndex - 1] : dataK[0]
                let userInfo: [AnyHashable: Any]? = ["preClose" : lastData.close,
                                                     "kLineEntity" : dataK[self.highLightIndex]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .ended {
            self.showLongPressHighlight = false
            self.setNeedsDisplay()
            if self.highLightIndex < dataK.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
            }
        }
    }
    
    
    // MARK: - 处理手指捏合扩大操作
    
    func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {
        let originScale: CGFloat = 1.0
        let kLineScaleFactor: CGFloat = 0.06
        let kLineScaleBound: CGFloat = 0.03
        // 获取缩放倍数
        let diffScale = recognizer.scale - originScale
        if abs(diffScale) > kLineScaleBound {
            guard recognizer.numberOfTouches == 2 else {
                return
            }
            let point1 = recognizer.location(ofTouch: 0, in: self)
            let point2 = recognizer.location(ofTouch: 1, in: self)
            let pinCenterX = (point1.x + point2.x) / 2
            
            // 中心点数据index
            let pinCenterLeftCount = pinCenterX / (theme.candleWidth + theme.candleGap)
            
            // 缩放后的candle宽度
            let newCandleWidth = theme.candleWidth * (diffScale > 0 ? (1 + kLineScaleFactor) : (1 - kLineScaleFactor))
            if newCandleWidth > theme.candleMaxWidth {
                self.theme.candleWidth = theme.candleMaxWidth
                
            } else if newCandleWidth < theme.candleMinWidth {
                self.theme.candleWidth = theme.candleMinWidth
                
            } else {
                self.theme.candleWidth = newCandleWidth
            }
            
//            // 更新容纳的总长度
//            self.updateKlineViewWidth()
//            
//            let newPinCenterX = pinCenterLeftCount * theme.candleWidth + (pinCenterLeftCount - 1) * theme.candleGap
//            
//            // 设置scrollview的contentoffset = newPinCenterX - pinCenterX
//            let count = CGFloat(dataK.count)
//            if ( count * theme.candleWidth + (count + 1) * theme.candleGap > self.scrollView.width ) {
//                let newOffsetX = newPinCenterX - (pinCenterX - renderRect.minX);
//                self.scrollView.contentOffset = CGPoint(x: newOffsetX > 0 ? newOffsetX : 0 , y: self.scrollView.contentOffset.y)
//                
//            } else {
//                self.scrollView.contentOffset = CGPoint(x: 0 , y: self.scrollView.contentOffset.y)
//            }
//            updateKlineViewWidth()
            self.setNeedsDisplay()
        }
    }
}
