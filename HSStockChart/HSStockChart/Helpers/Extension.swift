//
//  Extension.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    /// 输出格式化的String
    ///
    /// - Parameter format: eg: ".2" 保留两位小数
    /// - Returns: Formated String
    public func hs_toStringWithFormat(_ format: String) -> String {
        return String(format: "%\(format)f", self)
    }
    
    /// 输出为百分数
    ///
    /// - Returns: 以%结尾的 百分数输出
    public func hs_toPercentFormat() -> String {
        return String(format: "%.2f", self) + "%"
    }
}

extension String {
    
    public func hs_toDate(_ format:String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.timeZone=TimeZone.autoupdatingCurrent
        dateformatter.dateFormat = format

        return dateformatter.date(from: self)
    }
}

extension Date {

    public func hs_toString(_ format:String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone.autoupdatingCurrent
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }

    public static func hs_toDate(_ dateString: String, format: String) -> Date {
        let dateformatter = DateFormatter()
        //dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.dateFormat = format
        dateformatter.locale = Locale(identifier: "en_US")
        let date = dateformatter.date(from: dateString) ?? Date()
        return date
    }
}


extension Double {
    
    /// %.2f 不带科学计数
    public func hs_toStringWithFormat(_ format:String) -> String! {
        return NSString(format: format as NSString, self) as String
    }
}
