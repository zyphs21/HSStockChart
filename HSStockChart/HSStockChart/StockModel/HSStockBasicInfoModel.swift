//
//  HSStockBasicInfoModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/5.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON

class HSStockBasicInfoModel: NSObject {

    var stockName: String = ""
    var preClosePrice: CGFloat = 0
    
    class func getStockBasicInfoModel(_ json: JSON) -> HSStockBasicInfoModel {
        let model = HSStockBasicInfoModel()
        model.stockName = json["name"].stringValue
        model.preClosePrice = CGFloat(json["last_close"].doubleValue)
        
        return model
    }
}
