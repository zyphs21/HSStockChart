//
//  KLineViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class KLineViewController: UIViewController {

    var kLineStockChartView = HSKLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(kLineStockChartView)
        
        let path = NSBundle.mainBundle().pathForResource("dayKLine", ofType: "json")
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let temp = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let model: [HSKLineModel] = HSKLineModel.createKLineModel(JSON(data: temp))
        
        setUpDayKLineView(model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setUpDayKLineView(data: [HSKLineModel]) {
        var array = [KLineEntity]()
        
        for (index, klineModel) in data.enumerate(){
            let entity = KLineEntity()
            
            entity.high = CGFloat(klineModel.high)
            
            entity.open = CGFloat(klineModel.open)
            
            if index == 0 {
                entity.preClosePx = CGFloat(klineModel.open)
            } else {
                entity.preClosePx = CGFloat(data[index - 1].close)
            }
            
            entity.low = CGFloat(klineModel.low)
            
            entity.close = CGFloat(klineModel.close)
            
            entity.rate = CGFloat(klineModel.inc)
            
            entity.date = klineModel.date
            
            entity.ma5 = CGFloat(klineModel.ma5)
            
            entity.ma10 = CGFloat(klineModel.ma10)
            
            entity.ma20 = CGFloat(klineModel.ma20)
            
            entity.volume = CGFloat(klineModel.vol)
            
            entity.diff = CGFloat(klineModel.diff)
            
            entity.dea = CGFloat(klineModel.dea)
            
            entity.macd = CGFloat(klineModel.macd)
            
            array.append(entity)
        }
        
        let dataSet = KLineDataSet()
        dataSet.data = array
        dataSet.highlightLineColor = UIColor(rgba: "#546679")
        self.kLineStockChartView.setUpData(dataSet)
    }
}
