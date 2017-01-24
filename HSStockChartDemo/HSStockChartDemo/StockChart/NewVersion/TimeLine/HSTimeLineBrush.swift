//
//  HSTimeLine.swift
//  dingdong
//
//  Created by Hanson on 2017/1/19.
//  Copyright © 2017年 vanyun. All rights reserved.
//

import UIKit

class HSTimeLineBrush: HSBasicBrush {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(context: CGContext, timeLineModels: [HSTimeLineModel], positionModels: [HSTimeLineCoordModel], theme: HSTimeLineTheme) {

        let fillPath = CGMutablePath()
        for index in 0 ..< positionModels.count {
            if index > 0 {
                //画分时线
                let prePricePoint = positionModels[index - 1].pricePoint
                self.drawline(context,
                              startPoint: prePricePoint,
                              stopPoint: positionModels[index].pricePoint,
                              color: theme.priceLineCorlor,
                              lineWidth: theme.lineWidth)
                
                //画均线
                let preAvgPoint = positionModels[index - 1].avgPoint
                self.drawline(context,
                              startPoint: preAvgPoint,
                              stopPoint: positionModels[index].avgPoint,
                              color: theme.avgLineCorlor,
                              lineWidth: theme.lineWidth)
            }
            //设置成交量的颜色
            var strokeColor = UIColor.clear
            let preClosePx = timeLineModels.first?.preClosePx ?? 0
            let comparePrice: CGFloat = (index == 0) ? preClosePx : timeLineModels[index - 1].price
            if timeLineModels[index].price > comparePrice {
                strokeColor = theme.volumeRiseColor
                
            } else if timeLineModels[index].price < comparePrice {
                strokeColor = theme.volumeFallColor
                
            } else {
                strokeColor = theme.volumeTieColor
            }
            
            
            // 为填充渐变颜色，包围图形
            if index == 1 {
                fillPath.move(to: CGPoint(x: positionModels[0].pricePoint.x, y: theme.uperChartHeightScale * frame.height))
                fillPath.addLine(to: positionModels[0].pricePoint)
            } else if index == 0 {
                
            } else {
                fillPath.addLine(to: positionModels[index].pricePoint)
            }
            if (positionModels.count - 1) == index {
                fillPath.addLine(to: positionModels[index].pricePoint)
                fillPath.addLine(to: CGPoint(x: positionModels[index].pricePoint.x, y: theme.uperChartHeightScale * frame.height))
                fillPath.closeSubpath()
            }
            
            
            // 画成交量图
            self.drawline(context,
                          startPoint: positionModels[index].volumeStartPoint,
                          stopPoint: positionModels[index].volumeEndPoint,
                          color: strokeColor,
                          lineWidth: theme.volumeWidth)
        }
        self.drawLinearGradient(context, path: fillPath, alpha: theme.fillAlpha, startColor: theme.fillStartColor.cgColor, endColor: theme.fillStopColor.cgColor)
    }
    
    // 画柱形
    func drawColumnRect(_ context: CGContext, rect: CGRect, color: UIColor) {
//        if ((rect.origin.x + rect.size.width) > self.contentRight) {
//            return
//        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    // 画渐变色
    func drawLinearGradient(_ context: CGContext, path: CGPath, alpha: CGFloat, startColor: CGColor, endColor: CGColor) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [startColor, endColor]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let pathRect = path.boundingBox
        
        //具体方向可根据需求修改
        let startPoint = CGPoint(x: pathRect.midX, y: pathRect.minY)
        let endPoint = CGPoint(x: pathRect.midX, y: pathRect.maxY)
        
        context.saveGState()
        context.addPath(path)
        context.clip()
        context.setAlpha(0.5)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        context.restoreGState()
    }
    
    
//    // 分时线最后一个点动画显示
//    if Date().isTradingTime() {
//    if self.enableAnimatePoint {
//    if (i == data.count - 1) {
//    // let xPosition = contentLeft + self.volumeWidth * CGFloat(data[i].numOfTime) - self.volumeWidth / 2
//    self.animatePoint.frame = CGRect(x: startX - layerWidth/2, y: yPrice - layerWidth/2, width: layerWidth, height: layerWidth)
//    }
//    }
//    }
    
    func breathingLightAnimate(_ time:Double) -> CAAnimationGroup {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 3
        scaleAnimation.autoreverses = false
        scaleAnimation.isRemovedOnCompletion = true
        scaleAnimation.repeatCount = MAXFLOAT
        scaleAnimation.duration = time
        
        let opacityAnimation = CABasicAnimation(keyPath:"opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0
        opacityAnimation.autoreverses = false
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.repeatCount = MAXFLOAT
        opacityAnimation.duration = time
        opacityAnimation.fillMode = kCAFillModeForwards
        
        let group = CAAnimationGroup()
        group.duration = time
        group.autoreverses = false
        group.isRemovedOnCompletion = true
        group.fillMode = kCAFillModeForwards
        group.animations = [scaleAnimation,opacityAnimation]
        group.repeatCount = MAXFLOAT
        
        return group
    }
    
    lazy var animatePoint: CALayer = {
        let animatePoint = CALayer()
        self.layer.addSublayer(animatePoint)
        animatePoint.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        animatePoint.cornerRadius = 2
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        layer.backgroundColor = UIColor(rgba: "#0095ff").cgColor
        layer.cornerRadius = 2
        layer.add(self.breathingLightAnimate(2), forKey: nil)
        
        animatePoint.addSublayer(layer)
        
        return animatePoint
    }()

}
