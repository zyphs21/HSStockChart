//
//  KLineViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class KLineViewController: UIViewController {

    var kLineStockChartView = KLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(kLineStockChartView)
        let model: KLineMessage = readFile("dayKLine", ext: "json")
        
        setUpDayKLineView(model.message!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpDayKLineView(data: [KLineModel]) {
        var array = [KLineEntity]()
        
        for (index,dic) in data.enumerate(){
            let entity = KLineEntity()
            if let h = dic.high{
                entity.high = CGFloat(h)
            }
            
            if let o = dic.open{
                entity.open = CGFloat(o)
                if index == 0 {
                    entity.preClosePx = CGFloat(o)
                } else {
                    if let c = data[index-1].close {
                        entity.preClosePx = CGFloat(c)
                    } else {
                        entity.preClosePx = CGFloat(o)
                    }
                }
            }
            
            if let l = dic.low {
                entity.low = CGFloat(l)
            }
            
            if let c = dic.close {
                entity.close = CGFloat(c)
            }
            
            if let r = dic.inc {
                entity.rate = CGFloat(r)
            }
            
            if let d = dic.dt {
                entity.date = d
            }
            
            if let ma5 = dic.ma?.MA5 {
                entity.ma5 = CGFloat(ma5)
            }
            
            if let ma10 = dic.ma?.MA10 {
                entity.ma10 = CGFloat(ma10)
            }
            
            if let ma20 = dic.ma?.MA20 {
                entity.ma20 = CGFloat(ma20)
            }
            
            if let v = dic.vol {
                entity.volume = CGFloat(v)
            }
            
            array.append(entity)
        }
        
        let dataSet = KLineDataSet()
        dataSet.data = array
        dataSet.highlightLineColor = UIColor(rgba: "#546679")
//        self.kLineStockChartView.dataSet = dataSet
        self.kLineStockChartView.setUpData(dataSet)
    }

}
