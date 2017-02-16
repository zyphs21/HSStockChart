//
//  HSHighLight.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSHighLight: UIView {

    var theme: HSKLineTheme = HSKLineTheme()
    var pricePoint: CGPoint = CGPoint.zero
    var volumePoint: CGPoint = CGPoint.zero
    var isShowVolume: Bool = true
    var model: AnyObject?
    var maxPrice: CGFloat = 0
    var minPrice: CGFloat = 0
    var uperChartHeight: CGFloat {
        get {
            return theme.kLineChartHeightScale * self.frame.height
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
