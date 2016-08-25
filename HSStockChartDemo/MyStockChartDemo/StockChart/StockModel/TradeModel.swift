//
//  PriceModel.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/16.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import ObjectMapper

public class TradeModel: Mappable {
    public var bp1:String?
    public var bc1:String?
    public var bp2:String?
    public var bc2:String?
    public var bp3:String?
    public var bc3:String?
    public var bp4:String?
    public var bc4:String?
    public var bp5:String?
    public var bc5:String?
    
    public var sp1:String?
    public var sc1:String?
    public var sp2:String?
    public var sc2:String?
    public var sp3:String?
    public var sc3:String?
    public var sp4:String?
    public var sc4:String?
    public var sp5:String?
    public var sc5:String?
    
    
    
    public init(){
        
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        bp1 <- map["bp1"]
        bc1 <- map["bc1"]
        bp2 <- map["bp2"]
        bc2 <- map["bc2"]
        bp3 <- map["bp3"]
        bc3 <- map["bc3"]
        bp4 <- map["bp4"]
        bc4 <- map["bc4"]
        bp5 <- map["bp5"]
        bc5 <- map["bc5"]
        
        sp1 <- map["sp1"]
        sc1 <- map["sc1"]
        sp2 <- map["sp2"]
        sc2 <- map["sc2"]
        sp3 <- map["sp3"]
        sc3 <- map["sc3"]
        sp4 <- map["sp4"]
        sc4 <- map["sc4"]
        sp5 <- map["sp5"]
        sc5 <- map["sc5"]
    }
}