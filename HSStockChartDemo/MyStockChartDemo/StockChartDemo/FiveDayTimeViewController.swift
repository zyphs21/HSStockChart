//
//  FiveDayTimeViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class FiveDayTimeViewController: UIViewController {

    var fiveDaysTimeLineStockChartView = TimeLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(fiveDaysTimeLineStockChartView)
        let model: PriceModel = readFile("5dayTimeLine", ext: "json")
        
        setupFiveDaysTimeLineView(model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - Function
    
    func setupFiveDaysTimeLineView(data: PriceModel) {
        
        var timeArray = [TimeLineEntity]()
        var lastVolume = CGFloat(0)
        let preClose = data.close
        
        var days = [String]()
        if let d = data.days{
            for day in d{
                let date = day.toDate("yyyy-MM-dd")?.toString("MM-dd")
                days.append(date!)
            }
        }
        
        //获取分时线数据
        if let shares = data.shares {
            var lastAvg = CGFloat(0)
            for  (index,dic) in shares.enumerate(){
                let entity = TimeLineEntity()
                entity.currtTime = (dic.dt?.toString("HH:mm"))!
                if let c = data.close{
                    entity.preClosePx = CGFloat(c)
                }
                
                if let p = dic.price{
                    entity.lastPirce = CGFloat(p)
                    if index == 0{
                        lastAvg = entity.lastPirce
                    }
                    
                    //涨跌幅
                    if let c = preClose{
                        entity.rate = (CGFloat(p/c) - 1) * 100
                    }
                }
                
                if let v = dic.volume{
                    entity.volume = CGFloat(v) - lastVolume // TODO:
                    lastVolume = CGFloat(v)
                    if let a = dic.amount{
                        //均线
                        entity.avgPirce = CGFloat(a/v)
                    }
                }
                
                
                if isnan(entity.avgPirce) {
                    entity.avgPirce = lastAvg
                }else{
                    lastAvg = entity.avgPirce
                }
                
                timeArray.append(entity)
            }
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
//        self.fiveDaysTimeLineStockChartView.endPointShowEnabled = NSDate().isTradingTime()
        self.fiveDaysTimeLineStockChartView.dataSet = set
        
    }
}
