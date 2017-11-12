//
//  HSStockChartNameSpace.swift
//  HSStockChart
//
//  Created by Hanson on 2017/11/12.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import Foundation

public protocol NameSpaceProtocol {
    associatedtype WrapperType
    var hschart: WrapperType { get }
    static var hschart: WrapperType.Type { get }
}

public extension NameSpaceProtocol {
    var hschart: NameSpaceWrapper<Self> {
        return NameSpaceWrapper(value: self)
    }
    
    static var hschart: NameSpaceWrapper<Self>.Type {
        return NameSpaceWrapper.self
    }
}

public struct NameSpaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
