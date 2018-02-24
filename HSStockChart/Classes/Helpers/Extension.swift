//
//  Extension.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import UIKit


// MARK: - UIColor Extension

extension UIColor: NameSpaceProtocol { }
extension NameSpaceWrapper where T: UIColor {
    
    public static func color(rgba: String) -> UIColor {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            var hexStr = (rgba as NSString).substring(from: 1) as NSString
            if hexStr.length == 8 {
                let alphaHexStr = hexStr.substring(from: 6)
                hexStr = hexStr.substring(to: 6) as NSString
                var alphaHexValue: UInt32 = 0
                let alphaScanner = Scanner(string: alphaHexStr)
                if alphaScanner.scanHexInt32(&alphaHexValue) {
                    let alphaHex = Int(alphaHexValue)
                    alpha = CGFloat(alphaHex & 0x000000FF) / 255.0
                } else {
                    print("scan alphaHex error")
                }
            }
            
            let rgbScanner = Scanner(string: hexStr as String)
            var hexValue: UInt32 = 0
            if rgbScanner.scanHexInt32(&hexValue) {
                if hexStr.length == 6 {
                    let hex = Int(hexValue)
                    red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hex & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hex & 0x0000FF) / 255.0
                } else {
                    print("invalid rgb string, length should be 6")
                }
            } else {
                print("scan hex error")
            }
            
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        
        return UIColor(red:red, green:green, blue:blue, alpha:alpha)
    }
}


// MARK: - CGFloat Extension

extension CGFloat: NameSpaceProtocol { }
extension NameSpaceWrapper where T == CGFloat {
    
    /// 输出格式化的String
    ///
    /// - Parameter format: eg: ".2" 保留两位小数
    /// - Returns: Formated String
    public func toStringWithFormat(_ format: String) -> String {
        return String(format: "%\(format)f", wrappedValue)
    }
    
    /// 输出为百分数
    ///
    /// - Returns: 以%结尾的 百分数输出
    public func toPercentFormat() -> String {
        return String(format: "%.2f", wrappedValue) + "%"
    }
}


// MARK: - String Extension

extension String: NameSpaceProtocol { }
extension NameSpaceWrapper where T == String {
    
    public func toDate(_ format: String) -> Date? {
        let dateformatter = DateFormatter.hschart.cached(withFormat: format)
        dateformatter.timeZone = TimeZone.autoupdatingCurrent
        
        return dateformatter.date(from: wrappedValue)
    }
}


// MARK: - DateFormatter Extension

private var cachedFormatters = [String: DateFormatter]()
extension DateFormatter: NameSpaceProtocol {}
extension NameSpaceWrapper where T: DateFormatter {
    
    public static func cached(withFormat format: String) -> DateFormatter {
        if let cachedFormatter = cachedFormatters[format] { return cachedFormatter }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        cachedFormatters[format] = formatter
        
        return formatter
    }
}


// MARK: - Date Extension

extension Date: NameSpaceProtocol { }
extension NameSpaceWrapper where T == Date {
    
    public func toString(_ format: String) -> String {
        let dateformatter = DateFormatter.hschart.cached(withFormat: format)
        dateformatter.timeZone = TimeZone.autoupdatingCurrent

        return dateformatter.string(from: wrappedValue)
    }
    
    public static func toDate(_ dateString: String, format: String) -> Date {
        let dateformatter = DateFormatter.hschart.cached(withFormat: format)
        dateformatter.locale = Locale(identifier: "en_US")
        let date = dateformatter.date(from: dateString) ?? Date()
        
        return date
    }
}


// MARK: - Double Extension

extension Double: NameSpaceProtocol { }
extension NameSpaceWrapper where T == Double {
    
    /// %.2f 不带科学计数
    public func toStringWithFormat(_ format:String) -> String! {
        return NSString(format: format as NSString, wrappedValue) as String
    }
}

