//
//  HSKLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/29.
//  Copyright © 2016年 hanson. All rights reserved.
//


import Foundation
import UIKit
import CoreGraphics

public class HSKLineModel {

    public var date: String = ""
    public var open: CGFloat = 0
    public var close: CGFloat = 0
    public var high: CGFloat = 0
    public var low: CGFloat = 0
    public var volume: CGFloat = 0
    public var ma5: CGFloat = 0
    public var ma10: CGFloat = 0
    public var ma20: CGFloat = 0
    public var ma30: CGFloat = 0
    public var diff: CGFloat = 0
    public var dea: CGFloat = 0
    public var macd: CGFloat = 0
    public var rate: CGFloat = 0

    public init() { }
}
