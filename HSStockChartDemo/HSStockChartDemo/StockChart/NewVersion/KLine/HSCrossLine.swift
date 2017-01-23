//
//  HSCrossLine.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/22.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSCrossLine: HSBasicBrush {
    
    var context: CGContext!
    var leftEdgeX: CGFloat!
    var showContentWidth: CGFloat!
    var theme: HSKLineTheme!
    
    init(frame: CGRect, context: CGContext, theme: HSKLineTheme) {
        super.init(frame: frame)
        
        self.context = context
        self.theme = theme
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func draw(pricePoint: CGPoint, volumePoint: CGPoint, leftEdgeX: CGFloat, model: HSKLineModel, contentWidth: CGFloat) {
        
        self.leftEdgeX = leftEdgeX
        self.showContentWidth = contentWidth
        
        drawLongPressHighlight(context, pricePoint: pricePoint, volumePoint: volumePoint, value: model)
        drawMALabel(context, entity: model)
    }
    

    
    /// 画出长按的十字线及标记
    ///
    /// - Parameters:
    ///   - context: CGContext
    ///   - pricePoint: 收盘价所在点
    ///   - volumePoint: 交易量所在的点
    ///   - value: HSKLineModel
    ///   - isShowVolume: 是否显示交易量图的标记线
    func drawLongPressHighlight(_ context: CGContext, pricePoint: CGPoint, volumePoint: CGPoint, value: AnyObject, isShowVolume: Bool = true) {
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerStr = ""
        var volumeMarkerString = ""
        
        if value.isKind(of: HSKLineModel.self) {
            let entity = value as! HSKLineModel
            rightMarkerStr = entity.close.toStringWithFormat(".2")
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            leftMarkerString = entity.rate.toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else{
            return
        }
        
        // 交叉线
        self.drawline(context, startPoint: CGPoint(x: pricePoint.x, y: 0), stopPoint: CGPoint(x: pricePoint.x, y: self.frame.height), color: theme.crossLineColor, lineWidth: theme.lineWidth)
        self.drawline(context, startPoint: CGPoint(x: 0, y: pricePoint.y), stopPoint: CGPoint(x: frame.width, y: pricePoint.y), color: theme.crossLineColor, lineWidth: theme.lineWidth)
        
        if isShowVolume {
            // 标记交易量的竖线
            context.beginPath()
            context.move(to: CGPoint(x: 0, y: volumePoint.y))
            context.addLine(to: CGPoint(x: frame.width, y: volumePoint.y))
            context.strokePath()
        }
        
        // 交叉点
        let radius:CGFloat = 3.0
        context.setFillColor(theme.crossLineColor.cgColor)
        context.fillEllipse(in: CGRect(x: pricePoint.x-(radius/2.0), y: pricePoint.y-(radius/2.0), width: radius, height: radius))
        
        
        // 标记标签
        
        let leftMarkerStringAttribute = NSMutableAttributedString(string: leftMarkerString, attributes: theme.highlightAttribute)
        let bottomMarkerStringAttribute = NSMutableAttributedString(string: bottomMarkerString, attributes: theme.highlightAttribute)
        let rightMarkerStringAttribute = NSMutableAttributedString(string: rightMarkerStr, attributes: theme.highlightAttribute)
        let volumeMarkerStringAttribute = NSMutableAttributedString(string: volumeMarkerString, attributes: theme.highlightAttribute)
        
        let leftMarkerStringAttributeSize = leftMarkerStringAttribute.size()
        let bottomMarkerStringAttributeSize = bottomMarkerStringAttribute.size()
        let rightMarkerStringAttributeSize = rightMarkerStringAttribute.size()
        let volumeMarkerStringAttributeSize = volumeMarkerStringAttribute.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        // 左标签
        labelX = leftEdgeX
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: leftMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        // 右标签
        labelX = leftEdgeX + self.showContentWidth - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        // 底部时间标签
        let maxX = self.frame.width - bottomMarkerStringAttributeSize.width
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = self.frame.height * theme.kLineChartHeightScale
        if labelX - self.frame.width > maxX {
            labelX = leftEdgeX + self.showContentWidth - bottomMarkerStringAttributeSize.width
            
        } else if labelX < leftEdgeX {
            labelX = leftEdgeX
        }
        self.drawLabel(context,
                       attributesText: bottomMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        
        if isShowVolume {
            // 交易量右标签
            let maxY = self.frame.height - volumeMarkerStringAttributeSize.height
            labelX = leftEdgeX + self.showContentWidth - volumeMarkerStringAttributeSize.width
            labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
            labelY = labelY > maxY ? maxY : labelY
            self.drawLabel(context,
                           attributesText: volumeMarkerStringAttribute,
                           rect: CGRect(x: labelX, y: labelY, width: volumeMarkerStringAttributeSize.width, height: volumeMarkerStringAttributeSize.height))
        }
    }
    
    
    /// 画长按后显示在左上角的 ma 值
    ///
    /// - Parameters:
    ///   - context: CGContext
    ///   - entity: HSKLineModel
    func drawMALabel(_ context: CGContext, entity: HSKLineModel) {
        
        let space:CGFloat = 5.0
        var startPoint = CGPoint(x: self.leftEdgeX + space, y: 0)
        
        let recoverAttribute = NSMutableAttributedString(string: "不复权", attributes: self.theme.annotationLabelAttribute)
        let recoverSize = recoverAttribute.size()
        self.drawLabel(context, attributesText: recoverAttribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: recoverSize.width, height: recoverSize.height))
        
        startPoint.x += recoverSize.width + space
        let ma5 = "MA5: " + entity.ma5.toStringWithFormat(".2")
        let ma5Attribute = NSMutableAttributedString(string: ma5 , attributes: getLabelAttribute(theme.ma5Color, backgroundColor: UIColor.white, fontSize: 8))
        let ma5Size = ma5Attribute.size()
        self.drawLabel(context, attributesText: ma5Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma5Size.width, height: ma5Size.height))
        
        startPoint.x += ma5Size.width + space
        let ma10 = "MA10: " + entity.ma10.toStringWithFormat(".2")
        let ma10Attribute = NSMutableAttributedString(string: ma10 , attributes: getLabelAttribute(theme.ma10Color, backgroundColor: UIColor.white, fontSize: 8))
        let ma10Size = ma10Attribute.size()
        self.drawLabel(context, attributesText: ma10Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma10Size.width, height: ma10Size.height))
        
        startPoint.x += ma10Size.width + space
        let ma20 = "MA20: " + entity.ma20.toStringWithFormat(".2")
        let ma20Attribute = NSMutableAttributedString(string: ma20 , attributes: getLabelAttribute(theme.ma20Color, backgroundColor: UIColor.white, fontSize: 8))
        let ma20Size = ma20Attribute.size()
        self.drawLabel(context, attributesText: ma20Attribute, rect: CGRect(x: startPoint.x, y: startPoint.y, width: ma20Size.width, height: ma20Size.height))
    }
}
