//
//  Common.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import ObjectMapper

public let ScreenWidth = UIScreen.mainScreen().bounds.width

public let ScreenHeight = UIScreen.mainScreen().bounds.height

func readFile<T: Mappable>(name:String,ext:String) -> T {
    
    let path = NSBundle.mainBundle().pathForResource(name, ofType: ext)
    let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
    let model = Mapper<T>().map(text)
    return model!
}