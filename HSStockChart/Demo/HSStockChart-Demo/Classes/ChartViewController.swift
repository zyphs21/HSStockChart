//
//  ChartViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/6.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON
import HSStockChart

class ChartViewController: UIViewController {
    
    var chartType: HSChartType = .timeLineForDay
    var timeLineView: HSTimeLine?
    var chartRect: CGRect = CGRect.zero
    var isLandscapeMode: Bool = false

    
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
            let modelArray = getTimeLineModelArray(getJsonDataFromFile("timeLineForDay"), type: chartType, basicInfo: stockBasicInfo)
            timeLineView?.dataT = modelArray
            timeLineView!.isUserInteractionEnabled = true
            timeLineView?.tag = chartType.rawValue
            timeLineView?.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLine(frame: chartRect, isFiveDay: true)
            let modelArray = getTimeLineModelArray(getJsonDataFromFile("timeLineForFiveday"), type: chartType, basicInfo: stockBasicInfo)
            stockChartView.dataT = modelArray
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForDay:
            self.view.addSubview(UIView())
//            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForDay)
//            stockChartView.tag = chartType.rawValue
//            stockChartView.isLandscapeMode = self.isLandscapeMode
//            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            self.view.addSubview(UIView())
//            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForWeek)
//            stockChartView.tag = chartType.rawValue
//            stockChartView.isLandscapeMode = self.isLandscapeMode
//            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            self.view.addSubview(UIView())
//            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForMonth)
//            stockChartView.tag = chartType.rawValue
//            stockChartView.isLandscapeMode = self.isLandscapeMode
//            self.view.addSubview(stockChartView)
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
    
    func getTimeLineModelArray(_ json: JSON) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = Date.hs_toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hs_toString("HH:mm")
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        return modelArray
    }

    func getTimeLineModelArray(_ json: JSON, type: HSChartType, basicInfo: HSStockBasicInfoModel) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        var toComparePrice: CGFloat = 0

        if type == .timeLineForFiveday {
            toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)

        } else {
            toComparePrice = basicInfo.preClosePrice
        }

        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = Date.hs_toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hs_toString("HH:mm")
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePx = basicInfo.preClosePrice
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }

        return modelArray
    }
}
