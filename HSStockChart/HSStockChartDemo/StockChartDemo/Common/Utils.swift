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
    
    class func getChartlist(fields: String, data: String) -> [String: String]? {
        let fields = Utils.string2Array(string: fields, separator: "|")
        let data   = Utils.string2Array(string: data, separator: "|")
        
        var dictionary = [String: String]()
        for (key, value) in zip(fields, data) {
            if value == "" {
                return nil
            } else {
                dictionary[key] = value
            }
        }
        return dictionary
    }
}
