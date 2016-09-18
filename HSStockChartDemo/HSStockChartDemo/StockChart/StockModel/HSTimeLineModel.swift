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
    
    var currentTime: String = ""
    var averagePirce: CGFloat = 0
    var price: CGFloat = 0
    var volume: CGFloat = 0
    var days: [String] = []
    
    class func getTimeLineModelArray(_ json: JSON) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.currentTime = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
            model.averagePirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        return modelArray
    }
}
