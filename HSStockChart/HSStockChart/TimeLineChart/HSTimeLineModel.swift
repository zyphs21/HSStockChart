//
//  HSTimeLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/26.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
//import SwiftyJSON

public class HSTimeLineModel: NSObject {
    
    public var time: String = ""
    public var price: CGFloat = 0
    public var volume: CGFloat = 0
    public var days: [String] = []
    public var preClosePx: CGFloat = 0
    public var avgPirce: CGFloat = 0
    public var totalVolume: CGFloat = 0
    public var trade: CGFloat = 0
    public var rate: CGFloat = 0
    
//    class func getTimeLineModelArray(_ json: JSON) -> [HSTimeLineModel] {
//        var modelArray = [HSTimeLineModel]()
//        for (_, jsonData): (String, JSON) in json["chartlist"] {
//            let model = HSTimeLineModel()
//            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
//            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
//            model.price = CGFloat(jsonData["current"].doubleValue)
//            model.volume = CGFloat(jsonData["volume"].doubleValue)
//            model.days = (json["days"].arrayObject as? [String]) ?? [""]
//            modelArray.append(model)
//        }
//        return modelArray
//    }
//
//    class func getTimeLineModelArray(_ json: JSON, type: HSChartType, basicInfo: HSStockBasicInfoModel) -> [HSTimeLineModel] {
//        var modelArray = [HSTimeLineModel]()
//        var toComparePrice: CGFloat = 0
//
//        if type == .timeLineForFiveday {
//            toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)
//
//        } else {
//            toComparePrice = basicInfo.preClosePrice
//        }
//
//        for (_, jsonData): (String, JSON) in json["chartlist"] {
//            let model = HSTimeLineModel()
//            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
//            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
//            model.price = CGFloat(jsonData["current"].doubleValue)
//            model.volume = CGFloat(jsonData["volume"].doubleValue)
//            model.rate = (model.price - toComparePrice) / toComparePrice
//            model.preClosePx = basicInfo.preClosePrice
//            model.days = (json["days"].arrayObject as? [String]) ?? [""]
//            modelArray.append(model)
//        }
//
//        return modelArray
//    }
}
