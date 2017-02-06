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
    
    init(frame: CGRect, lineType: HSChartType) {
        super.init(frame: frame)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 300))
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        kLine = HSKLine(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        kLine.kLineType = lineType
        scrollView.addSubview(kLine)
        
        let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
        self.configureView(data: modelArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(data: [HSKLineModel]) {
        kLine.dataK = data
        
        // 根据数据更新 kLine 总长度的长度 以及 scrollview 的contentSize
        self.kLine.updateKlineViewWidth()
        
        var contentOffsetX: CGFloat = 0
        if self.oldRightOffset < 0 {
            // 首次加载，将 kLine 的右边和scrollview的右边对齐
            contentOffsetX = kLine.frame.width - scrollView.frame.width
            
        } else {
            contentOffsetX = kLine.frame.width - self.oldRightOffset
        }
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
            //            print("load more")
            //            self.oldRightOffset = scrollView.contentSize.width - scrollView.contentOffset.x
            //            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
            //            dataK += modelArray
            //            self.configureView(data: dataK)
            
        }else{
            
        }
    }
}
