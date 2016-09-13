//
//  Extension.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation

import UIKit

public extension UIView {
    class func loadFromNibNamed(nibName:String,bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibName, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
    public var width:CGFloat! {
        get {
            return self.frame.width
        }
        set(newValue){
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    public var height:CGFloat! {
        get {
            return self.frame.height
        }
        set(newValue){
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    public var x:CGFloat! {
        get {
            return self.frame.origin.x
        }
        set(newValue){
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var y:CGFloat! {
        get {
            return self.frame.origin.y
        }
        set(newValue){
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
}
public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, al: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: al)
    }
    
    /**
     返回UIColor对象
     
     - parameter netHex: 16进制
     - parameter alpha:  透明度
     
     - returns: UIColor
     */
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, al: alpha)
    }
}

extension UIColor {
    public convenience init(rgba: String) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            var hexStr = (rgba as NSString).substringFromIndex(1) as NSString
            if hexStr.length == 8 {
                let alphaHexStr = hexStr.substringFromIndex(6)
                hexStr = hexStr.substringToIndex(6)
                
                var alphaHexValue: UInt32 = 0
                let alphaScanner = NSScanner(string: alphaHexStr)
                if alphaScanner.scanHexInt(&alphaHexValue) {
                    let alphaHex = Int(alphaHexValue)
                    alpha = CGFloat(alphaHex & 0x000000FF) / 255.0
                } else {
                    //SMJPrint("scan alphaHex error")
                }
            }
            
            let rgbScanner = NSScanner(string: hexStr as String)
            var hexValue: UInt32 = 0
            if rgbScanner.scanHexInt(&hexValue) {
                if hexStr.length == 6 {
                    let hex = Int(hexValue)
                    red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hex & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hex & 0x0000FF) / 255.0
                } else {
                    print("invalid rgb string, length should be 6")
                }
            } else {
                //SMJPrint("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}


extension Double{
    public func toDate() -> NSDate {
        let d:NSTimeInterval  = self/1000
        
        return NSDate(timeIntervalSince1970: d)
    }
}

extension String {
    
    //48-57num  65-90A 97-122a
    func allCharacter() -> Bool {
        if let asciiString = self.cStringUsingEncoding(NSASCIIStringEncoding){
            for v in 0 ..< asciiString.count - 1 {
                if (asciiString[v] >= 48 && asciiString[v] <= 57) || (asciiString[v] >= 65 && v <= 90) || (asciiString[v] >= 97 && asciiString[v] <= 122) {
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func allNumber() -> Bool {
        if let asciiString = self.cStringUsingEncoding(NSASCIIStringEncoding){
            for v in 0 ..< asciiString.count - 1 {
                if !(asciiString[v] >= 48 && asciiString[v] <= 57){
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func allLetter() -> Bool {
        if let asciiString = self.cStringUsingEncoding(NSASCIIStringEncoding){
            for v in 0 ..< asciiString.count - 1 {
                if !((asciiString[v] >= 65 && asciiString[v] <= 90) || (asciiString[v] >= 97 && asciiString[v] <= 122)) {
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func toInt()->Int{
        return (self as NSString).integerValue
    }
    
    func escapeSpaceTillCahractor()->String{
        return self.stringEscapeHeadTail(strs:["\r", " ", "\n"])
    }
    func escapeHeadStr(str:String)->(String, Bool){
        var result = self as NSString
        var findAtleastOne = false
        while( true ){
            let range = result.rangeOfString(str)
            if range.location == 0 && range.length == 1 {
                result = result.substringFromIndex(range.length)
                findAtleastOne = true
            }else{
                break
            }
        }
        return (result as String, findAtleastOne)
    }
    func escapeSpaceTillCahractor(strs strs:[String])->String{
        var result = self
        while( true ){
            var findAtleastOne = false
            for str in strs {
                var found:Bool = false
                (result, found) = result.escapeHeadStr(str)
                if found {
                    findAtleastOne = true
                    break  //for循环
                }
            }
            if findAtleastOne == false {
                break
            }
        }
        return result as String
    }
    func reverse()->String{
        var inReverse = ""
        for letter in self.characters {
            inReverse = "\(letter)" + inReverse
        }
        return inReverse
    }
    
    func escapeHeadTailSpace()->String{
        return self.escapeSpaceTillCahractor().reverse().escapeSpaceTillCahractor().reverse()
    }
    
    func stringEscapeHeadTail(strs strs:[String])->String{
        return self.escapeSpaceTillCahractor(strs:strs).reverse().escapeSpaceTillCahractor(strs:strs).reverse()
    }
    
    func toDate(format:String) -> NSDate? {
        let dateformatter = NSDateFormatter()
        dateformatter.timeZone=NSTimeZone.localTimeZone()
        dateformatter.dateFormat = format
        
        return dateformatter.dateFromString(self)
    }
    
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    
    func toRatioAttributedString(isChangeColor:Bool = true,isPlusShow:Bool = false,isSubShow:Bool = false) -> NSMutableAttributedString {
        let d = self.toDouble()
        
        if d > 0 {
            var s = "\(self)%"
            if isPlusShow {
                s = "+\(self)%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                //NSMakeRange(<#T##loc: Int##Int#>, <#T##len: Int##Int#>)
                
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0xff6262, alpha: 1), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(self)%"
            if isSubShow {
                s = "-\(self)%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0x1dbf60, alpha: 1), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        }
    }
    
    func toRatioAttributedString(format:String,isChangeColor:Bool = true,isPlusShow:Bool = false,isSubShow:Bool = false) -> NSMutableAttributedString {
        
        
        let d = self.toDouble()
        
        if d > 0 {
            var s = "\(d.toStringWithFormat(format))%"
            if isPlusShow {
                s = "+\(d.toStringWithFormat(format))%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0xff6262, alpha: 1), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(d.toStringWithFormat(format))%"
            if isSubShow {
                s = "-\(d.toStringWithFormat(format))%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0x1dbf60, alpha: 1), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        }
    }
    
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(pathComponent)
    }
    
}

extension NSDate {
    
    func addYear(year:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Year, value: year, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addMonth(mon:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: mon, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addDay(day:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: day, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addHour(hour:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: hour, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addMin(min:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Minute, value: min, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addSecond(second:Int) -> NSDate{
        return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Second, value: second, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func toString(format:String) -> String {
        let dateformatter = NSDateFormatter()
        dateformatter.timeZone = NSTimeZone.localTimeZone()
        dateformatter.dateFormat = format
        return dateformatter.stringFromDate(self)
    }
    
    class func toDate(dateString: String, format: String) -> NSDate {
        let dateformatter = NSDateFormatter()
        //dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.dateFormat = format
        dateformatter.locale = NSLocale(localeIdentifier: "en_US")
        let date = dateformatter.dateFromString(dateString) ?? NSDate()
        return date
    }
    
    var second:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).second
        }
    }
    
    var min:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).minute
        }
    }
    
    var hour:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).hour
        }
    }
    
    var day:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).day
        }
    }
    
    var month:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).month
        }
    }
    
    var year:Int{
        get{
            return NSCalendar.currentCalendar().components([.Day,.Month,.Year,.Hour,.Minute,.Second], fromDate: self).year
        }
    }
    
    // @Brief 判断时间是否为交易时间
    func isTradingTime() -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour,.Minute], fromDate: self)
        
        let hour = components.hour
        let minutes = components.minute
        let is1 = hour >= 9 && hour < 10 && minutes >= 15
        let is2 = hour >= 10 && hour <= 11
        let is3 = hour > 11  && hour < 11 && minutes <= 31
        let is4 = hour >= 13 && hour < 14
        let is5 = hour >= 14 && hour < 15
        let is6 = hour >= 15 && minutes <= 1
        
        
        if is1 || is2 || is3 || is4 || is5 || is6 {
            return true
        } else  {
            return false
        }
    }
    
    func isToday() ->Bool{
        let calender = NSCalendar.currentCalendar()
        let selfCmps = calender.components([.Day,.Month,.Year], fromDate: self)
        let nowCmps = calender.components([.Day,.Month,.Year], fromDate: NSDate())
        if selfCmps.year == nowCmps.year && selfCmps.month == nowCmps.month && selfCmps.day == nowCmps.day {
            return true
        }else{
            return false
        }
    }
    
    //是否交易日且开市
    //    func isRest() ->Bool{
    //        var companyDate = NSDate().isToday()
    //        var companyTime = NSDate().isTradingTime()
    //        if companyDate {
    //            if companyTime {
    //                return true
    //            }
    //        }
    //        return false
    //    }
    //是否新股
    func isNewStock(lsdt:NSDate) ->Bool{
        
        let nowTimeDifference = self.timeIntervalSince1970
        let lsdtTimeDifference = lsdt.timeIntervalSince1970
        
        let timeChange = nowTimeDifference - lsdtTimeDifference
        if timeChange/86400 <= 10{
            return true
        }else{
            return false
        }
    }
    
}

extension CGFloat{
    /// %.2f 不带科学计数
    func toStringWithFormat(format:String) -> String! {
        return NSString(format: format, self) as String
    }
    
    /// "###,##0.00"
    /// "0.00"
    /// 科学计数
    func toStringWithFormat1(format:String) -> String! {
        let nsnumberformaer = NSNumberFormatter()
        nsnumberformaer.positiveFormat = format
        nsnumberformaer.locale = NSLocale.currentLocale()
        let BB = nsnumberformaer.stringFromNumber(self)!
        
        return BB
    }
}

extension Double {
    
    /// %.2f 不带科学计数
    func toStringWithFormat(format:String) -> String! {
        return NSString(format: format, self) as String
    }
    
    /// "###,##0.00"
    /// "0.00"
    /// 科学计数
    func toStringWithFormat1(format:String) -> String! {
        let nsnumberformaer = NSNumberFormatter()
        nsnumberformaer.positiveFormat = format
        nsnumberformaer.locale = NSLocale.currentLocale()
        let BB = nsnumberformaer.stringFromNumber(self)!
        
        return BB
    }
    
    
    func toRatioAttributedString(isChangeColor:Bool = true,isPlusShow:Bool = true,isSubShow:Bool = true) -> NSMutableAttributedString {
        let d = self
        
        if d > 0 {
            var s = "\(d)%"
            if isPlusShow {
                s = "+\(d)%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0xff6262, alpha: 1), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(d)%"
            if isSubShow {
                s = "-\(d)%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0x1dbf60, alpha: 1), range: NSMakeRange(0,s.characters.count))
            }
            
            return attr
        }
    }
}

extension UIImage{
    class func imageWithColor(color:UIColor) -> UIImage
    {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage
    }
}

extension UILabel{
    func getLabelHeight() -> CGFloat{
        let constraint = CGSizeMake(self.frame.size.width, 99999)
        let context = NSStringDrawingContext()
        if let t = self.text{
            let boundingBox = (t as NSString).boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.font], context: context).size
            let size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height))
            return size.height
        }
        return 0
           }
}

extension UILabel {
    func heightWithWidth(width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.heightWithWidth(width, font: font)
    }
    
    func heightWithAttributedWidth(width: CGFloat) -> CGFloat {
        guard let attributedText = attributedText else {
            return 0
        }
        return attributedText.heightWithWidth(width)
    }
}

extension String {
    func heightWithWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.max)
        let actualSize = self.boundingRectWithSize(maxSize, options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
}

extension NSAttributedString {
    func heightWithWidth(width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.max)
        let actualSize = boundingRectWithSize(maxSize, options: [.UsesLineFragmentOrigin], context: nil)
        return actualSize.height
    }
}


extension UIFont {
    func sizeOfString(string:String,constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: 9999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self], context: nil).size
    }
}