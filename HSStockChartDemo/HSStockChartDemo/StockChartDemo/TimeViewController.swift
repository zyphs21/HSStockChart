//
//  TimeViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class TimeViewController: UIViewController {
    
    var timeLineStockChartView: HSTimeLineStockChartView?
    
//    var chartWidth: CGFloat {
//        get {
//            return self.view.frame.width
//        }
//    }
    
    var tapGesture : UITapGestureRecognizer{
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
    }
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLineStockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, ScreenWidth, 300), uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
        self.view.addSubview(timeLineStockChartView!)
        
        let path = NSBundle.mainBundle().pathForResource("dayTimeLine", ofType: "json")
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let temp = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let model: HSTimeLineModel = HSTimeLineModel.createTimeLineModel(JSON(data: temp))
        
        setupTimeLineView(model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Function
    func setupTimeLineView(data: HSTimeLineModel) {
        var timeArray = [TimeLineEntity]()
        var lastVolume = CGFloat(0)
        
        //获取分时线数据
        var lastAvg = CGFloat(0)
        for share in data.shares {
            
            let entity = TimeLineEntity()
            
            entity.currtTime = share.date.toString("HH:mm")
            
            entity.preClosePx = CGFloat(data.preClose)
            
            entity.price = CGFloat(share.price)
            
            entity.volume = CGFloat(share.volume) - lastVolume // 获得增量的 volume
            
            lastVolume = CGFloat(share.volume)
            
            entity.avgPirce = CGFloat(share.amount / share.volume)
            
            if isnan(entity.avgPirce) {
                entity.avgPirce = lastAvg
            }else {
                lastAvg = entity.avgPirce
            }
            
            //涨跌幅
            entity.rate = CGFloat(share.ratio)
            //entity.rate = (CGFloat(dic.price!) - CGFloat(data.close!)) / CGFloat(data.close!)
            
            timeArray.append(entity)
        }
        
        let set  = TimeLineDataSet()
        set.data = timeArray
        set.lineWidth = 1
        set.highlightLineWidth = 0.8
        set.avgLineCorlor = UIColor(rgba: "#ffc004")
        set.priceLineCorlor = UIColor(rgba: "#0095ff")
        set.highlightLineColor = UIColor(rgba: "#546679")

        set.volumeTieColor = UIColor(rgba: "#aaaaaa")
        set.volumeRiseColor = UIColor(rgba: "#f24957")
        set.volumeFallColor = UIColor(rgba: "#1dbf60")

        set.fillStartColor = UIColor(rgba: "#e3efff")
        set.fillStopColor = UIColor(rgba: "#e3efff")
        set.fillAlpha = 0.5
        set.drawFilledEnabled = true
        
        self.timeLineStockChartView!.dataSet = set
        timeLineStockChartView!.userInteractionEnabled = true
        timeLineStockChartView!.addGestureRecognizer(tapGesture)
    }
    
    func handleTapGestureAction(recognizer: UITapGestureRecognizer) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController {
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
//    
//    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
//        return UIInterfaceOrientation.Portrait
//    }
}

