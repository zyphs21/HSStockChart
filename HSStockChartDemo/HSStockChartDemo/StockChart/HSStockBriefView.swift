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
    
    func instanceViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func setupSubviews() {
        view = instanceViewFromNib()
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
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

}
