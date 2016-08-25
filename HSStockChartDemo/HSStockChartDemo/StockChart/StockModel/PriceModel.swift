//
//  PriceModel.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import ObjectMapper

public class PriceModel: Mappable{
    public var days:[String]?
    public var state:Bool?
    public var close:Double?
    public var max:Double?
    public var min:Double?
    public var shares:[ShareModel]?
    
    public init(){
        
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        days <- map["days"]
        state <- map["state"]
        close <- map["close"]
        max <- map["max"]
        min <- map["min"]
        shares <- map["shares"]
    }
    
}

public class ShareModel: Mappable{
    public var dt:NSDate?
    public var price:Double?
    public var volume:Double?
    public var amount:Double?
    public var ratio:Double?
    
    public init(){
        
    }
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        dt <- (map["dt"],CSFTransform())
        price <- map["price"]
        volume <- map["volume"]
        amount <- map["amount"]
        ratio <- map["ratio"]
    }
    
}

public class CSFTransform: TransformType {
    public typealias Object = NSDate
    public typealias JSON = Double
    
    public init() {}
    
    public func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let timeInt = value as? Double {
            return NSDate(timeIntervalSince1970: NSTimeInterval(timeInt))
        }else if let timeString = value as? String {
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.dateFromString(timeString)
            return date
        }
        return nil
    }
    
    public func transformToJSON(value: NSDate?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970)
        }
        return nil
    }
    
    public func transformToJSON(value: AnyObject?) -> Double? {
        if let _ = value as? String {
            
        }
        
        return nil
    }
}