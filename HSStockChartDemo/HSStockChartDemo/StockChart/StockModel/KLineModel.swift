//
//  KLineModel.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import ObjectMapper


public class KLineMessage:Mappable{
    public var message : [KLineModel]?
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        message <- map["message"]
    }
}

public class KLineModel: Mappable {
    public var dt: String?
    public var tick: String?
    public var open: Double?
    public var close: Double?
    public var high: Double?
    public var low: Double?
    public var inc: Double?
    public var vol: Double?
    
    public var ma: MAModel?

    public init(){
        
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        dt <- map["dt"]
        tick <- map["tick"]
        open <- map["open"]
        close <- map["close"]
        high <- map["high"]
        low <- map["low"]
        inc <- map["inc"]
        vol <- map["vol"]
        ma <- map["ma"]
        
    }
}

public class MAModel:Mappable{
    public var MA5:Double?
    public var MA10:Double?
    public var MA20:Double?
    
    public init(){
        
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        MA5 <- map["MA5"]
        MA10 <- map["MA10"]
        MA20 <- map["MA20"]
    }
}
