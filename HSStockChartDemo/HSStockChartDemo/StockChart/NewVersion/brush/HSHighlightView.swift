//
//  HSCrossLines.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/15.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSHighlightView: HSBasicBrush {

    var theme: HSKLineTheme = HSKLineTheme()
    var pricePoint: CGPoint = CGPoint.zero
    var volumePoint: CGPoint = CGPoint.zero
    var isShowVolume: Bool = true
    var model: AnyObject?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        toDraw(rect: rect, context: context)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            // 交给下一层级的view响应事件（解决该view在scrollView上面到时scrollView无法滚动问题）
            return nil
        }
        return view
    }
    
    func drawLongPressHighlight(pricePoint: CGPoint, volumePoint: CGPoint, value: AnyObject?, isShowVolume: Bool = true) {
        self.pricePoint = pricePoint
        self.volumePoint = volumePoint
        self.model = value
        self.isShowVolume = isShowVolume
        
        setNeedsDisplay()
    }
    
    fileprivate func toDraw(rect: CGRect, context: CGContext) {
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerStr = ""
        var volumeMarkerString = ""
        
        guard let model = model else { return }
        
        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
            rightMarkerStr = entity.close.toStringWithFormat(".2")
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            leftMarkerString = entity.rate.toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            drawMALabel(context, entity: entity)
            
        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
            rightMarkerStr = entity.price.toStringWithFormat(".2")
            bottomMarkerString = entity.time
            leftMarkerString = (entity.rate * 100).toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else{
            return
        }
        
        // 交叉线
        // 竖线
        self.drawline(context, startPoint: CGPoint(x: pricePoint.x, y: 0), stopPoint: CGPoint(x: pricePoint.x, y: rect.maxY), color: theme.crossLineColor, lineWidth: theme.lineWidth)
        // 横线
        self.drawline(context, startPoint: CGPoint(x: rect.minX, y: pricePoint.y), stopPoint: CGPoint(x: rect.maxX, y: pricePoint.y), color: theme.crossLineColor, lineWidth: theme.lineWidth)
        
        if isShowVolume {
            // 标记交易量的横线
            self.drawline(context, startPoint: CGPoint(x: rect.minX, y: volumePoint.y), stopPoint: CGPoint(x: rect.maxX, y: volumePoint.y), color: theme.crossLineColor, lineWidth: theme.lineWidth)
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
        labelX = rect.minX
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: leftMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        // 右标签
        labelX = rect.maxX - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        self.drawLabel(context,
                       attributesText: rightMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        // 底部时间标签
        let maxX = rect.maxX - bottomMarkerStringAttributeSize.width
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = rect.maxX - bottomMarkerStringAttributeSize.width
            
        } else if labelX < rect.minX {
            labelX = rect.minX
        }
        self.drawLabel(context,
                       attributesText: bottomMarkerStringAttribute,
                       rect: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        
        if isShowVolume {
            // 交易量右标签
            let maxY = rect.maxY - volumeMarkerStringAttributeSize.height
            labelX = rect.maxX - volumeMarkerStringAttributeSize.width
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
    fileprivate func drawMALabel(_ context: CGContext, entity: HSKLineModel) {
        
        let space:CGFloat = 5.0
        var startPoint = CGPoint(x: space, y: 0)
        
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
