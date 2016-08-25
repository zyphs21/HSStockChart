//
//  KLineEntity.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/22.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import UIKit

class KLineEntity: NSObject {
    var open: CGFloat = 0
    var high: CGFloat = 0
    var low: CGFloat = 0
    var close: CGFloat = 0
    var index: Int = 0
    var date: String = ""
    
    var volume: CGFloat = 0
    var ma5: CGFloat = 0
    var ma10: CGFloat = 0
    var ma20: CGFloat = 0
    var preClosePx: CGFloat = 0
    var rate: CGFloat = 0
}