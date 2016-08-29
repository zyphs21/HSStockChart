//
//  HSKLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/29.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class HSKLineModel: NSObject {

    var date: String = ""
    var tick: String = ""
    var open: Double = 0
    var close: Double = 0
    var high: Double = 0
    var low: Double = 0
    var inc: Double = 0
    var vol: Double = 0
    var ma5: Double = 0
    var ma10: Double = 0
    var ma20: Double = 0
    
    class func createKLineModel(json: JSON) -> [HSKLineModel] {
        var models: [HSKLineModel] = []
        for (_, jsonData): (String, JSON) in json["message"] {
            let model = HSKLineModel()
            model.date = jsonData["dt"].stringValue
            model.tick = jsonData["tick"].stringValue
            model.open = jsonData["open"].doubleValue
            model.close = jsonData["close"].doubleValue
            model.high = jsonData["high"].doubleValue
            model.low = jsonData["low"].doubleValue
            model.inc = jsonData["inc"].doubleValue
            model.vol = jsonData["vol"].doubleValue
            model.ma5 = jsonData["ma"]["MA5"].doubleValue
            model.ma10 = jsonData["ma"]["MA10"].doubleValue
            model.ma20 = jsonData["ma"]["MA20"].doubleValue
            
            models.append(model)
        }
        return models
    }
}
