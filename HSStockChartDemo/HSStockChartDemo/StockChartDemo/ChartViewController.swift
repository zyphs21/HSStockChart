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

class ChartViewController: UIViewController {
    
    var chartType: HSChartType = .timeLineForDay
    var timeLineView: HSTimeLine?

    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // MARK: - Function
    
    func setUpViewController() {
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            timeLineView = HSTimeLine(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300),
                                                    topOffSet: 10,
                                                    leftOffSet: 5,
                                                    bottomOffSet: 5,
                                                    rightOffSet: 5)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("OneDayTimeLine"), type: chartType, basicInfo: stockBasicInfo)
            timeLineView?.dataT = modelArray
            timeLineView!.isUserInteractionEnabled = true
            timeLineView!.tag = chartType.rawValue
            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLine(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300), topOffSet: 10, leftOffSet: 5, bottomOffSet: 5, rightOffSet: 5)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("FiveDayTimeLine"), type: chartType, basicInfo: stockBasicInfo)
            stockChartView.dataT = modelArray
            stockChartView.showFiveDayLabel = true
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
            
        case .kLineForDay:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
            stockChartView.setUpData(modelArray)
            stockChartView.tag = chartType.rawValue
            
            stockChartView.tag = chartType.rawValue
            
            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("WeeklyKLine"))
            stockChartView.monthInterval = 4
            stockChartView.setUpData(modelArray)
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            let stockChartView = HSKLineStockChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("MonthlyKLine"))
            stockChartView.monthInterval = 12
            stockChartView.setUpData(modelArray)
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}
