//
//  HSKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

public let TimeLineLongpress = "TimeLineLongpress"
public let TimeLineUnLongpress = "TimeLineUnLongpress"

public let TimeLineChartDidTap = "TimeLineChartDidTap"

public let KLineChartLongPress = "kLineChartLongPress"
public let KLineChartUnLongPress = "kLineChartUnLongPress"

public let KLineUperChartDidTap = "KLineUperChartDidTap"

public class HSKLineView: UIView {

    var scrollView: UIScrollView!
    var kLine: HSKLine!
    var upFrontView: HSKLineUpFrontView!
    
    var kLineType: HSChartType!
    var widthOfKLineView: CGFloat = 0
    var theme = HSKLineStyle()
    public var dataK: [HSKLineModel] = []
    
    public var isLandscapeMode = false

    public var allDataK: [HSKLineModel] = []
    var enableKVO: Bool = true

    var kLineViewWidth: CGFloat = 0.0
    var oldRightOffset: CGFloat = -1
    
    var uperChartHeight: CGFloat {
        get {
            return theme.uperChartHeightScale * self.frame.height
        }
    }
    var lowerChartTop: CGFloat {
        get {
            return uperChartHeight + theme.xAxisHeitht
        }
    }
    
    public init(frame: CGRect, kLineType: HSChartType, theme: HSKLineStyle?, priceLabelText: String? = nil, volumeLabelText: String? = nil) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        if let t = theme
        {
            self.theme = t
        }
        
        drawFrameLayer()
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)
        
        kLine = HSKLine()
        kLine.setTheme(theme: self.theme)
        kLine.kLineType = kLineType
        scrollView.addSubview(kLine)
        
        upFrontView = HSKLineUpFrontView(frame: bounds, priceLabelText: priceLabelText, volumeLabelText: volumeLabelText)
        addSubview(upFrontView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        kLine.addGestureRecognizer(pinGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        kLine.addGestureRecognizer(tapGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO {
            print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")
            
            // 拖动 ScrollView 时重绘当前显示的 klineview
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.drawKLineView()
            
            upFrontView.configureAxis(max: kLine.maxPrice, min: kLine.minPrice, maxVol: kLine.maxVolume)
        }
    }
    
    public func configureView(data: [HSKLineModel]) {
        dataK = data
        kLine.dataK = data
        let count: CGFloat = CGFloat(data.count)
        
        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < self.frame.width {
            kLineViewWidth = self.frame.width
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
        if kLineViewWidth < self.frame.width {
            kLineViewWidth = self.frame.width
        } else {
            kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }
        
        // 更新view长度
        print("currentWidth " + "\(kLineViewWidth)")
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kLineViewWidth, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: self.frame.height)
    }
    
    // 画边框
    func drawFrameLayer() {
        // K线图
        let uperFramePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: uperChartHeight))
        
        // K线图 内上边线 即最高价格线
        uperFramePath.move(to: CGPoint(x: 0, y: theme.viewMinYGap))
        uperFramePath.addLine(to: CGPoint(x: frame.maxX, y: theme.viewMinYGap))
        
        // K线图 内下边线 即最低价格线
        uperFramePath.move(to: CGPoint(x: 0, y: uperChartHeight - theme.viewMinYGap))
        uperFramePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight - theme.viewMinYGap))
        
        // K线图 中间的横线
        uperFramePath.move(to: CGPoint(x: 0, y: uperChartHeight / 2.0))
        uperFramePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight / 2.0))
        
        let uperFrameLayer = CAShapeLayer()
        uperFrameLayer.lineWidth = theme.frameWidth
        uperFrameLayer.strokeColor = theme.borderColor.cgColor
        uperFrameLayer.fillColor = UIColor.clear.cgColor
        uperFrameLayer.path = uperFramePath.cgPath
        
        // 交易量图
        let volFramePath = UIBezierPath(rect: CGRect(x: 0, y: uperChartHeight + theme.xAxisHeitht, width: frame.width, height: frame.height - uperChartHeight - theme.xAxisHeitht))
        
        // 交易量图 内上边线 即最高交易量格线
        volFramePath.move(to: CGPoint(x: 0, y: uperChartHeight + theme.xAxisHeitht + theme.volumeGap))
        volFramePath.addLine(to: CGPoint(x: frame.maxX, y: uperChartHeight + theme.xAxisHeitht + theme.volumeGap))
        
        let volFrameLayer = CAShapeLayer()
        volFrameLayer.lineWidth = theme.frameWidth
        volFrameLayer.strokeColor = theme.borderColor.cgColor
        volFrameLayer.fillColor = UIColor.clear.cgColor
        volFrameLayer.path = volFramePath.cgPath
        
        self.layer.addSublayer(uperFrameLayer)
        self.layer.addSublayer(volFrameLayer)
    }
    
    // 长按操作
    @objc func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: kLine)
            var highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            var positionModelIndex = highLightIndex - kLine.startIndex
            highLightIndex = highLightIndex <= 0 ? 0 : highLightIndex
            positionModelIndex = positionModelIndex <= 0 ? 0 : positionModelIndex
            
            if highLightIndex < kLine.dataK.count && positionModelIndex < kLine.positionModels.count {
                let entity = kLine.dataK[highLightIndex]
                let left = kLine.startX + CGFloat(highLightIndex - kLine.startIndex) * (self.theme.candleWidth + theme.candleGap) - scrollView.contentOffset.x
                let centerX = left + theme.candleWidth / 2.0
                let highLightVolume = kLine.positionModels[positionModelIndex].volumeStartPoint.y
                let highLightClose = kLine.positionModels[positionModelIndex].closeY
                let preIndex = (highLightIndex - 1 >= 0) ? (highLightIndex - 1) : highLightIndex
                let preData = kLine.dataK[preIndex]
                
                upFrontView.drawCrossLine(pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, chartType: kLine.kLineType)
                
                let userInfo: [AnyHashable: Any]? = ["preClose" : preData.close, "kLineEntity" : entity]
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .ended {
            upFrontView.removeCrossLine()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
        }
    }
    
    // 捏合缩放扩大操作
    @objc func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {

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
        default:
            enableKVO = true
            scrollView.isScrollEnabled = true
        }

        if abs(diffScale) > kLineScaleBound {
            let point1 = recognizer.location(ofTouch: 0, in: self)
            let point2 = recognizer.location(ofTouch: 1, in: self)

            let pinCenterX = (point1.x + point2.x) / 2
            let scrollViewPinCenterX = pinCenterX + scrollView.contentOffset.x
            
            // 中心点数据index
            let pinCenterLeftCount = scrollViewPinCenterX / (theme.candleWidth + theme.candleGap)

            // 缩放后的candle宽度
            let newCandleWidth = theme.candleWidth * (recognizer.velocity > 0 ? (1 + kLineScaleFactor) : (1 - kLineScaleFactor))
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
    
    /// 处理点击事件
    @objc func handleTapGestureAction(_ recognizer: UITapGestureRecognizer) {
        if !isLandscapeMode {
            let  point = recognizer.location(in: kLine)
            if point.y < lowerChartTop {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineUperChartDidTap), object: self.tag)
            }
        }
    }
}

extension HSKLineView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // MARK: - 用于滑动加载更多 KLine 数据
        if (scrollView.contentOffset.x < 0 && dataK.count < allDataK.count) {
            self.oldRightOffset = scrollView.contentSize.width - scrollView.contentOffset.x
            print("load more")
            self.configureView(data: allDataK)
        } else {
            
        }
    }
}
