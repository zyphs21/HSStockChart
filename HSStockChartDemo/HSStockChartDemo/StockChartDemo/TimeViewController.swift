//
//  TimeViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {

//    var timeLineStockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400))
    var timeLineStockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400), uperChartHeightScale: 0.7, topOffSet: 0, leftOffSet: 0, bottomOffSet: 0, rightOffSet: 0)
    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(timeLineStockChartView)
        let model: PriceModel = readFile("dayTimeLine", ext: "json")
        
        setupTimeLineView(model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Function
    
    func setupTimeLineView(data: PriceModel) {
        
        var timeArray = [TimeLineEntity]()
        var lastVolume = CGFloat(0)
        
        //获取分时线数据
        if let shares = data.shares {
            var lastAvg = CGFloat(0)
            for dic in shares {
                
                let entity = TimeLineEntity()
                
                entity.currtTime = dic.dt!.toString("HH:mm")
                
                if let close = data.close {
                    entity.preClosePx = CGFloat(close)
                }
                
                if let p = dic.price {
                    entity.lastPirce = CGFloat(p)
                }
                
                if let v = dic.volume {
                    entity.volume = CGFloat(v) - lastVolume // 获得增量的 volume
                    lastVolume = CGFloat(v)
                    if let a = dic.amount {
                        //均线
                        entity.avgPirce = CGFloat(a / v)
                    }
                }
                
                if isnan(entity.avgPirce) {
                    entity.avgPirce = lastAvg
                }else {
                    lastAvg = entity.avgPirce
                }
                
                //涨跌幅
                if let r = dic.ratio {
                    entity.rate = CGFloat(r)
                    //entity.rate = (CGFloat(dic.price!) - CGFloat(data.close!)) / CGFloat(data.close!)
                }
                
                timeArray.append(entity)
            }
        }
        
        //拼接画图所需要的数据
        let set  = TimeLineDataSet()
        set.data = timeArray
        set.lineWidth = 1
        set.highlightLineWidth = 0.8
        set.avgLineCorlor = UIColor(netHex: 0xffc004, alpha: 1)
        set.priceLineCorlor = UIColor(netHex: 0x0095ff, alpha: 1)
        set.highlightLineColor = UIColor(netHex: 0x546679, alpha: 1)
  
        set.volumeTieColor = UIColor(netHex: 0xaaaaaa, alpha: 1)
        set.volumeRiseColor = UIColor(netHex: 0xf24957, alpha: 1)
        set.volumeFallColor = UIColor(netHex: 0x1dbf60, alpha: 1)
        
        set.fillStartColor = UIColor(netHex: 0xe3efff, alpha: 1)
        set.fillStopColor = UIColor(netHex: 0xe3efff, alpha: 1)
        set.fillAlpha = 0.5
        set.drawFilledEnabled = true
        
        self.timeLineStockChartView.dataSet = set
        
    }
}
