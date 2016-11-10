//
//  HSCandle.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/9.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSCandle: NSObject {

    var context: CGContext!
    var klineData: KLineEntity?
    var klineCoordinate: KLineCoordinate?
    var coordinateBottomY: CGFloat = 0
    
    var xAxisLabelAttribute = [NSFontAttributeName:UIFont.systemFont(ofSize: 10),
                               NSBackgroundColorAttributeName: UIColor.clear,
                               NSForegroundColorAttributeName: UIColor(rgba: "#8695a6")]
    
    init(context: CGContext) {
        super.init()
        
        self.context = context
    }
    
    // 绘制单个 K 线
    func drawCandle() {
        
        if let data = klineData, let coordinate = klineCoordinate {
            
            var strokeColor = UIColor.red
            
            if coordinate.openPoint.y < coordinate.closePoint.y {
                strokeColor = UIColor.green
            } else {
                strokeColor = UIColor.red
            }
            
            // 画开收盘
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(8)
            context.strokeLineSegments(between: [coordinate.openPoint, coordinate.closePoint])
            
            // 画最高最低影线
            context.setLineWidth(1)
            context.strokeLineSegments(between: [coordinate.highPoint, coordinate.lowPoint])
            
            // 画底部日期
            if let date = data.date.toDate("yyyy-MM-dd") {
                let dateStrAtt = NSMutableAttributedString(string: date.toString("yyyy-MM"), attributes: self.xAxisLabelAttribute)
                let dateStrAttSize = dateStrAtt.size()
                let dateX = coordinate.highPoint.x - (dateStrAttSize.width / 2)
                let dateY = coordinateBottomY + 2
                dateStrAtt.draw(in: CGRect(x: dateX, y: dateY, width: dateStrAtt.size().width, height: dateStrAtt.size().height))
            }
        }
    }
}
