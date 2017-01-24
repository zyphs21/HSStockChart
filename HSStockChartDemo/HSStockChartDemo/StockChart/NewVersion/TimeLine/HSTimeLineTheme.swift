//
//  HSTimeLineTheme.swift
//  dingdong
//
//  Created by Hanson on 2017/1/19.
//  Copyright © 2017年 vanyun. All rights reserved.
//

import UIKit

class HSTimeLineTheme: HSBasicTheme {

    var highlightLineWidth : CGFloat = 0.8
    var fillAlpha:CGFloat = 0.5
    var drawFilledEnabled = true
    var volumeWidth: CGFloat = 0
    
    var gridBackgroundColor = UIColor.white
    var borderColor = UIColor(rgba: "#e4e4e4")
    var borderWidth: CGFloat = 1
    
    var xAxisHeitht: CGFloat = 30
    
    var viewMinYGap: CGFloat = 15
    var volumeMinGap: CGFloat = 10
    
    var highlightLineColor = UIColor(rgba: "#546679")
    var priceLineCorlor = UIColor(rgba: "#0095ff")
    var avgLineCorlor = UIColor(rgba: "#ffc004")
    var volumeRiseColor = UIColor(rgba: "#f24957")
    var volumeFallColor = UIColor(rgba: "#1dbf60")
    var volumeTieColor = UIColor(rgba: "#aaaaaa")
    var fillStartColor = UIColor(rgba: "#e3efff")
    var fillStopColor = UIColor(rgba: "#e3efff")
    
}
