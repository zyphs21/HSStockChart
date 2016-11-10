//
//  HSKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/9.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSKLineView: UIView {

    var scrollView: UIScrollView!
    
    var dataSet: KLineDataSet?
    var toDrawCoordinateArray: [KLineCoordinate] = []
    var toDrawKLineEntity: [KLineEntity] = []
    var startIndex: Int {
        get {
            let scrollViewOffsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x
            let leftArrCount = abs(scrollViewOffsetX - gapBetweenCandle) / ( candleWidth + gapBetweenCandle)
            return Int(leftArrCount)
        }
        set(value) {
            
        }
    }
    
    var startX: CGFloat {
        get {
            let leftArrCount = CGFloat(self.startIndex)
            let sumOfGap: CGFloat = (leftArrCount + 1) * gapBetweenCandle
            let startXPosition = sumOfGap + (leftArrCount * candleWidth) + candleWidth/2
            return startXPosition
        }
    }
    
    var oldContentOffsetX: CGFloat = 0
    var candleWidth: CGFloat = 8
    var gapBetweenCandle: CGFloat = 8.0 / 6.0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.scrollView = self.superview as? UIScrollView
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        super.didMoveToSuperview()
    }
    
    override func draw(_ rect: CGRect) {
        print("draw rect" + "\(rect)")
        
        if let data  = self.dataSet?.data , data.count > 0{
            let context = UIGraphicsGetCurrentContext()
            let kLineCandle = HSCandle(context: context!)
            for index in 0 ..< self.toDrawCoordinateArray.count {
                kLineCandle.klineData = toDrawKLineEntity[index]
                kLineCandle.klineCoordinate = toDrawCoordinateArray[index]
                kLineCandle.drawCandle()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            print(scrollView?.contentOffset.x ?? 000)
            let diff = abs(scrollView!.contentOffset.x - self.oldContentOffsetX)
            if diff >= 9 {
                print("oldContentOffsetX " + "\(oldContentOffsetX)")
                self.oldContentOffsetX = (self.scrollView?.contentOffset.x)!
                toDrawView()
            }
        }
    }
    
    func setUpData(_ dataSet: KLineDataSet) {
        if let d = dataSet.data {
            self.dataSet = dataSet
            let count = CGFloat(d.count)
            var kLineViewWidth = count * candleWidth + (count + 1) * gapBetweenCandle
            if kLineViewWidth < ScreenWidth {
                kLineViewWidth = ScreenWidth
            }

            self.snp.updateConstraints({ (make) in
                make.width.equalTo(kLineViewWidth)
            })
            self.layoutIfNeeded()
            
            self.scrollView.contentSize = CGSize(width: kLineViewWidth, height: 300)
            
        } else {
            //self.showFailStatusView()
        }
    }
    
    func toDrawView() {
        setToDrawKLineEntity()
        setKlineCoordinate()
        self.setNeedsDisplay()
    }
    
    func setToDrawKLineEntity(){
        let scrollViewWidth = self.scrollView.frame.width
        let needToDrawKLineCount = Int((scrollViewWidth - gapBetweenCandle) / (candleWidth + gapBetweenCandle))
        let needDrawKLineStartIndex = self.startIndex
        
        self.toDrawKLineEntity.removeAll()
        
        if (needDrawKLineStartIndex + needToDrawKLineCount) < self.dataSet!.data!.count {
            self.toDrawKLineEntity = Array(self.dataSet!.data![needDrawKLineStartIndex..<needToDrawKLineCount+needDrawKLineStartIndex])
            
        } else {
            let end = (self.dataSet?.data?.count)! - needToDrawKLineCount
            self.toDrawKLineEntity = Array(self.dataSet!.data![needDrawKLineStartIndex..<end])
        }
        
    }
    
    func setKlineCoordinate() {
        let toDrawEntityArray = self.toDrawKLineEntity
        
        var maxPrice = CGFloat.leastNormalMagnitude
        var minPrice = CGFloat.greatestFiniteMagnitude
        var maxVolume = CGFloat.leastNormalMagnitude
        var maxMACD = CGFloat.leastNormalMagnitude
        
        for i in 0 ..< toDrawEntityArray.count {
            let entity = toDrawEntityArray[i]
            minPrice = minPrice < entity.low ? minPrice : entity.low
            maxPrice = maxPrice > entity.high ? maxPrice : entity.high
            maxVolume = maxVolume > entity.volume ? maxVolume : entity.volume
            let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
            maxMACD = tempMax > maxMACD ? tempMax : maxMACD
        }
        
        let drawContenTop: CGFloat = 10
        let drawContenBottom: CGFloat = self.frame.size.height - 20
        
        let klineUnitValue = (maxPrice - minPrice) / (drawContenBottom - drawContenTop)
        
        self.toDrawCoordinateArray.removeAll()
        
        for i in 0 ..< toDrawEntityArray.count {
            let entity = toDrawKLineEntity[i]
            let xPosition = self.startX + CGFloat(i) * (gapBetweenCandle + candleWidth)
            
            let open = ((maxPrice - entity.open) * klineUnitValue) + drawContenTop
            let close = ((maxPrice - entity.close) * klineUnitValue) + drawContenTop
            let high = ((maxPrice - entity.high) * klineUnitValue) + drawContenTop
            let low = ((maxPrice - entity.low) * klineUnitValue) + drawContenTop
            
            let coordinate = KLineCoordinate()
            coordinate.openPoint = CGPoint(x: xPosition, y: open)
            coordinate.closePoint = CGPoint(x: xPosition, y: close)
            coordinate.highPoint = CGPoint(x: xPosition, y: high)
            coordinate.lowPoint = CGPoint(x: xPosition, y: low)
            self.toDrawCoordinateArray.append(coordinate)
        }
    }

}
