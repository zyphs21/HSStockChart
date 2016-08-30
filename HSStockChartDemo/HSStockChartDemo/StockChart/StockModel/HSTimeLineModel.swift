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
            share.date = NSDate.toDate(jsonData["dt"].stringValue)
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