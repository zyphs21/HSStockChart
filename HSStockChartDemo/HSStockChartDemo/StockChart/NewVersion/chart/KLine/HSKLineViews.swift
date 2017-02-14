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
    
    var scrollView: UIScrollView!
    var kLine: HSKLine!
    var kLineType: HSChartType!
    var widthOfKLineView: CGFloat = 0
    var oldRightOffset: CGFloat = -1
    let theme: HSKLineTheme = HSKLineTheme()
    var dataK: [HSKLineModel] = []
    var kLineViewWidth: CGFloat = 0.0

    init(frame: CGRect, lineType: HSChartType) {
        super.init(frame: frame)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 300))
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        self.addSubview(scrollView)
        
        kLine = HSKLine(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        kLine.kLineType = lineType
        scrollView.addSubview(kLine)
        
        dataK = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
        self.configureView(data: Array(dataK[dataK.count-70..<dataK.count]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            print("in klineview scrollView?.contentOffset.x " + "\(scrollView?.contentOffset.x)")

            // 拖动 ScrollView 时重绘当前显示的 klineview
            kLine.setNeedsDisplay(CGRect(x: scrollView.contentOffset.x, y: 0, width: scrollView.width, height: kLine.frame.height))
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
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: currentWidth, height: self.frame.height)


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
