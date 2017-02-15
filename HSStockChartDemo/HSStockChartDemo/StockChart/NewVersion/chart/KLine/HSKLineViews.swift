//
//  HSKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class HSKLineViews: UIView {
    
    var chartFrame: HSChartFrame!
    var scrollView: UIScrollView!
    var kLine: HSKLine!
    var highlightView: HSHighlightView!
    
    var kLineType: HSChartType!
    var widthOfKLineView: CGFloat = 0
    var oldRightOffset: CGFloat = -1
    let theme: HSKLineTheme = HSKLineTheme()
    var dataK: [HSKLineModel] = []
    var kLineViewWidth: CGFloat = 0.0

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

        highlightView = HSHighlightView(frame: frame)
        addSubview(highlightView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)
        
        dataK = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
        self.configureView(data: Array(dataK[dataK.count-70..<dataK.count]))
//        self.configureView(data: dataK)
    }
    
    override func layoutSubviews() {

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")

            // 拖动 ScrollView 时重绘当前显示的 klineview
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.setNeedsDisplay()
            highlightView.drawYAxisMark(maxPrice: kLine.maxPrice, minPrice: kLine.minPrice)
        }
    }

    func configureView(data: [HSKLineModel]) {

        if kLine.dataK.count == data.count {
            return
        }
        kLine.dataK = data
        let count: CGFloat = CGFloat(data.count)

        // 总长度
        var currentWidth: CGFloat = 0.0
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < ScreenWidth {
            kLineViewWidth = ScreenWidth
            currentWidth = ScreenWidth
        } else {
            currentWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }

        // 更新view长度
        print("currentWidth " + "\(currentWidth)")
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: currentWidth, height: scrollView.frame.height)

        var contentOffsetX: CGFloat = 0
        if scrollView.contentSize.width > 0 {
            contentOffsetX = currentWidth - scrollView.contentSize.width
        } else {
            // 首次加载，将 kLine 的右边和scrollview的右边对齐
            contentOffsetX = kLine.frame.width - scrollView.frame.width
        }
        
        scrollView.contentSize = CGSize(width: currentWidth, height: self.frame.height)
        scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        print("ScrollKLine contentOffsetX " + "\(contentOffsetX)")
    }
    
    // 长按操作
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: kLine)
            let highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            if highLightIndex < dataK.count {
                let index = highLightIndex - kLine.startIndex
                let entity = dataK[highLightIndex]
                let left = kLine.startX + CGFloat(highLightIndex - kLine.startIndex) * (self.theme.candleWidth + theme.candleGap) - scrollView.contentOffset.x
                let centerX = left + theme.candleWidth / 2.0
                let highLightVolume = kLine.positionModels[index].volumeStartPoint.y
                let highLightClose = kLine.positionModels[index].closePoint.y
                
                highlightView.drawLongPressHighlight(pricePoint: CGPoint(x: centerX, y: highLightClose),
                                                 volumePoint: CGPoint(x: centerX, y: highLightVolume),
                                                 value: entity)
                
                let lastData = highLightIndex > 0 ? dataK[highLightIndex - 1] : dataK[0]
                let userInfo: [AnyHashable: Any]? = ["preClose" : lastData.close, "kLineEntity" : dataK[highLightIndex]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartLongPress), object: self, userInfo: userInfo)
            }
        }
        
        if recognizer.state == .ended {
            highlightView.drawLongPressHighlight(pricePoint: CGPoint.zero,
                                                 volumePoint: CGPoint.zero,
                                                 value: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: KLineChartUnLongPress), object: self)
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}

extension HSKLineViews: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // MARK: - 用于滑动加载更多 KLine 数据
        if (scrollView.contentOffset.x < 0) {
                print("load more")
                self.configureView(data: dataK)
        } else {
            
        }
    }
}
