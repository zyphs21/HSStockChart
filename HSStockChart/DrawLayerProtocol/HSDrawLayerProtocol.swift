//
//  HSDrawLayerProtocol.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

public enum HSChartType: Int {
    case timeLineForDay
    case timeLineForFiveday
    case kLineForMinute
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
}

protocol HSDrawLayerProtocol {
    
    var theme: HSTimeLineStyle { get }
    
    func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimate: Bool) -> CAShapeLayer
    
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> CATextLayer
        
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?, chartType: HSChartType) -> CAShapeLayer
    
    
}

extension HSChartType {
    var dateFormatString: String {
        switch self {
        case .kLineForMinute, .timeLineForDay:
            return "HH:mm"
        case .kLineForDay, .kLineForWeek, .kLineForMonth,
             .timeLineForFiveday:
            return "MM-dd"
        }
    }
}

extension HSDrawLayerProtocol {
    
    var theme: HSTimeLineStyle {
        return HSTimeLineStyle()
    }
    
    func drawLine(lineWidth: CGFloat,
                  startPoint: CGPoint,
                  endPoint: CGPoint,
                  strokeColor: UIColor,
                  fillColor: UIColor,
                  isDash: Bool = false,
                  isAnimate: Bool = false) -> CAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = fillColor.cgColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }
        
        if isAnimate {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        
        return lineLayer
    }
    
    func drawTextLayer(frame: CGRect,
                       text: String,
                       foregroundColor: UIColor,
                       backgroundColor: UIColor = UIColor.clear,
                       fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    
    /// 获取纵轴的标签图层
    func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool) -> CATextLayer {
        let textSize = theme.getTextSize(text: text)
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = yAxisLabelEdgeInset
        } else {
            labelX = frame.width - textSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = y - textSize.height / 2.0
        
        let yMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height),
                                       text: text,
                                       foregroundColor: theme.textColor)
        
        return yMarkLayer
    }
    
    /// 获取长按显示的十字线及其标签图层
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?, chartType: HSChartType) -> CAShapeLayer {
        let highlightLayer = CAShapeLayer()
        let corssLineLayer = CAShapeLayer()
        var volMarkLayer = CATextLayer()
        var yAxisMarkLayer = CATextLayer()
        var bottomMarkLayer = CATextLayer()
        var bottomMarkerString = ""
        var yAxisMarkString = ""
        var volumeMarkerString = ""

        guard let model = model else { return highlightLayer }

        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
            yAxisMarkString = entity.close.hschart.toStringWithFormat(".2")
            bottomMarkerString = entity.date.hschart.toDate("yyyyMMddHHmmss")?.hschart.toString(chartType.dateFormatString) ?? ""
            volumeMarkerString = entity.volume.hschart.toStringWithFormat(".2")

        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
            yAxisMarkString = entity.price.hschart.toStringWithFormat(".2")
            bottomMarkerString = entity.time
            volumeMarkerString = entity.volume.hschart.toStringWithFormat(".2")

        } else{
            return highlightLayer
        }

        let linePath = UIBezierPath()
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.height))

        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))

        // 标记交易量的横线
        if(volumePoint.y > 0)
        {
            linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
            linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))
        }

        // 交叉点
        //linePath.addArc(withCenter: pricePoint, radius: 3, startAngle: 0, endAngle: 180, clockwise: true)

        corssLineLayer.lineWidth = theme.lineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath

        // 标记标签大小
        let yAxisMarkSize = theme.getTextSize(text: yAxisMarkString)
        let volMarkSize = theme.getTextSize(text: volumeMarkerString)
        let bottomMarkSize = theme.getTextSize(text: bottomMarkerString)

        var labelX: CGFloat = 0
        var labelY: CGFloat = 0

        // 纵坐标标签
        if pricePoint.x > frame.width / 2 {
            labelX = frame.minX
        } else {
            labelX = frame.maxX - yAxisMarkSize.width
        }
        labelY = pricePoint.y - yAxisMarkSize.height / 2.0
        yAxisMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: yAxisMarkSize.width, height: yAxisMarkSize.height),
                                       text: yAxisMarkString,
                                       foregroundColor: UIColor.white,
                                       backgroundColor: theme.textColor)

        // 底部时间标签
        let maxX = frame.maxX - bottomMarkSize.width
        labelX = pricePoint.x - bottomMarkSize.width / 2.0
        labelY = frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkSize.width
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        bottomMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: bottomMarkSize.height),
                                        text: bottomMarkerString,
                                        foregroundColor: UIColor.white,
                                        backgroundColor: theme.textColor)

        // 交易量右标签
        if(volumePoint.y > 0)
        {
            if pricePoint.x > frame.width / 2 {
                labelX = frame.minX
            } else {
                labelX = frame.maxX - volMarkSize.width
            }
            let maxY = frame.maxY - volMarkSize.height
            labelY = volumePoint.y - volMarkSize.height / 2.0
            labelY = labelY > maxY ? maxY : labelY
            volMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: volMarkSize.width, height: volMarkSize.height),
                                            text: volumeMarkerString,
                                            foregroundColor: UIColor.white,
                                            backgroundColor: theme.textColor)
        }

        highlightLayer.addSublayer(corssLineLayer)
        highlightLayer.addSublayer(yAxisMarkLayer)
        highlightLayer.addSublayer(bottomMarkLayer)
        if(volumePoint.y > 0)
        {
            highlightLayer.addSublayer(volMarkLayer)
        }
        
        return highlightLayer
    }
    
    func getTextSize(text: String, fontSize: CGFloat = 10, addOnWith: CGFloat = 5, addOnHeight: CGFloat = 0) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        let width = ceil(size.width) + addOnWith
        let height = ceil(size.height) + addOnWith
        
        return CGSize(width: width, height: height)
    }
}
