//
//  HSTimeLineBase.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/7/29.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSTimeLineBase: UIView {
    
    internal lazy var baseTheme: HSStockChartTheme = {
        var baseTheme = HSStockChartTheme()
        return baseTheme
    }()
    
    public dynamic var uperChartHeightScale: CGFloat {
        get { return baseTheme.uperChartHeightScale }
        set { baseTheme.uperChartHeightScale = newValue }
    }
    
    public dynamic var xAxisHeitht: CGFloat {
        get { return baseTheme.xAxisHeitht }
        set { baseTheme.xAxisHeitht = newValue }
    }
    
    public dynamic var viewMinYGap: CGFloat {
        get { return baseTheme.viewMinYGap }
        set { baseTheme.viewMinYGap = newValue }
    }
    
    public dynamic var volumeGap: CGFloat {
        get { return baseTheme.volumeGap }
        set { baseTheme.volumeGap = newValue }
    }
    
    public dynamic var ma5Color: UIColor {
        get { return baseTheme.ma5Color }
        set { baseTheme.ma5Color = newValue }
    }
    
    public dynamic var ma10Color: UIColor {
        get { return baseTheme.ma10Color }
        set { baseTheme.ma10Color = newValue }
    }
    
    public dynamic var ma20Color: UIColor {
        get { return baseTheme.ma20Color }
        set { baseTheme.ma20Color = newValue }
    }
    
    public dynamic var borderColor: UIColor {
        get { return baseTheme.borderColor }
        set { baseTheme.borderColor = newValue }
    }
    
    public dynamic var crossLineColor: UIColor {
        get { return baseTheme.crossLineColor }
        set { baseTheme.crossLineColor = newValue }
    }
    
    public dynamic var riseColor: UIColor {
        get { return baseTheme.riseColor }
        set { baseTheme.riseColor = newValue }
    }
    
    public dynamic var fallColor: UIColor {
        get { return baseTheme.fallColor }
        set { baseTheme.fallColor = newValue }
    }
    
    public dynamic var priceLineCorlor: UIColor {
        get { return baseTheme.priceLineCorlor }
        set { baseTheme.priceLineCorlor = newValue }
    }
    
    public dynamic var avgLineCorlor: UIColor {
        get { return baseTheme.avgLineCorlor }
        set { baseTheme.avgLineCorlor = newValue }
    }
    
    public dynamic var fillColor: UIColor {
        get { return baseTheme.fillColor }
        set { baseTheme.fillColor = newValue }
    }
    
}
