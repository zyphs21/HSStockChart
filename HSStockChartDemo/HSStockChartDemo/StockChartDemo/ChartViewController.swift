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
    var chartRect: CGRect = CGRect.zero

    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        print(self.view.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(self.view.frame)
//        setUpViewController()
    }
    
    override func viewDidLayoutSubviews() {
        print(self.view.frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.view.frame)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    // MARK: - Function
    
    func setUpViewController() {
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            timeLineView = HSTimeLine(frame: chartRect)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("OneDayTimeLine"), type: chartType, basicInfo: stockBasicInfo)
            timeLineView?.dataT = modelArray
            timeLineView!.isUserInteractionEnabled = true
            timeLineView!.tag = chartType.rawValue
            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLine(frame: chartRect, isFiveDay: true)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("FiveDayTimeLine"), type: chartType, basicInfo: stockBasicInfo)
            stockChartView.dataT = modelArray
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
            
        case .kLineForDay:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForDay)
//            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("DaylyKLine"))
//            stockChartView.setUpData(modelArray)
            stockChartView.tag = chartType.rawValue
            
            stockChartView.tag = chartType.rawValue
            
            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForWeek)
//            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("WeeklyKLine"))
//            stockChartView.monthInterval = 4
//            stockChartView.setUpData(modelArray)
            stockChartView.tag = chartType.rawValue
            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForMonth)
//            let modelArray = HSKLineModel.getKLineModelArray(getJsonDataFromFile("MonthlyKLine"))
//            stockChartView.monthInterval = 12
//            stockChartView.setUpData(modelArray)
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
