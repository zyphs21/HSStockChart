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
    var open: CGFloat = 0
    var close: CGFloat = 0
    var high: CGFloat = 0
    var low: CGFloat = 0
    var volume: CGFloat = 0
    var ma5: CGFloat = 0
    var ma10: CGFloat = 0
    var ma20: CGFloat = 0
    var ma30: CGFloat = 0
    var diff: CGFloat = 0
    var dea: CGFloat = 0
    var macd: CGFloat = 0
    var rate: CGFloat = 0
    
    class func getKLineModelArray(_ json: JSON) -> [HSKLineModel] {
        var models = [HSKLineModel]()
        
        for (_, jsonData): (String, JSON) in json["data"] {
            let dict = Utils.getChartlist(fields: json["fields"].stringValue, data: jsonData.stringValue)!
            
            let model = HSKLineModel()
            // model.date = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("yyyyMMddHHmmss")
            // model.open = CGFloat(jsonData["open"].doubleValue)
            // model.close = CGFloat(jsonData["close"].doubleValue)
            // model.high = CGFloat(jsonData["high"].doubleValue)
            // model.low = CGFloat(jsonData["low"].doubleValue)
            // model.volume = CGFloat(jsonData["volume"].doubleValue)
            
//            model.ma5 = CGFloat(jsonData["ma5"].doubleValue)
//            model.ma10 = CGFloat(jsonData["ma10"].doubleValue)
//            model.ma20 = CGFloat(jsonData["ma20"].doubleValue)
//            model.ma30 = CGFloat(jsonData["ma30"].doubleValue)
            
//            model.diff = CGFloat(jsonData["dif"].doubleValue)
//            model.dea = CGFloat(jsonData["dea"].doubleValue)
//            model.macd = CGFloat(jsonData["macd"].doubleValue)
//            model.rate = CGFloat(jsonData["percent"].doubleValue)
            
            model.date = dict["date"]!
            model.open = CGFloat(Double(dict["open"]!)!)
            model.close = CGFloat(Double(dict["close"]!)!)
            model.high = CGFloat(Double(dict["high"]!)!)
            model.low = CGFloat(Double(dict["low"]!)!)
            model.volume = CGFloat(Double(dict["volume"]!)!)
            
            models.append(model)
        }
        return models
    }
    
//    class func xxx() {
//        let date = model.date
//        let close = String(jsonData["close"].doubleValue)
//        let open = String(jsonData["open"].doubleValue)
//        let high = String(jsonData["high"].doubleValue)
//        let low =  String(jsonData["low"].doubleValue)
//        let volume = String(jsonData["volume"].doubleValue)
//        let balance = String(jsonData["volume"].doubleValue * 10)
//        
//        let str = [date, close, open, high, low, volume, balance].joined(separator: "|")
//        print("\"\(str)\",")
//    }
}
