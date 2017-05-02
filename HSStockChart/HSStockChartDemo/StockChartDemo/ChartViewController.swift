//
//  ChartViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/6.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON
import Moya

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
      // let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            timeLineView = HSTimeLine(frame: chartRect)
            getServerTimeLineData(code: "zanjia") { result in
                let json = JSON(result)
                let modelArray = HSTimeLineModel.getTimeLineModelArray(json, type: self.chartType, basicInfo: nil)
                self.timeLineView?.dataT = modelArray
                self.timeLineView!.isUserInteractionEnabled = true
                self.timeLineView?.tag = self.chartType.rawValue
                self.timeLineView?.isLandscapeMode = self.isLandscapeMode
                self.view.addSubview(self.timeLineView!)
            }
            
//            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("timeLineForDay"), type: chartType, basicInfo: nil)
//            timeLineView?.dataT = modelArray
//            timeLineView!.isUserInteractionEnabled = true
//            timeLineView?.tag = chartType.rawValue
//            timeLineView?.isLandscapeMode = self.isLandscapeMode
//            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLine(frame: chartRect, isFiveDay: true)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("timeLineForFiveday"), type: chartType, basicInfo: nil)
            stockChartView.dataT = modelArray
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForDay:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForDay)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForWeek)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            let stockChartView = HSKLineView(frame: chartRect, kLineType: .kLineForMonth)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
  
    func getServerTimeLineData(code: String, _ completion: @escaping (Any)->Void) {
        let provider = MoyaProvider<StockChartsApi>()
        provider.request(.minlineForDay(code: code)) { result in
          switch result {
            case let .success(response):
              do {
                let data = try response.mapJSON()
                completion(data)
              } catch { }
            case let .failure(error):
              print(error)
          }
        }
    }
}
