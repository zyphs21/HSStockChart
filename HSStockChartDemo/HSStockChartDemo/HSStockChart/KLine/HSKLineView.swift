//
//  HSKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class HSKLineView: UIView {

    var chartFrame: HSChartFrame!
    var scrollView: UIScrollView!
    var kLine: HSKLine!
    var highlightView: HSHighLight!
    
    var kLineType: HSChartType!
    var widthOfKLineView: CGFloat = 0
    let theme: HSKLineTheme = HSKLineTheme()
    var dataK: [HSKLineModel] = []

    var allDataK: [HSKLineModel] = []
    var enableKVO: Bool = true

    var kLineViewWidth: CGFloat = 0.0
    var oldRightOffset: CGFloat = -1
    
    init(frame: CGRect, kLineType: HSChartType) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        chartFrame = HSChartFrame(frame: frame)
        addSubview(chartFrame)
        
        scrollView = UIScrollView(frame: frame)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)
        
        kLine = HSKLine()
        kLine.kLineType = kLineType
        scrollView.addSubview(kLine)
        
        highlightView = HSHighLight(frame: frame)
        addSubview(highlightView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        kLine.addGestureRecognizer(pinGesture)
        
        // MARK: - TODO
        allDataK = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
        let tmpDataK = Array(allDataK[allDataK.count-70..<allDataK.count])
        self.configureView(data: tmpDataK)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO {
            print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")
            
            // 拖动 ScrollView 时重绘当前显示的 klineview
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.drawKLineView()
            
            highlightView.configureAxis(max: kLine.maxPrice, min: kLine.minPrice, maxVol: kLine.maxVolume)
        }
    }
    
    func configureView(data: [HSKLineModel]) {
        dataK = data
        kLine.dataK = data
        let count: CGFloat = CGFloat(data.count)
        
        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < ScreenWidth {
            kLineViewWidth = ScreenWidth
        } else {
            kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }
        
        // 更新view长度
        print("currentWidth " + "\(kLineViewWidth)")
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kLineViewWidth, height: scrollView.frame.height)
        
        var contentOffsetX: CGFloat = 0
        
        if scrollView.contentSize.width > 0 {
            contentOffsetX = kLineViewWidth - scrollView.contentSize.width
        } else {
            // 首次加载，将 kLine 的右边和scrollview的右边对齐
            contentOffsetX = kLine.frame.width - scrollView.frame.width
        }
        
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: self.frame.height)
        scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        kLine.contentOffsetX = scrollView.contentOffset.x
        print("ScrollKLine contentOffsetX " + "\(contentOffsetX)")

    }
    
    func updateKlineViewWidth() {
        let count: CGFloat = CGFloat(kLine.dataK.count)
        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < ScreenWidth {
            kLineViewWidth = ScreenWidth
        } else {
            kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }
        
        // 更新view长度
        print("currentWidth " + "\(kLineViewWidth)")
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kLineViewWidth, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: self.frame.height)
    }
    
    // 长按操作
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: kLine)
            let highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            if highLightIndex < kLine.dataK.count {
                let index = highLightIndex - kLine.startIndex
                let entity = kLine.dataK[highLightIndex]
                let left = kLine.startX + CGFloat(highLightIndex - kLine.startIndex) * (self.theme.candleWidth + theme.candleGap) - scrollView.contentOffset.x
                let centerX = left + theme.candleWidth / 2.0
                let highLightVolume = kLine.positionModels[index].volumeStartPoint.y
                let highLightClose = kLine.positionModels[index].closeY
                
                highlightView.drawCrossLine(pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity)
                
                let lastData = highLightIndex > 0 ? kLine.dataK[highLightIndex - 1] : kLine.dataK[0]
                let userInfo: [AnyHashable: Any]? = ["preClose" : lastData.close, "kLineEntity" : kLine.dataK[highLightIndex]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .ended {
            highlightView.clearCrossLine()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
        }
    }
    
    func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {

        guard recognizer.numberOfTouches == 2 else { return }

        let scale = recognizer.scale
        let originScale: CGFloat = 1.0
        let kLineScaleFactor: CGFloat = 0.06
        let kLineScaleBound: CGFloat = 0.03
        let diffScale = scale - originScale // 获取缩放倍数

        switch recognizer.state {
        case .began:
            enableKVO = false
            scrollView.isScrollEnabled = false
        case .ended:
            enableKVO = true
            scrollView.isScrollEnabled = true
        default:
            break
        }

        if abs(diffScale) > kLineScaleBound {
            let point1 = recognizer.location(ofTouch: 0, in: self)
            let point2 = recognizer.location(ofTouch: 1, in: self)

            let pinCenterX = (point1.x + point2.x) / 2
            let scrollViewPinCenterX = pinCenterX + scrollView.contentOffset.x
            
            // 中心点数据index
            let pinCenterLeftCount = scrollViewPinCenterX / (theme.candleWidth + theme.candleGap)

            // 缩放后的candle宽度
            let newCandleWidth = theme.candleWidth * (diffScale > 0 ? (1 + kLineScaleFactor) : (1 - kLineScaleFactor))
            if newCandleWidth > theme.candleMaxWidth {
                self.theme.candleWidth = theme.candleMaxWidth
                kLine.theme.candleWidth = theme.candleMaxWidth
                
            } else if newCandleWidth < theme.candleMinWidth {
                self.theme.candleWidth = theme.candleMinWidth
                kLine.theme.candleWidth = theme.candleMinWidth
                
            } else {
                self.theme.candleWidth = newCandleWidth
                kLine.theme.candleWidth = newCandleWidth
            }
            
            // 更新容纳的总长度
            self.updateKlineViewWidth()
            
            let newPinCenterX = pinCenterLeftCount * theme.candleWidth + (pinCenterLeftCount - 1) * theme.candleGap
            let newOffsetX = newPinCenterX - pinCenterX
            self.scrollView.contentOffset = CGPoint(x: newOffsetX > 0 ? newOffsetX : 0 , y: self.scrollView.contentOffset.y)

            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.drawKLineView()
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}

extension HSKLineView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // MARK: - 用于滑动加载更多 KLine 数据
        if (scrollView.contentOffset.x < 0 && dataK.count < allDataK.count) {
            self.oldRightOffset = scrollView.contentSize.width - scrollView.contentOffset.x
            print("load more")
            self.configureView(data: allDataK)
        } else {
            
        }
    }
}
