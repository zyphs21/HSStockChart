//
//  HSTimeLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/26.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class HSTimeLineModel: NSObject {
    
    var ts: Int = 0
    var time: String = ""
    var price: CGFloat = 0
    var volume: CGFloat = 0
    var days: [String] = []
    var preClosePx: CGFloat = 0
    var avgPirce: CGFloat = 0
    var totalVolume: CGFloat = 0
    var trade: CGFloat = 0
    var rate: CGFloat = 0
    
    class func getTimeLineModelArray(_ json: JSON) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        return modelArray
    }
    
    class func getTimeLineModelArray(_ json: JSON, type: HSChartType, basicInfo: HSStockBasicInfoModel?) -> [HSTimeLineModel] {
        let snapshot = basicInfo ?? HSStockBasicInfoModel.getStockBasicInfoModel(json["quote"])
      
        var modelArray = [HSTimeLineModel]()
        var toComparePrice: CGFloat = 0
        
        if type == .timeLineForFiveday {
            toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)
        } else {
            toComparePrice = snapshot.preClosePrice
        }
        
//        for (_, jsonData): (String, JSON) in json["chartlist"] {
//            let time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
//            let ts = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").timeIntervalSince1970.description
//            let avgPirce = String(jsonData["avg_price"].doubleValue)
//            let price = String(jsonData["current"].doubleValue)
//            let volume = jsonData["volume"].stringValue
//            
//            print("\"\([ts, time, price, volume, "0", avgPirce].joined(separator: "|"))\",")
//        }
        
        
        for (_, jsonData): (String, JSON) in json["data"] {
            let dict = Utils.getChartlist(fields: json["fields"].stringValue, data: jsonData.stringValue)!
            let model = HSTimeLineModel()
                
//            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
//            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
//            model.price = CGFloat(jsonData["current"].doubleValue)
//            model.volume = CGFloat(jsonData["volume"].doubleValue)
//            model.rate = (model.price - toComparePrice) / toComparePrice
//            model.preClosePx = snapshot.preClosePrice
//            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            
            model.time = dict["t"]!
            model.avgPirce = CGFloat(79)
            model.price = CGFloat(Double(dict["price"]!)!)
            model.volume = CGFloat(Double(dict["volume"]!)!)
            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePx = snapshot.preClosePrice
            model.days = [""]
            modelArray.append(model)
        }
        
        return modelArray
    }
}
