//
//  HSTimeLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/26.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import CoreGraphics

public class HSTimeLineModel {
    public var time: String = ""
    public var price: CGFloat = 0
    public var volume: CGFloat = 0
    public var days: [String] = []
    public var preClosePx: CGFloat = 0
    public var avgPirce: CGFloat = 0
    public var totalVolume: CGFloat = 0
    public var trade: CGFloat = 0
    public var rate: CGFloat = 0
    
    public init() { }
}
