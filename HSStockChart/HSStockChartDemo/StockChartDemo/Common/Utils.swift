//
//  Utils.swift
//  HSStockChartDemo
//
//  Created by zhen on 29/04/2017.
//  Copyright © 2017 hanson. All rights reserved.
//

public class Utils {
  class func string2Array(string: String, separator: String) -> [String] {
    return string.components(separatedBy: separator)
  }
}
