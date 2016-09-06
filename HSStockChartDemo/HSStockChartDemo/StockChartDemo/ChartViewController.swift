//
//  ChartViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/6.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

enum HSChartType: Int {
    case timeLineForDay
    case timeLineForFiveday
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
}

protocol ChartViewControllerDelegate {
    func showLandscapeChartView()
}

class ChartViewController: UIViewController {
    
    var chartType: HSChartType = .timeLineForDay
    var delegate: ChartViewControllerDelegate?
    var tapGesture : UITapGestureRecognizer{
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    }

    
    // MARK: - Life Circle
    
    func setUpViewController() {
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            let stockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, self.view.frame.width, 300),uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("OneDayTimeLine"))
            stockChartView.dataSet = getTimeLineViewDataSet(modelArray, info: stockBasicInfo)
            stockChartView.userInteractionEnabled = true
            stockChartView.addGestureRecognizer(tapGesture)
            self.view.addSubview(stockChartView)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLineStockChartView(frame: CGRectMake(0, 0, self.view.frame.width, 300),uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
            self.view.addSubview(stockChartView)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("FiveDayTimeLine"))
            stockChartView.dataSet = getTimeLineViewDataSet(modelArray, info: stockBasicInfo)
            stockChartView.showFiveDayLabel = true
            stockChartView.userInteractionEnabled = true
            stockChartView.addGestureRecognizer(tapGesture)
            
            
        case .kLineForDay:
            let stockChartView = HSKLineStockChartView(frame: CGRectMake(0, 0, self.view.frame.width, 300))
            self.view.addSubview(stockChartView)
            let modelArray = HSKLineModel.createKLineModel(getJsonDataFromFile("dayKLine"))
            stockChartView.setUpData(getKLineViewDataSet(modelArray))
            
        case .kLineForWeek:
            print("kLineForWeek")
            
        case .kLineForMonth:
            print("kLineForMonth")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Function
    
    func getTimeLineViewDataSet(data: [HSTimeLineModel], info: HSStockBasicInfoModel) -> TimeLineDataSet {
        var timeArray = [TimeLineEntity]()
        var days = [String]()
        if let firstData = data.first {
            for day in firstData.days {
                let date = day.toDate("yyyy-MM-dd")?.toString("MM-dd") ?? ""
                days.append(date)
            }
        }
        
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
        set.days = days
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
        
        return set
    }
    
    func getKLineViewDataSet(data: [HSKLineModel]) -> KLineDataSet {
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
        
        return dataSet
    }
    
    func getJsonDataFromFile(fileName: String) -> JSON {
        let pathForResource = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: NSUTF8StringEncoding)
        let jsonContent = content.dataUsingEncoding(NSUTF8StringEncoding)!
        return JSON(data: jsonContent)
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        delegate?.showLandscapeChartView()
    }
    
}
