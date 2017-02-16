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
    
    var leftTLayer = CATextLayer()
    var volTLayer = CATextLayer()
    var ma5TextLayer = CATextLayer()
    var ma10TextLayer = CATextLayer()
    var ma20TextLayer = CATextLayer()
    
    var maxPriceTextLayer = CATextLayer()
    var minPriceTextLayer = CATextLayer()
    var midPriceTextLayer = CATextLayer()
    var maxVolTextLayer = CATextLayer()
    
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
    
    func addLabelTextLayer() {
        
    }
    
    func getTextLayer(text: String, color: UIColor, frame: CGRect) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = 10
        textLayer.foregroundColor = color.cgColor // UIColor(rgba: "#8695a6")
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.truncationMode = kCATruncationEnd
        textLayer.contentsScale = UIScreen.main.scale
    }

}
