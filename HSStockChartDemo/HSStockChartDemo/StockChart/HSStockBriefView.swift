//
//  HSStockBriefView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/7.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSStockBriefView: UIView {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    weak var view: UIView!
    
    override func layoutSubviews() {
        view.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        view = instanceViewFromNib()
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func instanceViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func configureView(timeLineEntity: TimeLineEntity) {
        
        var labelColor: UIColor
        if timeLineEntity.rate < 0 {
            labelColor = UIColor.greenColor()
        } else if timeLineEntity.rate > 0 {
            labelColor = UIColor.redColor()
        } else {
            labelColor = UIColor.grayColor()
        }
        priceLabel.textColor = labelColor
        ratioLabel.textColor = labelColor
        
        priceLabel.text = timeLineEntity.price.toStringWithFormat("%.2f")
        ratioLabel.text = (timeLineEntity.rate * 100).toStringWithFormat("%.2f") + "%"
        timeLabel.text = timeLineEntity.currtTime
        volumeLabel.text = timeLineEntity.volume.toStringWithFormat("%.2f")
    }

}
