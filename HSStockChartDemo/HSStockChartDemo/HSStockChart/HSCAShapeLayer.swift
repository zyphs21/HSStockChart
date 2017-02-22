//
//  HSCAShapeLayer.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/23.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSCAShapeLayer: CAShapeLayer {

    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}
