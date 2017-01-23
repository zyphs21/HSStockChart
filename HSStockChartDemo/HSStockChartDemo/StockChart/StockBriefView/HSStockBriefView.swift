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
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func instanceViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func configureView(_ timeLineEntity: HSTimeLineModel) {
        
        var labelColor: UIColor
        if timeLineEntity.rate < 0 {
            labelColor = UIColor(rgba: "#1DBF60")
        } else if timeLineEntity.rate > 0 {
            labelColor = UIColor.red
        } else {
            labelColor = UIColor.gray
        }
        priceLabel.textColor = labelColor
        ratioLabel.textColor = labelColor
        
        priceLabel.text = timeLineEntity.price.toStringWithFormat(".2")
        ratioLabel.text = (timeLineEntity.rate * 100).toStringWithFormat(".2") + "%"
        timeLabel.text = timeLineEntity.currentTime
        volumeLabel.text = timeLineEntity.volume.toStringWithFormat(".2")
    }

}
