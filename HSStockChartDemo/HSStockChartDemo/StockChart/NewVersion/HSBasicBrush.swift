//
//  HSBasicBrush.swift
//  dingdong
//
//  Created by Hanson on 2017/1/23.
//  Copyright © 2017年 vanyun. All rights reserved.
//

import UIKit

/// 基本画笔类
class HSBasicBrush: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 画标签
    ///
    /// - Parameters:
    ///   - context: CGContext
    ///   - attributesText: 标签字符
    ///   - rect: 标签所在区域
    func drawLabel(_ context: CGContext, attributesText: NSAttributedString, rect: CGRect) {
        context.setFillColor(UIColor.clear.cgColor)
        attributesText.draw(in: rect)
    }
    
    
    /// 画线
    ///
    /// - Parameters:
    ///   - context: CGContext
    ///   - startPoint: 线段起始点
    ///   - stopPoint: 线段终点
    ///   - color: 线段颜色
    ///   - lineWidth: 线段宽度
    ///   - isDashLine: 是否画为虚线
    func drawline(_ context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, color: UIColor, lineWidth: CGFloat, isDashLine: Bool = false) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.beginPath()
        context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context.addLine(to: CGPoint(x: stopPoint.x, y: stopPoint.y))
        if isDashLine {
            let arr: [CGFloat] = [6, 3]
            context.setLineDash(phase: 0, lengths: arr)
        }
        context.strokePath()
        context.restoreGState()
    }
    
    
    /// 画 Y 轴上的标签
    ///
    /// - Parameters:
    ///   - context: CGContext
    ///   - str: 显示的字符
    ///   - labelAttribute: 字符属性
    ///   - xAxis: X 坐标点
    ///   - yAxis: Y 左边点
    ///   - isLeft: 是否画在左边的 Y 轴
    func drawYAxisLabel(_ context: CGContext, str: String, labelAttribute: [String : NSObject], xAxis: CGFloat, yAxis: CGFloat, isLeft: Bool) {
        
        let valueAttributedString = NSMutableAttributedString(string: str, attributes: labelAttribute)
        let valueAttributedStringSize = valueAttributedString.size()
        let labelInLineCenterSize = valueAttributedStringSize.height/2.0
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = xAxis + yAxisLabelEdgeInset
            
        } else {
            labelX = xAxis - valueAttributedStringSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = yAxis - labelInLineCenterSize
        
        self.drawLabel(context, attributesText: valueAttributedString, rect: CGRect(x: labelX, y: labelY, width: valueAttributedStringSize.width, height: valueAttributedStringSize.height))
    }
    
    
    /// 构建一个字符属性
    ///
    /// - Parameters:
    ///   - foregroundColor: 前置颜色
    ///   - backgroundColor: 背景色
    ///   - fontSize: 字体大小
    /// - Returns: 字符属性
    func getLabelAttribute(_ foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> [String: AnyObject] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: foregroundColor]
    }
}
