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
//    var pricePoint: CGPoint = CGPoint.zero
//    var volumePoint: CGPoint = CGPoint.zero
//    var isShowVolume: Bool = true
//    var model: AnyObject?
//    var maxPrice: CGFloat = 0
//    var minPrice: CGFloat = 0
    
    var rrLabel: UILabel!
    var volLabel: UILabel!
    var ma5: UILabel!
    var ma10: UILabel!
    var ma20: UILabel!
    var maxPLabel: UILabel!
    var minPLabel: UILabel!
    var midPLabel: UILabel!
    var maxVolLabel: UILabel!
    
    var corssLineLayer = CAShapeLayer()
    var volMarkLayer = CATextLayer()
    var leftMarkLayer = CATextLayer()
    var rightMarkLayer = CATextLayer()
    var bottomMarkLayer = CATextLayer()

//    var leftTLayer = CATextLayer()
//    var volTLayer = CATextLayer()
//    var ma5TextLayer = CATextLayer()
//    var ma10TextLayer = CATextLayer()
//    var ma20TextLayer = CATextLayer()
//    
//    var maxPriceTextLayer = CATextLayer()
//    var minPriceTextLayer = CATextLayer()
//    var midPriceTextLayer = CATextLayer()
//    var maxVolTextLayer = CATextLayer()
    
    var uperChartHeight: CGFloat {
        get {
            return theme.kLineChartHeightScale * self.frame.height
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        maxPLabel = initLabel(text: "0.0", color: UIColor(rgba: "#8695a6"), size: 9)
        minPLabel = initLabel(text: "0.0", color: UIColor(rgba: "#8695a6"), size: 9)
        midPLabel = initLabel(text: "0.0", color: UIColor(rgba: "#8695a6"), size: 9)
        maxVolLabel = initLabel(text: "0.0", color: UIColor(rgba: "#8695a6"), size: 9)
        rrLabel = initLabel(text: "不复权", color: UIColor(rgba: "#8695a6"), size: 9)
        volLabel = initLabel(text: "成交量", color: UIColor(rgba: "#8695a6"), size: 9)
        
        addSubview(maxPLabel)
        addSubview(minPLabel)
        addSubview(midPLabel)
        addSubview(maxVolLabel)
        addSubview(rrLabel)
        addSubview(volLabel)
        
        maxPLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(theme.viewMinYGap)
        }
        minPLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(uperChartHeight - theme.viewMinYGap)
        }
        midPLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(uperChartHeight / 2)
        }
        maxVolLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(uperChartHeight + theme.xAxisHeitht)
        }
        rrLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(5)
            make.top.equalTo(self)
        }
        volLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(5)
            make.top.equalTo(uperChartHeight + theme.xAxisHeitht)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            // 交给下一层级的view响应事件（解决该view在scrollView上面到时scrollView无法滚动问题）
            return nil
        }
        return view
    }
    
    func initLabel(text: String, color: UIColor, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: size)
        
        return label
    }
    
    func configureAxis(max: CGFloat, min: CGFloat, maxVol: CGFloat) {
        let maxPriceStr = max.toStringWithFormat(".2")
        let minPriceStr = min.toStringWithFormat(".2")
        let midPriceStr = ((max + min) / 2).toStringWithFormat(".2")
        maxPLabel.text = maxPriceStr
        minPLabel.text = minPriceStr
        midPLabel.text = midPriceStr
    }
    
    func clearCrossLine() {
        corssLineLayer.removeFromSuperlayer()
        leftMarkLayer.removeFromSuperlayer()
        rightMarkLayer.removeFromSuperlayer()
        bottomMarkLayer.removeFromSuperlayer()
        volMarkLayer.removeFromSuperlayer()
    }
    
    func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?, isShowVolume: Bool = true) {
        clearCrossLine()
        
        var leftMarkerString = ""
        var bottomMarkerString = ""
        var rightMarkerString = ""
        var volumeMarkerString = ""
        
        guard let model = model else { return }
        
        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
            rightMarkerString = entity.close.toStringWithFormat(".2")
            bottomMarkerString = entity.date.toDate("yyyyMMddHHmmss")?.toString("MM-dd") ?? ""
            leftMarkerString = entity.rate.toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
            rightMarkerString = entity.price.toStringWithFormat(".2")
            bottomMarkerString = entity.time
            leftMarkerString = (entity.rate * 100).toPercentFormat()
            volumeMarkerString = entity.volume.toStringWithFormat(".2")
            
        } else{
            return
        }
        
        let linePath = UIBezierPath()
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.maxY))

        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))
        
        if isShowVolume {
            // 标记交易量的横线
            linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
            linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))
        }
        
        // 交叉点
//        linePath.addArc(withCenter: pricePoint, radius: 3, startAngle: 0, endAngle: 180, clockwise: true)
        
        corssLineLayer.lineWidth = theme.lineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath
        
        // 标记标签
        
        let leftMarkerStringAttribute = NSMutableAttributedString(string: leftMarkerString, attributes: theme.highlightAttribute)
        let bottomMarkerStringAttribute = NSMutableAttributedString(string: bottomMarkerString, attributes: theme.highlightAttribute)
        let rightMarkerStringAttribute = NSMutableAttributedString(string: rightMarkerString, attributes: theme.highlightAttribute)
        let volumeMarkerStringAttribute = NSMutableAttributedString(string: volumeMarkerString, attributes: theme.highlightAttribute)
        
        let leftMarkerStringAttributeSize = leftMarkerStringAttribute.size()
        let bottomMarkerStringAttributeSize = bottomMarkerStringAttribute.size()
        let rightMarkerStringAttributeSize = rightMarkerStringAttribute.size()
        let volumeMarkerStringAttributeSize = volumeMarkerStringAttribute.size()
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        // 左标签
        labelX = frame.minX
        labelY = pricePoint.y - leftMarkerStringAttributeSize.height / 2.0
        leftMarkLayer = getTextLayer(text: leftMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: leftMarkerStringAttributeSize.width, height: leftMarkerStringAttributeSize.height))
        
        // 右标签
        labelX = frame.maxX - rightMarkerStringAttributeSize.width
        labelY = pricePoint.y - rightMarkerStringAttributeSize.height / 2.0
        rightMarkLayer = getTextLayer(text: rightMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: rightMarkerStringAttributeSize.width, height: rightMarkerStringAttributeSize.height))
        
        // 底部时间标签
        let maxX = frame.maxX - bottomMarkerStringAttributeSize.width
        labelX = pricePoint.x - bottomMarkerStringAttributeSize.width / 2.0
        labelY = frame.height * theme.uperChartHeightScale
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkerStringAttributeSize.width
            
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        bottomMarkLayer = getTextLayer(text: bottomMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: bottomMarkerStringAttributeSize.width, height: bottomMarkerStringAttributeSize.height))
        
        
        if isShowVolume {
            // 交易量右标签
            let maxY = frame.maxY - volumeMarkerStringAttributeSize.height
            labelX = frame.maxX - volumeMarkerStringAttributeSize.width
            labelY = volumePoint.y - volumeMarkerStringAttributeSize.height / 2.0
            labelY = labelY > maxY ? maxY : labelY
            volMarkLayer = getTextLayer(text: volumeMarkerString, foregroundColor: UIColor.white, backgroundColor: UIColor(rgba: "#8695a6"), frame: CGRect(x: labelX, y: labelY, width: volumeMarkerStringAttributeSize.width, height: volumeMarkerStringAttributeSize.height))
        }
        
        self.layer.addSublayer(corssLineLayer)
        self.layer.addSublayer(leftMarkLayer)
        self.layer.addSublayer(rightMarkLayer)
        self.layer.addSublayer(bottomMarkLayer)
        self.layer.addSublayer(volMarkLayer)
    }
    
    func getTextLayer(text: String, foregroundColor: UIColor, backgroundColor: UIColor, frame: CGRect) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = 10
        textLayer.foregroundColor = foregroundColor.cgColor // UIColor(rgba: "#8695a6")
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.truncationMode = kCATruncationEnd
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }

}
