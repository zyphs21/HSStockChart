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
    func showLandscapeChartView(_ index: Int)
}

class ChartViewController: UIViewController {
    
    var chartType: HSChartType = .timeLineForDay
    var delegate: ChartViewControllerDelegate?
    var timeLineView: HSTimeLineStockChartView?
    var tapGesture : UITapGestureRecognizer{
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    }

    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.timeLineView?.animatePoint.addAnimation(self.breathingLightAnimate(2), forKey: nil)
    }
    
    // MARK: - Function
    
    func setUpViewController() {
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            timeLineView = HSTimeLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300),uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("OneDayTimeLine"))
            timeLineView!.dataSet = getTimeLineViewDataSet(modelArray, info: stockBasicInfo, type: chartType)
            timeLineView!.isUserInteractionEnabled = true
            timeLineView!.tag = chartType.rawValue
            timeLineView!.addGestureRecognizer(tapGesture)
            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300),uperChartHeightScale: 0.7, topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("FiveDayTimeLine"))
            stockChartView.dataSet = getTimeLineViewDataSet(modelArray, info: stockBasicInfo, type: chartType)
            stockChartView.showFiveDayLabel = true
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            stockChartView.addGestureRecognizer(tapGesture)
            self.view.addSubview(stockChartView)
            
            
        case .kLineForDay:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
            stockChartView.setUpData(getKLineViewDataSet(modelArray))
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("WeeklyKLine"))
            stockChartView.monthInterval = 4
            stockChartView.setUpData(getKLineViewDataSet(modelArray))
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("MonthlyKLine"))
            stockChartView.monthInterval = 12
            stockChartView.setUpData(getKLineViewDataSet(modelArray))
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
        }
    }
    
    func getTimeLineViewDataSet(_ data: [HSTimeLineModel], info: HSStockBasicInfoModel, type: HSChartType) -> TimeLineDataSet {
        var timeArray = [TimeLineEntity]()
        var days = [String]()
        var toComparePrice: CGFloat = 0
        if let firstData = data.first {
            for day in firstData.days {
                let date = day.toDate("yyyy-MM-dd")?.toString("MM-dd") ?? ""
                days.append(date)
            }
        }
        if type == .timeLineForFiveday {
            toComparePrice = data[0].price
        } else {
            toComparePrice = info.preClosePrice
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
            entity.rate = (data.price - toComparePrice) / toComparePrice
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
    
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        let index = recognizer.view?.tag ?? 0
        delegate?.showLandscapeChartView(index)
    }
    
//    func breathingLightAnimate(time:Double) -> CAAnimationGroup {
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnimation.fromValue = 1
//        scaleAnimation.toValue = 3
//        scaleAnimation.autoreverses = false
//        scaleAnimation.removedOnCompletion = true
//        scaleAnimation.repeatCount = MAXFLOAT
//        scaleAnimation.duration = time
//        
//        let opacityAnimation = CABasicAnimation(keyPath:"opacity")
//        opacityAnimation.fromValue = 1.0
//        opacityAnimation.toValue = 0
//        opacityAnimation.autoreverses = false
//        opacityAnimation.removedOnCompletion = true
//        opacityAnimation.repeatCount = MAXFLOAT
//        opacityAnimation.duration = time
//        opacityAnimation.fillMode = kCAFillModeForwards
//        
//        let group = CAAnimationGroup()
//        group.duration = time
//        group.autoreverses = false
//        group.removedOnCompletion = true
//        group.fillMode = kCAFillModeForwards
//        group.animations = [scaleAnimation,opacityAnimation]
//        group.repeatCount = MAXFLOAT
//        
//        return group
//    }
}
