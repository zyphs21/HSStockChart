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

    var days: [String] = []
    var state: Bool = false
    var preClose: Double = 0
    var max: Double = 0
    var min: Double = 0
    var shares: [Share] = []
    
    var currentTime: String = ""
    var averagePirce: CGFloat = 0
    var price: CGFloat = 0
    var volume: CGFloat = 0
    
    class func getTimeLineModelArray(json: JSON) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.currentTime = NSDate.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
            model.averagePirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            modelArray.append(model)
        }
        return modelArray
    }
    
    class func createTimeLineModel(json: JSON) -> HSTimeLineModel {
        let model = HSTimeLineModel()
        model.days = json["days"].arrayObject as! [String]
        model.state = json["state"].boolValue
        model.preClose = json["close"].doubleValue
        model.max = json["max"].doubleValue
        model.min = json["min"].doubleValue
        for (_, jsonData): (String, JSON) in json["shares"] {
            let share = Share()
            share.amount = jsonData["amount"].doubleValue
            share.date = NSDate.toDate(jsonData["dt"].stringValue, format: "yyyy-MM-dd HH:mm:ss")
            share.price = jsonData["price"].doubleValue
            share.ratio = jsonData["ratio"].doubleValue
            share.volume = jsonData["volume"].doubleValue
            model.shares.append(share)
        }
        return model
    }
}

class Share: NSObject {
    var date: NSDate = NSDate()
    var price: Double = 0
    var volume: Double = 0
    var amount: Double = 0
    var ratio: Double = 0
}