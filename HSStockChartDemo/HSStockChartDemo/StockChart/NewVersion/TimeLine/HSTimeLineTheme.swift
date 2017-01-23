//
//  HSTimeLineTheme.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/23.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSTimeLineTheme: NSObject {

    var highlightLineWidth : CGFloat = 0
    var highlightLineColor = UIColor(rgba: "#546679")
    var lineWidth : CGFloat = 1
    var priceLineCorlor = UIColor(rgba: "#0095ff")
    var avgLineCorlor = UIColor(rgba: "#ffc004")
    var volumeRiseColor = UIColor(rgba: "#f24957")
    var volumeFallColor = UIColor(rgba: "#1dbf60")
    var volumeTieColor = UIColor(rgba: "#aaaaaa")
    var drawFilledEnabled = true
    var fillStartColor = UIColor(rgba: "#e3efff")
    var fillStopColor = UIColor(rgba: "#e3efff")
    var fillAlpha:CGFloat = 0.5

}
