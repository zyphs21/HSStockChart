//
//  HSScrollKLineView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/8.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class HSScrollKLineView: UIView {
    
    var scrollView: UIScrollView!
    var kLineView: HSKLineView!
    var widthOfKLineView: CGFloat = 0
    var kLineViewWidthConstraint: Constraint!
    
    var oldRightOffset: CGFloat = -1

    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 300))
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        kLineView = HSKLineView(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        scrollView.addSubview(kLineView)
//        kLineView.snp.makeConstraints { (make) in
//            kLineViewWidthConstraint = make.width.equalTo(0).constraint   //937
////            make.top.left.equalTo(scrollView)
////            make.height.equalTo(300)
//        }
//        self.layoutIfNeeded()
        
        let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
        self.configureView(dataSet: getKLineViewDataSet(modelArray))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(dataSet: KLineDataSet) {
        kLineView.dataSet = dataSet
        
        //updateKlineViewWidth()  //更新 KLineView 的长度
        self.kLineView.updateKlineViewWidth()
        
        var contentOffsetX: CGFloat = 0
        if self.oldRightOffset < 0 {
            contentOffsetX = kLineView.frame.width - scrollView.frame.width //widthOfKLineView - scrollView.frame.width
        } else {
            contentOffsetX = kLineView.frame.width - self.oldRightOffset//widthOfKLineView - self.oldRightOffset
        }
        print("ScrollKLine contentOffsetX " + "\(contentOffsetX)")
        scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
    }
    
    func updateKlineViewWidth() {
        if let data = kLineView.dataSet?.data {
            let count = CGFloat(data.count)
            print("data count" + "\(count)")
            // 总长度
            var kLineViewWidth = count * kLineView.candleWidth + (count + 1) * kLineView.gapBetweenCandle
            if kLineViewWidth < ScreenWidth {
                kLineViewWidth = ScreenWidth
            }
            self.widthOfKLineView = kLineViewWidth
            print("总长度 " + "\(kLineViewWidth)")
            // 更新长度
            kLineView.frame = CGRect(x: kLineView.frame.origin.x, y: kLineView.frame.origin.y, width: kLineViewWidth, height: 300)
//            kLineViewWidthConstraint.deactivate()
//            kLineView.snp.makeConstraints { (make) in
//                kLineViewWidthConstraint = make.width.equalTo(kLineViewWidth).constraint
//            }
//            kLineView.layoutIfNeeded()
            //self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: kLineViewWidth, height: self.frame.height)
            
            print("klineview frame " + "\(kLineView.frame)")
            
            self.scrollView.contentSize = CGSize(width: kLineViewWidth, height: 300)
            
        } else {
            //self.showFailStatusView()
        }
    }
    
    // MARK: - 获取数据
    
    func getKLineViewDataSet(_ data: [HSKLineModel]) -> KLineDataSet {
        var array = [KLineEntity]()
        for (index, klineModel) in data.enumerated(){
            let entity = KLineEntity()
            entity.high = klineModel.high
            entity.open = klineModel.open
            
            if index == 0 {
                entity.preClosePx = klineModel.open
            } else {
                entity.preClosePx = data[index - 1].close
            }
            
            entity.low = klineModel.low
            entity.close = klineModel.close
            entity.date = klineModel.date
            entity.rate = klineModel.rate
            entity.ma5 = klineModel.ma5
            entity.ma10 = klineModel.ma10
            entity.ma20 = klineModel.ma20
            entity.volume = klineModel.vol
            entity.diff = klineModel.diff
            entity.dea = klineModel.dea
            entity.macd = klineModel.macd
            array.append(entity)
        }
        
        let dataSet = KLineDataSet()
        dataSet.data = array
        dataSet.highlightLineColor = UIColor(rgba: "#546679")
        
        return dataSet
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}

extension HSScrollKLineView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // MARK: - 加载更多 KLine 数据
        if (scrollView.contentOffset.x < 0) {
//            print("load more")
//            self.oldRightOffset = scrollView.contentSize.width - scrollView.contentOffset.x
//            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
//            let dataSet = getKLineViewDataSet(modelArray)
//            dataSet.data? += (getKLineViewDataSet(modelArray).data!)
//            self.configureView(dataSet: dataSet)
            
        }else{
            
        }
    }
}
