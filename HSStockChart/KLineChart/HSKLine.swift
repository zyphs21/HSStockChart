//
//  HSKLineNew.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSCAShapeLayer: CAShapeLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}


public class HSKLine: UIView, HSDrawLayerProtocol {

    var kLineType: HSChartType = HSChartType.kLineForDay
    var theme = HSKLineStyle()
    
    var dataK: [HSKLineModel] = []
    var positionModels: [HSKLineCoordModel] = []
    var klineModels: [HSKLineModel] = []
    
    var kLineViewTotalWidth: CGFloat = 0
    var showContentWidth: CGFloat = 0
    var contentOffsetX: CGFloat = 0
    var highLightIndex: Int = 0
    
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var maxVolume: CGFloat = 0
    var maxMA: CGFloat = 0
    var minMA: CGFloat = 0
    var maxMACD: CGFloat = 0
    
    var priceUnit: CGFloat = 0.1
    var volumeUnit: CGFloat = 0
    
    var renderRect: CGRect = CGRect.zero
    var renderWidth: CGFloat = 0
    
    var candleChartLayer = HSCAShapeLayer()
    var volumeLayer = HSCAShapeLayer()
    var ma5LineLayer = HSCAShapeLayer()
    var ma10LineLayer = HSCAShapeLayer()
    var ma20LineLayer = HSCAShapeLayer()
    var xAxisTimeMarkLayer = HSCAShapeLayer()
    
    var uperChartHeight: CGFloat {
        get {
            return theme.uperChartHeightScale * self.frame.height
        }
    }
    var lowerChartHeight: CGFloat {
        get {
            return self.frame.height * (1 - theme.uperChartHeightScale) - theme.xAxisHeitht
        }
    }
    
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
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
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
            return scrollViewOffsetX
        }
    }
    
    // 当前显示区域最多显示的蜡烛图个数
    var countOfshowCandle: Int {
        get{
            return Int((renderWidth - theme.candleWidth) / ( theme.candleWidth + theme.candleGap))
        }
    }
    
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    public func setTheme(theme: HSKLineStyle)
    {
        self.theme = theme
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Drawing Function
    
    func drawKLineView() {
        calcMaxAndMinData()
        convertToPositionModel(data: dataK)

        clearLayer()
        drawxAxisTimeMarkLayer()
        drawCandleChartLayer(array: positionModels)
        drawVolumeLayer(array: positionModels)
        drawMALayer(array: positionModels)
    }
    
    /// 计算当前显示区域的最大最小值
    fileprivate func calcMaxAndMinData() {
        if dataK.count > 0 {
            self.maxPrice = CGFloat.leastNormalMagnitude
            self.minPrice = CGFloat.greatestFiniteMagnitude
            self.maxVolume = CGFloat.leastNormalMagnitude
            self.maxMA = CGFloat.leastNormalMagnitude
            self.minMA = CGFloat.greatestFiniteMagnitude
            self.maxMACD = CGFloat.leastNormalMagnitude
            let startIndex = self.startIndex
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
            // 当均线数据缺失时候，注意注释这段，不然 minPrice 为 0，导致整体绘画比例不对
            self.maxPrice = self.maxPrice > self.maxMA ? self.maxPrice : self.maxMA
            self.minPrice = self.minPrice < self.minMA ? self.minPrice : self.minMA
        }
    }
    
    
    /// 转换为坐标 model
    ///
    /// - Parameter data: [HSKLineModel]
    fileprivate func convertToPositionModel(data: [HSKLineModel]) {
        self.positionModels.removeAll()
        self.klineModels.removeAll()
        
        let axisGap = countOfshowCandle / 3
        let gap = theme.viewMinYGap
        let minY = gap
        let maxDiff = self.maxPrice - self.minPrice
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (uperChartHeight - 2 * minY) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeGap) / self.maxVolume
        }
        let count = (startIndex + countOfshowCandle + 1) > data.count ? data.count : (startIndex + countOfshowCandle + 1)
        if startIndex < count {
            for index in startIndex ..< count {
                let model = data[index]
                let leftPosition = startX + CGFloat(index - startIndex) * (theme.candleWidth + theme.candleGap)
                let xPosition = leftPosition + theme.candleWidth / 2.0
                
                let highPoint = CGPoint(x: xPosition, y: (maxPrice - model.high) * priceUnit + minY)
                let lowPoint = CGPoint(x: xPosition, y: (maxPrice - model.low) * priceUnit + minY)
                
                let ma5Point = CGPoint(x: xPosition, y: (maxPrice - model.ma5) * priceUnit + minY)
                let ma10Point = CGPoint(x: xPosition, y: (maxPrice - model.ma10) * priceUnit + minY)
                let ma20Point = CGPoint(x: xPosition, y: (maxPrice - model.ma20) * priceUnit + minY)
                
                let openPointY = (maxPrice - model.open) * priceUnit + minY
                let closePointY = (maxPrice - model.close) * priceUnit + minY
                var fillCandleColor = UIColor.black
                var candleRect = CGRect.zero
                
                let volume = (model.volume - 0) * volumeUnit
                let volumeStartPoint = CGPoint(x: xPosition, y: self.frame.height - volume)
                let volumeEndPoint = CGPoint(x: xPosition, y: self.frame.height)
                
                if(openPointY > closePointY) {
                    fillCandleColor = theme.riseColor
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: openPointY - closePointY)
                    
                } else if(openPointY < closePointY) {
                    fillCandleColor = theme.fallColor
                    candleRect = CGRect(x: leftPosition, y: openPointY, width: theme.candleWidth, height: closePointY - openPointY)
                    
                } else {
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: theme.candleMinHeight)
                    if(index > 0) {
                        let preKLineModel = data[index - 1]
                        if(model.open > preKLineModel.close) {
                            fillCandleColor = theme.riseColor
                        } else {
                            fillCandleColor = theme.fallColor
                        }
                    }
                }
                
                let positionModel = HSKLineCoordModel()
                positionModel.highPoint = highPoint
                positionModel.lowPoint = lowPoint
                positionModel.closeY = closePointY
                positionModel.ma5Point = ma5Point
                positionModel.ma10Point = ma10Point
                positionModel.ma20Point = ma20Point
                positionModel.volumeStartPoint = volumeStartPoint
                positionModel.volumeEndPoint = volumeEndPoint
                positionModel.candleFillColor = fillCandleColor
                positionModel.candleRect = candleRect
                if index % axisGap == 0 {
                    positionModel.isDrawAxis = true
                }
                self.positionModels.append(positionModel)
                self.klineModels.append(model)
            }
        }
    }
    
    /// 画蜡烛图
    func drawCandleChartLayer(array: [HSKLineCoordModel]) {
        candleChartLayer.sublayers?.removeAll()
        for object in array.enumerated() {
            let candleLayer = getCandleLayer(model: object.element)
            candleChartLayer.addSublayer(candleLayer)
        }
        self.layer.addSublayer(candleChartLayer)
    }
    
    /// 画交易量图
    func drawVolumeLayer(array: [HSKLineCoordModel]) {
        volumeLayer.sublayers?.removeAll()
        for object in array.enumerated() {
            let model = object.element
            let volLayer = drawLine(lineWidth: theme.candleWidth,
                                    startPoint: model.volumeStartPoint,
                                    endPoint: model.volumeEndPoint,
                                    strokeColor: model.candleFillColor,
                                    fillColor: model.candleFillColor)
            volumeLayer.addSublayer(volLayer)
        }
        self.layer.addSublayer(volumeLayer)
    }
    
    /// 画交均线图
    func drawMALayer(array: [HSKLineCoordModel]) {
        
        if(array.count == 0)
        {
            return
        }
        
        let ma5LinePath = UIBezierPath()
        let ma10LinePath = UIBezierPath()
        let ma20LinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preMa5Point = array[index - 1].ma5Point
            let ma5Point = array[index].ma5Point
            ma5LinePath.move(to: preMa5Point)
            ma5LinePath.addLine(to: ma5Point)
            
            let preMa10Point = array[index - 1].ma10Point
            let ma10Point = array[index].ma10Point
            ma10LinePath.move(to: preMa10Point)
            ma10LinePath.addLine(to: ma10Point)
            
            let preMa20Point = array[index - 1].ma20Point
            let ma20Point = array[index].ma20Point
            ma20LinePath.move(to: preMa20Point)
            ma20LinePath.addLine(to: ma20Point)
        }
        ma5LineLayer = HSCAShapeLayer()
        ma5LineLayer.path = ma5LinePath.cgPath
        ma5LineLayer.strokeColor = theme.ma5Color.cgColor
        ma5LineLayer.fillColor = UIColor.clear.cgColor
        
        ma10LineLayer = HSCAShapeLayer()
        ma10LineLayer.path = ma10LinePath.cgPath
        ma10LineLayer.strokeColor = theme.ma10Color.cgColor
        ma10LineLayer.fillColor = UIColor.clear.cgColor
        
        ma20LineLayer = HSCAShapeLayer()
        ma20LineLayer.path = ma20LinePath.cgPath
        ma20LineLayer.strokeColor = theme.ma20Color.cgColor
        ma20LineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(ma5LineLayer)
        self.layer.addSublayer(ma10LineLayer)
        self.layer.addSublayer(ma20LineLayer)
    }
    
    func drawxAxisTimeMarkLayer() {
        var lastDate: Date?
        xAxisTimeMarkLayer.sublayers?.removeAll()
        for (index, position) in positionModels.enumerated() {
            if let date = klineModels[index].date.hschart.toDate("yyyyMMddHHmmss") {
                if lastDate == nil {
                    lastDate = date
                }
                if position.isDrawAxis {
                    switch kLineType {
                    case .kLineForMinute:
                        xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.highPoint.x, dateString: date.hschart.toString("HH:mm")))
                    case .kLineForDay, .kLineForWeek, .kLineForMonth:
                        xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.highPoint.x, dateString: date.hschart.toString("yyyy-MM")))
                    default:
                        xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.highPoint.x, dateString: date.hschart.toString("MM-dd")))
                    }
                    lastDate = date
                }
            }
        }
        self.layer.addSublayer(xAxisTimeMarkLayer)
    }
    
    
    /// 清除图层
    func clearLayer() {
        ma5LineLayer.removeFromSuperlayer()
        ma10LineLayer.removeFromSuperlayer()
        ma20LineLayer.removeFromSuperlayer()
        candleChartLayer.removeFromSuperlayer()
        volumeLayer.removeFromSuperlayer()
        xAxisTimeMarkLayer.removeFromSuperlayer()
    }
    
    /// 获取单个蜡烛图的layer
    fileprivate func getCandleLayer(model: HSKLineCoordModel) -> HSCAShapeLayer {
        // K线
        let linePath = UIBezierPath(rect: model.candleRect)
        // 影线
        linePath.move(to: model.lowPoint)
        linePath.addLine(to: model.highPoint)
        
        let klayer = HSCAShapeLayer()
        klayer.path = linePath.cgPath
        klayer.strokeColor = model.candleFillColor.cgColor
        klayer.fillColor = model.candleFillColor.cgColor
        
        return klayer
    }
    
    
    /// 横坐标单个时间标签
    func drawXaxisTimeMark(xPosition: CGFloat, dateString: String) -> HSCAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xPosition, y: 0))
        linePath.addLine(to: CGPoint(x: xPosition,  y: self.frame.height * theme.uperChartHeightScale))
        linePath.move(to: CGPoint(x: xPosition, y: self.frame.height * theme.uperChartHeightScale + theme.xAxisHeitht))
        linePath.addLine(to: CGPoint(x: xPosition, y: self.frame.height))
        let lineLayer = HSCAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 0.25
        lineLayer.strokeColor = theme.borderColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        
        let textSize = theme.getTextSize(text: dateString)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        let maxX = frame.maxX - textSize.width
        labelX = xPosition - textSize.width / 2.0
        labelY = self.frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = maxX
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        let timeLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height),
                                      text: dateString,
                                      foregroundColor: theme.textColor)
        
        let shaperLayer = HSCAShapeLayer()
        shaperLayer.addSublayer(lineLayer)
        shaperLayer.addSublayer(timeLayer)
        
        return shaperLayer
    }

}
