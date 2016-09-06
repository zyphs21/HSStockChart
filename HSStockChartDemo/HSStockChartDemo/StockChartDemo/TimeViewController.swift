//
//  TimeViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol TimeViewControllerDelegate {
    func showLandscapeView()
}

class TimeViewController: UIViewController {
    
    var timeLineStockChartView: HSTimeLineStockChartView?
    
    var delegate: TimeViewControllerDelegate?
    
    var tapGesture : UITapGestureRecognizer{
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
    }
    
    
    // MARK: - Init

    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        
        self.view.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLineStockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, self.view.frame.width, 300), uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
        self.view.addSubview(timeLineStockChartView!)
        
        var pathForResource = NSBundle.mainBundle().pathForResource("OneDayTimeLine", ofType: "json")
        var content = try! String(contentsOfFile: pathForResource!, encoding: NSUTF8StringEncoding)
        var jsonContent = content.dataUsingEncoding(NSUTF8StringEncoding)!
        let modelArray = HSTimeLineModel.getTimeLineModelArray(JSON(data: jsonContent))
        
        pathForResource = NSBundle.mainBundle().pathForResource("SZ300033", ofType: "json")
        content = try! String(contentsOfFile: pathForResource!, encoding: NSUTF8StringEncoding)
        jsonContent = content.dataUsingEncoding(NSUTF8StringEncoding)!
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(JSON(data: jsonContent))
        
        setUpTimeLineView(modelArray, info: stockBasicInfo)
        
    }

    override func viewDidAppear(animated: Bool) {
        print("timeViewController appear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        //self.timeLineStockChartView?.setNeedsDisplay()
    }
    
    
    //MARK: - Function
    
    func setUpTimeLineView(data: [HSTimeLineModel], info: HSStockBasicInfoModel) {
        var timeArray = [TimeLineEntity]()
        
        //获取分时线数据
        for data in data {
            
            let entity = TimeLineEntity()
            
            entity.currtTime = data.currentTime
            
            entity.preClosePx = info.preClosePrice
            
            entity.price = data.price
            
            entity.volume = data.volume
            
            entity.avgPirce = data.averagePirce
            
            // 涨跌幅
            entity.rate = (data.price - info.preClosePrice) / info.preClosePrice
            
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
        delegate?.showLandscapeView()
    }
    
}

