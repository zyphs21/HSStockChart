//
//  Api.swift
//  HSStockChartDemo
//
//  Created by zhen on 29/04/2017.
//  Copyright © 2017 hanson. All rights reserved.
//

import Moya

enum StockChartsApi {
  case minlineForDay(code: String)
  case klineForDay(code: String)
}

// MARK: - TargetType Protocol Implementation
extension StockChartsApi: TargetType {
  var baseURL: URL { return URL(string: "http://syb.ybk1818.com")! }
  
  var path: String {
    switch self {
    case .minlineForDay(let code):
      return "/api/products/\(code)/minline"
    case .klineForDay(let code):
      return "/api/products/\(code)/kline"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .minlineForDay, .klineForDay:
      return .get
    }
  }
  
  var parameters: [String: Any]? {
    switch self {
    case .minlineForDay, .klineForDay:
      return nil
    }
  }
  
  var parameterEncoding: ParameterEncoding {
    switch self {
    case .minlineForDay, .klineForDay:
      return URLEncoding.default // Send parameters in URL    
    }
  }
  
  var sampleData: Data {
    switch self {
    default:
      return "hello world".data(using: String.Encoding.utf8)! as Data
    }
  }
  
  var task: Task {
    switch self {
    case .minlineForDay, .klineForDay:
      return .request
    }
  }
}
