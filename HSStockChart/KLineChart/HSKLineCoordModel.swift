//
//  HSKLineCoordModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit
import CoreGraphics

public class HSKLineCoordModel {

    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var ma5Point: CGPoint = .zero
    var ma10Point: CGPoint = .zero
    var ma20Point: CGPoint = .zero
    
    var volumeStartPoint: CGPoint = .zero
    var volumeEndPoint: CGPoint = .zero
    
    var candleFillColor: UIColor = UIColor.black
    var candleRect: CGRect = CGRect.zero
    
    var closeY: CGFloat = 0
    
    var isDrawAxis: Bool = false
}
