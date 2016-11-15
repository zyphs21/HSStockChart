//
//  HSKLineBriefView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/8.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class HSKLineBriefView: UIView {
    
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var time: UILabel!
    
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
    
    func configureView(_ preClose: CGFloat, kLineEntity: KLineEntity) {
        let riseColor = UIColor.red
        let downColor = UIColor(rgba: "#1DBF60")

        if kLineEntity.rate > 0 {
            close.textColor = riseColor
            ratio.textColor = riseColor
        } else {
            close.textColor = downColor
            ratio.textColor = downColor
        }
        
        if preClose < kLineEntity.open {
            open.textColor = riseColor
        } else {
            open.textColor = downColor
        }
        
        if preClose < kLineEntity.high {
            high.textColor = riseColor
        } else {
            high.textColor = downColor
        }
        
        if preClose < kLineEntity.low {
            low.textColor = riseColor
        } else {
            low.textColor = downColor
        }
        open.text = kLineEntity.open.toStringWithFormat("%.2f")
        close.text = kLineEntity.close.toStringWithFormat("%.2f")
        high.text = kLineEntity.high.toStringWithFormat("%.2f")
        low.text = kLineEntity.low.toStringWithFormat("%.2f")
        volume.text = (kLineEntity.volume / 10000).toStringWithFormat("%.2f") + "万"
        ratio.text = kLineEntity.rate.toStringWithFormat("%.2f") + "%"
        time.text = kLineEntity.date
    }

}
