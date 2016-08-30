//
//  FiveDayTimeViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class FiveDayTimeViewController: UIViewController {

    var fiveDaysTimeLineStockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(fiveDaysTimeLineStockChartView)
//        let model: PriceModel = readFile("5dayTimeLine", ext: "json")
        
        let path = NSBundle.mainBundle().pathForResource("5dayTimeLine", ofType: "json")
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let temp = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let model: HSTimeLineModel = HSTimeLineModel.createTimeLineModel(JSON(data: temp))
        
        setupFiveDaysTimeLineView(model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - Function
    
    func setupFiveDaysTimeLineView(data: HSTimeLineModel) {
        
        var timeArray = [TimeLineEntity]()
        var lastVolume = CGFloat(0)
        let preClose = data.preClose
        
        var days = [String]()
        for day in data.days{
            let date = day.toDate("yyyy-MM-dd")?.toString("MM-dd")
            days.append(date!)
        }
        
        //获取分时线数据
        var lastAvg = CGFloat(0)
        for  (index, model) in data.shares.enumerate() {
            
            let entity = TimeLineEntity()
            
            entity.currtTime = (model.date.toString("HH:mm"))
            
            entity.preClosePx = CGFloat(data.preClose)
            
            entity.price = CGFloat(model.price)
            if index == 0 {
                lastAvg = entity.price
            }
            
            //涨跌幅
            entity.rate = ((CGFloat(model.price) / CGFloat(preClose)) - 1) * 100
            entity.volume = CGFloat(model.volume) - lastVolume
            if entity.volume < 0 {
                entity.volume = 0
            }
            lastVolume = CGFloat(model.volume)
            entity.avgPirce = CGFloat(model.amount / model.volume)
            
            if isnan(entity.avgPirce) {
                entity.avgPirce = lastAvg
            }else{
                lastAvg = entity.avgPirce
            }
            
            timeArray.append(entity)
        }
        
        //拼接画图所需要的数据
        let set  = TimeLineDataSet()
        set.data = timeArray;
        set.days = days
        set.avgLineCorlor = UIColor(netHex: 0xffc004, alpha: 1)
        set.priceLineCorlor = UIColor(netHex: 0x0095ff, alpha: 1)
        set.lineWidth = 1;
        set.highlightLineWidth = 0.8
        set.highlightLineColor = UIColor(netHex: 0x546679, alpha: 1)
        
        
        
        set.volumeTieColor = UIColor(netHex: 0xaaaaaa, alpha: 1)
        set.volumeRiseColor = UIColor(netHex: 0xf24957, alpha: 1)
        set.volumeFallColor = UIColor(netHex: 0x1dbf60, alpha: 1)
        
        set.fillStartColor = UIColor(netHex: 0xe3efff, alpha: 1)
        set.fillStopColor = UIColor(netHex: 0xe3efff, alpha: 1)
        set.fillAlpha = 0.5
        set.drawFilledEnabled = true
        self.fiveDaysTimeLineStockChartView.countOfTimes = 405
        self.fiveDaysTimeLineStockChartView.showFiveDayLabel = true
        //self.fiveDaysTimeLineStockChartView.endPointShowEnabled = NSDate().isTradingTime()
        self.fiveDaysTimeLineStockChartView.dataSet = set
        
    }
}
